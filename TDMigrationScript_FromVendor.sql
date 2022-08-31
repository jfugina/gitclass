/*Overview: 
1.	Run query to create MigrationUsers (creates 1st table)
2.	Run query to create MigrationNotes (creates 2nd table)
3.	Run query to create MigrationTasks (creates 3rd table)
4.	Check that no ISSM note or task is more than 4000 characters
5.	Run query to create SEVISDocuments (creates 4th table)
6.	Script data in these four temp tables to .sql files
7.	Compress these four .sql files into a .zip folder (1st .zip folder)
8.	Compress PDFs related to SEVISDocuments into a .zip folder (2nd .zip folder)
9.	Run query to create UserDocuments (creates 5th table)
10.	Follow process to create bcp and xml of UserDocuments
11.	Compress bcp and xml for UserDocuments into a .zip folder (3rd .zip folder)
12.	Transfer the 3 resulting .zip folders to your Terra Dotta provided SSH folder using SFTP or SCP
*/
--MigrationUsers: 

SELECT     tblDataMain.pk_sysid, tblDataMain.stud_id, tblDataMain.SEVISId, tblDataMain.fname, 
	tblDataMain.mname, tblDataMain.lname, tblDataMain.NameSuffix, tblDataMain.dob, tblDataMain.gender, 	
	tblDataProfile.enddate, tblDataProfile.profilestatus, tblDataProfile.profiletype, tblDataProfile.profilesubtype, 
        tblDataAddresses.EMail, tblDataAddresses.AddressType
INTO MigrationUsers
FROM         tblDataMain INNER JOIN
                      tblDataProfile ON tblDataMain.pk_sysid = tblDataProfile.fk_sysid LEFT OUTER JOIN
                      tblDataAddresses ON tblDataMain.pk_sysid = tblDataAddresses.fk_sysId
WHERE     (tblDataProfile.CurrentProfile = '1') AND (tblDataAddresses.AddressType = N'Local')


--MigrationNotes:

SELECT  dbo.tblDataNotes.pk_noteid, dbo.tblDataNotes.fk_sysid AS fsaAtlas_Id, dbo.tblDataNotes.notedate, CONCAT(dbo.tblPasswd.FName, ' ', 
	dbo.tblPasswd.LName) As Commentor, CONCAT(dbo.tblDataNotes.notecategory,' - ', dbo.tblDataNotes.notetext) as Comment  
INTO MigrationNotes                    
FROM         dbo.tblDataNotes LEFT OUTER JOIN
                      dbo.tblPasswd ON dbo.tblDataNotes.fk_advisorID = dbo.tblPasswd.user_id
WHERE     (dbo.tblDataNotes.DeleteFlag = 0)


--MigrationTasks:

SELECT     dbo.tblDataClientIntake.pk_jobID, dbo.tblDataClientIntake.fk_sysId AS fsaAtlas_Id, dbo.tblDataClientIntake.DateIntake 
	as notedate, CONCAT(dbo.tblPasswd.FName, ' ', dbo.tblPasswd.LName) As Commentor, 
	CONCAT(dbo.tblDataClientIntake.Source, ' - ',dbo.tblDataClientIntake.JobType,' - ', dbo.tblDataClientIntake.IntakeNote,
	' - ', dbo.tblDataClientIntake.ClientInstructions) as Comment
INTO MigrationTasks
FROM         dbo.tblDataClientIntake LEFT OUTER JOIN
             dbo.tblPasswd ON dbo.tblDataClientIntake.fk_AdvisorID = dbo.tblPasswd.user_id
WHERE     (dbo.tblDataClientIntake.DeleteFlag = 0)

/*
** Please note that TDS has a 4000 character limit for migrated notes & tasks.  To check if any of your comments exceed this limit, use the following script: 

○	Select TOP 1000 * from [your database name].[MigrationNotes] order by len(Comment)
○	Select TOP 1000 *  from [your database name].[MigrationTasks] order by len(Comment)

Edit any notes that are over 4000 characters.
*/
--SEVISDocuments:

SELECT     tblDataDocuments.pk_DataDocumentID, tblSeventCommon.fk_sysId, tblDataDocuments.path, tblSeventCommon.CreateTimestamp, 
                      tblSeventCommon.ReturnTimestamp, tblSeventCommon.VisaType, tblSeventNames.RecordEvent
