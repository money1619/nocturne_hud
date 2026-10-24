-- Nombre de joueurs connectés et slots du serveur, lus par le HUD (GlobalState répliqué)
local function update()
  GlobalState.nh_players = #GetPlayers()
end

GlobalState.nh_maxPlayers = GetConvarInt('sv_maxclients', Config.MaxPlayers)
AddEventHandler('playerJoining', function() update() end)
AddEventHandler('playerDropped', function() SetTimeout(500, update) end)
CreateThread(function() update() end)

-- Compteur kilométrique propre au HUD (aucune autre ressource) : km par plaque dans data/odometer.json.
-- Le serveur fait foi : le conducteur envoie de petits deltas, vérifiés, et lit le total sur le véhicule (state bag nh_km).
local ODO_FILE <const> = 'data/odometer.json'
local REPORT_MIN_MS <const> = 2000   -- un envoi toutes les 2 s au plus par joueur
local REPORT_MAX_KMS <const> = 0.15  -- km par seconde écoulée acceptés au plus (540 km/h)
local odo, odoDirty, lastReport, lastDriven = {}, false, {}, {} -- lastDriven[src] = { veh, à quel moment }

do
  local raw = LoadResourceFile(GetCurrentResourceName(), ODO_FILE)
  local ok, t = pcall(json.decode, raw or '')
  if ok and type(t) == 'table' then odo = t end
end

local function norm(plate) return type(plate) == 'string' and plate:gsub('^%s+', ''):gsub('%s+$', ''):upper() or nil end

local function saveOdo()
  if not odoDirty then return end
  odoDirty = false
  SaveResourceFile(GetCurrentResourceName(), ODO_FILE, json.encode(odo), -1)
end

local function publish(veh, plate)
  Entity(veh).state:set('nh_km', math.floor((odo[plate] or 0) * 100 + 0.5) / 100, true)
end

-- Véhicule conduit par ce joueur (ou quitté il y a moins de 15 s, pour la distance envoyée en descendant) :
-- entité serveur et plaque, nil sinon
local function drivenBy(src, netId)
  if type(netId) ~= 'number' then return end
  local veh = NetworkGetEntityFromNetworkId(netId)
  if veh == 0 or not DoesEntityExist(veh) then return end
  local now, ld = GetGameTimer(), lastDriven[src]
  if GetPedInVehicleSeat(veh, -1) == GetPlayerPed(src) then lastDriven[src] = { veh = veh, at = now }
  elseif not (ld and ld.veh == veh and now - ld.at < 15000) then return end
  local plate = norm(GetVehicleNumberPlateText(veh))
  if plate and plate ~= '' then return veh, plate end
end

-- À l'entrée dans un véhicule (conducteur ou passager) : publie le compteur pour l'afficher tout de suite
RegisterNetEvent('nocturne_hud:odoRequest', function(netId)
  local src = source
  if type(netId) ~= 'number' then return end
  local veh = NetworkGetEntityFromNetworkId(netId)
  if veh == 0 or not DoesEntityExist(veh) or GetVehiclePedIsIn(GetPlayerPed(src), false) ~= veh then return end
  if GetPedInVehicleSeat(veh, -1) == GetPlayerPed(src) then lastDriven[src] = { veh = veh, at = GetGameTimer() } end
  local plate = norm(GetVehicleNumberPlateText(veh))
  if plate and plate ~= '' then publish(veh, plate) end
end)

RegisterNetEvent('nocturne_hud:odoAdd', function(netId, km)
  local src = source
  km = tonumber(km)
  if not km or km ~= km or km <= 0 then return end
  local now = GetGameTimer()
  local last = lastReport[src]
  if last and now - last < REPORT_MIN_MS then return end
  local veh, plate = drivenBy(src, netId)
  if not veh then return end
  lastReport[src] = now
  local maxKm = REPORT_MAX_KMS * math.min(60, (now - (last or now - 10000)) / 1000)
  odo[plate] = (odo[plate] or 0) + math.min(km, maxKm)
  odoDirty = true
  publish(veh, plate)
end)

AddEventHandler('playerDropped', function() lastReport[source], lastDriven[source] = nil, nil end)
CreateThread(function() while true do Wait(60000); saveOdo() end end)
AddEventHandler('onResourceStop', function(res) if res == GetCurrentResourceName() then saveOdo() end end)
