---@diagnostic disable: assign-type-mismatch, undefined-global
local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

function addTimeToDate(timeBand)
    local currentTime = os.time()
    local number, unit = timeBand:match("^(%d+)(%a+)$")
    number = tonumber(number)
    if unit == "d" then
        currentTime = currentTime + (number * 24 * 60 * 60)
    elseif unit == "w" then
        currentTime = currentTime + (number * 7 * 24 * 60 * 60)
    elseif unit == "m" then
        currentTime = currentTime + (number * 30 * 24 * 60 * 60)
    elseif unit == "y" then
        currentTime = currentTime + (number * 365 * 24 * 60 * 60)
    else
        currentTime = currentTime + (1 * 24 * 60 * 60)
    end
    return os.date("%Y-%m-%d", currentTime)
end

--- CreateCallbacks

QBCore.Functions.CreateCallback('ph-playerMang:server:uploadPlayerOff', function(source, cb, input)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(false) end

    local citizenid = input.cid
    local off_date = input.date
    local reason = input.reason
    local by_player = Player.PlayerData.citizenid
    
    local checkPlauerInDataOrNo = MySQL.query.await('SELECT citizenid FROM player_services WHERE citizenid = ?', { citizenid })
    if checkPlauerInDataOrNo and #checkPlauerInDataOrNo > 0 then
        return TriggerClientEvent('QBCore:Notify', src, "اللاعب موقوف مسبقًا..", "error")
    end

    MySQL.insert('INSERT INTO player_services (citizenid, off_date, reason, by_player) VALUES (?, ?, ?, ?)', {
        citizenid,
        off_date,
        reason,
        by_player
    },
    function(row) if row > 0 then return cb(true) end cb(false) end)
end)

