fx_version 'cerulean'
lua54 'yes'
games {'gta5'}

--INFO --
name        'P_playerRob'
author      'Projekti'
version     '1.0.5'

shared_script {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
	'ox_inventory',
    'ox_lib'
}
