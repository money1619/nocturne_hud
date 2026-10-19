-- tests/emu_test.lua — nocturne_hud lancé dans fivem-emulator (vrai fxmanifest, vrai code serveur et client),
-- avec le mock ESX 1.12.4 et la vraie ressource esx_notify de dev2 (crochet vers le HUD).
-- Lancer depuis nocturne_hud/ : lua5.4 tests/emu_test.lua   (EMU_DIR = dossier de fivem-emulator)
-- Limites : l'émulateur n'a ni rendu ni physique GTA ; les natives propres au HUD (véhicule, minimap, scaleform…)
-- sont simulées ici et enregistrent leurs appels. Ce n'est pas un essai en jeu.
local EMU_DIR = os.getenv('EMU_DIR') or '/home/fivem2/fivem-emulator'
local ESX_NOTIFY = os.getenv('ESX_NOTIFY') or '/home/fivem2/FXServer/txData/ESXLegacy_40D842.base/resources/[core]/esx_notify'
package.path = EMU_DIR .. '/?.lua;' .. package.path
local Emu = require('fivem_emu')

local emu = Emu.new({ seed = 7 })
local esx = require('mocks.esx')(emu, {})

-- Natives absentes de l'émulateur : valeurs plausibles, appels enregistrés
local calls = {}
local function rec(name, ...) calls[#calls + 1] = { name = name, args = { ... }, t = emu.now } end
local function count(name, pred)
    local n = 0
    for _, c in ipairs(calls) do if c.name == name and (not pred or pred(c.args)) then n = n + 1 end end
    return n
end
local veh = { speed = 0.0, class = 0, fuel = 80.0 }
local function vector3(x, y, z) return { x = x, y = y, z = z } end -- le test n'a pas les vecteurs de l'émulateur
local values = {
    GetEntitySpeed = function() return veh.speed end, GetVehicleClass = function() return veh.class end,
    GetVehicleFuelLevel = function() return veh.fuel end, GetEntityMaxHealth = function() return 200 end,
    GetPedInVehicleSeat = function(v, seat) local p = emu:currentPlayer() return seat == -1 and p and p.ped or 0 end,
    GetPlayerSprintStaminaRemaining = function() return 100.0 end, GetPlayerUnderwaterTimeRemaining = function() return 10.0 end,
    GetSafeZoneSize = function() return 1.0 end, GetAspectRatio = function() return 16 / 9 end,
    GetClockHours = function() return 12 end, GetClockMinutes = function() return 30 end,
    GetStreetNameAtCoord = function() return 1, 0 end, GetStreetNameFromHashKey = function() return 'Grove Street' end,
    GetNameOfZone = function() return 'DAVIS' end, GetLabelText = function(s) return s end,
    GetVehicleLightsState = function() return true, 0, 0 end, GetVehicleCurrentGear = function() return 1 end,
    GetVehicleCurrentRpm = function() return 0.3 end, GetVehicleEngineHealth = function() return 1000.0 end,
    GetVehicleNumberPlateText = function() return 'NOCT 01' end, GetEntityForwardVector = function() return vector3(0.0, 1.0, 0.0) end,
    GetModelDimensions = function() return vector3(-1.0, -2.4, -0.6), vector3(1.0, 2.4, 1.0) end,
    GetOffsetFromEntityInWorldCoords = function(_, x, y, z) return vector3(x, y, z) end,
    GetEntityVelocity = function() return vector3(0.0, 0.0, 0.0) end, GetEntityHeightAboveGround = function() return 0.0 end,
    GetSelectedPedWeapon = function() return 2725352035 end, GetPedArmour = function() return 0 end, -- 2725352035 = joaat('WEAPON_UNARMED')
    HasScaleformMovieLoaded = function() return true end, RequestScaleformMovie = function() return 1 end,
    GetActivePlayers = function() return { 0 } end, IsVehicleOnAllWheels = function() return true end,
    GetVehicleSteeringAngle = function() return 0.0 end, GetVehicleModelNumberOfSeats = function() return 4 end,
}
local zero = { 'IsPauseMenuActive', 'IsScreenFadedOut', 'IsHudHidden', 'IsPedSprinting', 'IsPedRunning',
    'IsPedSwimmingUnderWater', 'IsPedArmed', 'NetworkIsPlayerTalking', 'HasEntityCollidedWithAnything',
    'GetIsVehicleEngineRunning', 'GetAmmoInClip', 'GetAmmoInPedWeapon', 'GetHeliMainRotorHealth', 'GetLandingGearState' }
local recorded = { 'DisplayRadar', 'SetPedConfigFlag', 'HideHudComponentThisFrame', 'SetMinimapComponentPosition',
    'SetRadarBigmapEnabled', 'BeginScaleformMovieMethod', 'ScaleformMovieMethodAddParamInt', 'EndScaleformMovieMethod',
    'RegisterKeyMapping', 'SetVehicleMaxSpeed', 'SetControlNormal', 'SetEntityVelocity', 'SetPedToRagdoll',
    'SetEntityHealth', 'SetVehicleIndicatorLights', 'PlaySoundFrontend', 'SetBoatAnchor', 'SetBoatFrozenWhenAnchored' }
for name, fn in pairs(values) do emu:native(name, function(...) rec(name, ...) return fn(...) end, 'client') end
for _, name in ipairs(zero) do emu:native(name, function(...) rec(name, ...) return false end, 'client') end
for _, name in ipairs(recorded) do emu:native(name, function(...) rec(name, ...) end, 'client') end
-- State bags absents de l'émulateur : tables simples (GlobalState répliqué à la main plus bas)
local global = {}
emu:native('GlobalState', global, 'shared')
emu:native('LocalPlayer', { state = { proximity = { index = 2, distance = 8.0 } } }, 'client')

emu:loadResource('.', 'nocturne_hud')
emu:loadResource(ESX_NOTIFY, 'esx_notify')
emu:start('nocturne_hud')
emu:start('esx_notify')

local alice = emu:addPlayer({ name = 'Alice', esx = { accounts = { money = 250, bank = 4000 } } })
esx:waitLoaded(alice)
emu:run(5000)

local T = Emu.tester('nocturne_hud (émulateur)')
local function nui(kind)
    local out = {}
    for _, m in ipairs(alice.nui) do if m.resource == 'nocturne_hud' and m.msg and m.msg.t == kind then out[#out + 1] = m end end
    return out
end
local function lastSlow() local s = nui('s') return s[#s] and s[#s].msg.d end

T:eq(#emu.errors, 0, 'démarrage : aucune erreur Lua (serveur et client) en 5 s')
T:check(#nui('u') >= 15, 'mises à jour du HUD envoyées à pied (≈ 4 par seconde)')
T:eq(global.nh_maxPlayers ~= nil, true, 'serveur : nombre de places publié (GlobalState)')
local s = lastSlow()
T:check(s and s.cash == 250 and s.bank == 4000, 'argent ESX affiché : 250 $ liquide, 4 000 $ banque')
T:eq(count('RegisterKeyMapping'), 9, '9 touches enregistrées (ceinture, clignotants, warnings, limiteur, régulateur, ancre, cinéma, menu)')

-- Argent : l'événement esx:setAccountMoney (compte reçu) met le HUD à jour sans attendre la boucle de 2 s
esx:xPlayer(alice).addMoney(100)
emu:run(1100)
s = lastSlow()
T:check(s and s.cash == 350, 'après addMoney(100) : 350 $ affichés en moins de 1,1 s')

-- Minimap : DisplayRadar seulement quand l'état change
local radarBefore = count('DisplayRadar')
emu:run(5000)
T:eq(count('DisplayRadar'), radarBefore, 'minimap : aucun DisplayRadar répété pendant 5 s sans changement')

-- F7 : mode cinéma (minimap cachée, puis rendue)
alice:clientCommand('hud_cinema')
emu:run(400)
T:check(count('DisplayRadar', function(a) return a[1] == false end) >= 1, 'F7 : minimap cachée')
alice:clientCommand('hud_cinema')
emu:run(400)
local lastRadar
for _, c in ipairs(calls) do if c.name == 'DisplayRadar' then lastRadar = c.args[1] end end
T:eq(lastRadar, true, 'F7 de nouveau : minimap rendue')

-- Réglages : /hudsetting donne la souris à la page, le bouton Fermer la rend
alice:clientCommand('hudsetting')
emu:run(100)
T:eq(alice.nuiFocus and alice.nuiFocus.focus, true, '/hudsetting : focus NUI donné')
alice:nuiCallback('close', {})
emu:run(100)
T:eq(alice.nuiFocus and alice.nuiFocus.focus, false, 'Fermer : focus NUI rendu')

-- Véhicule : ceinture et éjection native coupée
alice:enterVehicle()
emu:run(500)
T:check(count('SetPedConfigFlag', function(a) return a[2] == 32 and a[3] == false end) >= 1,
    'en voiture : éjection native du jeu (flag 32) coupée, le HUD gère l\'éjection')
alice:clientCommand('hud_seatbelt')
emu:run(200)
local u = nui('u'); u = u[#u].msg.d
T:eq(u.veh and u.veh.belt, true, 'ceinture attachée affichée au compteur')
-- Choc à 110 km/h ceinture attachée : pas d'éjection, dégâts réduits
veh.speed = 110 / 3.6; emu:run(200); veh.speed = 30 / 3.6; emu:run(200)
T:eq(count('SetPedToRagdoll'), 0, 'choc ceinture attachée : pas d\'éjection')
-- Sans ceinture : éjection (ragdoll puis vitesse)
alice:clientCommand('hud_seatbelt'); emu:run(100)
veh.speed = 110 / 3.6; emu:run(200); veh.speed = 20 / 3.6; emu:run(300)
T:eq(count('SetPedToRagdoll'), 1, 'choc sans ceinture : une éjection')
veh.speed = 0.0

-- Notifications : la vraie esx_notify passe par le HUD quand il tourne
local before = #nui('notify')
-- appel « depuis » une ressource cliente, comme le ferait n'importe quel script du serveur
local caller = emu:env(alice, 'esx_notify')
local ok, err = pcall(function() caller.exports.esx_notify:Notify('success', 3000, 'Paiement ~g~reçu~s~ ~br~!') end)
if not ok then print('appel Notify :', err) end
emu:run(100)
local n = nui('notify')
if ok and #n > before then
    T:eq(n[#n].msg.d.text, 'Paiement reçu !', 'esx_notify → notification au style du HUD, codes ~g~ ~s~ ~br~ retirés')
else
    T:check(ok, 'esx_notify → HUD (export client appelable depuis le test)')
end
emu:stop('nocturne_hud')
emu:run(100)
local nuiEsx = 0
for _, m in ipairs(alice.nui) do if m.resource == 'esx_notify' then nuiEsx = nuiEsx + 1 end end
pcall(function() caller.exports.esx_notify:Notify('info', 3000, 'HUD arrêté') end)
emu:run(100)
local nuiEsx2 = 0
for _, m in ipairs(alice.nui) do if m.resource == 'esx_notify' then nuiEsx2 = nuiEsx2 + 1 end end
T:eq(nuiEsx2, nuiEsx + 1, 'HUD arrêté : esx_notify affiche lui-même la notification')

T:eq(#emu.errors, 0, 'aucune erreur Lua sur toute la séance')
print(emu:report())
os.exit(T:summary() and 0 or 1)
