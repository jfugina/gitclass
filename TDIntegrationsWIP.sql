Integrations.dbo.tds_student_data_load

select * from Integrations.dbo.tdv_terradotta_student_extract

--4011 from dm and mp with open prime
4033 when adding email
4011 when email<>''
4020 with 2nd major -- corrected w/max(cip)
4051 with minor -- corrected w/max(cip)
4051 with local addresses (no dupes)
4051 with class_nsc (no dupes)
4052 with 4yr advisors (1 dup)
4135 when adding faculty advisor records - some with multiple 4yr advisor types
4135 (no change) when adding holds and academic actions, milestones, and LOA
4101 - tweaks to holds, milestones, LOA

select * from Student_info.dbo.hsv_current_room_assignments
where studentId in (select sisid from tdt_terradotta_student_integration)

select * from tdt_terradotta_student_integration 
where uuuid in
(
select uuuid--, count(*)
from Integrations.dbo.tdt_terradotta_student_integration
group by uuuid
having count(*) > 1
)
order by uuuid

select * from 
(select o.universalId, o.OrganizationName from Integrations.dbo.PersonOrganization o join PersonEmploymentPosition p on p.positionId = o.positionId  and p.universalId = o.universalId
and p.PrimaryJobIndicator = 1 and o.organizationType = 'Supervisory') as org
where org.universalId = 1353581141 

select * from PersonEmploymentPosition 
where universalId = 1353581141 and primaryJobIndicator = 1

select * from PersonOrganization where positionId = P100024259


select * from Integrations.dbo.tdv_terradotta_student_extract order by custom10 desc

select * from Integrations.dbo.personVisa
where universalId in (select universalId from Integrations.dbo.tdv_terradotta_student_extract)


select t.name, c.name from sysobjects t join syscolumns c on t.id = c.id
where t.type = 'U'
and c.name like '%GPA%'

select * from at_gpa where gp_semester in (select sm_semester from at_semester where sm_status = 'C')




select visa_type_cd, '     ' as sevis_value, count(*) as numfound 
into Integrations.dbo.tdt_visacode_translation 
select * from Integrations.dbo.tdt_terradotta_student_integration
group by visa_type_cd


select * from Integrations.dbo.tdt_countrycode_translation
KS fips KR ISO

select * from at_address where ad_type = 'L' and ad_line1 like 'MSC%' - only 12 records total ever - not valid
select ct_code1 as ceeb, ct_code2 as iso, ct_value as name
into #cc
from dd_code_table where ct_type = 'CC'

select c.ceeb, c.iso, t.fips, c.name as ceebName, t.name as fipsName
into #cc2
from #cc c left outer join Integrations.dbo.countrycodes t on t.iso = c.iso

select * from at_advisors



insert into Integrations.dbo.tdt_countrycode_translation
select * from #cc2

select t.name, c.name from sysobjects t join syscolumns c on t.id = c.id
where t.type = 'V'
and c.name like '%nat%l%'
and t.name like 'at%'

select * from at_ssn where isNull(no_ssn_or_itin, '') <> '' and ss_outdated <> 'X'

select ss_ssn, ss_id_id_no, case when isNull(no_ssn_or_itin, '') = 1 then 'No SSN or ITIN' when isNull(itin, '') = 1 then 'ITIN' else '' end
from at_ssn
where ss_outdated = ''


select * from at_academic_action 
where aa_action_id = '8224'
order by aa_semester


select * from at_class_nsc








drop table #VisaTemp
select v.employeeId, v.universalId, v.visaNumber, v.visaType, v.visaIssueDate, v.visaExpiryDate, v.visaVerificationDate
into #VisaTemp 
from PersonVisa v join 
(select universalId, max(visaIssueDate) as maxDate from PersonVisa group by universalId) as a
on a.universalId = v.universalId and v.visaIssueDate = a.maxDate

select universalId, count(*) from #VisaTemp group by universalId having count(*) > 1
select * from #visaTemp where universalid = 1353670641

select * from Integrations.dbo.PersonVisa where universalId in 
(select uuuid from Integrations.dbo.tdt_terradotta_student_integration)
order by employeeId

select * from Integrations.dbo.PersonOrganization where OrganizationType = 'Supervisory'
order by employeeId




select * from Integrations.dbo.tdt_terradotta_student_integration where sisid = 503826
select * from at_demographics where dm_id_id_no = 503826

select * from at_academic_action where aa_id_id_no = '430670'


select fa.av_id_id_no_stdt, fa.av_id_id_no_adv, fanm.id_last + ', ' + fanm.id_first
from 
(select 'FAC' av_id_id_no_stdt, max(av_seq_no)
	  from Student_info.dbo.at_advisors fa with (nolock) 
	  where getdate() between av_effect_start_dt and av_effect_end_dt
	  and av_type = 'FAC'
	  group by av_id_id_no_stdt) as fa join at_entity fanm on fanm.id_id_no = fa.

