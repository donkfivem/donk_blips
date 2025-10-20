shared_script "@ReaperV4/bypass.lua"
lua54 "yes" -- needed for Reaper

shared_scripts { '@FiniAC/fini_events.lua' }


fx_version 'cerulean'
game 'gta5'
lua54 'yes'


client_scripts {
	'client/main.lua',
	'client/ui.lua'
}

shared_scripts {
	'@ox_lib/init.lua',
}

	
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
	'blips.lua',
}

ui_page 'web/build/index.html'

files {
	'web/build/index.html',
	'web/build/**/*',
}