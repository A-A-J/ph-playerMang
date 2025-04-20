Config = {}

--- رصيد البنك او الكاش الذي سوف يتم ايقاف خدماته في حال كان رصيد اللاعب اقل منه
Config.BankMoney = -1000
Config.CashPlayer = -1000

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