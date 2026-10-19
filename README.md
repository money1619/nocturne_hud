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

Exemple : `exports.nocturne_hud:SetNeeds(80, 65, nil)`

## Joueurs connectés
Le serveur publie le nombre réel de joueurs et les slots (`sv_maxclients`) ; `Config.MaxPlayers` ne sert qu'en secours.
