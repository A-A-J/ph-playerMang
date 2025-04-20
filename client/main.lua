---@diagnostic disable: assign-type-mismatch, undefined-global
-- if not lib then return print("err ox_lib, line 1") end
local QBCore = exports['qb-core']:GetCoreObject()


-- SlashCommand


RegisterCommand('manageservices', function()
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData then return end
    local job = playerData.job.name
    local grade = playerData.job.grade.level
    QBCore.Functions.TriggerCallback('ph-playerMang:server:CheckPermission', function(hasPermission)
        if hasPermission then
            menu()
        else
            QBCore.Functions.Notify("ليس لديك الصلاحيات لاستخدام هذا الأمر", "error")
        end
    end, job, grade)
end)


-- Functions


local function AwaitCallback(name, ...)
    local promise = promise:new()
    QBCore.Functions.TriggerCallback(name, function(result)
        promise:resolve(result)
    end, ...)
    return Citizen.Await(promise)
end

function menu()
    exports['qb-menu']:openMenu({
        {
            header = 'ايقاف خدمات',
            isMenuHeader = true,
        },
        {
            header = 'ايقاف خدمات مواطن',
            txt = 'منع البنك، الكراج، المطاعم، المعارض، الوظائف',
            icon = 'fas fa-power-off',
            params = {
                event = 'ph-playerMang:client:addPlayerOff',
            }
        },
        {
            header = 'الموقفين عن الخدمة',
            txt = 'تصفح قائمة اسماء الموقوفين',
            icon = 'fa fa-users',
            params = {
                event = 'ph-playerMang:client:getPlayerOff',
            }
        },
        {
            header = 'اغلاق القائمة',
            params = {
                event = 'qb-menu:client:closeMenu',
            }
        }
    })
end


-- Event


RegisterNetEvent('ph-playerMang:client:openMenu', function() menu(source) end)

RegisterNetEvent("ph-playerMang:client:addPlayerOff", function()
    local dialog = exports['qb-input']:ShowInput({
        header = 'ايقاف خدمات مواطن',
        submitText = "ارسال",
        inputs = {
            {
                text = "الهوية",
                label = "هوية اللاعب",
                min = 1111,
                max = 9999,
                name = "cid",
                type = "number",
                isRequired = true,
            },
            {
                text = "السبب",
                name = "reason",
                type = "textarea",
                isRequired = true,
            },
            {
                text = "التاريخ",
                name = "date",
                type = "date",
                isRequired = true,
                min="2025-01-01",
                max="2030-01-01",
            }
        },
    })
    if not dialog then return end
    QBCore.Functions.TriggerCallback('ph-playerMang:server:uploadPlayerOff', function(success)
        if success then return QBCore.Functions.Notify('تم إيقاف خدمات المواطن بنجاح!') end
        QBCore.Functions.Notify('النظام عطلان، عُد لاحقًا #2', 'error')
    end, dialog)

    -- ox_lib
    -- QBCore.Functions.TriggerCallback('ph-playerMang:server:getPlayers', function(getData)
        -- if getData == false then return QBCore.Functions.Notify('لايوجد مواطنين لايقاف خدماتهم', 'error') end
        -- local card = {}
        -- for index, value in ipairs(getData) do
        --     card[index] = {text = string.format('الاسم: %s %s - الهوية: %s', value.charinfo.firstname, value.charinfo.lastname, value.citizenid), value = value.citizenid}
        -- end
        -- local input = lib.inputDialog('ايقاف خدمات مواطن', {
        --     {type = 'select',  label = 'الهوية', description = 'يجب ادخال هوية المواطن/العسكري', required = true, options = card},
        --     {type = 'date', label = 'تاريخ رفع الايقاف عن الخدمة', icon = {'far', 'calendar'}, required = true, default = true, format = "DD/MM/YYYY"},
        --     {type = 'textarea',  label = 'السبب', description = 'عقوبة من المحكمة/الاخلال بأمن المدينة للدرجة الاخيرة', required = true},
        -- })
        -- if not input then return end
    -- end)

end)

RegisterNetEvent("ph-playerMang:client:getPlayerOff", function()
    QBCore.Functions.TriggerCallback('ph-playerMang:server:getPlayersOff', function(getData)
        if getData == false then return QBCore.Functions.Notify('لايوجد موقوفين عن الخدمة', 'error') end
        local users = { { header = "اختر المواطن المطلوب لفك خدماته", isMenuHeader = true } }
        for index, value in ipairs(getData) do
            table.insert(users,{
                header = value.name or value.citizenid,
                txt = string.format("تم الايقاف بواسطة: %s <br/> حتى يوم %s", value.by_player, value.off_date),
                icon = 'fas fa-hammer',
                params = {
                    event = 'ph-playerMang:client:optionPlayerServiceSuspension',
                    args = {
                        citizenid = value.citizenid,
                        name = value.name or value.citizenid,
                        reason = value.reason,
                        off_date = value.off_date,
                    }
                }
            })
        end
        table.insert(users, { header = "العودة", params = { event = "ph-playerMang:client:openMenu" } })
        table.insert(users, { header = "إغلاق القائمة", params = { event = "qb-menu:client:closeMenu" } })
        exports['qb-menu']:openMenu(users)
    end)
end)

