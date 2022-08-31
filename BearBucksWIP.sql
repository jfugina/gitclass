select * from PersonName where FirstName like '%Tester%'
EXECUTE WPWFPROD.dbo.PS_WP_SP_CBORD_EMPLOYEE  384045 --4
EXECUTE WPWFPROD.dbo.PS_WP_SP_CBORD_EMPLOYEE  384046 --5
EXECUTE WPWFPROD.dbo.PS_WP_SP_CBORD_EMPLOYEE  384047 --6
EXECUTE WPWFPROD.dbo.PS_WP_SP_CBORD_EMPLOYEE  384048 --7
EXECUTE WPWFPROD.dbo.PS_WP_SP_CBORD_EMPLOYEE  504011 --1
EXECUTE WPWFPROD.dbo.PS_WP_SP_CBORD_EMPLOYEE  504012 --3
EXECUTE WPWFPROD.dbo.PS_WP_SP_CBORD_EMPLOYEE  504013 --2

select distinct campus from PersonEmploymentProfile

select * from PersonName where lastName like 'McCaus%'

select * from [Integrations].[dbo].PersonOrganization
where organizationCode like 'MS%'
and OrganizationType = 'Supervisory'

select * from [Integrations].[dbo].PersonEmploymentProfile
where employeeId in (select employeeId from [Integrations].[dbo].PersonName where FirstName like '%Tester%')


select top 500 * from hs_cbord_entity
order by cbord_id desc

select * from delete hs_cbord_entity where cbord_id > 288000
update hs_cbord_entity set cbord_hrms_id = null where cbord_id > 288000



/********************************************************************/
-- for all four below, remove the emplid from the hs_cbord_entity
update hs_cbord_entity set cbord_hrms_id = null where cbord_id > 288000

-- tester4 North Campus, but working for DOM, so should resolve to Med meal plan
update [Integrations].[dbo].PersonEmploymentProfile
set campus = 'North Campus'  
--select * from [Integrations].[dbo].PersonEmploymentProfile
where employeeId = 384045

update [Integrations].[dbo].PersonOrganization
set OrganizationCode = 'MS Dept of Medicine' 
--select * from PersonOrganization
where employeeId = 384045 and OrganizationType = 'Supervisory'

/********************************************************************/
-- tester5 Danforth Campus (regression test – should resolve to Danforth meal plan)
update [Integrations].[dbo].PersonEmploymentProfile
set campus = 'North Campus'  
--select * from PersonEmploymentProfile
where employeeId = 384046

/********************************************************************/
-- tester6 Med School Campus (regression test – should resolve to Med meal plan)
update [Integrations].[dbo].PersonEmploymentProfile
set campus = 'Med School'  
--select * from PersonEmploymentProfile
where employeeId = 384047

/********************************************************************/
-- tester7 Tyson – should resolve to Dan meal plan
update [Integrations].[dbo].PersonEmploymentProfile
set campus = 'Tyson'  
--select * from PersonEmploymentProfile
where employeeId = 384048

/********************************************************************/

select a.*, job.* from [Integrations].[dbo].personName a
	JOIN [Integrations].[dbo].[PersonEmploymentPosition] JOB WITH (NOLOCK) ON
		A.EmployeeId = JOB.EmployeeId AND JOB.ImportIsActiveRecord = 1  and JOB.PrimaryJobIndicator = 1
		AND JOB.JobEffectiveDate = (SELECT MAX(HRS1.JobEffectiveDate)
	  		FROM [Integrations].[dbo].[PersonEmploymentPosition] HRS1 WITH (NOLOCK) 
	 		WHERE HRS1.EmployeeId = JOB.EmployeeId AND HRS1.ImportIsActiveRecord = 1
	   		AND HRS1.PositionId = JOB.PositionId 
	   		AND CAST(HRS1.JobEffectiveDate AS DATE)	<= CAST(GETDATE() AS DATE))		

	JOIN [Integrations].[dbo].[PersonEmploymentProfile] WJOB WITH (NOLOCK)  ON
		JOB.EmployeeId = WJOB.EmployeeId
		AND WJOB.[Status]IN ('Active','On Leave')
		AND WJOB.ImportIsActiveRecord = 1

	JOIN [Integrations].[dbo].[PersonOrganization] ORG WITH (NOLOCK) ON
		ORG.EmployeeId = JOB.EmployeeId
		AND ORG.OrganizationType = 'Supervisory' 
		and ORG.PositionId = JOB.PositionId
		and JOB.ImportIsActiveRecord = 1

where a.firstName like '%Tester%'