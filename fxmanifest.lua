fx_version 'cerulean'
game 'gta5'

author 'ph-playerMang'
description 'by:hudhali, player services management'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
}

dependencies {
    'qb-core',
    'qb-target',
    'ox_lib'
}