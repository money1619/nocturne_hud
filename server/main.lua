-- Nombre de joueurs connectés et slots du serveur, lus par le HUD (GlobalState répliqué)
local function update()
  GlobalState.nh_players = #GetPlayers()
end

GlobalState.nh_maxPlayers = GetConvarInt('sv_maxclients', Config.MaxPlayers)
AddEventHandler('playerJoining', function() update() end)
AddEventHandler('playerDropped', function() SetTimeout(500, update) end)
CreateThread(function() update() end)
