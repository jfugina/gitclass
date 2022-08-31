select * from Decal_Type
order by entry_date desc

select * from decal_type_Proration
order by entry_date desc

where entry_By = 'JAF'
order by decal_type_key, type


select * from decal_type where entry_by = 'JAF' and entry_date > '2/1/2021'

select * from decal_type order by decal_type_key



select * from ParkingPermits.dbo.WUTMP_DecalTypes
select * from ParkingPermits.dbo.WUTMP_DecalTypeProrations
select * from ParkingPermits.dbo.WUTMP_PermitPeopleGroups
--delete from ParkingPermits.dbo.WUTMP_PermitPeopleGroups where isNull(online, 'N') = 'N'


--don't load this - just compare the two and make the appropriate updates
 select * from ParkingPermits.dbo.validParkingOptions order by 2
-- insert into ValidParkingOptions (id, ParkingOption, Description, OrderOfAppearance, CapMaximum, NumberPurchased, Active, Visible, CreateDate)
select dt.decal_type_key, pg.PermitDesc, pg.AccessDesc, 0, isNull(OnlineCap, 10000), 0, 1, 1, getdate()
from ParkingPermits.dbo.WUTMP_PermitPeopleGroups pg
join CTI_GLOBAL.dbo.decal_Type dt on dt.code = pg.DecalID COLLATE DATABASE_DEFAULT
order by 2

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

 select * from decal_Type_Proration
 where entry_time > '2/20/2021'



 -- next step - get the decal type keys for the new year updated in the ParkingPermits.PermitMapping table
 -- note:  some may not match by name.  Spaces and such will need to be manually corrected, and some decal_type_key values may need to be manually updated
select pm.*, dt.description, dt.decal_type_key
from ParkingPermits.dbo.PermitMapping pm left outer join decal_type dt 
 on dt.Description = pm.TTDescription COLLATE DATABASE_DEFAULT and dt.Active_Date >= '2021/08/01' COLLATE DATABASE_DEFAULT

--update ParkingPermits.dbo.PermitMapping set TTDecalTypeKey = dt.decal_type_key
from ParkingPermits.dbo.PermitMapping pm join decal_type dt 
 on dt.Description = pm.TTDescription COLLATE DATABASE_DEFAULT and dt.Active_Date >= '2021/08/01' COLLATE DATABASE_DEFAULT

 --now manually go back and figure out which type keys are out of sync and manually fill in.
 select * from ParkingPermits.dbo.PermitMapping -- note:  ParkingOptionId 24 is used for both Parksmart reduced and OPP Zone 1.  Why?  The fix was to add a parking option (31) and re-map.


 --Manually edit the values in these tables for the new year
select * from ParkingPermits.dbo.ValidParkingOptions -- note, had to add a row for parksmart because of referencial integrity with the mapping table.  Manual fix.
-- update ValidParkingOptions to set numberPurchased back to zero?  Do the caps need to be udpated?
select * from ParkingPermits.dbo.ValidDeliveryOptions -- 6 rows, just review description text, and active/visible
select * from ParkingPermits.dbo.ValidPaymentOptions -- 8 rows, confirm/review for new year
select * from ParkingPermits.dbo.ValidPermitRequestStatus -- 4 rows, likely unchanged
select * from ParkingPermits.dbo.ValidUserTypes -- 13 rows.  Should not have changed for 2021, but confirm

select * from ParkingPermits.dbo.UserTypePaymentOptions -- link between user types and payment options.  Confirm if there are changes, manual update if needed.
-- update and set active = 0
	where validUserTypeId not in (select id from ParkingPermits.dbo.ValidUserTypes where IsNull(active, 1) = 1)
	where validPaymentOptionId not in (select id from ParkingPermits.dbo.ValidPaymentOptions where active = 1)
	
select * from ParkingPermits.dbo.UserTypeDeliveryOptions-- link between user types and delivery options - should not require changes
 -- update and set Active = 0
	where validUserTypeId not in (select id from ParkingPermits.dbo.ValidUserTypes where IsNull(active, 1) = 1)
	where validDeliveryOptionId not in (select id from ParkingPermits.dbo.ValidDeliveryOptions where active = 1) -- or option is inactive

--shows pricing for parkingOptions.  Link to PermitMappingId - this is decalType.code.  Struggling with this table.  Why is purchase Price and price text different? 
-- it does not appear that the pricing values are consumed from this table, so hopefully it's fine.  The new pricing is in the prorations table. 
-- This table will get updated with the correct decal type code in CTI_GLOBAL.decal_types
select * from ParkingPermits.dbo.UserTypeParkingOptions 
--where PurchasePrice <> cast(PurchasePriceText as numeric(10,2))

select * from ParkingPermits.dbo.ValidParkingOptions 
where id not in (select ValidParkingOptionId from ParkingPermits.dbo.UserTypeParkingOptions)

--step 1 will be to sync the permitmappingid with the correct code for the new decal types.
--step 2 will be to update the prices with the new year info
--Based on the code search, it doesn't look like pricing or Permit Mapping is used from this table.  It's used from prorations.
-- But get it synced up anyway.
select utpo.ValidUserTypeId, utpo.ValidParkingOptionId, utpo.PurchasePrice, utpo.PurchasePriceText, utpo.PermitMappingId, dt.code, dt.fee, pm.*--vpo.*
from ParkingPermits.dbo.UserTypeParkingOptions utpo
--join ParkingPermits.dbo.ValidParkingOptions vpo on vpo.id = utpo.ValidParkingOptionId
join ParkingPermits.dbo.PermitMapping pm on pm.ParkingOptionId = utpo.ValidParkingOptionId
join decal_type dt on dt.decal_type_key = pm.TTDecalTypeKey
--join decal_type dt on dt.code = cast(utpo.PermitMappingId as varchar(5))
order by dt.code


