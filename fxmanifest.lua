fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'donk'
description 'Blips Creator with Admin Management'
version '2.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

dependencies {
    'ox_lib',
    'oxmysql'
}
