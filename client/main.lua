local T = ({
  fr = { seatbelt = 'HUD · Ceinture', left = 'HUD · Clignotant gauche', right = 'HUD · Clignotant droit', hazard = 'HUD · Warnings',
         limiter = 'HUD · Limiteur de vitesse', cruise = 'HUD · Régulateur de vitesse', anchor = 'HUD · Ancre (bateau)', cinema = 'HUD · Mode cinématique', vmenu = 'HUD · Menu véhicule',
         m_title = 'Véhicule', m_engine = 'Moteur', m_lights = 'Phares', m_doors = 'Portes', m_windows = 'Fenêtres', m_seats = 'Changer de siège',
         m_radio = 'Radio', m_radio_next = 'Station suivante', m_radio_off = 'Éteindre la radio', m_on = 'Allumé', m_off = 'Éteint',
         m_open = 'Ouverte', m_closed = 'Fermée', m_down = 'Baissée', m_up = 'Montée', m_all_open = 'Tout ouvrir', m_all_close = 'Tout fermer',
         m_free = 'Libre', m_taken = 'Occupé', m_driver = 'Conducteur', m_passenger = 'Passager', m_back = 'Arrière', m_slow = 'Arrêtez-vous d\'abord',
         m_only_driver = 'Réservé au conducteur', m_lights_auto = 'Auto', m_lights_on = 'Allumés', m_lights_off = 'Éteints',
         doors = { 'Avant gauche', 'Avant droite', 'Arrière gauche', 'Arrière droite', 'Capot', 'Coffre' } },
  en = { seatbelt = 'HUD · Seatbelt', left = 'HUD · Left indicator', right = 'HUD · Right indicator', hazard = 'HUD · Hazard lights',
         limiter = 'HUD · Speed limiter', cruise = 'HUD · Cruise control', anchor = 'HUD · Anchor (boat)', cinema = 'HUD · Cinematic mode', vmenu = 'HUD · Vehicle menu',
         m_title = 'Vehicle', m_engine = 'Engine', m_lights = 'Headlights', m_doors = 'Doors', m_windows = 'Windows', m_seats = 'Change seat',
         m_radio = 'Radio', m_radio_next = 'Next station', m_radio_off = 'Turn radio off', m_on = 'On', m_off = 'Off',
         m_open = 'Open', m_closed = 'Closed', m_down = 'Down', m_up = 'Up', m_all_open = 'Open all', m_all_close = 'Close all',
         m_free = 'Free', m_taken = 'Taken', m_driver = 'Driver', m_passenger = 'Passenger', m_back = 'Rear', m_slow = 'Stop first',
         m_only_driver = 'Driver only', m_lights_auto = 'Auto', m_lights_on = 'On', m_lights_off = 'Off',
         doors = { 'Front left', 'Front right', 'Rear left', 'Rear right', 'Hood', 'Trunk' } },
})[Config.Locale] or {}
local QB, ESX
local needs = { hunger = 100, thirst = 100, stress = 0 }
local drugs = { toxicity = 0, addiction = 0, alcohol = 0 } -- AEOM_DRUG_SYSTEM (0-100)
local money = { cash = 0, bank = 0 }
local job = ''
local hideMap, mapVeh = false, false
local editing = false

-- état véhicule géré par le HUD
local trip, tripPos = 0.0, nil
local blinkHead, blinkTurned = 0.0, false   -- clignotant : cap de départ, virage effectué
local fuelRef, tripRef, fuelWarned = nil, 0.0, false
local cinema = false -- km parcourus depuis l'entrée dans le véhicule
local belt, blink, cruise, cruiseSpd, anchor = false, 0, nil, 0, false -- blink: 0 off, 1 gauche, 2 droite, 3 warnings
local lastVeh = 0

---------------------------------------------------------------- framework
local function refreshQB()
  local pd = QB.Functions.GetPlayerData()
  if not pd or not pd.money then return end
  money.cash, money.bank = pd.money.cash or 0, pd.money.bank or 0
  if pd.job then
    local l, g = pd.job.label or '', pd.job.grade and pd.job.grade.name
    job = (g and g ~= '' and g:lower() ~= l:lower() and pd.job.name ~= 'unemployed') and (l .. ' · ' .. g) or l
  end
  local m = pd.metadata or {}
  needs.hunger = m.hunger or needs.hunger
  needs.thirst = m.thirst or needs.thirst
  needs.stress = m.stress or needs.stress
