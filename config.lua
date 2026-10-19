Config = {}

-- 'auto' détecte qb-core ou es_extended (qbx_core seulement s'il fournit qb-core). Sinon 'qb', 'esx' ou 'standalone'.
Config.Framework = 'auto'

-- Langue : 'fr' ou 'en' (HUD, réglages et noms des touches)
Config.Locale = 'fr'

-- Ressource de carburant (exports[x]:GetFuel(veh)). nil = carburant natif GTA.
-- Exemples : 'LegacyFuel', 'ps-fuel', 'cdn-fuel', 'ox_fuel' (ox_fuel utilise l'état natif → laisser nil)
Config.FuelResource = nil

Config.MaxPlayers = 128                -- secours seulement : les slots réels (sv_maxclients) sont lus par le serveur
Config.MinimapOnlyInVehicle = false   -- force la minimap seulement en véhicule pour tous (sinon chaque joueur choisit dans /hudsetting)
Config.MinimapScale = 0.85            -- taille de la minimap native (1.0 = taille GTA)
Config.MinimapFrameOffset = { x = -4, y = 0 }  -- décale le cadre du HUD (pixels, base 1080p) : x négatif = gauche, y positif = bas
Config.HideMinimapBars = true         -- retire les barres vie / armure natives sous la minimap
Config.TickOnFoot = 250               -- ms entre deux mises à jour à pied
Config.TickInVehicle = 60             -- ms en véhicule (compteur fluide)

-- Commande d'ouverture des réglages
Config.SettingsCommand = 'hudsetting'

-- Touches par défaut (le joueur peut les changer dans Paramètres > Raccourcis > FiveM)
Config.Keys = {
  seatbelt = 'B',
  indicatorLeft = 'LEFT',
  indicatorRight = 'RIGHT',
  hazard = 'DOWN',
  limiter = 'L',
  cruise = 'J',
  anchor = '',          -- ancre du bateau (vide = pas de touche par défaut, commande /ancre)
  cinema = 'F7',        -- mode cinématique : cache tout le HUD + bandes noires
  vehicleMenu = 'F9',   -- menu véhicule : moteur, phares, portes, fenêtres, radio, sièges
}

-- Ceinture : sans ceinture, un choc violent éjecte par le pare-brise ; attachée, elle réduit les blessures
Config.Seatbelt = {
  enabled = true,
  ejectSpeed = 90,      -- km/h minimum avant le choc pour être éjecté
  ejectDrop = 45,       -- perte de vitesse brutale (km/h en un instant) qui compte comme un choc
  ejectDamage = 40,     -- points de vie perdus à l'éjection
  beltDamage = 5,       -- choc encaissé avec la ceinture
}

-- Masquer les éléments natifs GTA remplacés par le HUD
-- Cercle au sol montrant la portée de la voix quand le joueur la change (pma-voice)
Config.VoiceCircle = {
  enabled = true,
  duration = 2500,                         -- ms d'affichage
  color = { r = 145, g = 132, b = 217 },   -- couleur d'accent du HUD
}

-- Notifications au style du HUD, via exports.nocturne_hud:Notify(data). Attention : ox_lib et esx_notify ne
-- l'appellent pas d'eux-mêmes ; il faut les y brancher pour que leurs notifications passent par le HUD.
Config.Notifications = {
  enabled = true,
  duration = 5000,      -- ms par défaut
}

-- Carburant : bip et pulsation sous ce seuil (%), autonomie estimée affichée sous showRange (%)
Config.Fuel = { warn = 10, showRange = 25 }

Config.HideNative = { 3, 4, 6, 7, 8, 9 } -- argent, nom véhicule, zone, classe, rue
