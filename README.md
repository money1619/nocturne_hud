# Nocturne HUD — Custom FiveM HUD for GTA V Roleplay

**Nocturne HUD** is a customizable FiveM HUD for GTA V roleplay servers, with support for QBCore, ESX and Standalone frameworks.

> **French:** Nocturne HUD est un HUD FiveM personnalisable pour serveurs GTA V roleplay, compatible QBCore, ESX et Standalone.

[![GitHub release](https://img.shields.io/github/release/money1619/nocturne_hud.svg)](https://github.com/money1619/nocturne_hud/releases)
[![License: Proprietary](https://img.shields.io/badge/License-Modif%20OK%20%C2%B7%20No%20resale-lightgrey.svg)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-HUD-blue.svg)](https://github.com/money1619/nocturne_hud)

---

## 📑 Sommaire / Table of Contents

- [Features / Fonctionnalités](#features--fonctionnalités)
- [Supported Frameworks / Frameworks supportés](#supported-frameworks--frameworks-supportés)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands / Commandes](#commands--commandes)
- [Exports](#exports-client)
- [Screenshots / Captures d'écran](#screenshots--captures-écran)
- [Compatibility / Compatibilité](#compatibility--compatibilité)
- [License / Licence](#license--licence)

---

## 🚀 Features / Fonctionnalités

- Player status: health, armor, hunger, thirst, stress
- Money display: cash and bank
- Job information with label
- Voice indicators: range, talking, radio (pma-voice)
- Vehicle information: speedometer, seatbelt, indicators, hazards, limiter, cruise control, engine, lights, doors, windows, radio, seats
- Customizable HUD layout: move, resize (50–200 %), show/hide each element, streamer mode
- Player settings saved locally (KVP)
- Seatbelt: ejection on violent crash without belt, reduced injuries with belt
- Cinema mode (F10): hides all HUD + black bars
- Fuel warning and estimated range
- Built-in odometer: kilometres per plate kept by the HUD itself (`data/odometer.json`), no other resource
- Notifications at HUD style via exports
- Minimap native control: hide bars, scale, offset
- No SQL tables, no inventory objects, player settings in KVP, odometer in a JSON file
- Lightweight: sends only changed data to the NUI page (at least once per second)
- Fonts Inter and Sora included locally (no Google Fonts dependency)
- Multilingual: French (`fr`) and English (`en`)

> **Français:** Statuts joueur (vie, armure, faim, soif, stress), argent liquide et banque, emploi, indicateurs de voix (pma-voice), compteur de vitesse, ceinture, clignotants, warnings, régulateur, limiteur, HUD personnalisable (position, taille, affichage/masque, mode streamer), réglages sauvegardés en KVP, éjection par pare-brise sans ceinture, mode cinéma F10, carburant avec autonomie estimée, compteur kilométrique intégré (par plaque, sans autre ressource), notifications style HUD, minimap native configurable, pas de base de données, polices incluses localement, multilingue fr/en.

---

## 🛠 Supported Frameworks / Frameworks supportés

| Framework | Details |
|-----------|---------|
| **QBCore** | Money, bank, job, hunger, thirst, stress (events `hud:client:UpdateNeeds` / `UpdateStress`) |
| **ESX** (Legacy) | Money, bank, job, hunger/thirst via `esx_status` |
| **Standalone** | Exports `SetNeeds(h, t, s)`, `SetMoney(cash, bank)`, `SetJob(label)` |
| **pma-voice** | Voice range, talking, radio indicators |
| **Fuel** | Native GTA fuel level of the vehicle (LegacyFuel, ox_fuel, cdn-fuel… keep it up to date; no export called) |

---

## 📦 Installation

1. Copy the `nocturne_hud` folder into your `resources/` directory.
2. Add `ensure nocturne_hud` to your `server.cfg` (after qb-core / es_extended and pma-voice).
3. Disable your old HUD (qb-hud, ps-hud, esx_hud…) to avoid duplicates.
4. Configure `config.lua` (framework, slots).

> **Français:**
> 1. Copier le dossier `nocturne_hud` dans `resources/`.
> 2. Ajouter `ensure nocturne_hud` dans `server.cfg` (après qb-core / es_extended et pma-voice).
> 3. Désactiver l'ancien HUD (qb-hud, ps-hud, esx_hud…) pour éviter les doublons.
> 4. Régler `config.lua` (framework, ressource carburant, slots).

### Inventory objects / Objets d'inventaire

Nocturne HUD adds no inventory objects and uses no SQL tables (player settings in KVP). There is no `install/` folder to copy into ox_inventory.

---

## ⚙️ Configuration

Edit `config.lua`:

```lua
Config.Framework = 'auto'    -- 'auto', 'qb', 'esx' or 'standalone'
Config.Locale = 'fr'         -- 'fr' or 'en'
Config.MaxPlayers = 128      -- fallback only
Config.SettingsCommand = 'hudsetting'
```

See `config.lua` for all options: seatbelt, voice circle, notifications, fuel, odometer, minimap, native HUD elements to hide.

---

## ⌨️ Commands / Commandes

| Command | Description |
|---------|-------------|
| `/hudsetting` | Open HUD customization menu (move, resize, show/hide elements) |
| `/ancre` | Drop / lift boat anchor |
| `Esc` | Close settings menu |

**Default keys** (changeable in FiveM Settings > Keybinds):
- `B` — Seatbelt
- `LEFT` / `RIGHT` — Indicators
- `DOWN` — Hazard lights
- `L` — Speed limiter
- `J` — Cruise control
- `F10` — Cinema mode

---

## 🔌 Exports (client)

| Export | Role |
|--------|------|
| `SetNeeds(faim, soif, stress)` | Status 0–100 (standalone); `nil` keeps current value |
| `SetMoney(liquide, banque)` | Money displayed (standalone or custom economy) |
| `SetJob(libellé)` | Job displayed |
| `IsSeatbeltOn()` | `true` if seatbelt is fastened |
| `toggleHud(afficher)` | `false` hides HUD and minimap, `true` shows them (jg-hud contract) |
| `setMinimapReplaced(actif)` | `true` keeps the native minimap hidden: another resource draws its own in its place |
| `isMinimapWanted()` | `true` if the HUD wants a minimap shown (player settings, cinema mode, `toggleHud`) |
| `getMinimapAnchor()` | Native minimap rectangle `{ x, y, w, h }` (screen fractions) |
| `Notify(data)` | HUD-style notification (`title`, `description`, `type`, `duration`) |

Example: `exports.nocturne_hud:SetNeeds(80, 65, nil)`

---

## 🖼 Screenshots / Captures d'écran

Add in-game screenshots here to show the HUD layout:

- Player status panel
- Speedometer and vehicle info
- Customization menu (`/hudsetting`)

> **Note:** Add screenshots to `docs/screenshots/` or link them from the GitHub Pages site. Players need to see what the HUD looks like before installing.

---

## ✅ Compatibility / Compatibilité

- Native minimap remains in place; can be hidden via `/hudsetting` but not moved
- Language: `Config.Locale = 'fr'` or `'en'`
- No dependency (ox_lib is no longer required since the vehicle menu was removed)
- Tested with ESX Legacy 1.15.2, ox_lib 3.40.3, oxmysql 2.14.3, ox_inventory, ox_target, txAdmin

---

## 📄 License / Licence

Copyright © 2026 AEOM Development (`LICENSE`): you may modify it and share modified versions for free, **as long as AEOM Development is credited as the original creator**; **selling or reselling it (Tebex or anywhere else) is prohibited**.
© 2026 AEOM Development : modification permise en créditant AEOM Development comme créateur original, revente interdite (Tebex ou ailleurs). Voir `LICENSE`.
Fonts Inter and Sora (`html/fonts`) keep their own SIL OFL 1.1 license (`html/fonts/OFL-*.txt`).

---

## 🔗 Links

- **Repository:** https://github.com/money1619/nocturne_hud
- **Issues:** https://github.com/money1619/nocturne_hud/issues
- **Releases:** https://github.com/money1619/nocturne_hud/releases

---

*Nocturne HUD — Free custom FiveM HUD for GTA V roleplay servers. QBCore • ESX • Standalone • pma-voice • Lua*