end

local function refreshESX()
  local pd = ESX.GetPlayerData()
  if not pd then return end
  for _, a in ipairs(pd.accounts or {}) do
    if a.name == 'money' then money.cash = a.money elseif a.name == 'bank' then money.bank = a.money end
  end
  if pd.job then
    local l, g = pd.job.label or '', pd.job.grade_label
    job = (g and g ~= '' and g:lower() ~= l:lower() and pd.job.name ~= 'unemployed') and (l .. ' · ' .. g) or l
  end
end

CreateThread(function()
  local fw = Config.Framework
  local tries = 0
  -- Le framework peut démarrer après le HUD : nouvelle tentative pendant ~1 min
  while not QB and not ESX and fw ~= 'standalone' and tries < 30 do
    if (fw == 'auto' or fw == 'qb') and GetResourceState('qb-core') == 'started' then
      QB = exports['qb-core']:GetCoreObject()
    elseif (fw == 'auto' or fw == 'esx') and GetResourceState('es_extended') == 'started' then
      ESX = exports['es_extended']:getSharedObject()
    else
      tries = tries + 1
      Wait(2000)
    end
  end
  while true do
    if QB then pcall(refreshQB) elseif ESX then pcall(refreshESX) end
    Wait(2000)
  end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function() if QB then refreshQB() end end)
RegisterNetEvent('hud:client:UpdateNeeds', function(h, t) needs.hunger, needs.thirst = h or needs.hunger, t or needs.thirst end)
RegisterNetEvent('hud:client:UpdateStress', function(s) needs.stress = s or needs.stress end)
RegisterNetEvent('esx:setAccountMoney', function() if ESX then refreshESX() end end)
RegisterNetEvent('esx:setJob', function() if ESX then refreshESX() end end)
RegisterNetEvent('esx:playerLoaded', function() if ESX then refreshESX() end end)
AddEventHandler('esx_status:onTick', function(st)
  for _, s in ipairs(st or {}) do
    if s.name == 'hunger' then needs.hunger = s.percent
    elseif s.name == 'thirst' then needs.thirst = s.percent
    elseif s.name == 'stress' then needs.stress = s.percent end
  end
end)

-- API pour d'autres ressources (standalone ou custom)
exports('SetNeeds', function(h, t, s) needs.hunger = h or needs.hunger; needs.thirst = t or needs.thirst; needs.stress = s or needs.stress end)
exports('SetMoney', function(c, b) money.cash = c or money.cash; money.bank = b or money.bank end)
exports('SetJob', function(label) job = label or '' end)

-- Jauges toxicité / addiction / alcool : envoyées par AEOM_DRUG_SYSTEM à chaque changement
local function setDrugs(d)
  if type(d) ~= 'table' then return end
  for k in pairs(drugs) do
    local v = tonumber(d[k])
    if v then drugs[k] = math.max(0, math.min(100, v)) end
  end
end
AddEventHandler('nocturne_hud:drugStats', setDrugs)
CreateThread(function() -- valeurs actuelles si le HUD (re)démarre après AEOM
  Wait(2000)
  if GetResourceState('AEOM_DRUG_SYSTEM') == 'started' then
    local ok, st = pcall(function() return exports.AEOM_DRUG_SYSTEM:GetPlayerState() end)
    if ok then setDrugs(st) end
  end
end)
AddEventHandler('onResourceStop', function(res)
  if res == 'AEOM_DRUG_SYSTEM' then drugs.toxicity, drugs.addiction, drugs.alcohol = 0, 0, 0 end
end)
exports('IsSeatbeltOn', function() return belt end)

