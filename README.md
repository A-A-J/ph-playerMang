![Image](https://media.discordapp.net/attachments/1320802774950346762/1363598388192481370/image.png?ex=68069d76&is=68054bf6&hm=ef04ece59185e9a05fb59bc06cb0ab054d89c30c2415ef04ef9c7f8494fa52ca&=&format=webp&quality=lossless&width=1172&height=821)


## 📁 ph-playerMang
The **ph-playerMang** script is a custom addon for the **QBCore** framework in **FiveM**, designed to manage player services by suspending or resuming them based on specific conditions. The script provides a user-friendly interface for managing service-related penalties in any other script.


## ✨ Features
- **Multiple Service Suspensions:** Administrators can suspend players' services across various sectors, including banks, garages, restaurants, showrooms, and jobs.
- **Integrated Management:** Enables adding, modifying, or removing service suspensions, with tracking of details like the reason and the date of lifting the suspension.
- **Automated Management:** If a player's bank balance falls below -1000 dollars, the system automatically suspends their services.
- **Protection for Critical Jobs:** Certain jobs, such as police, paramedics, and judges, can be exempted from service suspensions.


## 👨‍🏫 Usage Guide
### To integrate the script into qb-management
Use the event `ph-playerMang:client:openMenu` based on critical functions such as police or court.

### Example ([qb-management](https://github.com/qbcore-framework/qb-management/blob/3375d488002e098c0486ed203c5b955d45065bee/client/cl_boss.lua#L84))
```
RegisterNetEvent('qb-bossmenu:client:OpenMenu', function()
    if PlayerJob.name == 'police' then
        table.insert(bossMenu, {
            header = 'Citizen Services Administration',
            params = {
                event = 'ph-playerMang:client:openMenu',
            }
        })
    end
end)
```
#

### To check if a player is banned from services in another script (e.g., bank)
```
local checkPlayerMang = exports["ph-playerMang"]:IsPlayerBannedFromServices(source)
if checkPlayerMang == true then
    return TriggerClientEvent('QBCore:Notify', src, "You have a service suspension and cannot complete the purchase, sorry", "error")
end
```

#

### To add a service ban to a player in another script
```
local success = exports["ph-playerMang"]:AddPlayerToBanList(source, "reason", 2025-01-01)
if success then
    return TriggerClientEvent('QBCore:Notify', src, "Your services have been suspended", "error")
end
```

#

### To remove a service ban from a player in another script
```
local success = exports["ph-playerMang"]:RemovePlayerFromBanList(source)
if success then
    return TriggerClientEvent('QBCore:Notify', src, "Your service suspension has been lifted", "success")
end
```


### 📞 call me
[Discord: Hudhali](https://discord.com/users/927741280946094131)
