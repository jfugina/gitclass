USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[tds_student_data_load]    Script Date: 06/24/2022 1:34:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[tds_student_data_load]
as

/* Set up the advisors table.  need to get current advisor, but some have multiple in the current date range, so we have to go with the advisor on the max sequence# */
create table #advisorsCurrent (av_id_id_no_stdt int, av_seq_no int, av_id_id_no_adv int, av_type varchar(5))

insert into #advisorsCurrent(av_id_id_no_stdt, av_seq_no, av_type)
select av_id_id_no_stdt, max(av_seq_no), av_type
from [sisdb.wustl.edu].Student_info.dbo.at_advisors with (nolock) 
where getdate() between av_effect_start_dt and av_effect_end_dt
and (av_type = 'FAC' or av_type like '%FYA%')
group by av_id_id_no_stdt, av_type

update #advisorsCurrent
set av_id_id_no_adv = a.av_id_id_no_adv
from [sisdb.wustl.edu].Student_info.dbo.at_advisors a with (nolock) join #advisorsCurrent ac 
on ac.av_id_id_no_stdt = a.av_id_id_no_stdt
and ac.av_seq_no = a.av_seq_no
and ac.av_type = a.av_type
-- will use above table to join for faculty and 4yr advisors for custom fields below

-- set up a table from the workday integration contianing only the most recent visa record (based on expiration)
select v.employeeId, v.universalId, v.visaNumber, v.visaType, v.visaIssueDate, v.visaExpiryDate, v.visaVerificationDate
into #VisaTemp 
from [sisdb.wustl.edu].Integrations.dbo.PersonVisa v join 
(select universalId, max(visaIssueDate) as maxDate from PersonVisa group by universalId) as a
on a.universalId = v.universalId and v.visaIssueDate = a.maxDate

truncate table tdt_terradotta_student_integration


insert into tdt_terradotta_student_integration (sisid, uuuid, user_first_name, user_middle_name, user_last_name, suffix,
user_sex, user_dob, country_of_cit_cd, subject_field_code, major1_cd, major2_cd, minor_cd, education_level_cd,
user_email, visa_type_cd, phone_number, us_address_line_1, us_address_line_2, us_city, us_state_cd, us_zip_code, preferred_name,
custom1, custom2, custom3, custom4, custom5, custom6, custom10, custom11, custom12, custom13, custom14, custom15, custom16, custom17, 
custom20, custom21, custom22, custom23, custom24, custom26, custom27, custom28, custom29, 
custom30, custom31, custom32, custom33
/*
custom1 -- intentToGraduate processed - pull from degree info (not grad master), looking for the semester
custom2 -- AcademicAdvisor - from at_major_program
custom3 -- 4 Year Advisor - from at_advisors - needs work to eliminate duplicates
custom4 -- EnrollmentStatus - from at_class_nsc.ns_grad_level for max semester
custom5 -- enrolledUnits - from at_class_nsc
custom6 -- hold or academic actions - if holds only, use 
custom7 -- emergency contact name (address type U), NOT approved to pull
custom8 -- emergency contact phone (address type U), NOT approved to pull
custom9 -- emergency contact email - notes say this doesn't exist in SIS
custom10 -- holds or academic actions (suspended, expelled, etc)
custom11 -- date suspended or expelled
custom12 -- on campus housing bldg/room, addresses, local type, where line1 starts with MSC (see StarRez)
custom13 -- LOA Non-Med Start Date milestone record
custom14 -- LOA Med Start Date milestone record
custom15 -- approved for remote study - milestone 8224, but unreliable
custom16 -- degree date
custom17 -- US ID Type - from Admin Utilities>Change SSN/ITIN>National ID Type
custom18 -- expiring plans - not in SIS
custom19 -- expiring followup plans req'd - not in SIS
custom20 -- class year - Student level - do they just want the straight up level?
custom21 -- study abroad
custom22 -- marital status (demographics)
custom23 -- Enrolled School - 1st 2 chars of primary major
custom24 -- advisor email (notes read like this is a Y/N value, but can't find referenced field in SIS Admin
custom25 -- language test score - do not pull from SIS
custom26 -- Cumulative GPA
custom27 -- SIS ID
custom28 -- (WD) End Date
custom29 -- (WD) Visa Type
custom30 -- (WD) EmplId
custom31 -- (WD) Sponsor Dept
custom32 -- (WD) Passport#
custom33 -- (WD) Visa#
custom34
*/
)
--514823:  two records, cit country needs correcting
-- 514839
--514839
--514837
--514870

