select * from ParkingPermits.dbo.PermitRequest order by id desc

select * from Online_Permits
order by trans_key desc

alter procedure jaf_ClearTestPermitRequests @sisoremplid varchar(6), @personRole char(1)
as 
begin
	
	declare @personKey int
	select @personKey = person_key 
	from person_main 
	where tt_person_type = @PersonRole and local_id = @sisoremplid


	delete ParkingPermits.dbo.PermitRequest where personKey = @personKey
	delete Online_Permits where person_key = @personKey and entry_date > '2021-03-01'

end


jaf_ClearTestPermitRequests '115558', 'E'

/*
delete online_Permits
where entry_Date > '3/15/2021'
--where trans_key in (61448)
delete ParkingPermits.dbo.PermitRequest where trans_key = (61449)
*/

select * from person_main where local_id = '115558'

update person_main 
set User_Defined1 = 'PT Active STAF', User_defined4 = 'Danforth'
where local_id = '115558'


select * from person_main where local_id = '448547'

select * from ParkingPermits.dbo.AuditActions order by ActionDate desc



select top 10 *  
FROM [dbo].[atv_parking_lottery_stdt_info] sis
	--FROM [dbo].[atv_parking_lottery_stdt_info] sis
	WHERE isLoftshousing = 'Y'

431977

-- SIS Override
--Aspen Small
if (@EmpOrSisId='448547')
BEGIN
	set @UserType='STDT_UGL'
END
--Jakob Braunschweiger
if (@EmpOrSisId='466081') -- use 473276, Kayleigh Lewis
BEGIN
	set @UserType='STDT_UGV'
END
--Jordan Weinrich
if (@EmpOrSisId='486824')
BEGIN
	set @UserType='STDT_UGC'
END
-- Mackenzie Hines-Wilson
if (@EmpOrSisId='446573') -- this one is OK if we test with last year.
BEGIN
	set @UserType='STDT_UG40'
END

select * from person_main where local_id = '473276'
select distinct user_defined1 from person_main

select * from person_main where user_defined1 = 'PT Active STAF' and user_defined4 = 'Danforth'

update person_main set user_defined1 = 'PT Active STAF', user_defined4 = 'Danforth'
where local_id = '341553'

select pm.person_key, pm.local_id, last_name, first_name, user_defined1, user_defined4, pa.*
from person_main pm
join person_additional pa on pa.person_key = pm.person_key
where user_defined1 = 'PT Active STAF' and user_defined4 = 'Danforth'
and pm.person_key = 182187


select * from WD_INT037_Workers where emplid = '368720'

select * from person_main where person_key = 182187


select * from wphr0051 where emplid = '369261' -- this is the Tier1 test case for legacy HR.  Make sure that the parksmart reduced works.



select * from WPHR0051 where [empl status] = 'R'

use cti_global
use ParkingPermits

-- XREF for User Payment Options
select utpo.id, ut.userType, po.PaymentOption, po.Active as 'OptionIsActive', po.Visible as 'OptionIsVisible', utpo.Active as 'xrefActive',utpo.visible as 'xrefVisible'
from UserTypePaymentOptions utpo
join ValidUserTypes ut on ut.id = utpo.ValidUserTypeId
join ValidPaymentOptions po on po.id = utpo.ValidPaymentOptionId
order by UserType, PaymentOption

-- delivery options
select utdo.id, ut.userType, do.DeliveryOption, do.Active as 'OptionIsActive', do.Visible as 'OptionIsVisible', utdo.Active as 'xrefActive',utdo.visible as 'xrefVisible'
from UserTypeDeliveryOptions utdo
join ValidUserTypes ut on ut.id = utdo.ValidUserTypeId
join ValidDeliveryOptions do on do.id = utdo.ValidDeliveryOptionId
order by UserType, DeliveryOption

--XREF for User ParkingOptions
select utpo.id, ut.userType, po.ParkingOption, po.Active as 'OptionIsActive', po.Visible as 'OptionIsVisible', utpo.Active as 'xrefActive',utpo.visible as 'xrefVisible'
from UserTypeParkingOptions utpo
join ValidUserTypes ut on ut.id = utpo.ValidUserTypeId
join ValidParkingOptions po on po.id = utpo.ValidParkingOptionId
order by UserType, ParkingOption
