
select * from ParkingPermits.dbo.WUTMP_DecalTypes
select * from ParkingPermits.dbo.WUTMP_DecalTypeProrations
select * from ParkingPermits.dbo.WUTMP_PermitPeopleGroups
--delete from ParkingPermits.dbo.WUTMP_PermitPeopleGroups where isNull(online, 'N') = 'N'

-- LOAD DECAL TYPES - note:  may need to change a few things to overwrite nulls ------
insert into Decal_type (code, description, lot, active_date, expiration_days, expiration_date, expiration_code, fee,
    temp_permit, sun, mon, tue, wed, thu, fri, sat, entry_by, entry_date, product_source, inactive)
select code, description, lot, Active_Date, Expiration_Days, Expiration_Date, Expiration_Code, Fee,
    'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'JAF', GETDATE(), 'TTW', 'N'
 from ParkingPermits.dbo.WUTMP_DecalTypes
 WHERE code is not null

insert into decal_type_proration (decal_type_key, begin_date, end_date, type, dollar_value, Percent_value, entry_by, entry_date, entry_time, product_source)
  select dt.decal_type_key,
 cast( pt.Begin_Date as date),
 cast (pt.End_Date as date),
 'I',
 pt.Dollar_Value,
 ((pt.Dollar_Value/dt.fee) * 100) as value,
 'JAF',
 getdate(),
 getdate(),
 'TTW'
  from decal_type dt
 join ParkingPermits.dbo.WUTMP_DecalTypes dti on dti.code = dt.code COLLATE DATABASE_DEFAULT
 join ParkingPermits.dbo.WUTMP_DecalTypeProrations pt on pt.Code = dti.Code COLLATE DATABASE_DEFAULT
 where pt.Type = 'I'


 insert into decal_type_proration (decal_type_key, begin_date, end_date, type, dollar_value, Percent_value, entry_by, entry_date, entry_time, product_source)
  select dt.decal_type_key,
 cast( pt.Begin_Date as date),
 cast (pt.End_Date as date),
 'R',
 pt.Dollar_Value,
 ((pt.Dollar_Value/dt.fee) * 100) as value,
 'JAF',
 getdate(),
 getdate(),
 'TTW'
 from decal_type dt
 join ParkingPermits.dbo.WUTMP_DecalTypes dti on dti.code = dt.code COLLATE DATABASE_DEFAULT
 join ParkingPermits.dbo.WUTMP_DecalTypeProrations pt on pt.Code = dti.Code COLLATE DATABASE_DEFAULT
 where pt.type = 'R'

--1. Load ValidParkingOptions from People Group matrix.  ID is not an identity, so use the decal type
 select * from validParkingOptions order by 2
-- truncate table ValidParkingOptions
-- insert into ValidParkingOptions (id, ParkingOption, Description, OrderOfAppearance, CapMaximum, NumberPurchased, Active, Visible, CreatedDate)
select dt.decal_type_key, left(pg.PermitDesc, 64), left(pg.AccessDesc, 512), ROW_NUMBER() OVER(ORDER BY pg.DecalID), isNull(OnlineCap, 10000), 0, 1, 1, getdate()
from ParkingPermits.dbo.WUTMP_PermitPeopleGroups pg
join CTI_GLOBAL.dbo.decal_Type dt on dt.code = pg.DecalID COLLATE DATABASE_DEFAULT


--2. Load Relateds
select * from PermitMapping -- id is an identity column
-- truncate table PermitMapping
insert into PermitMapping(ParkingOptionId, ParkingOptionDesc, TTDecalTypeKey, TTDescription, Active)
select id, ParkingOption, id, dt.description, 1
 from ValidParkingOptions vpo 
 join CTI_GLOBAL.dbo.Decal_Type dt on dt.decal_type_key = vpo.id

--2.1 
select * from ParkingPermits.dbo.UserTypeParkingOptions -- this is where we have to do a pivot table.  No identity ID???
--select * from ParkingPermits.dbo.ValidUserTypes -- this didn't really change
-- start here.  Would need to turn identity on.  And need to come back and fill in OrderOfAppearance
insert into userTypeParkingOptions (ValidUserTypeId, ValidParkingOptionId, OrderOfAppearance, PurchasePrice, PurchasePriceText, Tier1Price, Tier1PriceText, Active, visible, PermitMappingId)
select ut.id, dt.decal_type_key, 0, dt.fee, dt.fee, dt.fee, dt.fee, 1,1, ut.id
--select dt.decal_type_key, decalId, PersonGrp, ut.id, ut.UserType, checked
from
  (select decalId, empl_ht, empl_wc, stdt_g, stdt_ugc, stdt_ug40, empl_ht_p, empl_wc_p, stdt_ugl, empl_nc, empl_nc_p, empl_r, stdt_ugv 
  from ParkingPermits.dbo.WUTMP_PermitPeopleGroups) p
unpivot
	(checked for personGrp in (empl_ht, empl_wc, stdt_g, stdt_ugc, stdt_ug40, empl_ht_p, empl_wc_p, stdt_ugl, empl_nc, empl_nc_p, empl_r, stdt_ugv )
	) as unpvt
join cti_global.dbo.decal_type dt on dt.code = unpvt.decalId COLLATE DATABASE_DEFAULT
left outer join ParkingPermits.dbo.ValidUserTypes ut on ut.UserType = unpvt.PersonGrp
where checked = 'X'

--ProRatedPermitPrices (repeated from UTPO)
create table #Prorations (decal_type_key int, begin_date smalldatetime, end_date smalldatetime, dollar_value money, PeriodText varchar(20))
 insert into #Prorations (decal_type_key, begin_date, end_date, dollar_value)
 select decal_type_key, begin_date, end_date, dollar_value from Decal_Type_Proration 
  where Entry_date > '3/1/2021'
  and type = 'I'

update #Prorations set PeriodText = format(end_date, 'MMMM ') + cast(datepart(YYYY, end_date) as char(4))
select * from #Prorations

 --truncate table ParkingPermits.dbo.ProRatedPermitPrices
-- insert into ParkingPermits.dbo.ProRatedPermitPrices(ValidParkingOptionId, UserTypeParkingOptionId, Description, PeriodName, StartDate, EndDate, PurchasePrice, PurchasePriceText, Tier1Price, Tier1PriceText, Active, isDefault)
  select ValidparkingOptionId, id, dt.Description, p.PeriodText, p.Begin_date, p.end_date, dollar_value, dollar_value, dollar_Value, dollar_value, 1, case when dt.fee=dollar_value then 1 else 0 end
 from parkingPermits.dbo.UserTypeParkingOptions  utpo
 join decal_type dt on dt.decal_type_key = utpo.PermitMappingId
 join #Prorations p on p.decal_type_key = utpo.PermitMappingId
 order by ValidParkingOptionId, id, begin_date

 select * from ParkingPermits.dbo.ProratedPermitPrices 

--UserTypeDeliveryOptions -- no identity
select * from ParkingPermits.dbo.UserTypeDeliveryOptions
insert into UserTypeDeliveryOptions (ValidUserTypeId, ValidDeliveryOptionId, OrderOfAppearance, Active, Visible)
-- On the matrix - Res Life for undergrad residents (3 of these); USMail for all but frats

--UserTypePaymentOptions - confirm against matrix.  Only three options.

select t.name, c.name from sysobjects t join syscolumns c on t.id = c.id
where c.name like '%ParkingOption%'

