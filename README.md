# nocturne_hud — HUD joueur FiveM

## Installation
1. Copier le dossier `nocturne_hud` dans `resources/`.
2. Ajouter `ensure nocturne_hud` dans `server.cfg` (après qb-core / es_extended et pma-voice).
3. Désactiver l'ancien HUD (qb-hud, ps-hud, esx_hud…) pour éviter les doublons.
4. Régler `config.lua` (framework, ressource carburant, slots).

## Compatibilité
- **QBCore** : argent, banque, emploi, faim, soif, stress (événements `hud:client:UpdateNeeds` / `UpdateStress` déjà gérés).
- **ESX** : argent, banque, emploi, faim/soif via `esx_status`.
- **Standalone** : exports `SetNeeds(h, t, s)`, `SetMoney(cash, bank)`, `SetJob(label)`.
- **pma-voice** : portée de voix, parole, radio.
- Carburant : natif, ou `Config.FuelResource = 'LegacyFuel'` (ou toute ressource avec `GetFuel`).

## Joueur
- `/hudsetting` : déplacer chaque élément (chaque statut séparément), taille 50–200 %, afficher/masquer, style, disposition, unité, mode streamer. Échap pour fermer. Sauvegardé sur le PC du joueur.
- Touches (modifiables dans Paramètres › Raccourcis › FiveM) : B ceinture · ← → clignotants · ↓ warnings · L limiteur · J régulateur. Phares (H) et train d'atterrissage restent natifs, le HUD les affiche.
- `/ancre` (ou la touche « HUD · Ancre », `Config.Keys.anchor`) : jeter / lever l'ancre d'un bateau.
- Le régulateur se coupe au freinage ou en cas de choc. Sans ceinture, un choc violent (≥ `Config.Seatbelt.ejectSpeed` km/h) éjecte par le pare-brise et blesse ; attachée, elle limite les blessures et empêche de sortir.

## Test hors jeu
Ouvrir `html/index.html` dans un navigateur : données de démo, double-clic pour les réglages.

## Nouveautés 1.7
- Mode cinéma sur **F10** par défaut (F7 est pris par esx_billing sur dev2).
- Export `toggleHud(afficher)` au même contrat que jg-hud : jg-mechanic l'utilise (voir `integration/`).
- Réglages et profils gardés en **KVP** (stockage FiveM du joueur), repris automatiquement depuis l'ancienne copie du navigateur.
- Kilométrage : réel avec `vehicle_mileage`, sinon rien n'est affiché (`Config.FakeOdometer = true` pour l'ancien compteur déduit de la plaque). Le trajet en cours n'est plus affiché.
- Le HUD n'envoie à la page que ce qui a changé (au moins une fois par seconde).
- Polices Inter et Sora incluses (`html/fonts`, licence OFL) : plus de chargement depuis Google.
- Sons de ceinture : clic à l'attache, bip au-dessus de 20 km/h sans ceinture (`Config.Seatbelt.sounds`).

## Notes
- La minimap native reste à sa place : elle se masque depuis /hudsetting mais ne se déplace pas.
- Langue : `Config.Locale = 'fr'` ou `'en'`.

## Exports (client)
| Export | Rôle |
|---|---|
| `exports.nocturne_hud:SetNeeds(faim, soif, stress)` | Statuts 0–100 (framework sans esx_status / qb) ; `nil` garde la valeur actuelle |
| `exports.nocturne_hud:SetMoney(liquide, banque)` | Argent affiché (standalone ou économie custom) |
| `exports.nocturne_hud:SetJob(libellé)` | Emploi affiché |
| `exports.nocturne_hud:IsSeatbeltOn()` | `true` si la ceinture est attachée |
| `exports.nocturne_hud:toggleHud(afficher)` | `false` cache HUD et minimap, `true` les rend (contrat jg-hud) |
| `exports.nocturne_hud:Notify(data)` | Notification au style du HUD (`title`, `description`, `type`, `duration`) ; `false` si rien à afficher |

Exemple : `exports.nocturne_hud:SetNeeds(80, 65, nil)`

## Joueurs connectés
Le serveur publie le nombre réel de joueurs et les slots (`sv_maxclients`) ; `Config.MaxPlayers` ne sert qu'en secours.

## Licence
Code sous licence [Creative Commons BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr) (fichier `LICENSE`) :
utilisation et modification libres sur votre serveur, en citant l'auteur ; **revente et tout usage commercial interdits**
(y compris sur Tebex) ; les versions modifiées partagées restent sous la même licence.
Les polices Inter et Sora (`html/fonts`) gardent leur propre licence SIL OFL 1.1 (`html/fonts/OFL-*.txt`).
