select * from tdt_missingF
select * from tdt_opt where sisid is null or sevisid is null



update tdt_opt set sisid = f.sisid
from tdt_opt o join tdt_fsaatlas f on f.sevisId = o.sevisId
where o.sisid is null
update tdt_opt set Active = 'Y', OPTType = 'GRACE PD' where SevisID is null




select * from tdt_fsaAtlas where sevisid = 'N0031962004'
select * from tdt_terradotta_student_integration where sisid = '473217'
union

select * from tdt_terradotta_student_integration where uuuid = '1353609344'
union
select * from tdt_fsaAtlas where sevisid = 'N0029546493'



update tdt_missingJ set UUUID = f.SISID
from tdt_MissingJ m join tdt_fsaAtlas f on m.[SEVIS ID] = f.sevisId

select * from tdt_fsaAtlas where sisid in (select uuuid from tdt_missingF)

-- get the MP temp table from the proc, if needed
select mp.mp_id_id_no,  mp.mp_status, mp.mp_prime_joint_div, mp.mp_term_sem, mp.mp_program_code, mp.mp_maint_dt, f.*
--into #programs
from tdt_missingF f
join #p2 mp on mp.mp_id_id_no = f.uuuid
where mp_prime_joint_div = 'P'
order by mp_status, mp_term_sem, f.uuuid, mp.mp_maint_dt

--below is the standalone query to show last semester enrolled info
select n1.ns_id_id_no, n1.ns_semester, ns_prog, ns_name, ns_birthdate, ns_cip2000_code, ns_enr_st, ns_status_dt, ns_anticipated_grad, ns_term_end, ns_maint_dt,
mp.mp_status, mp.mp_term_sem, mp.mp_program_code, o.*
--into lastEnrollmentJ
from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc n1
join 
	(select ns_id_id_no, max(ns_semester) as ns_semester
	from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc n
	where ns_id_id_no in (select uuuid from tdt_missingF)
	group by ns_id_id_no) as l on l.ns_id_id_no = n1.ns_id_id_no and l.ns_semester = n1.ns_semester
left outer join [sisdb.wustl.edu].Student_info.dbo.at_major_program mp on mp.mp_id_id_no = n1.ns_id_id_no and mp.mp_prime_joint_div = 'P' and mp.mp_program_code = n1.ns_prog
left outer join tdt_opt o on o.sisid = n1.ns_id_id_no
order by isNull(o.active, 'X') desc, o.OPTStatus, n1.ns_semester, n1.ns_id_id_no

select * from [sisdb.wustl.edu].Student_info.dbo.at_major_program where mp_id_id_no = '489729'

select * from lastEnrollment where ns_id_id_no in 
(select ns_id_id_no from lastEnrollment
group by ns_id_id_no having count(ns_id_id_no) > 1)

drop table #lastEnrollment
select *from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc

select j.*, l.* 
from tdt_missingJ j 
left outer join lastEnrollment l on j.uuuid = l.ns_id_id_no

select f.uuuid as sisid, f.[sevis id], f.[date of birth], e.user_dob, f.[surname / primary name], e.user_last_name, f.[email address],  e.user_email, f.status
from tdv_terradotta_student_extract e
join tdt_missingF f on f.uuuid = e.custom18

select * from tdv_terradotta_student_extract

select * from tdt_missingF 

select p.* 
into #p2
from  #programs p
join 
(select mp_id_id_no, max(mp_maint_dt) as lastUpdate from #programs group by mp_id_id_no) as l
on l.mp_id_id_no = p.mp_id_id_no and l.lastUpdate = p.mp_maint_dt

select * from [sisdb.wustl.edu].Student_info.dbo.at_demographics where dm_id_id_no = '420345'
select * from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc where ns_id_id_no = '420345' order by ns_semester

select * from tdv_terradotta_student_extract where uuuid in
(select uuuid from tdt_terradotta_student_integration
group by uuuid having count(uuuid) > 1)