RegisterNetEvent("ph-playerMang:client:optionPlayerServiceSuspension", function(player)
    exports['qb-menu']:openMenu({
        {
            header = string.format("المواطن %s", player.name),
            isMenuHeader = true,
        },
        {
            header = 'تعديل عقوبة إيقاف الخدمات',
            txt = 'تعديل السبب أو تاريخ إزالة العقوبة',
            icon = 'fas fa-edit',
            params = {
                event = 'ph-playerMang:client:editServiceSuspension',
                args = {player}
            }
        },
        {
            header = 'إزالة عقوبة إيقاف الخدمات',
            txt = 'إزالة المواطن من سجل العقوبات',
            icon = 'fa fa-trash',
            params = {
                event = 'ph-playerMang:client:removeServiceSuspension',
                args = {player}
            }
        },
        {
            header = 'العودة',
            params = {
                event = 'ph-playerMang:client:getPlayerOff',
            }
        },
        {
            header = 'اغلاق القائمة',
            params = {
                event = 'qb-menu:client:closeMenu',
            }
        }
    })
end)

RegisterNetEvent("ph-playerMang:client:editServiceSuspension", function (data)
    local sendData = data[1]
    local dialog = exports['qb-input']:ShowInput({
        header = string.format("تعديل ايقاف %s", sendData.name),
        submitText = "حفظ التعديلات",
        inputs = {
            {
                text = "الهوية",
                min = 1111,
                max = 9999,
                name = "cid",
                type = "number",
                isRequired = true,
                default = sendData.citizenid,
                disabled = true,
            },
            {
                text = "السبب",
                name = "reason",
                type = "textarea",
                default  = sendData.reason,
                isRequired = true,
            },
            {
                text = "التاريخ",
                name = "date",
                type = "date",
                isRequired = true,
                default  = sendData.off_date,
                min="2025-01-01",
                max="2030-01-01",
            }
        },
    })
    if not dialog then return end
    QBCore.Functions.TriggerCallback('ph-playerMang:server:editServiceSuspensionSave', function(success)
        if success then return QBCore.Functions.Notify('تم تعديل بيانات ايقاف خدمات المواطن') end
        QBCore.Functions.Notify('لم يتم العثور على المواطن في النظام', 'error')
    end, dialog)

    -- -- ox_lib
    -- QBCore.Functions.TriggerCallback('ph-playerMang:server:editServiceSuspension', function(getData)
    --     if #getData < 1 then return QBCore.Functions.Notify('السستم عطلان #3') end
    --     local getDataNow = getData[1]
    --     local input = lib.inputDialog(string.format("تعديل ايقاف خدمات المواطن %s", getDataNow.name), {
    --         {type = 'input', label = 'معرف المواطن', required = true, disabled = true, default = getDataNow.citizenid},
    --         {type = 'date', label = 'تاريخ رفع الايقاف عن الخدمة', icon = {'far', 'calendar'}, required = true, format = "DD/MM/YYYY", default = getDataNow.off_date},
    --         {type = 'textarea',  label = 'السبب', description = 'عقوبة من المحكمة/الاخلال بأمن المدينة للدرجة الاخيرة', required = true, default = getDataNow.reason},
    --     })
    --     if not input then return end
    --     QBCore.Functions.TriggerCallback('ph-playerMang:server:editServiceSuspensionSave', function(success)
    --         if success then return QBCore.Functions.Notify('تم تعديل بيانات ايقاف خدمات المواطن') end
    --         QBCore.Functions.Notify('السستم عطلان، عُد لاحقًا #4', 'error')
    --     end, input)
    -- end, sendData)
end)

RegisterNetEvent("ph-playerMang:client:removeServiceSuspension", function (data)
    exports['qb-menu']:openMenu({
        {
            header = 'هل أنت متأكد من الحذف؟',
            isMenuHeader = true,
        },
        {
            header = string.format("نعم؛ إزالة ايقاف خدمات المواطن %s", data[1].name),
            icon = 'fas fa-trash',
            params = {
                event = 'ph-playerMang:client:trashServiceSuspension',
                args = data
            }
        },
        {
            header = 'العودة',
            params = {
                event = 'ph-playerMang:client:optionPlayerServiceSuspension',
                args = {
                    citizenid = data[1].citizenid,
                    name = data[1].name or data[1].citizenid,
                    reason = data[1].reason,
                    off_date = data[1].off_date,
                }
            }
        },
        {
            header = 'اغلاق القائمة',
            params = {
                event = 'qb-menu:client:closeMenu',
            }
        }
    })

    -- local status = lib.alertDialog({
    --     header = 'هل أنت متأكد من إزالة ايقاف الخدمات؟',
    --     content = string.format("المواطن: %s   \n سبب الايقاف: %s", data[1].name, data[1].reason),
    --     centered = true,
    --     cancel = true
    -- })

    -- if status == 'confirm' then
    --     QBCore.Functions.TriggerCallback('ph-playerMang:server:removeServiceSuspension', function(success)
    --         if success then
    --             return QBCore.Functions.Notify('تم إزالة ايقاف الخدمات بنجاح')
    --         end
    --         QBCore.Functions.Notify('السستم عطلان، عُد لاحقًا #4', 'error')
    --     end, data)
    -- end
end)

RegisterNetEvent("ph-playerMang:client:trashServiceSuspension", function (data)
    print(json.encode(data))
    QBCore.Functions.TriggerCallback('ph-playerMang:server:removeServiceSuspension', function(success)
        if success then
            return QBCore.Functions.Notify('تم إزالة ايقاف الخدمات بنجاح')
        end
        QBCore.Functions.Notify('السستم عطلان، عُد لاحقًا #4', 'error')
    end, data)
end)


-- exports


exports("IsPlayerBanned", function()
    return AwaitCallback('ph-playerMang:IsPlayerBanned')
end)

exports("addPlayerBanned", function(reason, customDate)
    return AwaitCallback('ph-playerMang:addPlayerFromBanList', reason, customDate)
end)

exports("removePlayerBanned", function()
    return AwaitCallback('ph-playerMang:RemovePlayerBannd')
end)