---------------------------------------------------------------- helpers
-- position réelle de la minimap native (fractions de l'écran)
local function minimapAnchor()
  local sz = GetSafeZoneSize()
  local aspect = GetAspectRatio(false)
  local off = math.abs(sz - 1.0) * 10 * 0.05
  local s = Config.MinimapScale or 1.0
  local w = 1.0 / (4 * aspect) * s
  local h = 1.0 / 5.674 * s
  -- Décalage du cadre en pixels (base 1080p) : Config.MinimapFrameOffset, pour coller au bord de la carte native
  local nudge = Config.MinimapFrameOffset or {}
  local x = off + (nudge.x or 0) / (1080 * aspect)
  local bottom = 1.0 - off + (nudge.y or 0) / 1080
  return { x = x, y = bottom - h, w = w, h = h }
end

local CLS = { [8] = 'moto', [13] = 'bike', [14] = 'boat', [15] = 'heli', [16] = 'plane' }

local fuelRes, mileageRes = false, false -- rafraîchis chaque seconde (boucle lente)

local function fuelOf(veh)
  if fuelRes then
    local ok, v = pcall(function() return exports[Config.FuelResource]:GetFuel(veh) end)
    if ok and v then return v end
  end
  return GetVehicleFuelLevel(veh)
end

local function myVeh()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then return veh, true end
  return veh, false
end

local function resetVeh(oldVeh)
  if cruise == 'limit' and oldVeh and DoesEntityExist(oldVeh) then SetVehicleMaxSpeed(oldVeh, 0.0) end
  belt, blink, cruise, anchor = false, 0, nil, false
  SetPedConfigFlag(PlayerPedId(), 32, true)
end

---------------------------------------------------------------- keybinds
RegisterCommand('hud_seatbelt', function()
  local veh = GetVehiclePedIsIn(PlayerPedId(), false)
  if veh == 0 then return end
  local c = GetVehicleClass(veh)
  if c == 8 or c == 13 or c == 14 then return end
  belt = not belt
  SetPedConfigFlag(PlayerPedId(), 32, not belt)
end, false)

local function setBlink(v)
  local veh, drv = myVeh()
  if veh == 0 or not drv then return end
  blink = (blink == v) and 0 or v
  blinkHead, blinkTurned = GetEntityHeading(veh), false
  SetVehicleIndicatorLights(veh, 1, blink == 1 or blink == 3) -- gauche
  SetVehicleIndicatorLights(veh, 0, blink == 2 or blink == 3) -- droite
end
RegisterCommand('hud_left', function() setBlink(1) end, false)
RegisterCommand('hud_right', function() setBlink(2) end, false)
RegisterCommand('hud_hazard', function() setBlink(3) end, false)

local function setCruise(mode)
  local veh, drv = myVeh()
  if veh == 0 or not drv then return end
  local c = GetVehicleClass(veh)
  if CLS[c] and CLS[c] ~= 'moto' then return end
  if cruise == mode then
    cruise = nil
    SetVehicleMaxSpeed(veh, 0.0)
    return
  end
  local kmh = GetEntitySpeed(veh) * 3.6
  if mode == 'cruise' and kmh < 25 then return end
  cruiseSpd = math.max(mode == 'cruise' and 30 or 20, math.floor(kmh / 5 + 0.5) * 5)
  if cruiseSpd == 0 then cruiseSpd = 50 end
  cruise = mode
  if mode == 'limit' then SetVehicleMaxSpeed(veh, cruiseSpd / 3.6) else SetVehicleMaxSpeed(veh, 0.0) end
end
RegisterCommand('hud_limiter', function() setCruise('limit') end, false)
RegisterCommand('hud_cruise', function() setCruise('cruise') end, false)

local function toggleAnchor()
  local veh, drv = myVeh()
  if veh == 0 or not drv or GetVehicleClass(veh) ~= 14 then return end
  if not anchor and not CanAnchorBoatHere(veh) then return end
  anchor = not anchor
  SetBoatAnchor(veh, anchor)
  SetBoatFrozenWhenAnchored(veh, anchor)
end
RegisterCommand('ancre', toggleAnchor, false)
RegisterCommand('hud_anchor', toggleAnchor, false)

RegisterKeyMapping('hud_seatbelt', T.seatbelt, 'keyboard', Config.Keys.seatbelt)
RegisterKeyMapping('hud_left', T.left, 'keyboard', Config.Keys.indicatorLeft)
RegisterKeyMapping('hud_right', T.right, 'keyboard', Config.Keys.indicatorRight)
RegisterKeyMapping('hud_hazard', T.hazard, 'keyboard', Config.Keys.hazard)
RegisterKeyMapping('hud_limiter', T.limiter, 'keyboard', Config.Keys.limiter)
RegisterKeyMapping('hud_cruise', T.cruise, 'keyboard', Config.Keys.cruise)
RegisterKeyMapping('hud_anchor', T.anchor, 'keyboard', Config.Keys.anchor or '')

RegisterCommand('hud_cinema', function()
  cinema = not cinema
  SendNUIMessage({ t = 'cinema', on = cinema })
end, false)
RegisterKeyMapping('hud_cinema', T.cinema, 'keyboard', Config.Keys.cinema or '')

-- Notifications au style du HUD (appelé par ox_lib et esx_notify) ; false = laisser l'affichage d'origine
exports('Notify', function(data)
  local N = Config.Notifications
  if not (N and N.enabled) or type(data) ~= 'table' then return false end
  local function clean(s) return type(s) == 'string' and s:gsub('~%a~', ''):gsub('~h~', '') or nil end
  SendNUIMessage({ t = 'notify', d = {
    title = clean(data.title), text = clean(data.description), type = data.type or 'info',
    duration = tonumber(data.duration) or N.duration or 5000,
  } })
  return true
end)

---------------------------------------------------------------- réglages
RegisterCommand(Config.SettingsCommand, function()
  editing = true
  SetNuiFocus(true, true)
  SendNUIMessage({ t = 'edit' })
end, false)

RegisterNUICallback('close', function(_, cb)
  editing = false
  SetNuiFocus(false, false)
  cb('ok')
end)

RegisterNUICallback('cfg', function(d, cb)
  hideMap = d and d.hideMap == true
  mapVeh = d and d.mapVeh == true
  cb('ok')
end)

---------------------------------------------------------------- minimap : taille + barres natives
CreateThread(function()
  local s = Config.MinimapScale or 1.0
  if s ~= 1.0 then
    SetMinimapComponentPosition('minimap', 'L', 'B', -0.0045, 0.002 * s, 0.150 * s, 0.188888 * s)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.020 * s, 0.032 * s, 0.111 * s, 0.159 * s)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.03 * s, 0.022 * s, 0.266 * s, 0.237 * s)
  end
  SetRadarBigmapEnabled(true, false); Wait(0); SetRadarBigmapEnabled(false, false)
  if not Config.HideMinimapBars then return end
  local mm = RequestScaleformMovie('minimap')
  while not HasScaleformMovieLoaded(mm) do Wait(0) end
  while true do
    BeginScaleformMovieMethod(mm, 'SETUP_HEALTH_ARMOUR')
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()
    Wait(100)
  end
