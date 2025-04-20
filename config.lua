Config = {}

--- رصيد البنك او الكاش الذي سوف يتم ايقاف خدماته في حال كان رصيد اللاعب اقل منه
Config.BankMoney = -1000
-- Config.CashPlayer = -1000

Config.ReasonBankOrCash = 'الرصيد أقل من -1000 دولار'

--- منع ايقاف الخدمات بحسب معرفات المستخدمين المعينين
Config.BannedPlayers = {
    ["DUH02938"] = true, -- citizenid
}

-- منع ايقاف الخدمات للوظيفة بحسب القريد الخاص بها
Config.ExemptJobs = {
    ["police"] = {4, 5, 6},
    ["ems"] = {3, 4},
    ["judge"] = {0, 1, 2}
}

-- هل تريد استخدام حدث الايقاف عن طريق وظيفة الحدق [ph-playerMang:client:openMenu] بدلا من استخدام نظام Target لكل pc
--- false يعني استخدام الحدث فقط
--- true يعني استخدام نظام Target لكل pc
Config.youUserTargetOrEvent = false

-- مواقع إدارة ايقاف الخدمات للمواطنين
Config.pc = {
    {
        label = "نظام ايقاف الخدمات",
        name = "pc_system_services",
        center = { x = 442.2742614746094, y = -979.501220703125, z = 30.6895809173584 },
        width = 0.5,
        length = 0.5,
        heading = 0,
        debugPoly = false,
        maxZ = 30.88958091735838,
        minZ = 26.88958091735841,
        job = {
            ["police"] = 2
        }
    }
}