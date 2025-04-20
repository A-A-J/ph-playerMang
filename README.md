# ph-playerMang
سكربت **ph-playerMang** هو إضافة مخصصة لنظام **QBCore** في لعبة **FiveM**، يهدف إلى إدارة خدمات اللاعبين من خلال إيقاف أو استئناف خدماتهم بناءً على شروط معينة. يوفر السكربت واجهة سهلة الاستخدام لإدارة العقوبات المتعلقة بالخدمات في اي سكربت آخر..

---

## طريق الاستخدام
### لتحقق من ايقاف اللاعب لاي سكربت مثل البنك بسكربت آخر
```
local checkPlayerMang = exports["ph-playerMang"]:IsPlayerBannedFromServices(source)
if checkPlayerMang == true then
    return TriggerClientEvent('QBCore:Notify', src, "لديك ايقاف خدمات لايمكنك اتمام علمية الشراء للاسف", "error")
end
```

### لاضافة ايقاف خدمات على لاعب بسكربت آخر
```
local success = exports["ph-playerMang"]:AddPlayerToBanList(source, "reason", 2025-01-01)
if success then
    return TriggerClientEvent('QBCore:Notify', src, "تم ايقاف خدماتك", "error")
end
```

### لفك الخدمات عن لاعب بسكربت آخر
```
local success = exports["ph-playerMang"]:RemovePlayerFromBanList(source)
if success then
    return TriggerClientEvent('QBCore:Notify', src, "تم فك إيقاف خدماتك", "success")
end
```