fx_version "cerulean"

version '1.0.0' 
author 'Alph0xDev'
description 'A simple and customizable pause menu for FiveM'
lua54 'yes'

game 'gta5'

ui_page "web/index.html"

client_script "client.lua"
shared_script "config.lua*"
server_script "server.lua"

files {
	'web/index.html',
	'web/**/*',
}