QBCore.Functions.CreateCallback('ph-playerMang:server:getPlayersOff', function(source, cb, id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(false) end
    MySQL.query('SELECT * FROM player_services', {}, function(result)
        if #result == 0 then return cb(false) end
        for i, value in ipairs(result) do
            local playerGET = QBCore.Functions.GetPlayerByCitizenId(value.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(value.citizenid) or value.citizenid
            local playerBy = QBCore.Functions.GetPlayerByCitizenId(value.by_player) or QBCore.Functions.GetOfflinePlayerByCitizenId(value.by_player) or 'Bank'
            if playerGET.PlayerData then
                value.name = string.format("%s %s", playerGET.PlayerData.charinfo.firstname,playerGET.PlayerData.charinfo.lastname)
            end
            value.by_player = playerBy == 'Bank' and 'Bank' or string.format("%s %s", playerBy.PlayerData.charinfo.firstname,playerBy.PlayerData.charinfo.lastname)
            value.off_date = os.date("%Y-%m-%d", value.off_date/1000)
        end
        cb(result)
    end)
end)

QBCore.Functions.CreateCallback('ph-playerMang:server:editServiceSuspensionSave', function(source, cb, input)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(false) end
    local citizenid = input.cid
    local off_date = input.date -- os.date('%Y-%m-%d', math.floor(input[2] / 1000))
    local reason = input.reason
    MySQL.query('SELECT * FROM player_services WHERE citizenid = ?', {citizenid}, function(result)
        if #result == 0 then return cb(false) end
        MySQL.query('UPDATE player_services SET off_date = ?, reason = ? WHERE citizenid = ?', {
            off_date,
            reason,
            citizenid
        }, function(row) if row.affectedRows > 0 then return cb(true) end cb(false) end)
    end)
end)

QBCore.Functions.CreateCallback('ph-playerMang:server:removeServiceSuspension', function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(false) end
    local citizenid = data[1].citizenid
    MySQL.query('SELECT citizenid FROM player_services WHERE citizenid = ?', { citizenid }, function(result)
        if #result == 0 then return cb(false) end
        MySQL.query('DELETE FROM player_services WHERE citizenid = ?', { citizenid }, function(row) if row.affectedRows > 0 then return cb(true) end cb(false) end)
    end)
end)

-- Exports

exports('IsPlayerBannedFromServices', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local citizenid = Player.PlayerData.citizenid
    if Config.BannedPlayers[citizenid] then
        return true
    end

    local result = MySQL.query.await('SELECT citizenid FROM player_services WHERE citizenid = ?', { citizenid })
    return result and #result > 0
end)
-- -- Example
-- local checkPlayerMang = exports["ph-playerMang"]:IsPlayerBannedFromServices(source)
-- if checkPlayerMang == true then
--     return TriggerClientEvent('QBCore:Notify', src, "لديك ايقاف خدمات لايمكنك اتمام علمية الشراء للاسف", "error")
-- end

exports('AddPlayerToBanList', function(source, note, customDate)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    local citizenid = Player.PlayerData.citizenid
    local by_player = citizenid
    local reason = note
    local off_date = customDate -- customDate and os.date('%Y-%m-%d', math.floor(customDate / 1000)) or os.date('%Y-%m-%d', os.time() + (30 * 24 * 60 * 60))
    local existingPlayer = MySQL.query.await('SELECT citizenid FROM player_services WHERE citizenid = ?', { citizenid })
    if existingPlayer and #existingPlayer > 0 then
        return false
    end
    local row = MySQL.insert.await('INSERT INTO player_services (citizenid, off_date, reason, by_player) VALUES (?, ?, ?, ?)', { citizenid, off_date, reason, by_player })
    return row > 0
end)

-- ---Example
-- local success = exports["ph-playerMang"]:AddPlayerToBanList(source, "reason", 2025-01-01)
-- if success then
--     return TriggerClientEvent('QBCore:Notify', src, "تم ايقاف خدماتك", "error")
-- end
-- ---

exports('RemovePlayerFromBanList', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    local citizenid = Player.PlayerData.citizenid
    local existingPlayer = MySQL.query.await('SELECT citizenid FROM player_services WHERE citizenid = ?', { citizenid })
    if not existingPlayer or #existingPlayer == 0 then return false end
    MySQL.query.await('DELETE FROM player_services WHERE citizenid = ?', { citizenid })
end)
-- ---Example
-- local success = exports["ph-playerMang"]:RemovePlayerFromBanList(source)
-- if success then
--     return TriggerClientEvent('QBCore:Notify', src, "تم فك إيقاف خدماتك", "success")
-- end
-- ---

-- CreateThread

CreateThread(function()
    while true do
        Wait(5000)
        local players = QBCore.Functions.GetPlayers()
        for _, playerId in pairs(players) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player then
                local citizenid = Player.PlayerData.citizenid
                local bankBalance = Player.PlayerData.money.bank
                -- [[local cashPlayer = Player.PlayerData.money.cash]] --- لتحقق من الكاش
                local job = Player.PlayerData.job.name
                local grade = Player.PlayerData.job.grade.level
                local src = playerId

                if Config.BannedPlayers[citizenid] then goto continue end

                if Config.ExemptJobs[job] then
                    for _, allowedGrade in ipairs(Config.ExemptJobs[job]) do
                        if grade == allowedGrade then
                            goto continue
                        end
                    end
                end

                local result = MySQL.query.await('SELECT * FROM player_services WHERE citizenid = ?', { citizenid })
                if result and #result > 0 then
                    local playerData = result[1]
                    local offDateTimestamp = tonumber(result[1].off_date) or 0
                    offDateTimestamp = offDateTimestamp / ((offDateTimestamp > 9999999999) and 1000 or 1)
                    if playerData.by_player == "AUTO_SYSTEM" and bankBalance >= 0 --[[ (bankBalance >= 0 or cashPlayer >= 0) ]] then
                        MySQL.query.await('DELETE FROM player_services WHERE citizenid = ?', { citizenid })
                        TriggerClientEvent('QBCore:Notify', src, "تم ازالة ايقاف الخدمات من البنك", "success")
                    elseif os.time() > offDateTimestamp then
                        MySQL.query.await('DELETE FROM player_services WHERE citizenid = ?', { citizenid })
                        TriggerClientEvent('QBCore:Notify', src, "تم إزالة إيقاف الخدمات لانتهاء المدة المحددة", "success")
                    end
                else
                    if bankBalance <= Config.BankMoney --[[or cashPlayer <= Config.CashPlayer--]] then
                        local reason = Config.ReasonBankOrCash
                        local off_date = os.date('%Y-%m-%d', os.time() + (30 * 24 * 60 * 60))
                        local by_player = "AUTO_SYSTEM"
                        MySQL.insert('INSERT INTO player_services (citizenid, off_date, reason, by_player) VALUES (?, ?, ?, ?)',
                            { citizenid, off_date, reason, by_player })
                        TriggerClientEvent('QBCore:Notify', src, "تم ايقاف خدماتك من البنك", "error")
                    end
                end
                ::continue::
            end
        end
    end
end)

-- Register

QBCore.Functions.CreateCallback('ph-playerMang:IsPlayerBanned', function(source, cb)
    local isBanned = exports['ph-playerMang']:IsPlayerBannedFromServices(source)
    cb(isBanned)
end)

QBCore.Functions.CreateCallback('ph-playerMang:addPlayerFromBanList', function(source, cb, reason, customDate)
    cb(exports['ph-playerMang']:AddPlayerToBanList(source, reason, addTimeToDate(customDate)))
end)

QBCore.Functions.CreateCallback('ph-playerMang:RemovePlayerBannd', function(source, cb)
    local success = exports['ph-playerMang']:RemovePlayerFromBanList(source)
    cb(success)
end)