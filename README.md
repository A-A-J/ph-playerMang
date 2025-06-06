![Image](https://cdn.discordapp.com/attachments/1345919818435526780/1345919819005825136/image.png?ex=68438b82&is=68423a02&hm=a81ed75f5c59bce916d7b1fe0554ddbf63f3c0199f84230238636d5f7382d49b&)


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
