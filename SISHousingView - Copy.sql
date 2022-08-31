USE [CTI_GLOBAL]
GO

/****** Object:  View [dbo].[atv_parking_lottery_stdt_info]    Script Date: 09/28/2021 10:11:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/***********

Change History:

08/20/2020	AJH	Removing conditions on Join to at_demographics as we are now including freshmen
				Adding join to hs_semester to pull the sis semester code. NOTE: if Spring semester is ever used, the semester_code_id will need to be updated
				Added return value to indicate whether the user is a freshman or not

***********/


CREATE view [dbo].[atv_parking_lottery_stdt_info] as
	--KMK - EA-1900 - Add year code so we can pull data for year student is requesting permit
	Select Cast (y.year_code as varchar(20) )		'year_code',
		id.id_id_no				'sisid'		
		-- JDC Determine Grad/Undergrad
		,Case 
			When pr_program_level = 'G' then 'G'
			--KMK - 7/18/2018 - Do not consider students with an ITG as a grad student
			--When exists (Select 1 from 
			--		at_graduation_master with(nolock) 
			--		--Join at_sis_controls py1 with(nolock) on py1.sic_control_code = 'parkyear' -- JDC - 5/25/2018 - this gets the base year for eligibility.
			--		where gm_id_id_no = id.id_id_no
			--			--and gm_sortsem >= '201802' --kmk - 5/16/2018 - changed from 201702 to 201802
			--			and gm_sortsem >= CAST(y.fiscal_year-1 As char(4)) + '02' -- KMK- 5/25/2018 - anyone graduating should be treated as a grad student
			--		)	Then 'G'
			Else 'U'
		End									'grad_undergrad'
		-- JDC Determine iswashuhousing
		, Case 
			--KMK - EA-1900 - join to application table exported from StarRez
			--When ra.room_assignment_buf_id is not Null then 'Y'
			--When ha.housing_application_id is not null then 'Y'
			When ra.external_id is not Null then 'Y'
			When ha.external_id is not null then 'Y'
			Else	'N'								
			End								'iswashuhousing'
		-- JDC Determine Lofts housing
		, Case
			WHEN c.[complex_name] = 'Apartments' 
				AND LEFT(b.[building_code],1) = 'L'			-- dorm code
				THEN 'Y'
			-- code from Kristina
			--KMK - EA-1900 - join to application table exported from StarRez
   --		  When ra.room_assignment_buf_id is not Null then 'N' --all others assigned to rooms, not lofts
   --         When ha.building_id is not null then 'N' --Fraternity students, not assigned to room - we know they will not be lofts
    		  When ra.room_assignment_id is not Null then 'N' --all others assigned to rooms, not lofts
			  When ha.type = 'Greek' then 'N' --Fraternity students, not assigned to room - we know they will not be lofts
			  when (pr_program_level <> 'G' )
						--KMK - 7/18/2018 - Do not consider students with an ITG as a grad student
						--and not exists (Select 1 from at_graduation_master with(nolock) 
						--  --Join at_sis_controls py2 with(nolock) on py2.sic_control_code = 'parkyear' -- JDC this get the base year for eligibility. 
      --                     where gm_id_id_no = id.id_id_no
      --                            --and gm_sortsem >= '201802' --kmk - 5/16/2018 - changed from 201702 to 201802
   			--					  and gm_sortsem >= CAST(y.fiscal_year-1 AS char(4)) + '02' -- KMK - 5/25/2018 - Anyone graduating should be treated as a grad student
                            --)) and 
						   --kmk - 5/16/2018 - changed from 2018 to 2019
                           --ha.id_id_no is not null and SUBSTRING(dm_Frozen_Coh, 3, 4 ) <= '2019' then 'Y' --seniors without a room assignment, assume lofts 
						   and ha.id_id_no is not null and SUBSTRING(dm_Frozen_Coh, 3, 4 ) <= y.fiscal_year then 'Y' --  KMK - 5/25/2018 - seniors without a room assignment, assume lofts


			Else 'N'								
			End								'isloftshousing'
		, isNull(c.[complex_name], '') as ComplexName
		, CASE
			WHEN dm_enroll_status = 'F' AND dm_semester_entry = at_semester_code THEN 'F'
			ELSE 'N'
		END 'isFreshman'

	From [SISDB.WUSTL.EDU].[student_info].[dbo].at_entity id with(nolock)
	 Left Outer JOIN [SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_year y         WITH (NOLOCK) ON 
	--KMK - EA-1900 - pull both current and next year data. Student should specify if purchasing permit for current or next year
		--y.active_flag = 'N'
		y.active_flag in ('C', 'N')
	Join [SISDB.WUSTL.EDU].[Student_Info].[dbo].at_major_program with(nolock) on
		mp_id_id_no = id.id_id_no
		and mp_status = 1
		and mp_prime_joint_div = 'P'
		-- jdc exclude folks who are in the exception table. Bring them in the union below
		/*and  not exists (Select 1
				From dbo.at_parking_lottery_exception ex with(nolock)
				Where ex.sisid = id.id_id_no and ex.year_code = y.year_code
				) -- jaf:  leaving out lottery excludes
				*/
	--Join at_sis_controls py with(nolock) on 
	--	py.sic_control_code = 'parkyear'	-- JDC - 5/25/2018 - this gets the base year for eligibility.
	Join [SISDB.WUSTL.EDU].[Student_Info].[dbo].at_status with(Nolock) on
		st_id_id_no = id.id_id_no
	Join [SISDB.WUSTL.EDU].[Student_Info].[dbo].at_demographics with(nolock) on
		dm_id_id_no = id.id_id_no
		--and (st_prime_div not in ('AR', 'BU', 'EN', 'FA', 'LA', 'FX','WW')
		--	--or SUBSTRING(dm_Frozen_Coh, 3, 4 ) < '2021' --kmk - 5/16/2018 - changed from 2020 to 2021
		--	or SUBSTRING(dm_Frozen_Coh, 3, 4 ) < y.fiscal_year + 3 -- KMK - 5/25/2018 - excludes freshmen and sophomores using frozen cohort
		--															-- JAF - changed +2 to +3 to let sophomores be included.
		--	)
	Join [SISDB.WUSTL.EDU].[Student_Info].[dbo].at_programs with(nolock) on
		mp_pr_id_no = pr_id_no
	--KMK - EA-1900 - next year data will reside in hs_room_assignment table instead of hs_room_assignment_buf table
  --   Left Outer JOIN hs_room_assignment_buf ra       WITH (NOLOCK) ON 
     Left Outer JOIN [SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_room_assignment ra       WITH (NOLOCK) ON 
		y.year_id = ra.year_id  
		AND ra.id_id_no = id.id_id_no 
		--KMK - EA-1900 - don't pull future bookings in the current year
		AND ra.current_flag = case when (y.active_flag = 'N' or getdate() < (select s.begin_date from [SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_semester s where s.year_id =y.year_id and s.semester_code_id = 1)) then 'F' else 'C' end
	LEFT OUTER JOIN [SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_room r		WITH (NOLOCK) ON r.room_id = ra.room_id
    LEFT OUTER JOIN [SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_building b		WITH (NOLOCK) ON b.building_id = r.building_id
	LEFT OUTER JOIN	[SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_complex c 		WITH (NOLOCK) ON c.complex_id = b.complex_id
	--KMK - EA-1900 - join to application table exported from StarRez
	--left outer join hs_housing_application ha with (nolock) on 
	--	ha.id_id_no = id.id_id_no 
	--	and ha.year_id = y.year_id 
 	left outer join [SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_starrez_app_export ha with (nolock) on 
		ha.id_id_no = id.id_id_no 
		and ha.year_code = y.year_code 
   --left outer join hs_lookup_value lv on ha.housing_status_id  = lv.lookup_value_id and lv.lookup_value = 'RECEIVED'
	--KMK EA-1900 - join to application table exported from StarRez, housing status values have changed. Question for parking - do we want just COMPLETED, or do we also want CONTRACT SIGNED and RECEIVED?
    --and ha.housing_status_id = (select lv.lookup_value_id from hs_lookup l join hs_lookup_value lv on l.lookup_id = lv.lookup_id where l.lookup = 'HOUSESTATUS' and lv.lookup_value = 'RECEIVED')
    and ha.status in ('COMPLETED')
	LEFT JOIN [SISDB.WUSTL.EDU].[Student_Info].[dbo].hs_semester sem WITH (NOLOCK) ON 
		sem.year_id = y.year_id 
		AND semester_code_id = 1 -- semester_code_id = 1 is Fall, = 2 is Spring
	where (id.id_test_person = 'N' or id.id_test_person is NULL)
GO


