-- Tests hors jeu de client/main.lua avec des doubles de natives (ce n'est PAS un essai GTA).
-- Chaque cas décrit le comportement attendu ; ceux marqués [connu] échouent sur la 1.6.0 (défauts relevés en revue)
-- et doivent passer après correction.
-- Usage (depuis nocturne_hud/) : lua5.4 tests/hud_test.lua
local unpack = table.unpack

---------------------------------------------------------------- monde simulé
local W
local function reset()
  W = {
    clock = 0, calls = {}, nui = {}, flags = {}, radar = {},
    ped = { x = 0.0, y = 0.0, z = 30.0, health = 200, armor = 0, inVeh = 0, under = false, air = 0 },
    veh = { id = 7, speed = 0.0, class = 0, collided = false, heading = 0.0, seats = 4 },
    controls = {}, stamina = 100,
  }
end
reset()
local function log(name, ...) W.calls[#W.calls + 1] = { name, ... } end
local function count(name) local n = 0 for _, c in ipairs(W.calls) do if c[1] == name then n = n + 1 end end return n end
local function index(name) for i, c in ipairs(W.calls) do if c[1] == name then return i end end end

---------------------------------------------------------------- ordonnanceur (CreateThread / Wait)
local threads = {}
function CreateThread(fn) threads[#threads + 1] = { co = coroutine.create(fn), wake = W.clock } end
function Wait(ms) coroutine.yield(math.max(ms or 0, 0)) end
function SetTimeout(ms, fn) CreateThread(function() Wait(ms) fn() end) end
local function run(ms)
  local stop = W.clock + ms
  while W.clock < stop do
    for _, t in ipairs(threads) do
      if coroutine.status(t.co) ~= 'dead' and t.wake <= W.clock then
        local ok, d = coroutine.resume(t.co)
        if not ok then error(d) end
        t.wake = W.clock + math.max(d or 0, 1)
      end
    end
    W.clock = W.clock + 10
  end
end

---------------------------------------------------------------- natives et API FiveM
function GetGameTimer() return W.clock end
function PlayerPedId() return 1 end
function PlayerId() return 0 end
function GetPlayerServerId() return 3 end
function vector3(x, y, z) return setmetatable({ x = x, y = y, z = z }, { __sub = function(a, b) return vector3(a.x - b.x, a.y - b.y, a.z - b.z) end, __len = function(v) return math.sqrt(v.x ^ 2 + v.y ^ 2 + v.z ^ 2) end }) end
function GetEntityCoords(e) local p = W.ped return vector3(p.x, p.y, p.z) end
function GetVehiclePedIsIn() return W.ped.inVeh end
function GetPedInVehicleSeat(v, s) return (s == -1 and W.ped.inVeh ~= 0) and 1 or 0 end
function GetEntitySpeed() return W.veh.speed / 3.6 end
function GetVehicleClass() return W.veh.class end
function GetEntityHealth() return W.ped.health end
function GetEntityMaxHealth() return 200 end
function SetEntityHealth(_, h) W.ped.health = h; log('SetEntityHealth', h) end
function GetEntityForwardVector() return vector3(0.0, 1.0, 0.0) end
function SetEntityCoords(_, x, y, z) log('SetEntityCoords', x, y, z); W.ped.inVeh = 0 end
function SetEntityVelocity(...) log('SetEntityVelocity', ...) end
function SetPedToRagdoll(...) log('SetPedToRagdoll', ...) end
function ClearPedTasksImmediately(...) log('ClearPedTasksImmediately', ...); W.ped.inVeh = 0 end
function TaskLeaveVehicle(...) log('TaskLeaveVehicle', ...) end
function SetPedConfigFlag(_, f, v) W.flags[f] = v; log('SetPedConfigFlag', f, v) end
function GetPedConfigFlag(_, f) return W.flags[f] == true end
function HasEntityCollidedWithAnything() return W.veh.collided end
function IsControlPressed(_, c) return W.controls[c] == true end
function SetControlNormal(_, c, v) log('SetControlNormal', c, v) end
function DisableControlAction(...) log('DisableControlAction', ...) end
function HideHudComponentThisFrame() end
function DisplayRadar(v) W.radar[#W.radar + 1] = v; log('DisplayRadar', v) end
function SendNUIMessage(m) W.nui[#W.nui + 1] = m end
function IsPedSwimmingUnderWater() return W.ped.under end
function GetPlayerUnderwaterTimeRemaining() return W.ped.air end
function GetPlayerSprintStaminaRemaining() return W.stamina end
function GetResourceState(r) return (r == 'es_extended') and 'missing' or 'missing' end
function GetConvarInt(_, d) return d end
function GetCurrentResourceName() return 'nocturne_hud' end
function GetVehicleEngineHealth() return W.veh.engine or 1000.0 end
function GetEntityModel() return 99 end
function GetModelDimensions() return vector3(-1.0, -2.4, -0.6), vector3(1.0, 2.4, 0.9) end
function GetOffsetFromEntityInWorldCoords(_, ox, oy, oz) local p = W.ped return vector3(p.x + ox, p.y + oy, p.z + oz) end
function GetVehicleFuelLevel() return W.veh.fuel or 60.0 end
function GetVehicleNumberPlateText() return 'ABC123' end
function GetVehicleLightsState() return true, 0, 0 end
function GetVehicleCurrentGear() return 3 end
function GetVehicleCurrentRpm() return 0.5 end
function GetEntityHeading() return W.veh.heading end
function IsVehicleOnAllWheels() return true end
function SetVehicleMaxSpeed(...) log('SetVehicleMaxSpeed', ...) end
function GetLabelText(s) return s end
function GetNameOfZone() return 'ZONE' end
function GetStreetNameAtCoord() return 1, 0 end
function GetStreetNameFromHashKey() return 'Rue' end
function GetClockHours() return 12 end
function GetClockMinutes() return 0 end
function GetSafeZoneSize() return 1.0 end
function GetAspectRatio() return 16 / 9 end
function RequestScaleformMovie() return 1 end
function HasScaleformMovieLoaded() return true end
function GetActivePlayers() return { 0 } end
function NetworkIsPlayerTalking() return false end
function GetSelectedPedWeapon() return 0 end
function IsPauseMenuActive() return false end
function IsScreenFadedOut() return false end
function IsHudHidden() return false end
function GetPedArmour() return 0 end
function IsPedSprinting() return false end
function IsPedRunning() return false end
function PlaySoundFrontend(...) log('PlaySoundFrontend', ...) end
LocalPlayer = { state = {} }
GlobalState = {}
json = { encode = function(t) local s = {} for k, v in pairs(t) do s[#s + 1] = tostring(k) .. '=' .. tostring(v) end table.sort(s) return table.concat(s, ',') end }
lib = { registerContext = function() end, showContext = function() end, notify = function() end }
local handlers, commands, nuicb, exported = {}, {}, {}, {}
function RegisterNetEvent(n, fn) if fn then handlers[n] = fn end end
function AddEventHandler(n, fn) handlers[n] = handlers[n] or {}; if type(handlers[n]) == 'table' then table.insert(handlers[n], fn) else handlers[n] = { handlers[n], fn } end end
function RegisterCommand(n, fn) commands[n] = fn end
function RegisterKeyMapping() end
function RegisterNUICallback(n, fn) nuicb[n] = fn end
function SetNuiFocus(...) log('SetNuiFocus', ...) end
exports = setmetatable({}, { __call = function(_, n, fn) exported[n] = fn end, __index = function() return setmetatable({}, { __index = function() return function() return nil end end }) end })
-- toute autre native : sans effet, renvoie 0
setmetatable(_G, { __index = function(_, k) if type(k) == 'string' and k:match('^%u') then return function() return 0 end end end })

-- NH_DIR : dossier à tester (par défaut la copie de travail) ; ex. une extraction de la 1.6.0 d'origine
local DIR = os.getenv('NH_DIR') or '.'
dofile(DIR .. '/config.lua')
local src = assert(io.open(DIR .. '/client/main.lua')):read('a'):gsub('`[%w_]+`', '0')
assert(load(src, '@client/main.lua'))()

---------------------------------------------------------------- cas
local passed, failed, known = 0, 0, 0
local KNOWN = {}
local function check(name, cond, isKnown)
  if cond then passed = passed + 1 else failed = failed + 1; if isKnown then known = known + 1 end end
  print((cond and 'PASS ' or (isKnown and 'FAIL [connu] ' or 'FAIL ')) .. name)
end
local function lastU() for i = #W.nui, 1, -1 do if W.nui[i].t == 'u' then return W.nui[i].d end end end
local function enterVehicle(speed) W.ped.inVeh = W.veh.id; W.veh.speed = speed; run(200) end
local function fire(name, ...) local h = handlers[name]; if type(h) == 'table' then for _, f in ipairs(h) do f(...) end elseif h then h(...) end end

run(3000)

-- Oxygène : l'air restant est en secondes ; la jauge doit partir de 100 % et suivre la réserve réelle
W.ped.under, W.ped.air = true, 40.0
run(300)
W.ped.air = 20.0
run(300)
local u = lastU()
check('oxygène : 20 s restantes sur 40 s → environ 50 %', u and math.abs(u.stats.oxygen - 50) <= 5, true)
W.ped.under = false

-- Ceinture attachée : choc encaissé (−beltDamage), pas d'éjection
W.calls = {}; W.ped.health = 200
enterVehicle(100)
commands['hud_seatbelt']()
W.veh.speed = 40; run(200)
check('ceinture attachée : choc de 100 à 40 km/h encaissé, pas d\'éjection', count('SetEntityCoords') == 0 and W.ped.health == 200 - Config.Seatbelt.beltDamage)
check('ceinture attachée : sortie du véhicule bloquée (contrôle 75)', (function() for _, c in ipairs(W.calls) do if c[1] == 'DisableControlAction' and c[3] == 75 then return true end end end)())
commands['hud_seatbelt']()

-- Sans ceinture : une seule éjection, joueur sorti avant la vitesse, pas d'éjection native en double
W.calls = {}; W.ped.health = 200; W.veh.speed = 100; W.ped.inVeh = W.veh.id; run(200)
local flagAtCrash = W.flags[32]
W.veh.speed = 40; run(200)
check('sans ceinture : choc de 100 à 40 km/h → une éjection', count('SetEntityCoords') == 1)
check('sans ceinture : dégâts d\'éjection appliqués', W.ped.health == 200 - Config.Seatbelt.ejectDamage)
local iRag, iVel = index('SetPedToRagdoll'), index('SetEntityVelocity')
check('éjection : ragdoll avant la vitesse (sinon la vitesse est perdue)', iRag and iVel and iRag < iVel, true)
check('sans ceinture : éjection native du jeu (flag 32) coupée, pour ne pas éjecter deux fois', flagAtCrash == false, true)

-- Freinage fort mais pas un choc : pas d'éjection
W.calls = {}; W.ped.health = 200; W.ped.inVeh = W.veh.id; W.veh.speed = 100; run(200)
W.veh.speed = 75; run(200)
check('freinage de 100 à 75 km/h : pas d\'éjection', count('SetEntityCoords') == 0)

-- Régulateur : maintient la vitesse, se coupe au freinage
W.calls = {}; W.ped.inVeh = W.veh.id; W.veh.speed = 80; run(200)
commands['hud_cruise']()
W.veh.speed = 70; run(100)
check('régulateur : accélère quand la vitesse tombe sous la consigne', count('SetControlNormal') > 0)
W.controls[72] = true; run(100); W.calls = {}; run(100)
check('régulateur : coupé au freinage (plus d\'accélération)', count('SetControlNormal') == 0)
W.controls[72] = nil

-- Minimap : DisplayRadar seulement quand l'état change (ne pas écraser cinema ni apex_minimap à chaque tick)
W.radar = {}; run(2000)
check('minimap : pas de DisplayRadar répété quand rien ne change', #W.radar <= 1, true)

-- Carburant : seuil d'alerte envoyé à l'UI = Config.Fuel.warn, et l'UI l'utilise (pas de 15 codé en dur)
local d = lastU()
check('carburant : seuil envoyé à l\'UI = Config.Fuel.warn', d and d.veh and d.veh.fuelWarn == Config.Fuel.warn)
local js = assert(io.open(DIR .. '/html/app.js')):read('a')
check('carburant : app.js lit fuelWarn au lieu d\'un seuil codé en dur', not js:find('fuel%s*<%s*15') and js:find('fuelWarn') ~= nil, true)

-- Notifications : texte nettoyé des codes de couleur GTA, envoyé à l'UI
W.nui = {}
local ok = exported['Notify']({ title = '~r~Alerte', description = 'Texte ~h~gras', type = 'error' })
local n = W.nui[#W.nui]
check('Notify : accepté et nettoyé (~r~, ~h~)', ok == true and n and n.t == 'notify' and n.d.title == 'Alerte' and n.d.text == 'Texte gras')

-- Notify : tous les codes de couleur GTA retirés (~br~, ~s~…) ; message vide → false (affichage d'origine)
W.nui = {}
local okBr = exported['Notify']({ description = 'Tu as reçu ~br~ 1x balle~s~ !', type = 'success' })
local nb = W.nui[#W.nui]
check('Notify : ~br~ et ~s~ retirés', okBr == true and nb and nb.d.text == 'Tu as reçu  1x balle !')
W.nui = {}
check('Notify : message vide refusé (false, rien envoyé à l\'UI)', exported['Notify']({ type = 'info' }) == false and #W.nui == 0)
check('Notify : message non texte refusé', exported['Notify']({ description = 42 }) == false)

-- F7 : mode cinéma du HUD, minimap cachée puis rendue
W.radar = {}; commands['hud_cinema'](); run(400)
local hidden = W.radar[#W.radar] == false
commands['hud_cinema'](); run(400)
check('F7 cinéma : minimap cachée puis réaffichée', hidden and W.radar[#W.radar] == true)

-- Moteur très abîmé : jauge bornée à 0 (le natif descend jusqu'à -4000)
W.ped.inVeh = W.veh.id; W.veh.speed = 30; W.veh.engine = -400.0; run(200)
local dv = lastU()
check('moteur : santé négative bornée à 0', dv and dv.veh and dv.veh.engine == 0, true)
W.veh.engine = nil

-- ESX : esx:setAccountMoney met à jour le compte reçu, sans attendre le rafraîchissement suivant
local h = handlers['esx:setAccountMoney']
if type(h) == 'table' then h = h[1] end
pcall(h, { name = 'bank', money = 12345 })
W.nui = {}; run(1200)
local slow
for i = #W.nui, 1, -1 do if W.nui[i].t == 's' then slow = W.nui[i].d break end end
check('ESX : esx:setAccountMoney(compte) met la banque à jour tout de suite', slow and slow.bank == 12345, true)

-- 1.7.1 : date du jeu lue sur l'horloge GTA quand GlobalState.gameDate est absent (aucune ressource ne la fournit)
function GetClockYear() return 2026 end
function GetClockMonth() return 6 end      -- 0 = janvier
function GetClockDayOfMonth() return 3 end
W.nui = {}; run(1200)
local sd
for i = #W.nui, 1, -1 do if W.nui[i].t == 's' then sd = W.nui[i].d break end end
check('date du jeu : horloge GTA (3 juillet 2026) sans GlobalState.gameDate',
  sd and type(sd.gameDate) == 'table' and sd.gameDate.year == 2026 and sd.gameDate.month == 7 and sd.gameDate.day == 3)

-- 1.7.1 : plus de trajet en cours envoyé à la page
W.ped.inVeh = W.veh.id; W.veh.class = 0; W.veh.speed = 50; run(300)
local tv = lastU()
check('trajet en cours retiré : ni trip ni km inventé', tv and tv.veh and tv.veh.trip == nil and tv.veh.km == nil)

-- 1.7.1 : décrochage selon le modèle, train rentré, en chute
local P = { agl = 100.0, vz = -5.0, gear = 4, max = 70.0 } -- max en m/s (252 km/h) → seuil 88 km/h
function GetEntityHeightAboveGround() return P.agl end
function GetEntityVelocity() return vector3(0.0, 0.0, P.vz) end
function GetLandingGearState() return P.gear end
function GetVehicleEstimatedMaxSpeed() return P.max end
local function plane(speed) W.veh.class = 16; W.veh.speed = speed; run(300); local d = lastU(); return d and d.veh end
check('avion lent (70 km/h), train rentré, en chute : DÉCROCHAGE', plane(70).stall == true)
check('avion à 120 km/h (au-dessus de 35 % de 252) : pas de décrochage', plane(120).stall == false)
P.gear = 0
check('approche train sorti à 70 km/h : pas de décrochage', plane(70).stall == false)
P.gear, P.vz = 4, 0.0
check('lent mais en palier (vitesse verticale nulle) : pas de décrochage', plane(70).stall == false)
P.vz, P.agl = -5.0, 10.0
check('près du sol (33 ft) : pas de décrochage', plane(70).stall == false)
W.veh.class = 0

-- 1.7.1 : radio du menu F9 sans station débloquée : pas d'erreur (modulo par 0)
local menus = {}
lib.registerContext = function(c) menus[c.id] = c end
lib.showContext = function() end
local GRS = GetResourceState
GetResourceState = function(r) return r == 'ox_lib' and 'started' or 'missing' end
function GetNumUnlockedRadioStations() return 0 end
function GetPlayerRadioStationName() return nil end
W.ped.inVeh = W.veh.id; W.veh.speed = 0
commands['hud_vehmenu']()
local radioOpt
for _, o in ipairs(menus.nh_vehicle and menus.nh_vehicle.options or {}) do if o.icon == 'radio' then radioOpt = o end end
local okRadio = radioOpt and pcall(radioOpt.onSelect)
GetResourceState = GRS
check('menu F9 : station suivante sans station débloquée, sans erreur', okRadio == true)
run(200)

-- Arrêt de la ressource : minimap rendue, éjection native rétablie
W.calls = {}
fire('onResourceStop', 'nocturne_hud')
check('arrêt : minimap réaffichée et flag 32 rétabli', W.radar[#W.radar] == true and W.flags[32] == true)

print(('RESULT %d passed, %d failed (%d défaut(s) connu(s) de la 1.6.0) ; doubles de natives, pas un essai GTA'):format(passed, failed, known))
os.exit(failed - known == 0 and 0 or 1)
