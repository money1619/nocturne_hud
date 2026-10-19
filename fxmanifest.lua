fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nocturne_hud'
description 'HUD joueur Nocturne — statuts, argent, voix, véhicule (voiture, moto, vélo, bateau, hélico, avion)'
version '1.6.0'

shared_scripts { '@ox_lib/init.lua', 'config.lua' }
client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'
files {
  'html/index.html',
  'html/style.css',
  'html/app.js'
}

-- Cfx.re Asset Escrow : fichiers laissés lisibles et modifiables par l'acheteur (le reste est chiffré)
escrow_ignore {
    'config.lua',
}