select id_id_no
	, case isNull(oid.eoi_wupeopleid, 0) when 0 then 'NEEDS AUDIT' else cast(oid.eoi_wupeopleid as varchar(20)) end
	, id_first
	, id_middle
	, id_last
	, id_suffix -- should this come from the at_names table where nm_curr_prev = 'C'?
	, dm_sex
	, convert(char(10), dm.dm_birthdate, 101) -- some values are year 1899 and are not valid in TD
	, case when len(dm_cit_cntry_cd) > 2 then '**' else cc.fips end -- some rogue values - audit those later
	, pmaj.pr_cip2000_code -- subject field code
	, pmaj.pr_cip2000_code -- major1
	, pmaj2.pr_cip2000_code -- second major
	, pmnr.pr_cip2000_code -- minor
	, case pmaj.pr_award_level 
			when 10 then '6' -- dentist
			when 17 then '6' -- doctorate
			when 18 then '6' --doctorate
			when 3 then '3' -- associates
			when 5 then '4' -- bachelors
			when 7 then '5' -- masters
			else '11' -- 1,2,4 and 6 are certificates - map to Other
		end -- ed level code, needs conversion
	, isNull(rtrim(em.em_email_addr), '')
	, case vt.sevis_value when '' then '*' + dm_visa_type + '*' else vt.sevis_value end -- this will need transforms
	, right(case isNull(rtrim(a1.ad_cell_phone), '') when '' then isNull(rtrim(a1.ad_phone), '') else isNull(rtrim(a1.ad_cell_phone), '') end, 10) 
	, isNull(a1.ad_line1, '') 
	, isNull(a1.ad_line2, '') 
	, isNull(a1.ad_city, '') 
	, isNull(a1.ad_state, '') 
	, isNull(substring(a1.ad_zip, 1,5), '') 
	, id_familiar -- preferred name
	, pmaj.di_semester
	, FACADV.fac_advisor_name
	, FYADV.yr4_advisor_name -- note, this causes lots of dupes
	, ns_enr_st
	, ns_units
	, HOLD.holds
	, ACTN.actionCount
	, ACTN.actionLatest
	, ra.Hall + '/' + ra.room
	, '(' + LOA_NonMed.aa_semester + ') ' + LOA_NonMed.aa_comment
	, '(' + LOA_Med.aa_semester + ') ' + LOA_Med.aa_comment
	, '' as approvedforRemoteStudy
	, pmaj.di_degree_date
	, case when isNull(no_ssn_or_itin, '') = 1 then 'No SSN or ITIN' when isNull(itin, '') = 1 then 'ITIN' else '' end
	, ns_level 
	, '(' + sa.aa_semester + ') ' + sa.aa_comment
	, dm.dm_marital_status
	, left (pmaj.mp_program_code, 2)
	, coalesce (FACADV.em_email_addr, FYADV.em_email_addr)
	, gpa.gp_cum_gpa
	, e.id_id_no
	, cast(v.visaExpiryDate as varchar(10))
	, v.visaType 
	, v.employeeId 
	, org.organizationName
	, '' as custom32WDPassportNum -- not in SIS integration
	, v.visaNumber
from [sisdb.wustl.edu].Student_info.dbo.at_entity e with (nolock)
join [sisdb.wustl.edu].Student_info.dbo.at_demographics dm with (nolock) on dm.dm_id_id_no = e.id_id_no
join -- major
	(select mp_id_id_no, mp_advisor_name, mp_program_code, p.pr_cip2000_code, p.pr_award_level, di.di_degree_date, di.di_semester
	  from [sisdb.wustl.edu].Student_info.dbo.at_major_program mp with (nolock) 
	  join [sisdb.wustl.edu].Student_info.dbo.at_programs p with (nolock) on p.pr_id_no = mp.mp_pr_id_no 
	  left outer join [sisdb.wustl.edu].Student_info.dbo.at_degree_info di on di.di_program_code = mp_program_code and di.di_id_id_no = mp_id_id_no
	  where mp_status = 1 and mp_prime_joint_div = 'P'
	 ) as pmaj
	on pmaj.mp_id_id_no = e.id_id_no