INTO SEVISDocuments
FROM         tblDataDocuments INNER JOIN
                      tblSeventCommon ON tblDataDocuments.fk_SeventCommonId = tblSeventCommon.pk_SeventCommonId INNER JOIN
                      tblSeventNames ON tblSeventCommon.fk_SeventId = tblSeventNames.pk_SeventId

--Scripting data in the temp tables to files:
/*
●	Right click on the fsaAtlas DB 
●	Select "Tasks => Generate Scripts...". 
●	Follow the wizard, and choose the objects that you want to generate scripts for (Choose the four tables created above (named MigrationUsers, MigrationNotes, MigrationTasks, and SEVISDocuments). 
●	From the next step, click on "Advanced", and for the node that is labeled "Types of data to script" choose "Schema and data", so that field headers and data type are also included with the data. 
●	Save the files and note the file location
●	Compress the files into a .zip folder titled UsersNotesTasksDocs.zip
●	If you wish, the temporary tables you just created can be deleted. 
*/

--Zip up the SEVIS Documents PDFs
--**IMPORTANT** 
--The documents found at the path in the above SEVISDocuments (sevis batch) query should be zipped up into a file as well (example E:\fsaATLAS\InstitutionName\SevisTransfer\Download\).  The .zip folder should be titled SEVISDocPDFs.zip


--UserDocuments:

SELECT     tblContext.fk_SysId, Concat (tblPasswd.FName,' ', tblPasswd.LName) as UpdatedBy , tblDocuments.DocumentName, tblDocuments.Keyword, 
	tblDocuments.FileName, tblDocuments.FileData, tblDocuments.DateCreated, tblDocuments.DocumentId
INTO UserDocuments
FROM         tblContext INNER JOIN
                      tblContextDocuments ON tblContext.ContextId = tblContextDocuments.fk_ContextId INNER JOIN
                      tblDocuments ON tblContextDocuments.fk_DocumentId = tblDocuments.DocumentId INNER JOIN
                      tblPasswd ON tblDocuments.LastUpdatedBy = tblPasswd.user_id


--UserDocuments BCP File Generation
/*
Prerequisites 
●	Enough space for the bcp generation file
●	Information of Database Server and user credentials 


BCP instructions
●	Open a cmd console in the fsaATLAS database server (if possible) or in a machine which has access to it
●	Go to the path where the bcp export file will be created. Enough free space is required.
●	(*) Generate the format of bcp file using this command: 

bcp fsaATLAS.dbo.UserDocuments format nul -n -x -f UserDocuments.xml -T -S servername -U user1 -P password1 

●	(* Replace the servername, user1 and password1 with the correct values. Use the user’s credentials that have access to the fsaATLAS database.)
●	(*) Generate the bcp export file using this command: 

bcp fsaATLAS.dbo.UserDocuments out UserDocuments.bcp -T -n -S servername -U user1 -P password1 

●	Take the two resulting files, UserDocuments.xml and UserDocuments.bcp, and zip them up in a .zip folder named UserDocuments.zip
*/
/*********Screen shot from word doc deleted ********************/
--Transfer zip files to Terra Dotta
/*
You should now have three separate zip folders, UsersNotesTasksDocs.zip, SEVISDocPDFs.zip, and UserDocuments.zip.  

It is likely that even when compressed, these files will be VERY large.  Therefore, please send us the zip files one at a time, starting with UsersNotesTasksDocs.zip.  Please notify us via email when the first file has been sent.  Then, allow us time to process the data in the first zip file before sending the next one.  We will prompt you for the following files when we are ready.  The second file transferred should be SEVISDocPDFs.zip, and finally UserDocuments.zip.

Our SFTP server information:

hostname: sftp-us.terradotta.com
port: 22
username: [same as the username normally used by your institution -- it will communicated via the migration email thread if you are uncertain]
authentication is managed by key pairs instead of passwords

See this article for more information on SFTP transfer: 
https://terradotta.zendesk.com/hc/en-us/articles/360042736274-Transferring-Data-to-Terra-Dotta
*/