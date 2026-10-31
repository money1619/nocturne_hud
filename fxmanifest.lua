fx_version 'cerulean'
game 'gta5'
author 'AEOM Development'
lua54 'yes'

name 'nocturne_hud'
description 'Nocturne HUD — Custom FiveM HUD for GTA V Roleplay. Supports QBCore, ESX and Standalone. Player status, money, job, voice, speedometer, seatbelt, vehicle info. Lua, no dependency.'
version '1.10.2'

shared_script 'config.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'
files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'html/fonts/fonts.css',
  'html/fonts/*.woff2'
}