end)

---------------------------------------------------------------- boucle par frame (contrôles)
CreateThread(function()
  while true do
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    for _, c in ipairs(Config.HideNative) do HideHudComponentThisFrame(c) end
    if veh ~= 0 then
      if belt then DisableControlAction(0, 75, true) end -- pas de sortie ceinture attachée
      if cruise == 'cruise' and GetPedInVehicleSeat(veh, -1) == ped then
        if IsControlPressed(0, 72) or IsControlPressed(0, 76) or HasEntityCollidedWithAnything(veh) then
          cruise = nil
        elseif not IsControlPressed(0, 71) and GetEntitySpeed(veh) * 3.6 < cruiseSpd - 0.5 and IsVehicleOnAllWheels(veh) then
          SetControlNormal(0, 71, 0.85)
        end
      end
    end
    Wait(0)
  end
end)

---------------------------------------------------------------- portée de voix : cercle au sol
local circleUntil, circleDist, lastProx = 0, 0, nil
function showVoiceCircle(dist)
  local VC = Config.VoiceCircle
  if not (VC and VC.enabled) or not dist then return end
  local running = GetGameTimer() < circleUntil
  circleUntil, circleDist = GetGameTimer() + VC.duration, dist
  if running then return end
  CreateThread(function()
    local c = VC.color
    while GetGameTimer() < circleUntil do
      local left = circleUntil - GetGameTimer()
      local a = math.floor(math.min(1.0, left / 600) * 170)           -- fondu sur la fin
      local p = GetEntityCoords(PlayerPedId())
      local d = circleDist * 2.0
      DrawMarker(25, p.x, p.y, p.z - 0.97, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, d, d, 1.0, c.r, c.g, c.b, a, false, false, 2, false, nil, nil, false)
      DrawMarker(1, p.x, p.y, p.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, d, d, 0.25, c.r, c.g, c.b, math.floor(a * 0.25), false, false, 2, false, nil, nil, false)
      Wait(0)
    end
  end)