left outer join -- second major
	(select mp_id_id_no, /*mp_program_code, */ max(pr_cip2000_code ) as pr_cip2000_code
	  from [sisdb.wustl.edu].Student_info.dbo.at_major_program mp2  with (nolock) 
	  join [sisdb.wustl.edu].Student_info.dbo.at_programs p2 with (nolock) on p2.pr_id_no = mp2.mp_pr_id_no 
	  where mp2.mp_status = 1 and mp2.mp_prime_joint_div = 'J' and (p2.pr_da_marker_name = 'SECOND' or p2.pr_program_type = 'Major') and p2.pr_da_marker_name <> 'SPECIAL'
	  group by mp_id_id_no
	 ) as pmaj2
	on pmaj2.mp_id_id_no = e.id_id_no 
left outer join -- minor
	(select mp_id_id_no, /*mp_program_code,*/ max(pr_cip2000_code ) as pr_cip2000_code
	  from [sisdb.wustl.edu].Student_info.dbo.at_major_program mp3  with (nolock) 
	  join [sisdb.wustl.edu].Student_info.dbo.at_programs p3 with (nolock) on p3.pr_id_no = mp3.mp_pr_id_no 
	  where mp3.mp_status = 1 and mp3.mp_prime_joint_div = 'J' and (p3.pr_da_marker_name = 'MINOR' or p3.pr_program_type = 'Minor')
	  group by mp_id_id_no
	 ) as pmnr
	on pmnr.mp_id_id_no = e.id_id_no
left outer join tdt_visacode_translation vt on vt.visa_type_cd = dm.dm_visa_type
left outer join [sisdb.wustl.edu].Student_info.dbo.at_address a1 with (nolock) on a1.ad_id_id_no = e.id_id_no and a1.ad_type = 'L' and isNull(ad_country_cd, 'US') = 'US' -- added this part because some Local addresses are not US based
left outer join [sisdb.wustl.edu].Student_info.dbo.at_email_addr em with (nolock) on em.em_id_id_no = e.id_id_no and em.em_email_addr <> ''
left outer join [sisdb.wustl.edu].Student_info.dbo.at_class_nsc ns with (nolock) on ns_id_id_no = e.id_id_no and ns.ns_semester = (select max(ns_semester)from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc with (nolock) where ns_id_id_no = e.id_id_no) 
left outer join [sisdb.wustl.edu].Student_info.dbo.at_entity_other_ids oid with (nolock) on oid.eoi_id_id_no = e.id_id_no
left outer join tdt_countryCode_translation cc on cc.ceeb = dm.dm_cit_cntry_cd
left outer join [sisdb.wustl.edu].Student_info.dbo.at_ssn ss with (nolock) on ss.ss_id_id_no = e.id_id_no and ss.ss_outdated <> 'X'
left outer join [sisdb.wustl.edu].Student_info.dbo.at_gpa gpa with (nolock) on gpa.gp_id_id_no = e.id_id_no and gpa.gp_semester in (select sm_semester from [sisdb.wustl.edu].Student_info.dbo.at_semester with (nolock) where sm_status = 'C')
left outer join -- faculty advisor
	(select av_id_id_no_stdt, av_id_id_no_adv, rtrim(id_last) + ', ' + rtrim(id_first) as fac_advisor_name, facem.em_email_addr
	  from #advisorsCurrent fa with (nolock) join [sisdb.wustl.edu].Student_info.dbo.at_entity adv1 with (nolock) on adv1.id_id_no = fa.av_id_id_no_adv
	  left outer join [sisdb.wustl.edu].Student_info.dbo.at_email_addr facem with (nolock) on facem.em_id_id_no = fa.av_id_id_no_adv
	  where av_type = 'FAC'
	) as FACADV
  on FACADV.av_id_id_no_stdt = e.id_id_no 

