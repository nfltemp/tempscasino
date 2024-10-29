fx_version 'cerulean'
game 'gta5'

description 'NFL Temp Casino'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua',
    'shop.lua',
    'ai.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_lib'
}