end

---------------------------------------------------------------- ceinture : choc violent
local prevSpeed = 0
local function crashCheck(veh, ped)
  local S = Config.Seatbelt
  local kmh = GetEntitySpeed(veh) * 3.6
  local before = prevSpeed
  prevSpeed = kmh
  local c = GetVehicleClass(veh)
  if not (S and S.enabled) or c == 8 or (c >= 13 and c <= 16) or c == 21 then return end -- motos, vélos, bateaux, aériens, trains
  if before < S.ejectSpeed or before - kmh < S.ejectDrop then return end
  if belt then
    SetEntityHealth(ped, math.max(101, GetEntityHealth(ped) - S.beltDamage))
    return
  end
  -- Éjection par le pare-brise, dans le sens de la marche
  local fwd = GetEntityForwardVector(veh)
  local pos = GetEntityCoords(ped)
  SetEntityCoords(ped, pos.x + fwd.x, pos.y + fwd.y, pos.z + 0.5, false, false, false, false)
  SetEntityVelocity(ped, fwd.x * before / 3.6 * 0.8, fwd.y * before / 3.6 * 0.8, 2.0)
  SetPedToRagdoll(ped, 4000, 4000, 0, false, false, false)
  SetEntityHealth(ped, math.max(101, GetEntityHealth(ped) - S.ejectDamage))
  prevSpeed = 0
end

---------------------------------------------------------------- envoi au HUD
local lastSprint, staminaInverted = 0, false
local function stats(ped)
  local hp = math.max(0, GetEntityHealth(ped) - 100) / math.max(1, GetEntityMaxHealth(ped) - 100) * 100
  local pid = PlayerId()
  -- Selon la build, le natif renvoie l'endurance restante (100 = reposé) ou consommée (0 = reposé).
  -- Calibrage : après 20 s sans sprint, le joueur est reposé, la valeur brute dit dans quel sens lire
  local raw = GetPlayerSprintStaminaRemaining(pid)
  if IsPedSprinting(ped) or IsPedRunning(ped) then lastSprint = GetGameTimer()
  elseif GetGameTimer() - lastSprint > 20000 then
    if raw >= 90 then staminaInverted = false elseif raw <= 10 then staminaInverted = true end
  end
  local stam = math.max(0, math.min(100, staminaInverted and 100 - raw or raw))
  local oxy = 100
  if IsPedSwimmingUnderWater(ped) then oxy = math.max(0, math.min(100, GetPlayerUnderwaterTimeRemaining(pid) * 10)) end
  return {
    health = math.floor(hp + 0.5), armor = GetPedArmour(ped),
    hunger = math.floor(needs.hunger + 0.5), thirst = math.floor(needs.thirst + 0.5), stress = math.floor(needs.stress + 0.5),
    stamina = math.floor(stam + 0.5), oxygen = math.floor(oxy + 0.5),
    toxicity = math.floor(drugs.toxicity + 0.5), addiction = math.floor(drugs.addiction + 0.5), alcohol = math.floor(drugs.alcohol + 0.5),
  }, IsPedSwimmingUnderWater(ped)
end

