/*adding a comment for GIT diff  and more commentary after git add*/
Declare @JSON varchar(max)
SELECT @JSON=BulkColumn
FROM OPENROWSET (BULK 'C:\Users\jfugina\Documents\StudentResponse.json', SINGLE_CLOB) import
If (ISJSON(@JSON)=1)
Print 'It is a valid JSON'
ELSE
Print 'Error in JSON format'

--create table MuleJson (rowkey int identity, deltaDate smalldatetime, rootValue varchar(100), content varchar(max), contenttype smallint, createDate smalldatetime)

--truncate table MuleJson
Declare @JSON varchar(max)
SELECT @JSON=BulkColumn
FROM OPENROWSET (BULK 'C:\Users\jfugina\Documents\StudentResponse.json', SINGLE_CLOB) import
insert into MuleJson (deltaDate, rootValue, content, contentType)
select '9/23/2021', *
FROM OPENJSON (@JSON)

select * from MuleJson

insert into WorkerDeltaMule (deltaDate, worker_id, universal_id, NamePrefix, FirstName, lastName, Suffix, ReportingName, Contact,
	EmploymentProfile, EmploymentStatus, isActiveStudent, Campus, CostCenterHierarchyRollup, LocationHierarchy, OrigHireDate, TerminationDate,
	workerType, workerPrimaryPositionType, CampusMailStop, HireDate, RetireeIndicator, Biographic)

select m.deltaDate, student_id, universal_id, NamePrefix, FirstName, LastName, Suffix, Contact, 
AcademicUnit, AcademicEntity, PrimeDivCode, PrimeDivName, StudentTypeCode, StudentTypeName, EnrollmentStatus, EmailAddr, AcademicLevel
into StudentMule 
from MuleJson m
--where deltaDate > '6/15/20'
cross apply OPENJSON(m.content)
with ( --case sensitive!
	Student_id char(10),
	Universal_id bigint,
	NamePrefix varchar(5) '$.Name.Prefix',
	FirstName varchar(100) '$.Name.FirstName',
	LastName varchar(100) '$.Name.LastName',
	Suffix varchar(10) '$.Name.Suffix',
	Contact nvarchar(max) as JSON,
	AcademicUnit varchar(100),
	AcademicEntity char(100), 
	PrimeDivCode varchar(20) ,
	PrimeDivName varchar(200),
	StudentTypeCode varchar(100),
	StudentTypeName varchar(100), 
	EnrollmentStatus varchar(100),
	EmailAddr varchar(100),
	AcademicLevel varchar(4) 
) as s

select *
from studentMule
where AcademicUnit like 'Med%'

select * from studentMule
where PrimeDivCode = 'UC'

group by suffix



select w.Worker_id, w.ReportingName, w.EmploymentStatus, w.isActiveStudent, w.campus, 
--w.OrigHireDate, w.HireDate, 
p.JobEffectiveDate, 
--w.TerminationDate, 
p.JobEndDate, p.TerminationReason, 
w.WorkerType, w.WorkerPrimaryPositionType, w.RetireeIndicator, 
p.EmployeeType, p.TimeType, p.JobFTE, p.WorkPeriodPercentOfYear, p.PayGroup, p.PayType
--into #PrimaryPosition or #flatWorker
from WorkerDeltaMule w
cross apply OPENJSON(w.EmploymentProfile, '$.EmploymentPosition')
	WITH (PrimaryJobIndicator int,
			EmployeeType varchar(10),
			JobTitle varchar(100),
			TimeType varchar(20),
			JobFTE varchar(10),
			WorkPeriodPercentOfYear varchar(10),
			PayGroup varchar(10),
			PayType varchar(10),
			JobEffectiveDate smalldatetime,
			JobEndDate smalldatetime,
			TerminationReason varchar(200),
			BuildingNumber varchar(10),
			Organization nvarchar(max) as JSON

	)
	as p
where p.PrimaryJobIndicator = 1

select distinct suffix from WorkerDeltaMule where suffix is not null