--Step 1 - update the new year decal codes.  I don't think this is ever used, because they're not correct in the prior year, and the data types between tables don't match.
--update ParkingPermits.dbo.UserTypeParkingOptions set permitMappingId = cast(left(dt.code,4) as int) /*decided to update to key, because codes aren't correct without letters */
-- update ParkingPermits.dbo.UserTypeParkingOptions set permitMappingId = pm.TTDecalTypeKey
from ParkingPermits.dbo.UserTypeParkingOptions utpo
join ParkingPermits.dbo.PermitMapping pm on pm.ParkingOptionId = utpo.ValidParkingOptionId
--join decal_type dt on dt.decal_type_key = pm.TTDecalTypeKey
--Step2 (didn't do, because I don't think those values are ever pulled from here.  If anything, set them to zero for the new year)

--Last thing - ProRatedPermitPrices (used for caching, to enhance performance)
--now we need to update the prorated permit prices for the new year in the ParkingPermits database
--for 2021, there should be 26 of these.  Join the parking option to the permit mapping to get to the DecalTypeKey
-- With the detailTypeKey, pull in the prorated pricing to the 

--Pull this year's issue prorations from TT and update the period text
 create table #Prorations (decal_type_key int, begin_date smalldatetime, end_date smalldatetime, dollar_value money, PeriodText varchar(20))
 insert into #Prorations (decal_type_key, begin_date, end_date, dollar_value)
 select decal_type_key, begin_date, end_date, dollar_value from Decal_Type_Proration 
  where Entry_date > '3/1/2021'
  and type = 'I'

update #Prorations set PeriodText = format(end_date, 'MMMM ') + cast(datepart(YYYY, end_date) as char(4))
select * from #Prorations

/*
-- cross-check and update.
-- re-think - too difficult to cross-check.  Just re-insert with the new values from the spreadsheet
 select ppp.ValidParkingOptionId,  ppp.UserTypeParkingOptionId,  ppp.Description,  ppp.PeriodName,  ppp.StartDate,  ppp.EndDate,  ppp.PurchasePrice, 
	case ut.id when 11 then (dtp.dollar_value/2) else dtp.dollar_value end as 'currentYearAmt', ut.id, ut.UserType
-- update ParkingPermits.dbo.ProratedPermitPrices set PurchasePrice = case ut.id when 11 then (dtp.dollar_value/2) else dtp.dollar_value end, StartDate = dtp.begin_date, EndDate = dtp.End_date
 from ParkingPermits.dbo.ProratedPermitPrices ppp
 join ParkingPermits.dbo.UserTypeParkingOptions utpo on utpo.id = ppp.UserTypeParkingOptionId
 join ParkingPermits.dbo.ValidUserTypes ut on ut.id = utpo.ValidUserTypeId
 join ParkingPermits.dbo.PermitMapping pm on pm.ParkingOptionId = ppp.ValidParkingOptionId
 join #Prorations dtp on dtp.Decal_Type_Key = pm.TTDecalTypeKey and left(dtp.PeriodText, 5) = left(ppp.PeriodName, 5)
 where ppp.UserTypeParkingOptionId <> 62 -- this one is all messed up - looks like they did some strange single semester pricing for the first term.  Update group manually
-- and ppp.PurchasePrice <> case ut.id when 11 then (dtp.dollar_value/2) else dtp.dollar_value end
 order by validParkingOptionId, StartDate, userTypeParkingOptionId
 */

 --truncate table ParkingPermits.dbo.ProRatedPermitPrices
-- insert into ParkingPermits.dbo.ProRatedPermitPrices(ValidParkingOptionId, UserTypeParkingOptionId, Description, PeriodName, StartDate, EndDate, PurchasePrice, PurchasePriceText, Tier1Price, Tier1PriceText, Active, isDefault)
  select ValidparkingOptionId, id, dt.Description, p.PeriodText, p.Begin_date, p.end_date, dollar_value, dollar_value, dollar_Value, dollar_value, 1, case when dt.fee=dollar_value then 1 else 0 end
 from parkingPermits.dbo.UserTypeParkingOptions  utpo
 join decal_type dt on dt.decal_type_key = utpo.PermitMappingId
 join #Prorations p on p.decal_type_key = utpo.PermitMappingId
 order by ValidParkingOptionId, id, begin_date

 select * from ParkingPermits.dbo.ProratedPermitPrices 

 
 select * from #Prorations

 --update ParkingPermits.dbo.ProratedPermitPrices set PeriodName = replace(PeriodName, '2021', '2022')
 --update ParkingPermits.dbo.ProratedPermitPrices set PeriodName = replace(PeriodName, '2020', '2021')
 --*TODO Still*:  Update the PurchasePriceText and Tier1Price/Text

 select *
 --distinct ValidParkingOptionId, PeriodName, PurchasePrice, PurchasePriceText
 from ParkingPermits.dbo.ProRatedPermitPrices

 select * from Decal_type where entry_date > '2/1/2021'
