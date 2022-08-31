/* T2 Conversion Script */
/* Started 9/2/2021     */
/* requested tables from T2:
Appeal  (I don’t think these were part of your conversion but if they are simple like others I have done I might be able to just slide these in so please send them so I can check)
Appeal_Code
Citation_Activity
Citation_Main - OK
Citation_Status
Color
Decal Type
Link_Permit_Main_Person_Main
Link_Permit_Main_Vehicle_Main
Link_Person_Main_Vehicle_Main
Notes
Officer
Overpay
Permit_Activity
Permit_Mian -ok
Permit_Status
Person_Activity
Person_Address
Person_Main
Person_Status
Transact
Vehicle_Main - OK
Vehicle_Make
Vehicle_Model
*/
--Appeal (see below vehicles)

--Appeal_Code - all good as-is
select * from Appeal_Code

--citation_Main
--get citations starting with FY20
select * 
into #T2Citation
from citation_main
where issue_date >= '2019-07-01'

select * from #T2Citation

--Citation_Activity
select * from citation_activity
where citation_key in (select citation_key from #T2citation)

--Citation_Status
select * from citation_status
where citation_key in (select citation_key from #T2citation)

--Color - OK as is
select * from color

--Decal Type -- possibly OK as is, but for final, filter down by date
select * from decal_type

--Permit_Main
-- get permits starting with FY20 (8/1/2019)
select *
into #T2Permits
from permit_main 
where active_date >= '2019-07-01' order by entry_Date desc 

select * from #T2Permits

--Permit_Activity
select * from Permit_activity
where permit_key in (select permit_key from #T2Permits)

--Permit_Status
select * from Permit_status
where permit_key in (select permit_key from #T2Permits)

--Link_Permit_Main_Person_Main
select *
into #T2_Link_Permit_Main_Person_Main
from link_permit_main_person_Main
where permit_key in (select permit_key from #T2Permits)

select * from #T2_Link_permit_main_person_main


--Link_Permit_Main_Vehicle_Main
select  * 
into #T2_Link_Permit_Main_Vehicle_Main
from Link_Permit_Main_Vehicle_Main
where permit_key in (select permit_key from #T2Permits)

select * from #T2_Link_Permit_Main_Vehicle_Main

--Vehicle_Main
-- get vehicles tied to citations and permits
select distinct v.* 
into #T2vehicles
from 
(select * from vehicle_main 
where vehicle_key in (select vehicle_key from #T2Citation)
union
select vm.* 
from vehicle_main vm 
join #T2_link_permit_main_vehicle_main vl on vl.vehicle_key = vm.vehicle_key
union
select distinct vm.* -- this query is going to pick up vehicles linked to mulitple people.  the links table will be narrowed later.
from vehicle_main vm
join link_person_main_vehicle_main pv on pv.vehicle_key = vm.vehicle_key
join #T2_link_permit_main_person_main pp on pp.person_key = pv.person_key
) as v

select * from #T2vehicles

--Vehicle_Make - OK
select * from Vehicle_Make

--Vehicle_Model -- ok, no rows
select * from Vehicle_Model


--Notes -- not sure how to filter - go by entry date > 7/1/2019?
select * from notes
where entry_date >= '7/1/2019'

--Officer - ok as is
select * 
into #Officer
from officer

update #officer set password = '<removed>'
select * from #officer


--Overpay -- first pass, filter by entry date > 7/1/2019.  May need to filter further based on person, transact, vehicle or permit keys
select * from overpay
where entry_date >= '7/1/2019'


--Person_Main
select * 
into #T2Person
from Person_main
where person_key in (select person_key from #T2_Link_Permit_Main_Person_Main)
or person_key in (select isNull(person_key, 0) from #T2Citation)
or person_key in (select person_key from person_status where entry_date >= '2019/07/01') -- this is mostly the upass requests
-- maybe include overpay and transact

-- scrub SSN, covert a few other things
select isNull(sid, '') as WUSTL_WUSTLEDUID,
case isNull(l.emplid, '') 
	when '' then case tt_person_type when 'E' then local_id else '' end
	else l.emplid end as WUSTL_EMPLID,
case isNull(l.sisid, '') 
	when '' then case tt_person_type when 'S' then local_id else '' end  
	when '0' then '' 
	else l.sisid end as WUSTL_SISID,
[Person_Key]
      ,[Last_Name]
      ,[First_Name]
      ,[Middle_Name]
      ,[Suffix_Name]
      ,[DOB]
      ,'' as [SSN]
      ,[Local_ID]
      ,[CID]
      ,[SID]
      ,[FBI]
      ,[Email_Address1]
      ,[Email_Address2]
      ,[Email_Address3]
      ,[Driver_License_Number]
      ,[Driver_License_State]
      ,[Driver_License_Type]
      ,[Driver_License_Expire]
      ,[Race]
      ,[Sex]
      ,[Ethnicity]
      ,[Build]
      ,[Height_Ft]
      ,[Height_In]
      ,[Weight]
      ,[Hair_Color]
      ,[Facial_Hair]
      ,[Eye_Color]
      ,[Skin_Tone]
      ,[Tatoo_Location]
      ,[Tatoo_Description]
      ,[Business_Phone]
      ,[Business_Ext]
      ,[Mobile_Phone]
      ,[Mobile_Ext]
      ,[Min_Age]
      ,[Max_Age]
      ,[Agency_Code]
      ,[Amount_Due]
      ,[User_Defined1]
      ,[User_Defined2]
      ,[User_Defined3]
      ,[User_Defined4]
      ,[User_Defined5]
      ,[Entry_By]
      ,[Entry_Date]
      ,[Product_Source]
      ,[Caution]
      ,[Finger_Print_Code]
      ,[Pager]
      ,tt_person_type as [Person_Type]
      ,[Billing_Flag]
      ,[Full_Name]
      ,[RPerson_Key]
      ,[Alias]
      ,[New_Changed_Flag]
      ,[Export]
      ,[Driver_License_Endorsement]
      ,[Driver_License_Restriction]
      ,[SKey]
      ,[CDL]
      ,[Restricted]
      ,[SexOff]
      ,[License_Type]
      ,[Entry_Time]
      ,[Account_ID]
      ,[Credit_Amt]
      ,[RoleType]
      ,[SourceID]
into #T2PersonWithIDs
from #T2Person t
left outer join id_lookup l on l.wupid = isNull(t.sid, '')

select * from #T2PersonWithIDs

---- auditing chunk - not needed for pull
select WUSTL_WUSTLEDUID, WUSTL_EMPLID, WUSTL_SISID, person_key, last_Name, first_name, person_type, local_id
into T2PersonKeys
from #T2PersonWithIDs
where WUSTL_WUSTLEDUID = ''
order by person_key desc

-- already went through A, B, Z, Y, X and Q last names on T2PersonKeys

update person_main set sid = k.WUSTL_WUSTLEDUID
from person_main pm join T2PersonKeys k on pm.person_key = k.person_key
where k.WUSTL_WUSTLEDUID <> ''


select pm.* from person_main pm
where last_name = 'Adams' and first_name like 'Freder%'



select sid, count(*) 
from #T2Person
where isNull(sid, '') <> ''
group by sid
having count(*) > 1
--only 172 records!  not terrible!

select full_name, sid, local_id, tt_person_type, * from #T2Person where full_name in 
(select full_name
from #T2Person
group by full_name
having count(full_name) > 1)
and full_name in (select full_name from #T2Person where isNull(sid, '') = '')
order by 1

select * from id_lookup
----- end audit chunk

/*
create table #T2PersonActivity (person_key int, hasCitation int, hasPermit int, hasUPass int)
insert into #T2PersonActivity (person_key, hasCitation, hasPermit, hasUPass) 
	select person_key, 0, 0, 0 from #T2Person

update #T2PersonActivity set hasCitation = c.citCount
from #T2PersonActivity a join
(select isNull(person_key, 0) as person_key, count(*) as citCount from #T2Citation group by person_key) as c
on a.person_key = c.person_key

update #T2PersonActivity set hasPermit = p.linkCount
from #T2PersonActivity a join
(select isNull(person_key, 0) as person_key, count(*) as linkCount from #T2_Link_Permit_Main_Person_Main group by person_key) as p
on a.person_key = p.person_key

update #T2PersonActivity set hasUPass = u.passCount
from #T2PersonActivity a join
(select isNull(person_key, 0) as person_key, count(*) as passCount from Person_status group by person_key) as U
on a.person_key = u.person_key

select a.hasCitation, a.hasPermit, a.hasUpass, p.* from #T2Person p
join #T2PersonActivity a on p.person_key = a.person_key
order by p.sid

-- audit for zero
select * from #T2PersonActivity 
where hasCitation = 0
and hasPermit = 0
and hasUpass = 0

select * from #T2PersonActivity where person_key = 110961


select a.*, p.* 
from #T2PersonActivity a
join #T2Person p on a.person_key = p.person_key
where isNull(sid, '') = ''

select l.wupid, l.sisid, l.emplid, p.*
update person_main set sid = l.wupid
from person_main p
join id_lookup l on rtrim(l.sisid) = p.local_id
where p.tt_person_type = 'S'
and isNull(sid, '')  = ''
and l.sisid <> '0'


select l.wupid, l.sisid, l.emplid, p.*
--update person_main set sid = l.wupid
from person_main p 
join id_lookup l on rtrim(l.emplid) = p.local_id
where p.tt_person_type = 'E'
and isNull(sid, '')  = ''
*/

--Link_Person_Main_Vehicle_Main
-- vehicles have been narrowed, so only grab links to converted vehicles
-- also narrow to target converted people (not 100% foolproof yet)
select distinct l.* 
into #T2_Link_person_main_vehicle_main
from Link_person_main_vehicle_main l
join #T2Vehicles v on v.vehicle_key = l.vehicle_key
where person_key in (select person_key from #T2Person) -- circular - don't know how to narrow without losing vehicles with citation history

select * from #T2_Link_person_main_vehicle_main

--Appeal  (I don’t think these were part of your conversion but if they are simple like others I have done I might be able to just slide these in so please send them so I can check)
--need to filter by person/vehicle
select * from appeal
where vehicle_key in (select vehicle_key from #T2Vehicles)
 or person_key in (select person_key from #T2_Link_Person_Main_Vehicle_Main)
 or person_key in (select person_key from #T2_Link_Permit_Main_Person_Main)

--Person_Activity
select * from Person_Activity
where person_key in (select person_key from #T2Person)
and entry_date >= '7/1/2019'

--Person_Address
select * from Person_Address
where person_key in (select person_key from #T2Person)

--Person_Status
select * from Person_Status
where person_key in (select person_key from #T2Person)
and entry_date >= '2019-07-01' -- ?Do we want to limit activity?  Or all history if the person is being brought over?

--Transact
select * from Transact
where entry_date >='7/1/2019'
-- note:  may need adjusting, but keeping it simple for first pass.

select * from images
where entry_date >= '7/1/2019'

select * from images
where entry_date >= '11/4/2021'
order by image_key


select * from images where FileName = 'Img91006231-01.jpg'



---------------
-- start merge logic for second pass
select * from #T2Person
order by sid





--note: t2 says to send wupid as a totally separate field
- they have cus_Primary_id  account_id  .
-- merge on my end.  send wusTL_WUPID and wustl_SISID and wUSTL_EMLID
select * from person_main 
where sid is null
and tt_person_type = 'E'
and local_id is not null
-- 9/2:  9524

select * from person_main 
where sid is null
and tt_person_type = 'S'
and local_id is not null
-- 9/2:  <didn't capture>

--update wupeople ids from web logins.
select distinct s.wupid, s.emplid, s.sisid, s.personType, s.fullName, p.full_name
from tt_ShibLog s 
join person_main p on p.local_id = s.emplid
where p.tt_person_type = 'E'
and p.sid is null -- 9/2: 4808

update person_main set sid = s.wupid
from person_main p join tt_shibLog s 
	on p.local_id = s.emplid
	where p.tt_person_type = 'E'
	and p.sid is null -- 9/2: updated 3608

select distinct s.wupid, s.emplid, s.sisid, s.personType, s.fullName, p.full_name, p.local_id, p.tt_person_type
from tt_ShibLog s 
join person_main p on p.local_id = s.sisid
where p.tt_person_type = 'S'
and p.sid is null -- 9/2: 45991
order by wupid

update person_main set sid = s.wupid
from person_main p join tt_shibLog s 
	on p.local_id = s.sisid
	where p.tt_person_type = 'S'
	and p.sid is null -- 9/2: updated 28148


select distinct emplid, wupeopleid, firstName, lastName
into #temp1
from WD_INT037_Workers_DeltaArchive 
where WUPeopleId not in (select IsNull(sid, '') from person_main)

select p.person_key, p.last_name, p.first_name, p.local_id, p.sid, t.*
from person_main p join #temp1 t on p.local_id = t.emplid
where p.tt_person_type = 'E'

-- update outdated wupeople ids.
update person_main set sid = t.wupeopleid
from person_main p join #temp1 t on p.local_id = t.emplid
where p.tt_person_type = 'E'
and p.sid <> t.wupeopleid

-- question:  Do we want to convert people without sids (wupeople id values)?  
-- do we want to go far enough back in history that we pull in folks without known wustl keys?

-- start the check for dups
select sid, count(*) from person_main
where isNull(sid, '') <> ''
group by sid
having count(sid) > 1
order by 2 desc

select * from person_main where sid = '1353571171' -- no permits
--185555, 6, 7, 8

select * from link_permit_main_person_main where person_key in (185555, 185556, 185557, 185558) --0
select * from link_person_main_vehicle_main where person_key in (185555, 185556, 185557, 185558) --0
select * from person_status where person_key in  (185555, 185556, 185557, 185558) -- all upasses linked to 185558
select * from citation_activity -- how to link person to citation?  person to vehicle to citation?

-- build analysis table for person_key, and log number of linked vehicles, linked tags, citations, upasses, and addresses




