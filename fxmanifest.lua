fx_version 'cerulean'

game 'gta5'

author 'ph-playerMang'
description 'by:hudhali, player services management'
version '1.1.0'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua'
}

dependencies {
    'qb-core',
    'qb-target'
}