left outer join -- 4y advisor
	(select av_id_id_no_stdt, av_id_id_no_adv, '(' + av_type + ') ' + rtrim(id_last) + ', ' + rtrim(id_first) as yr4_advisor_name, advem.em_email_addr
	  from #advisorsCurrent fa with (nolock) join [sisdb.wustl.edu].Student_info.dbo.at_entity adv1 with (nolock) on adv1.id_id_no = fa.av_id_id_no_adv
	  left outer join [sisdb.wustl.edu].Student_info.dbo.at_email_addr advem with (nolock) on advem.em_id_id_no = fa.av_id_id_no_adv
	  where av_type like '%FYA%'
	) as FYADV
   on FYADV.av_id_id_no_stdt = e.id_id_no 

left outer join  -- holds
	(select aa_id_id_no, 'Y' + cast(count(*) as varchar(2)) as holds  
	  from [sisdb.wustl.edu].Student_info.dbo.at_academic_action with (nolock)
	  where aa_rec_code = 'HD' 
	  and (aa_semester in (select sm_semester from [sisdb.wustl.edu].Student_info.dbo.at_semester with (nolock) where sm_status = 'C') or aa_semester = '') group by aa_id_id_no
	) as HOLD
   on HOLD.aa_id_id_no = e.id_id_no
left outer join -- probation or suspension
	(select aa_id_id_no, 'Y' + '(' + cast(count(aa_id_id_no) as varchar(2)) + ')' as actionCount, max(aa_semester + ' ' + aa_comment) as actionLatest  
	  from [sisdb.wustl.edu].Student_info.dbo.at_academic_action with (nolock)
	  where aa_actn_type = 'AAC' and aa_action_id in ('0001', '0002')
	  --and (aa_semester in (select sm_semester from [sisdb.wustl.edu].Student_info.dbo.at_semester where sm_status = 'C') or aa_semester = '') 
	  group by aa_id_id_no
	) as ACTN
   on ACTN.aa_id_id_no = e.id_id_no
left outer join -- StudyAbroad
	(select aa_id_id_no, aa_semester, aa_comment  
	  from [sisdb.wustl.edu].Student_info.dbo.at_academic_action with (nolock)
	  where (aa_semester in (select sm_semester from [sisdb.wustl.edu].Student_info.dbo.at_semester with (nolock) where sm_status = 'C') or aa_semester = '') 
	  and aa_actn_type = 'MSN' and aa_action_id = '8224' 
	) as sa
   on sa.aa_id_id_no = e.id_id_no
left outer join -- LOA Medical
	(select aa_id_id_no, aa_semester, aa_comment  
	  from [sisdb.wustl.edu].Student_info.dbo.at_academic_action with (nolock)
	  where (aa_semester in (select sm_semester from [sisdb.wustl.edu].Student_info.dbo.at_semester with (nolock) where sm_status = 'C') or aa_semester = '') 
	  and aa_actn_type = 'MSN' and aa_action_id = '1024' 
	) as LOA_Med
   on LOA_Med.aa_id_id_no = e.id_id_no
left outer join --LOA Non Medical
	(select aa_id_id_no, aa_semester, aa_comment
	  from [sisdb.wustl.edu].Student_info.dbo.at_academic_action with (nolock)
	  where (aa_semester in (select sm_semester from [sisdb.wustl.edu].Student_info.dbo.at_semester with (nolock) where sm_status = 'C') or aa_semester = '') 
	  and aa_actn_type = 'MSN' and aa_action_id = '1008'
	) as LOA_NonMed
   on LOA_NonMed.aa_id_id_no = e.id_id_no
left outer join #VisaTemp v on v.universalId = oid.eoi_wupeopleid
left outer join 
	(select o.universalId, o.OrganizationName 
	 from [sisdb.wustl.edu].Integrations.dbo.PersonOrganization o with (nolock) join [sisdb.wustl.edu].Integrations.dbo.PersonEmploymentPosition p with (nolock)
	 on p.positionId = o.positionId and p.universalId = o.universalId
	 where p.PrimaryJobIndicator = 1 and o.organizationType = 'Supervisory') as org
	on org.UniversalId = oid.eoi_wupeopleId
left outer join [sisdb.wustl.edu].Student_info.dbo.hsv_current_room_assignments ra on ra.studentId = e.id_id_no
where 
isNull(dm.dm_visa_type, '') <> ''
and dm.dm_visa_type not in  ('PR', 'US')
and isNull(dm.dm_citizenship, '') <> 'Y'
order by e.id_id_no