local function vehicleData(veh)
  local c = GetVehicleClass(veh)
  local cls = CLS[c] or 'car'
  local speed = GetEntitySpeed(veh) * 3.6
  local gear = GetVehicleCurrentGear(veh)
  local _, on, high = GetVehicleLightsState(veh)
  local d = {
    cls = cls, speed = speed, rpm = GetVehicleCurrentRpm(veh),
    gear = speed < 1 and 'N' or (gear == 0 and 'R' or tostring(gear)),
    fuel = fuelOf(veh), engine = GetVehicleEngineHealth(veh) / 10,
    belt = belt, lights = (high == 1) and 2 or ((on == 1) and 1 or 0),
    blink = blink, cruise = cruise, cruiseSpd = cruiseSpd, anchor = anchor,
  }
  -- Compteur kilométrique : réel pour les véhicules possédés (vehicle_mileage), sinon compteur « d'occasion »
  -- stable déduit de la plaque (même véhicule = même valeur) + distance parcourue depuis qu'on y est monté
  if mileageRes then
    local ok, km = pcall(function() return exports.vehicle_mileage:GetMileageKm(veh) end)
    if ok and km then d.km = km end
  end
  if not d.km and cls ~= 'bike' then
    local plate, h = GetVehicleNumberPlateText(veh) or '', 0
    for i = 1, #plate do h = (h * 31 + plate:byte(i)) % 1000003 end
    d.km = 8000 + h % 152000 + trip
  end
  d.trip = trip
  -- Autonomie : consommation mesurée depuis l'entrée (ou le dernier plein)
  local fuel = d.fuel or 0
  if not fuelRef or fuel > fuelRef + 1.0 then fuelRef, tripRef = fuel, trip end
  local used, dist = fuelRef - fuel, trip - tripRef
  if used > 0.5 and dist > 0.5 then d.range = fuel / (used / dist) end
  local F = Config.Fuel or {}
  if cls ~= 'bike' and fuel < (F.warn or 10) then
    if not fuelWarned then fuelWarned = true; PlaySoundFrontend(-1, 'Beep_Red', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true) end
  elseif fuel > (F.warn or 10) + 2 then fuelWarned = false end
  d.fuelWarn, d.fuelRange = F.warn or 10, F.showRange or 25
  if cls == 'heli' or cls == 'plane' then
    d.alt = GetEntityHeightAboveGround(veh) * 3.281
    local v = GetEntityVelocity(veh)
    d.vs = v.z * 196.85
    if cls == 'plane' then local st = GetLandingGearState(veh); d.gearDown = (st == 0 or st == 2) end
    if cls == 'heli' then d.rpm = GetHeliMainRotorHealth(veh) > 0 and (GetIsVehicleEngineRunning(veh) and 0.9 or 0.3) or 0 end
  end
  return d
end

CreateThread(function()
  while true do
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= lastVeh then if lastVeh ~= 0 then resetVeh(lastVeh) end lastVeh = veh; prevSpeed = 0; trip, tripPos = 0.0, nil; fuelRef, fuelWarned = nil, false end
    if veh ~= 0 then
      local p = GetEntityCoords(veh)
      if tripPos then local dd = #(p - tripPos); if dd < 60.0 then trip = trip + dd / 1000.0 end end -- au-delà : téléportation
      tripPos = p
    end
    if veh ~= 0 then
      crashCheck(veh, ped)
      if (blink == 1 or blink == 2) and GetPedInVehicleSeat(veh, -1) == ped then
        local diff = math.abs((GetEntityHeading(veh) - blinkHead + 180.0) % 360.0 - 180.0)
        if diff > 45.0 then blinkTurned = true end
        if blinkTurned and math.abs(GetVehicleSteeringAngle(veh)) < 4.0 then
          blink = 0
          SetVehicleIndicatorLights(veh, 0, false); SetVehicleIndicatorLights(veh, 1, false)
        end
      end
    end

    local st, under = stats(ped)

    local weapon
    local w = GetSelectedPedWeapon(ped)
    if w ~= `WEAPON_UNARMED` and IsPedArmed(ped, 4) then
      local _, clip = GetAmmoInClip(ped, w)
      local total = GetAmmoInPedWeapon(ped, w)
      weapon = { clip = clip, reserve = math.max(0, total - clip) }
    end

    local voice = { talking = NetworkIsPlayerTalking(PlayerId()), range = 1, radio = false }
    local prox = LocalPlayer.state.proximity
    if prox and prox.index then
      voice.range = math.max(0, math.min(2, prox.index - 1))
      if lastProx and lastProx ~= prox.index then showVoiceCircle(prox.distance) end
      lastProx = prox.index
    end
    local rc = LocalPlayer.state.radioChannel
    voice.radio = rc ~= nil and rc ~= 0

    DisplayRadar(not cinema and not hideMap and (not (Config.MinimapOnlyInVehicle or mapVeh) or veh ~= 0))

    SendNUIMessage({ t = 'u', d = {
      show = not cinema and not IsPauseMenuActive() and not IsScreenFadedOut() and not IsHudHidden(),
      stats = st, underwater = under,
      sprint = IsPedSprinting(ped),
      heading = (360 - GetEntityHeading(ped)) % 360,
      weapon = weapon, voice = voice,
      veh = veh ~= 0 and vehicleData(veh) or nil,
    }})
    Wait(veh ~= 0 and Config.TickInVehicle or Config.TickOnFoot)
  end
end)

