-- Test hors jeu du crochet posé dans jg-mechanic (framework/cl-functions.lua, Framework.Client.ToggleHud) :
-- extrait la VRAIE fonction du fichier installé et vérifie l'ordre : jg-hud, sinon nocturne_hud, sinon natives.
-- Doubles de natives, pas un essai GTA.
-- Usage (depuis nocturne_hud/) : lua5.4 tests/jg_mechanic_hook_test.lua [fichier cl-functions.lua]
local FILE = arg[1] or '../[jg]/jg-mechanic/framework/cl-functions.lua'
local src = assert(io.open(FILE)):read('a')
local fn = src:match('(function Framework%.Client%.ToggleHud%(toggle%).-\nend)\n')
assert(fn, 'Framework.Client.ToggleHud introuvable dans ' .. FILE)

local function run(states, toggle)
  local calls = {}
  local env = {
    Framework = { Client = {} },
    GetResourceState = function(r) return states[r] or 'missing' end,
    DisplayHud = function(v) calls[#calls + 1] = 'DisplayHud:' .. tostring(v) end,
    DisplayRadar = function(v) calls[#calls + 1] = 'DisplayRadar:' .. tostring(v) end,
    exports = setmetatable({}, { __index = function(_, res)
      return { toggleHud = function(_, v) calls[#calls + 1] = res .. ':' .. tostring(v) end }
    end }),
  }
  assert(load(fn, '@' .. FILE, 't', env))()
  env.Framework.Client.ToggleHud(toggle)
  return table.concat(calls, ',')
end

local passed, failed = 0, 0
local function check(name, cond) if cond then passed = passed + 1 else failed = failed + 1 end print((cond and 'PASS ' or 'FAIL ') .. name) end

check('jg-hud démarré : jg-hud seul est appelé (priorité inchangée)', run({ ['jg-hud'] = 'started', nocturne_hud = 'started' }, false) == 'jg-hud:false')
check('jg-hud arrêté, nocturne_hud démarré : toggleHud(false) de nocturne_hud', run({ nocturne_hud = 'started' }, false) == 'nocturne_hud:false')
check('nocturne_hud démarré : toggleHud(true) rend le HUD', run({ nocturne_hud = 'started' }, true) == 'nocturne_hud:true')
check('aucun HUD : natives DisplayHud et DisplayRadar', run({}, false) == 'DisplayHud:false,DisplayRadar:false')
check('nocturne_hud arrêté : pas d\'appel à son export', run({ nocturne_hud = 'stopped' }, true) == 'DisplayHud:true,DisplayRadar:true')
print(('RESULT %d passed, %d failed ; crochet jg-mechanic, doubles de natives, pas un essai GTA'):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
