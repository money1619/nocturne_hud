# Branchement des notifications

ox_lib et esx_notify n'appellent pas `exports.nocturne_hud:Notify` d'eux-mêmes. Sur dev2, ils ont été modifiés
(le 18/10, à la demande de Money) pour passer par le HUD **quand nocturne_hud est démarré** ; sinon, leur
affichage d'origine reste inchangé. `Notify` renvoie `false` s'il n'y a rien à afficher, et l'affichage
d'origine prend alors le relais.

- `ox_lib_notify.patch` : `resource/interface/client/notify.lua` d'ox_lib 3.32.3.
- `esx_notify_Notify.patch` : `Notify.lua` d'esx_notify 1.12.4.

Originaux : `~/backups/dev2_notify_hook_20261018_211337/` (sha256.txt). Une mise à jour d'ox_lib ou d'esx_notify
efface ces ajouts : réappliquer les correctifs (`patch -p0` n'est pas adapté aux libellés ; copier le bloc à la main).
Les modifications ne prennent effet qu'au redémarrage de ces ressources (aucun redémarrage n'a été fait).