---------------------------------------------------------------- données lentes (1 x / s, envoyées seulement si changées)
local lastSlow = ''
CreateThread(function()
  while true do
    fuelRes = Config.FuelResource and GetResourceState(Config.FuelResource) == 'started' or false
    mileageRes = GetResourceState('vehicle_mileage') == 'started'
    local coords = GetEntityCoords(PlayerPedId())
    local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(s1)
    if s2 ~= 0 then street = street .. ' / ' .. GetStreetNameFromHashKey(s2) end
    local d = {
      id = GetPlayerServerId(PlayerId()),
      players = GlobalState.nh_players or #GetActivePlayers(),           -- total serveur (OneSync : GetActivePlayers = joueurs proches)
      maxPlayers = GlobalState.nh_maxPlayers or Config.MaxPlayers,
      cash = money.cash, bank = money.bank, job = job,
      street = street, zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z)),
      map = minimapAnchor(),
      gameTime = ('%02d:%02d'):format(GetClockHours(), GetClockMinutes()),
      gameDate = GlobalState.gameDate,
      lang = Config.Locale, hour = GetClockHours(),
    }
    local enc = json.encode(d)
    if enc ~= lastSlow then lastSlow = enc; SendNUIMessage({ t = 's', d = d }) end
    Wait(1000)
  end
end)

-- Arrêt / redémarrage de la ressource : rend la souris et la minimap
AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  if editing then SetNuiFocus(false, false) end
  DisplayRadar(true)
  local veh = GetVehiclePedIsIn(PlayerPedId(), false)
  if cruise == 'limit' and veh ~= 0 then SetVehicleMaxSpeed(veh, 0.0) end
  SetPedConfigFlag(PlayerPedId(), 32, true)
end)

