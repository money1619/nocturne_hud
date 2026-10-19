-- Test hors jeu des crochets de notification posés dans ox_lib et esx_notify (integration/*.patch).
-- Charge les VRAIS fichiers installés et vérifie : HUD démarré et Notify vrai → affichage HUD seul ;
-- HUD arrêté, Notify faux ou en erreur → affichage d'origine. Doubles de natives, pas un essai GTA.
-- Usage (depuis nocturne_hud/) : lua5.4 tests/notify_hook_test.lua [dossier resources]
local RES = arg[1] or '../..'
local OXLIB = RES .. '/[ox]/ox_lib/resource/interface/client/notify.lua'
local ESXN = RES .. '/[core]/esx_notify/Notify.lua'

local state, hudResult, hudCalls, origCalls, sounds = 'started', true, {}, {}, 0
local function resetCase(st, res) state, hudResult, hudCalls, origCalls, sounds = st, res, {}, {}, 0 end

function GetResourceState(r) return r == 'nocturne_hud' and state or 'missing' end
exports = setmetatable({}, {
  __call = function() end,
  __index = function(_, r)
    if r ~= 'nocturne_hud' then return nil end
    return { Notify = function(_, data)
      hudCalls[#hudCalls + 1] = data
      if hudResult == 'error' then error('Notify en panne') end
      return hudResult
    end }
  end,
})
function SendNUIMessage(m) origCalls[#origCalls + 1] = m end
function SendNuiMessage(m) origCalls[#origCalls + 1] = m end
function GetSoundId() return 1 end
function PlaySoundFrontend() sounds = sounds + 1 end
function ReleaseSoundId() end
function RegisterNetEvent() end
function RegisterCommand() end
json = { encode = function(t) return t end }

-- ox_lib : `require 'resource.settings'` et l'objet lib
lib = { requestAudioBank = function() end }
local settings = { notification_audio = true, notification_position = 'top-right' }
function require(m) if m == 'resource.settings' then return settings end error('require ' .. m) end
assert(loadfile(OXLIB))()
-- esx_notify : ESX global, export et événement sécurisé
local esxNotify
ESX = { GetConfig = function() return { EnableDebug = false } end, SecureNetEvent = function() end }
exports = setmetatable({}, { __call = function(_, n, fn) if n == 'Notify' then esxNotify = fn end end,
  __index = getmetatable(exports).__index })
assert(loadfile(ESXN))()

local passed, failed = 0, 0
local function check(name, cond)
  if cond then passed = passed + 1 else failed = failed + 1 end
  print((cond and 'PASS ' or 'FAIL ') .. name)
end

-- ox_lib
resetCase('started', true)
lib.notify({ title = 'Titre', description = 'Texte', type = 'success', sound = { set = 'S', name = 'N' } })
check('ox_lib : HUD démarré et Notify vrai → affichage HUD seul', #hudCalls == 1 and #origCalls == 0)
check('ox_lib : son d\'ox_lib joué quand même', sounds == 1)
resetCase('stopped', true)
lib.notify({ description = 'Texte' })
check('ox_lib : HUD arrêté → affichage ox_lib, HUD non appelé', #hudCalls == 0 and #origCalls == 1 and origCalls[1].action == 'notify')
resetCase('started', false)
lib.notify({ description = '' })
check('ox_lib : Notify faux (message vide) → affichage ox_lib', #hudCalls == 1 and #origCalls == 1)
resetCase('started', 'error')
lib.notify({ description = 'Texte' })
check('ox_lib : Notify en erreur → affichage ox_lib, pas d\'erreur propagée', #origCalls == 1)
resetCase('started', true)
lib.defaultNotify({ description = 'Ancien format', status = 'inform' })
check('ox_lib : ancien format (status inform) passe aussi par le HUD', #hudCalls == 1 and hudCalls[1].type == 'info')

-- esx_notify
resetCase('started', true)
esxNotify('success', 4000, 'Tu as reçu ~br~ 1x balle~s~ !')
check('esx_notify : HUD démarré → affichage HUD seul, message transmis', #hudCalls == 1 and #origCalls == 0
  and hudCalls[1].description == 'Tu as reçu ~br~ 1x balle~s~ !' and hudCalls[1].duration == 4000 and hudCalls[1].type == 'success')
resetCase('started', true)
esxNotify(nil, nil, 'Texte')
check('esx_notify : type et durée par défaut transmis (info, 3000)', hudCalls[1] and hudCalls[1].type == 'info' and hudCalls[1].duration == 3000)
resetCase('stopped', true)
esxNotify('error', 3000, 'Texte')
check('esx_notify : HUD arrêté → affichage esx_notify', #hudCalls == 0 and #origCalls == 1)
resetCase('started', false)
esxNotify('info', 3000, nil)
check('esx_notify : Notify faux → affichage esx_notify (« ESX-Notify » par défaut)', #origCalls == 1 and origCalls[1].message == 'ESX-Notify')
resetCase('started', 'error')
esxNotify('info', 3000, 'Texte')
check('esx_notify : Notify en erreur → affichage esx_notify', #origCalls == 1)

print(('RESULT %d passed, %d failed ; crochets ox_lib et esx_notify, doubles de natives, pas un essai GTA'):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
