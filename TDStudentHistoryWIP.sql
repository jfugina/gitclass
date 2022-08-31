drop table #mpprime
-- pick up here - below doesn't work as well as max maint dt.
/*Define all most recent prime programs for international population */
select m.mp_id_id_no, m.mp_program_code, mp_pr_id_no, mp_sem_admitted, mp_status, mp_term_sem, mp_maint_dt
into #mpPrime -- most recently updated prime MP
from [sisdb.wustl.edu].Student_info.dbo.at_major_program m
join
	(select mp_id_id_no, max(mp_sem_admitted) as maxdt from [sisdb.wustl.edu].Student_info.dbo.at_major_program
	where mp_prime_joint_div = 'P' and mp_maint_dt > dateadd(yy, -3, getdate())
	group by mp_id_id_no) as t -- target most recent prime
	on t.mp_id_id_no = m.mp_id_id_no
	and t.maxdt = m.mp_sem_admitted
join [sisdb.wustl.edu].Student_info.dbo.at_demographics d
on d.dm_id_id_no = m.mp_id_id_no
where isNull(d.dm_visa_type, '') <> ''
and d.dm_visa_type not in  ('PR', 'US')
and isNull(d.dm_citizenship, '') <> 'Y'
and m.mp_prime_joint_div = 'P'
order by mp_maint_dt desc, mp_sem_admitted desc

/* get the most recent class_nsc record by semester, and join up to what we pulled for the major program */
select e.*,  c.ns_id_id_no, c.ns_semester, c.ns_prog, c.ns_grad_level, c.ns_units, c.ns_level, c.ns_enr_st, 
case e.mp_status when 1 then 'Active' when 2 then 'Closed/incomplete' when 3 then 'Complete/Graduated' else 'W' end as status,
case e.mp_status when 1 then null when 2 then coalesce(c.ns_status_dt, c.ns_term_end) when 3 then c.ns_term_end else c.ns_status_dt end as end_date,
case when e.mp_program_code <> c.ns_prog then 'DIFF' else '' end
from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc c
join 
	(select ns_id_id_no, max(ns_semester) as semester 
	from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc
	where ns_term_end >= dateadd(yy, -3, getdate())
	group by ns_id_id_no) as a
on a.ns_id_id_no = c.ns_id_id_no and a.semester = c.ns_semester
join #mpPrime e on e.mp_id_id_no = c.ns_id_id_no
order by c.ns_semester, c.ns_id_id_no

select * from #mpPrime where mp_id_id_no in
(select mp_id_id_no from #mpprime group by mp_id_id_no having count(mp_id_id_no) > 1)


select * from [sisdb.wustl.edu].Student_info.dbo.at_major_program where mp_prime_joint_div = 'P' and  mp_id_id_no in ('491149') order by mp_maint_dt

select * from [sisdb.wustl.edu].Student_info.dbo.at_class_nsc where ns_id_id_no = '491149' order by ns_maint_dt


select * from #enrollment order by mp_status

select * from #enrollment where mp_id_id_no in 
(
select mp_id_id_no from #enrollment
group by mp_id_id_no 
having count(*) > 1) 





order by mp_maint_dt desc



-- first put in active
-- then maximum term semster where not active?

select mp_id_id_no, 1, '' from [sisdb.wustl.edu].Student_info.dbo.at_major_program where mp_status = 3 and mp_prime_joint_div = 'P'
union
select mp_id_id_no, 3, max(mp_term_sem) from [sisdb.wustl.edu].Student_info.dbo.at_major_program where mp_status = 3 and mp_prime_joint_div = 'P')