select av_id_id_no_stdt, av_id_id_no_adv 
from Student_info.dbo.at_advisors fa with (nolock) 
	  where getdate() between av_effect_start_dt and av_effect_end_dt
	  and av_type = 'FAC'
	  and av_seq_no = (select max(av_seq_no) from Student_info.dbo.at_advisors av2 where av2.av_id_id_no_stdt = fa.av_id_id_no_stdt and getdate() between av_effect_start_dt and av_effect_end_dt
				and av_type = 'FAC'

	  select * from at_advisors where av_id_id_no_stdt = 473519
	  order by av_maint_dt

create table #advisorsCurrent (av_id_id_no_stdt int, av_seq_no int, av_id_id_no_adv int, av_type varchar(5))

insert into #advisorsCurrent(av_id_id_no_stdt, av_seq_no, av_type)
select av_id_id_no_stdt, max(av_seq_no), av_type
from at_advisors where getdate() between av_effect_start_dt and av_effect_end_dt
and av_type = 'FAC' or av_type like '%FYA%'
group by av_id_id_no_stdt, av_type

update #advisorsCurrent
set av_id_id_no_adv = a.av_id_id_no_adv
from at_advisors a join #advisorsCurrent ac 
on ac.av_id_id_no_stdt = a.av_id_id_no_stdt
and ac.av_seq_no = a.av_seq_no
and ac.av_type = a.av_type

select * from #advisorsCurrent where av_id_id_no_stdt = 473519

select * from at_advisors
where av_id_id_no_stdt in (select sisid from Integrations.dbo.tdt_terradotta_student_integration)
and getdate() between av_effect_start_dt and av_effect_end_dt
and av_type like '%FYA%' -- go with FAC, that's what most have
order by av_id_id_no_stdt



SELECT distinct a.av_type, c.ct_value                 -- display value
FROM at_advisors a with(nolock)
JOIN dd_code_table c with(nolock) ON      -- Code Table
        ct_type = 'ADVIS'                      -- ADVIS is the code type for Advisor Meeting Status
    and ct_code1 = av_type  -- ct_code1 is the code to match on

select distinct av_type from at_advisors
order by 1
--4Year and AA

select mp_pr_id_no, mp_prime_joint_div, mp_program_code, p.*
from at_major_program join at_programs p on pr_id_no = mp_pr_id_no
where mp_id_id_no = 472715
and mp_status = 1


select * from at_class_nsc where ns_id_id_no = 472715
select * from at_semester

select * from student_info.dbo.at_class_nsc ns with (nolock) on ns_id_id_no = e.id_id_no and ns.ns_semester = (select max(ns_semester)from student_info.dbo.at_class_nsc with (nolock) where ns_id_id_no = e.id_id_no) -- JMP 09/13/13 Added to eliminate duplicate NSC records







--514823:  two records, cit country needs correcting
-- 514839
--514839
--514837
--514870

select * from at_email_addr where em_id_id_no = 514823




select * from student_info.dbo.at_programs
order by pr_award_level


select * from student_info.dbo.at_address where ad_id_id_no = 496366 and ad_type = 'L'
use Student_info

select * from at_names
select * from at_entity

select * from at_degree_info where di_id_id_no in (select sisid from integrations.dbo.tdt_terradotta_student_integration)
order by di_id_id_no

(select mp_id_id_no, mp_advisor_name, mp_program_code, p.pr_cip2000_code, p.pr_award_level from Student_info.dbo.at_major_program mp with (nolock) join at_programs p with (nolock) on p.pr_id_no = mp.mp_pr_id_no where mp_status = 1 and mp_prime_joint_div = 'P')
(select mp_id_id_no, mp_program_code, pr_cip2000_code from Student_info.dbo.at_major_program mp2  with (nolock) join at_programs p2 with (nolock) on p2.pr_id_no = mp2.mp_pr_id_no where mp2.mp_status = 1 and mp2.mp_prime_joint_div = 'J' and (p2.pr_da_marker_name = 'SECOND' or p2.pr_program_type = 'MAJOR'))
(select mp_id_id_no, mp_program_code, pr_cip2000_code from Student_info.dbo.at_major_program mp3  with (nolock) join at_programs p3 with (nolock) on p3.pr_id_no = mp3.mp_pr_id_no where mp3.mp_status = 1 and mp3.mp_prime_joint_div = 'J' and (p3.pr_da_marker_name = 'MINOR' or p3.pr_program_type = 'Minor'))


left outer join Student_info.dbo.at_major_program mnr  with (nolock) on mnr.mp_id_id_no = dm.dm_id_id_no and mnr.mp_status = 1 and mnr.mp_prime_joint_div = 'J'
	left outer join Student_info.dbo.at_programs pmnr  with (nolock) on pmnr.pr_id_no = mnr.mp_pr_id_no and (pmnr.pr_da_marker_name = 'MINOR' or pmnr.pr_program_type = 'Minor')


select * from at_programs

select ac.ac_description, aa.*
from at_academic_action aa join at_acad_action_codes ac on aa.aa_action_id = ac.ac_action_id and aa_actn_type = ac.ac_actn_type
where aa_actn_type = 'MSN' 
--and aa.aa_id_id_no in (select sisid from integrations.dbo.tdt_terradotta_student_integration)
--and aa_action_id >9000
--and aa_semester in (select sm_semester from at_semester where sm_status = 'C' )
and aa_semester = '202205'
and ac_description like '%leave%'
order by aa_action_id

--8224 is remote study

select aa_id_id_no, 'Y' + cast(count(*) as varchar(2)) as actions  from at_academic_action where aa_semester = '202205' and aa_actn_type = 'AAC' and aa_action_id < 8000 group by aa_id_id_no

select aa_id_id_no, aa_comment from at_academic_action where aa_semester = '202205' and aa_actn_type = 'MSN' and aa_action_id = 1024 

select * from at_acad_action_codes where ac_actn_type = 'MSN'
and ac_description like '%leave%'
1024 --, 1124 - medical
1008 --, 1028, 1108, 1153, 2013, 8029 - non-med

