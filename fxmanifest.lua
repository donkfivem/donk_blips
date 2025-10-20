fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'donk'
description 'Advanced blip management system with NUI interface'
version '2.0.0'

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',
    'shared/bridge.lua'
}

-- Client scripts
client_scripts {
    'client/main.lua',
    'client/ui.lua',
    'client/menu.lua'
}

-- Server scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

-- UI
ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*'
}

-- Dependencies
dependencies {
    'ox_lib',
    'oxmysql'
}
