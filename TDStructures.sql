USE [Integrations]
GO

/****** Object:  Table [dbo].[tdt_countryCode_translation]    Script Date: 06/30/2022 3:02:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tdt_countryCode_translation](
	[CEEB] [varchar](50) NULL,
	[ISO] [varchar](50) NULL,
	[FIPS] [varchar](50) NULL,
	[CeebName] [varchar](50) NULL,
	[FipsName] [varchar](50) NULL
) ON [PRIMARY]
GO


USE [Integrations]
GO

/****** Object:  Table [dbo].[tdt_visacode_translation]    Script Date: 06/30/2022 3:03:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tdt_visacode_translation](
	[visa_type_cd] [nvarchar](10) NULL,
	[sevis_value] [varchar](5) NOT NULL,
	[numfound] [int] NULL
) ON [PRIMARY]
GO


USE [Integrations]
GO

/****** Object:  Table [dbo].[tdt_terradotta_student_integration]    Script Date: 06/30/2022 3:02:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tdt_terradotta_student_integration](
	[sisid] [int] NOT NULL,
	[UUUID] [nvarchar](200) NOT NULL,
	[user_first_name] [nvarchar](80) NULL,
	[user_middle_name] [nvarchar](50) NULL,
	[user_last_name] [nvarchar](80) NULL,
	[suffix] [char](3) NULL,
	[user_sex] [char](1) NULL,
	[user_dob] [char](10) NULL,
	[birth_city] [varchar](100) NULL,
	[birth_country_cd] [char](2) NULL,
	[country_of_pr_cd] [char](2) NULL,
	[country_of_cit_cd] [char](2) NULL,
	[program_start_date] [char](10) NULL,
	[program_end_date] [char](10) NULL,
	[subject_field_code] [char](7) NULL,
	[major1_cd] [char](7) NULL,
	[major2_cd] [char](7) NULL,
	[minor_cd] [char](7) NULL,
	[education_level_cd] [char](2) NULL,
	[user_email] [nvarchar](255) NULL,
	[visa_type_cd] [nvarchar](10) NULL,
	[phone_number] [char](10) NULL,
	[foreign_country_number] [char](4) NULL,
	[foreign_phone_number] [nvarchar](20) NULL,
	[us_address_line_1] [nvarchar](64) NULL,
	[us_address_line_2] [nvarchar](64) NULL,
	[us_city] [nvarchar](60) NULL,
	[us_state_cd] [char](2) NULL,
	[us_zip_code] [char](5) NULL,
	[mailing_address_line_1] [nvarchar](64) NULL,
	[mailing_address_line_2] [nvarchar](64) NULL,
	[mailing_city] [nvarchar](60) NULL,
	[mailing_state_cd] [char](2) NULL,
	[mailing_zip_code] [char](5) NULL,
	[foreign_address_line_1] [nvarchar](60) NULL,
	[foreign_address_line_2] [nvarchar](60) NULL,
	[foreign_city] [nvarchar](60) NULL,
	[foreign_state_cd] [nvarchar](30) NULL,
	[foreign_country_cd] [char](2) NULL,
	[foreign_postal_code] [varchar](20) NULL,
	[preferred_name] [nvarchar](180) NULL,
	[passport_name] [nvarchar](39) NULL,
	[us_born_non_citizen_reason_cd] [nchar](10) NULL,
	[ev_id] [nchar](10) NULL,
	[initial_session_start_date] [nchar](10) NULL,
	[campus_site_id] [nchar](10) NULL,
	[ev_position] [nchar](10) NULL,
	[sevis_id] [nchar](10) NULL,
	[education_level_remarks] [nchar](10) NULL,
	[academic_term] [nchar](10) NULL,
	[english_proficiency_required_fl] [nchar](10) NULL,
	[meets_english_proficiency_fl] [nchar](10) NULL,
	[reason_english_proficiency_not_required] [nchar](10) NULL,
	[commuter_from_mexico_fl] [nchar](10) NULL,
	[no_phone] [nchar](10) NULL,
	[tuition_amt] [nchar](10) NULL,
	[living_expenses_amt] [nchar](10) NULL,
	[dependent_expenses_amt] [nchar](10) NULL,
	[other_expenses_amt] [nchar](10) NULL,
	[other_amount_remarks] [nchar](10) NULL,
	[personal_funding_amt] [nchar](10) NULL,
	[school_funding_amt] [nchar](10) NULL,
	[school_funding_remarks] [nchar](10) NULL,
	[other_funding_amt] [nchar](10) NULL,
	[other_funding_remarks] [nchar](10) NULL,
	[on_campus_employment_funding_amt] [nchar](10) NULL,
	[program_category] [nchar](10) NULL,
	[ev_subject_description] [nchar](10) NULL,
	[ev_remarks] [nchar](10) NULL,
	[cancellation_reason_cd] [nchar](10) NULL,
	[termination_reason_cd] [nchar](10) NULL,
	[other_termination_reason] [nchar](10) NULL,
	[effective_date] [nchar](10) NULL,
	[remarks] [nchar](10) NULL,
	[session_start_date] [nchar](10) NULL,
	[ev_received_funding_from_us_government] [nchar](10) NULL,
	[ev_amount_of_funding_from_program_sponsor] [nchar](10) NULL,
	[ev_us_government_organization1_funding] [nchar](10) NULL,
	[ev_amount_from_us_government_organization1] [nchar](10) NULL,
	[ev_international_organization1_funding] [nchar](10) NULL,
	[ev_amount_from_international_organization1] [nchar](10) NULL,
	[ev_amount_from_foreign_govt] [nchar](10) NULL,
	[ev_amount_from_biational_commission] [nchar](10) NULL,
	[ev_other_funding_name] [nchar](10) NULL,
	[ev_other_funding_amount] [nchar](10) NULL,
	[ev_total_amout_of_personal_funding] [nchar](10) NULL,
	[ev_us_government_organization_funding] [nchar](10) NULL,
	[ev_amount_from_us_government_organization] [nchar](10) NULL,
	[ev_international_organization_funding] [nchar](10) NULL,
	[ev_amount_from_international_organization] [nchar](10) NULL,
	[reason_for_extension] [nchar](10) NULL,
	[shorten_reason_cd] [nchar](10) NULL,
	[custom1] [nvarchar](255) NULL,
	[custom2] [nvarchar](255) NULL,
	[custom3] [nvarchar](255) NULL,
	[custom4] [nvarchar](255) NULL,
	[custom5] [nvarchar](255) NULL,
	[custom6] [nvarchar](255) NULL,
	[custom7] [nvarchar](255) NULL,
	[custom8] [nvarchar](255) NULL,
	[custom9] [nvarchar](255) NULL,
	[custom10] [nvarchar](255) NULL,
	[custom11] [nvarchar](255) NULL,
	[custom12] [nvarchar](255) NULL,
	[custom13] [nvarchar](255) NULL,
	[custom14] [nvarchar](255) NULL,
	[custom15] [nvarchar](255) NULL,
	[custom16] [nvarchar](255) NULL,
	[custom17] [nvarchar](255) NULL,
	[custom18] [nvarchar](255) NULL,
	[custom19] [nvarchar](255) NULL,
	[custom20] [nvarchar](255) NULL,
	[custom21] [nvarchar](255) NULL,
	[custom22] [nvarchar](255) NULL,
	[custom23] [nvarchar](255) NULL,
	[custom24] [nvarchar](255) NULL,
	[custom25] [nvarchar](255) NULL,
	[custom26] [nvarchar](255) NULL,
	[custom27] [nvarchar](255) NULL,
	[custom28] [nvarchar](255) NULL,
	[custom29] [nvarchar](255) NULL,
	[custom30] [nvarchar](255) NULL,
	[custom31] [nvarchar](255) NULL,
	[custom32] [nvarchar](255) NULL,
	[custom33] [nvarchar](255) NULL,
	[custom34] [nvarchar](255) NULL,
	[custom35] [nvarchar](255) NULL,
	[custom36] [nvarchar](255) NULL,
	[custom37] [nvarchar](255) NULL,
	[custom38] [nvarchar](255) NULL,
	[custom39] [nvarchar](255) NULL,
	[custom40] [nvarchar](255) NULL,
	[custom41] [nvarchar](255) NULL,
	[custom42] [nvarchar](255) NULL,
	[custom43] [nvarchar](255) NULL,
	[custom44] [nvarchar](255) NULL,
	[custom45] [nvarchar](255) NULL,
	[custom46] [nvarchar](255) NULL,
	[custom47] [nvarchar](255) NULL,
	[custom48] [nvarchar](255) NULL,
	[custom49] [nvarchar](255) NULL,
	[custom50] [nvarchar](255) NULL
) ON [PRIMARY]
GO


USE [Integrations]
GO

/****** Object:  View [dbo].[tdv_terradotta_student_extract]    Script Date: 06/30/2022 3:03:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[tdv_terradotta_student_extract] as
SELECT [UUUID]
      ,[user_first_name]
      ,[user_middle_name]
      ,[user_last_name]
      ,[suffix]
      ,[user_sex]
      ,[user_dob]
      ,isNull(birth_city, '') as [birth_city]
      ,isNull(birth_country_cd, '') as [birth_country_cd]
      ,isNull([country_of_pr_cd], '') as [country_of_pr_cd]
      ,isNull([country_of_cit_cd], '') as [country_of_cit_cd]
      ,isNull([program_start_date], '') as [program_start_date]
      ,isNull([program_end_date], '') as [program_end_date]
      ,isNull([subject_field_code], '') as [subject_field_code]
      ,[major1_cd]
      ,isNull([major2_cd], '') as [major2_cd]
      ,isNull([minor_cd], '') as [minor_cd]
      ,isNull([education_level_cd], '') as [education_level_cd]
      ,isNull([user_email], '') as [user_email]
      ,[visa_type_cd]
      ,isNull([phone_number], '') as [phone_number]
      ,isNull([foreign_country_number], '') as [foreign_country_number]
      ,isNull([foreign_phone_number], '') as [foreign_phone_number]
      ,isNull([us_address_line_1], '') as [us_address_line_1]
      ,isNull([us_address_line_2], '') as [us_address_line_2]
      ,isNull([us_city], '') as [us_city]
      ,isNull([us_state_cd], '') as [us_state_cd]
      ,isNull([us_zip_code], '') as [us_zip_code]
      ,isNull([mailing_address_line_1], '') as [mailing_address_line_1]
      ,isNull([mailing_address_line_2], '') as [mailing_address_line_2]
      ,isNull([mailing_city], '') as [mailing_city]
      ,isNull([mailing_state_cd], '') as [mailing_state_cd]
      ,isNull([mailing_zip_code], '') as [mailing_zip_code]
      ,isNull([foreign_address_line_1], '') as [foreign_address_line_1]
      ,isNull([foreign_address_line_2], '') as [foreign_address_line_2]
      ,isNull([foreign_city], '') as [foreign_city]
      ,isNull([foreign_state_cd], '') as [foreign_state_cd]
      ,isNull([foreign_country_cd], '') as [foreign_country_cd]
      ,isNull([foreign_postal_code], '') as [foreign_postal_code]
      ,isNull([preferred_name], '') as [preferred_name]
      ,isNull([passport_name], '') as [passport_name]
      ,isNull([us_born_non_citizen_reason_cd], '') as [us_born_non_citizen_reason_cd]
      ,isNull([ev_id], '') as [ev_id]
      ,isNull([initial_session_start_date], '') as [initial_session_start_date]
      ,isNull([campus_site_id], '') as [campus_site_id]
      ,isNull([ev_position], '') as [ev_position]
      ,isNull([sevis_id], '') as [sevis_id]
      ,isNull([education_level_remarks], '') as [education_level_remarks]
      ,isNull([academic_term], '') as [academic_term]
      ,isNull([english_proficiency_required_fl], '') as [english_proficiency_required_fl]
      ,isNull([meets_english_proficiency_fl], '') as [meets_english_proficiency_fl]
      ,isNull([reason_english_proficiency_not_required], '') as [reason_english_proficiency_not_required]
      ,isNull([commuter_from_mexico_fl], '') as [commuter_from_mexico_fl]
      ,isNull([no_phone], '') as [no_phone]
      ,isNull([tuition_amt], '') as [tuition_amt]
      ,isNull([living_expenses_amt], '') as [living_expenses_amt]
      ,isNull([dependent_expenses_amt], '') as [dependent_expenses_amt]
      ,isNull([other_expenses_amt], '') as [other_expenses_amt]
      ,isNull([other_amount_remarks], '') as [other_amount_remarks]
      ,isNull([personal_funding_amt], '') as [personal_funding_amt]
      ,isNull([school_funding_amt], '') as [school_funding_amt]
      ,isNull([school_funding_remarks], '') as [school_funding_remarks]
      ,isNull([other_funding_amt], '') as [other_funding_amt]
      ,isNull([other_funding_remarks], '') as [other_funding_remarks]
      ,isNull([on_campus_employment_funding_amt], '') as [on_campus_employment_funding_amt]
      ,isNull([program_category], '') as [program_category]
      ,isNull([ev_subject_description], '') as [ev_subject_description]
      ,isNull([ev_remarks], '') as [ev_remarks]
      ,isNull([cancellation_reason_cd], '') as [cancellation_reason_cd]
      ,isNull([termination_reason_cd], '') as [termination_reason_cd]
      ,isNull([other_termination_reason], '') as [other_termination_reason]
      ,isNull([effective_date], '') as [effective_date]
      ,isNull([remarks], '') as [remarks]
      ,isNull([session_start_date], '') as [session_start_date]
      ,isNull([ev_received_funding_from_us_government], '') as [ev_received_funding_from_us_government]
      ,isNull([ev_amount_of_funding_from_program_sponsor], '') as [ev_amount_of_funding_from_program_sponsor]
      ,isNull([ev_us_government_organization1_funding], '') as [ev_us_government_organization1_funding]
      ,isNull([ev_amount_from_us_government_organization1], '') as [ev_amount_from_us_government_organization1]
      ,isNull([ev_international_organization1_funding], '') as [ev_international_organization1_funding]
      ,isNull([ev_amount_from_international_organization1], '') as [ev_amount_from_international_organization1]
      ,isNull([ev_amount_from_foreign_govt], '') as [ev_amount_from_foreign_govt]
      ,isNull([ev_amount_from_biational_commission], '') as [ev_amount_from_biational_commission]
      ,isNull([ev_other_funding_name], '') as [ev_other_funding_name]
      ,isNull([ev_other_funding_amount], '') as [ev_other_funding_amount]
      ,isNull([ev_total_amout_of_personal_funding], '') as [ev_total_amout_of_personal_funding]
      ,isNull([ev_us_government_organization_funding], '') as [ev_us_government_organization_funding]
      ,isNull([ev_amount_from_us_government_organization], '') as [ev_amount_from_us_government_organization]
      ,isNull([ev_international_organization_funding], '') as [ev_international_organization_funding]
      ,isNull([ev_amount_from_international_organization], '') as [ev_amount_from_international_organization]
      ,isNull([reason_for_extension], '') as [reason_for_extension]
      ,isNull([shorten_reason_cd], '') as [shorten_reason_cd]
      ,isNull([custom1], '') as [custom1]
      ,isNull([custom2], '') as [custom2]
      ,isNull([custom3], '') as [custom3]
      ,isNull([custom4], '') as [custom4]
      ,isNull([custom5], '') as [custom5]
      ,isNull([custom6], '') as [custom6]
      ,isNull([custom7], '') as [custom7]
      ,isNull([custom8], '') as [custom8]
      ,isNull([custom9], '') as [custom9]
      ,isNull([custom10], '') as [custom10]
      ,isNull([custom11], '') as [custom11]
      ,isNull([custom12], '') as [custom12]
      ,isNull([custom13], '') as [custom13]
      ,isNull([custom14], '') as [custom14]
      ,isNull([custom15], '') as [custom15]
      ,isNull([custom16], '') as [custom16]
      ,isNull([custom17], '') as [custom17]
      ,isNull([custom18], '') as [custom18]
      ,isNull([custom19], '') as [custom19]
      ,isNull([custom20], '') as [custom20]
      ,isNull([custom21], '') as [custom21]
      ,isNull([custom22], '') as [custom22]
      ,isNull([custom23], '') as [custom23]
      ,isNull([custom24], '') as [custom24]
      ,isNull([custom25], '') as [custom25]
      ,isNull([custom26], '') as [custom26]
      ,isNull([custom27], '') as [custom27]
      ,isNull([custom28], '') as [custom28]
      ,isNull([custom29], '') as [custom29]
      ,isNull([custom30], '') as [custom30]
      ,isNull([custom31], '') as [custom31]
      ,isNull([custom32], '') as [custom32]
      ,isNull([custom33], '') as [custom33]
      ,isNull([custom34], '') as [custom34]
      ,isNull([custom35], '') as [custom35]
      ,isNull([custom36], '') as [custom36]
      ,isNull([custom37], '') as [custom37]
      ,isNull([custom38], '') as [custom38]
      ,isNull([custom39], '') as [custom39]
      ,isNull([custom40], '') as [custom40]
      ,isNull([custom41], '') as [custom41]
      ,isNull([custom42], '') as [custom42]
      ,isNull([custom43], '') as [custom43]
      ,isNull([custom44], '') as [custom44]
      ,isNull([custom45], '') as [custom45]
      ,isNull([custom46], '') as [custom46]
      ,isNull([custom47], '') as [custom47]
      ,isNull([custom48], '') as [custom48]
      ,isNull([custom49], '') as [custom49]
      ,isNull([custom50], '') as [custom50]

  FROM [dbo].[tdt_terradotta_student_integration]

GO