---------------------------------------------------------------- menu véhicule (ox_lib)
local winDown = {}   -- [veh] = { [index] = true } : fenêtres baissées (le jeu n'expose pas cet état)
local lightMode = {} -- [veh] = 0 auto, 1 éteints, 2 allumés

local function vehNow()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh == 0 then return nil end
  return veh, GetPedInVehicleSeat(veh, -1) == ped, ped
end

local openVehicleMenu
local function back() SetTimeout(0, function() openVehicleMenu() end) end

local function doorsMenu(veh)
  local opts = {}
  for i = 0, 5 do
    if GetIsDoorValid(veh, i) and not IsVehicleDoorDamaged(veh, i) then
      local open = GetVehicleDoorAngleRatio(veh, i) > 0.05
      opts[#opts + 1] = { title = T.doors[i + 1], description = open and T.m_open or T.m_closed, icon = open and 'door-open' or 'door-closed',
        onSelect = function()
          if GetVehicleDoorAngleRatio(veh, i) > 0.05 then SetVehicleDoorShut(veh, i, false) else SetVehicleDoorOpen(veh, i, false, false) end
          SetTimeout(350, function() doorsMenu(veh) end)
        end }
    end
  end
  opts[#opts + 1] = { title = T.m_all_open, icon = 'up-right-from-square', onSelect = function()
    for i = 0, 5 do if GetIsDoorValid(veh, i) then SetVehicleDoorOpen(veh, i, false, false) end end
    SetTimeout(350, function() doorsMenu(veh) end) end }
  opts[#opts + 1] = { title = T.m_all_close, icon = 'lock', onSelect = function()
    SetVehicleDoorsShut(veh, false); SetTimeout(350, function() doorsMenu(veh) end) end }
  lib.registerContext({ id = 'nh_doors', title = T.m_doors, menu = 'nh_vehicle', options = opts })
  lib.showContext('nh_doors')
end

local function windowsMenu(veh, driver, ped)
  local opts, mine = {}, nil
  for s = -1, 2 do if GetPedInVehicleSeat(veh, s) == ped then mine = s + 1 end end -- index de fenêtre du siège occupé
  winDown[veh] = winDown[veh] or {}
  for i = 0, 3 do
    if driver or i == mine then
      local down = winDown[veh][i]
      opts[#opts + 1] = { title = T.doors[i + 1], description = down and T.m_down or T.m_up, icon = down and 'arrow-down' or 'arrow-up',
        onSelect = function()
          if winDown[veh][i] then RollUpWindow(veh, i); winDown[veh][i] = nil else RollDownWindow(veh, i); winDown[veh][i] = true end
          windowsMenu(veh, driver, ped)
        end }
    end
  end
  lib.registerContext({ id = 'nh_windows', title = T.m_windows, menu = 'nh_vehicle', options = opts })
  lib.showContext('nh_windows')
end

local function seatsMenu(veh, ped)
  local opts = {}
  local n = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
  for s = -1, n - 2 do
    local occ = GetPedInVehicleSeat(veh, s)
    local label = s == -1 and T.m_driver or (s == 0 and T.m_passenger or (T.m_back .. ' ' .. s))
    opts[#opts + 1] = { title = label, description = occ == ped and '✓' or (occ == 0 and T.m_free or T.m_taken), icon = 'chair',
      disabled = occ ~= 0,
      onSelect = function()
        if GetEntitySpeed(veh) * 3.6 > 5 then return lib.notify({ type = 'error', description = T.m_slow }) end
        if IsVehicleSeatFree(veh, s) then SetPedIntoVehicle(ped, veh, s) end
      end }
  end
  lib.registerContext({ id = 'nh_seats', title = T.m_seats, menu = 'nh_vehicle', options = opts })
  lib.showContext('nh_seats')
end

openVehicleMenu = function()
  local veh, driver, ped = vehNow()
  if not veh or GetResourceState('ox_lib') ~= 'started' then return end
  local engineOn = GetIsVehicleEngineRunning(veh)
  local _, lon, lhigh = GetVehicleLightsState(veh)
  local lm = lightMode[veh] or 0
  local function needDriver(fn) return function() if not driver then return lib.notify({ type = 'error', description = T.m_only_driver }) end fn() end end
  local opts = {
    { title = T.m_engine, description = engineOn and T.m_on or T.m_off, icon = 'power-off', iconColor = engineOn and '#6fcf97' or '#e5676b', disabled = not driver,
      onSelect = needDriver(function()
        SetVehicleEngineOn(veh, not GetIsVehicleEngineRunning(veh), false, true) -- true : le moteur ne redémarre pas tout seul
        back()
      end) },
    { title = T.m_lights, description = ({ [0] = T.m_lights_auto, T.m_lights_off, T.m_lights_on })[lm], icon = 'lightbulb',
      iconColor = (lon == 1 or lhigh == 1) and '#e0c96a' or nil, disabled = not driver,
      onSelect = needDriver(function()
        lm = (lm + 1) % 3; lightMode[veh] = lm
        SetVehicleLights(veh, lm) -- 0 normal, 1 éteints forcés, 2 allumés forcés
        back()
      end) },
    { title = T.m_doors, icon = 'car-side', arrow = true, disabled = not driver, onSelect = needDriver(function() doorsMenu(veh) end) },
    { title = T.m_windows, icon = 'wind', arrow = true, onSelect = function() windowsMenu(veh, driver, ped) end },
    { title = T.m_radio, description = GetPlayerRadioStationName() and GetLabelText(GetPlayerRadioStationName()) or T.m_off, icon = 'radio',
      onSelect = function() SetVehicleRadioEnabled(veh, true); SetRadioToStationIndex((GetPlayerRadioStationIndex() + 1) % GetNumUnlockedRadioStations()); back() end },
    { title = T.m_radio_off, icon = 'volume-xmark', onSelect = function() SetVehRadioStation(veh, 'OFF'); back() end },
    { title = T.m_seats, icon = 'chair', arrow = true, onSelect = function() seatsMenu(veh, ped) end },
  }
  lib.registerContext({ id = 'nh_vehicle', title = T.m_title, options = opts })
  lib.showContext('nh_vehicle')
end

RegisterCommand('hud_vehmenu', function()
  if lib and lib.getOpenContextMenu and lib.getOpenContextMenu() then return lib.hideContext(true) end
  openVehicleMenu()
end, false)
RegisterKeyMapping('hud_vehmenu', T.vmenu, 'keyboard', Config.Keys.vehicleMenu or '')

-- Nettoyage des états de véhicules disparus
CreateThread(function()
  while true do
    Wait(60000)
    for v in pairs(winDown) do if not DoesEntityExist(v) then winDown[v] = nil end end
    for v in pairs(lightMode) do if not DoesEntityExist(v) then lightMode[v] = nil end end
  end
end)
