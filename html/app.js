(() => {
const KEY = 'nocturne_hud_cfg_v1';
// ---------- langue (Config.Locale, envoyée par le client) : le français est la langue source
const EN = {"Vie": "Health", "Armure": "Armor", "Faim": "Hunger", "Soif": "Thirst", "Endurance": "Stamina", "Oxygène": "Oxygen", "Toxicité": "Toxicity", "Alcool": "Alcohol", "Voix": "Voice", "Heure": "Time", "Argent liquide": "Cash", "Banque": "Bank", "Emploi": "Job", "Arme": "Weapon", "munitions": "ammo", "Rue": "Street", "boussole": "compass", "Compteur véhicule": "Speedometer", "Accent général": "Main accent", "Cadre minimap": "Minimap frame", "Compteur": "Speedometer", "Argent": "Cash", "Général": "General", "Couleurs": "Colors", "Éléments": "Elements", "Élément": "Element", "clique aussi directement sur le HUD": "or click it on the HUD", "Couleur": "Color", "Couleur libre": "Custom color", "Par défaut": "Default", "Appliquer aux statuts": "Apply to statuses", "Tout réinitialiser": "Reset all", "Les alertes (vie basse, carburant…) restent en rouge.": "Alerts (low health, fuel…) stay red.", "Taille": "Size", "Appliquer à tout": "Apply to all", "Tailles par défaut": "Default sizes", "Clique un élément du HUD pour le sélectionner.": "Click a HUD element to select it.", "Éléments affichés": "Shown elements", "Toujours": "Always", "En véhicule seulement": "In vehicle only", "Style des statuts": "Status style", "Anneaux": "Rings", "Barres": "Bars", "Disposition des statuts": "Status layout", "En ligne": "Row", "Empilés": "Stacked", "Vitesse": "Speed", "Argent et banque": "Cash and bank", "Discret au repos": "Subtle when idle", "Toujours visible": "Always visible", "Discret : l’argent s’estompe et revient en plein quand il change.": "Subtle: money fades out and comes back when it changes.", "Cadre autour de la minimap": "Frame around the minimap", "Afficher les statuts seulement si utile": "Show statuses only when useful", "Icônes monochromes": "Monochrome icons", "Mode streamer (masque ID, argent, emploi)": "Streamer mode (hides ID, money, job)", "ARME": "WEAPON", "Carburant": "Fuel", "Glisse chaque élément où tu veux": "Drag any element anywhere", "clique pour le sélectionner": "click to select it", "Réglages du HUD": "HUD settings", "Enregistré automatiquement": "Saved automatically", "Changer de côté": "Switch side", "Réduire": "Minimize", "Réinitialiser positions": "Reset positions", "Fermer": "Close", "NŒUDS": "KNOTS", "ANCRE JETÉE": "ANCHORED", "DÉCROCHAGE": "STALL", "TRAIN SORTI": "GEAR DOWN", "TRAIN RENTRÉ": "GEAR UP", "VÉLO": "BIKE", "BATEAU": "BOAT", "HÉLICO": "HELI", "AVION": "PLANE", "Emploi masqué": "Job hidden", "RÉG": "CRU", "trajet": "trip", "Atténuer le HUD la nuit (heure du jeu)": "Dim the HUD at night (game time)", "Profils": "Profiles", "Charger": "Load", "Enregistrer": "Save", "Course": "Racing", "RP calme": "Chill RP", "Streamer": "Streamer", "vide": "empty", "Thèmes": "Themes", "Profil enregistré": "Profile saved", "SO": "SW", "O": "W", "NO": "NW"};
let LANG = 'fr', LOC = 'fr-FR';
const tr = s => {
  if (LANG === 'fr' || typeof s !== 'string') return s;
  const m = s.match(/^(\s*)([\s\S]*?)(\s*)$/);
  return m[1] + m[2].split(' · ').map(p => EN[p] ?? p).join(' · ') + m[3];
};
function translateDom(root) {
  const w = document.createTreeWalker(root, NodeFilter.SHOW_TEXT); let n;
  while ((n = w.nextNode())) { if (n._src === undefined) n._src = n.nodeValue; n.nodeValue = tr(n._src); }
  root.querySelectorAll('[title]:not([data-stat])').forEach(e => { if (e._srcT === undefined) e._srcT = e.title; e.title = tr(e._srcT); });
}
const IN_GAME = typeof GetParentResourceName === 'function';
const RES = IN_GAME ? GetParentResourceName() : 'nocturne_hud';
const post = (n, d) => IN_GAME ? fetch(`https://${RES}/${n}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(d || {}) }).catch(() => {}) : null;

const ICONS = {
  health: 'M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z',
  armor: 'M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z',
  hunger: 'M5 11a7 5 0 0 1 14 0zM4 14.5h16M6 18h12a1 1 0 0 0 1-1v-.5H5v.5a1 1 0 0 0 1 1z',
  thirst: 'M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z',
  stamina: 'M13 2 5 14h6l-1 8 8-12h-6z',
  stress: 'M3 12h4l2-5 4 10 2-5h6',
  toxicity: 'M9 3h6M10 3v6l-5 9a2 2 0 0 0 1.7 3h10.6a2 2 0 0 0 1.7-3l-5-9V3M7.5 15h9',
  addiction: 'M10.5 20.5a5 5 0 0 1-7-7l6-6a5 5 0 0 1 7 7zM7 10.5l6.5 6.5',
  alcohol: 'M7 3h10l-1 7a4 4 0 0 1-8 0zM12 14v6M8.5 21h7M7.5 7h9',
  oxygen: 'M5 15a3 3 0 1 0 6 0a3 3 0 1 0-6 0M12 8a3.5 3.5 0 1 0 7 0a3.5 3.5 0 1 0-7 0M15 18a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0'
};
const DEFS = [['health','Vie','#d46a6a'],['armor','Armure','#7f9ad9'],['hunger','Faim','#d6a35e'],['thirst','Soif','#62a9d6'],['stamina','Endurance','#cfd3e5'],['stress','Stress','#b38ad6'],['oxygen','Oxygène','#7cc4cf'],['toxicity','Toxicité','#8fbf5a'],['addiction','Addiction','#d68ab3'],['alcohol','Alcool','#e0c96a']];
const DRUG_STATS = ['toxicity', 'addiction', 'alcohol']; // AEOM_DRUG_SYSTEM : visibles seulement au-dessus de 0, rouges à 70+
const DANGER = '#d65a5a';
const ELS = ['info','cash','bank','job','weapon','street','vehicle'];
const SK = [...DEFS.map(d => d[0]), 'voice'];
const VISL = [['info','Heure · ID'],['cash','Argent liquide'],['bank','Banque'],['job','Emploi'],['weapon','Arme · munitions'],['street','Rue · boussole'],['map','Minimap'],['vehicle','Compteur véhicule'],['health','Vie'],['armor','Armure'],['hunger','Faim'],['thirst','Soif'],['stamina','Endurance'],['stress','Stress'],['oxygen','Oxygène'],['toxicity','Toxicité'],['addiction','Addiction'],['alcohol','Alcool'],['voice','Voix']];
const ORG = { info:'right top', cash:'right top', bank:'right top', job:'right top', weapon:'right top', street:'left bottom', vehicle:'right bottom' };
const DEF = { style:'rings', unit:'kmh', smart:true, streamer:false, mono:false, frame:true, night:true, money:'auto', mapMode:'always', layout:null, pos:{}, spos:{}, hide:{}, scale:{}, colors:{} };
const MS = 0.85, MAP_DEF = { x: 0, y: 1 - MS / 5.674, w: MS / (4 * 16 / 9), h: MS / 5.674 }; // minimap native, fractions écran
const CT = [['accent','Accent général'],['map','Cadre minimap'],['street','Rue · boussole'],['vehicle','Compteur'],['info','Heure · ID'],['cash','Argent'],['bank','Banque'],['job','Emploi'],['weapon','Arme'],...DEFS.map(([k,l]) => [k,l]),['voice','Voix']];
const PAL = ['#9184d9','#bdb4ee','#e9e9ed','#9ea2b6','#d46a6a','#e07a4f','#d6a35e','#e0c96a','#6fb38a','#4fc1a6','#7cc4cf','#62a9d6','#7f9ad9','#b38ad6','#d68ab3'];
const HEX = /^#[0-9a-f]{6}$/i;
const mix = (a, b, t) => '#' + [1,3,5].map(i => Math.round(parseInt(a.substr(i,2),16) * (1-t) + parseInt(b.substr(i,2),16) * t).toString(16).padStart(2,'0')).join('');
const hexA = (h, a) => `rgba(${[1,3,5].map(i => parseInt(h.substr(i,2),16)).join(',')},${a})`;
const colorOf = k => cfg.colors[k] || (DEFS.find(d => d[0] === k) || [])[2] || (['accent','voice','vehicle'].includes(k) ? '#9184d9' : '#e9e9ed');

const load = () => {
  try {
    const r = JSON.parse(localStorage.getItem(KEY)); const c = JSON.parse(JSON.stringify(DEF));
    if (!r || typeof r !== 'object') return c;
    if (['rings','bars','minimal'].includes(r.style)) c.style = r.style;
    if (['kmh','mph'].includes(r.unit)) c.unit = r.unit;
    if (['auto','always'].includes(r.money)) c.money = r.money;
    if (['row','column'].includes(r.layout)) c.layout = r.layout;
    if (['always','vehicle'].includes(r.mapMode)) c.mapMode = r.mapMode;
    if (r.colors && typeof r.colors === 'object') CT.forEach(([k]) => { if (HEX.test(r.colors[k])) c.colors[k] = r.colors[k]; });
    ['smart','streamer','mono','frame','night'].forEach(k => { if (typeof r[k] === 'boolean') c[k] = r[k]; });
    const rd = (o, keys) => { const out = {}; if (o && typeof o === 'object') keys.forEach(k => { const p = o[k]; if (p && isFinite(p.x) && isFinite(p.y)) out[k] = { x: +p.x, y: +p.y }; }); return out; };
    c.pos = rd(r.pos, ELS); c.spos = rd(r.spos, SK);
    if (r.hide && typeof r.hide === 'object') VISL.forEach(([k]) => { if (r.hide[k] === true) c.hide[k] = true; });
    if (r.scale && typeof r.scale === 'object') [...ELS, ...SK].forEach(k => { const v = +r.scale[k]; if (isFinite(v) && v >= 0.5 && v <= 2) c.scale[k] = v; });
    return c;
  } catch (e) { return JSON.parse(JSON.stringify(DEF)); }
};
let cfg = load();
const save = () => { try { localStorage.setItem(KEY, JSON.stringify(cfg)); } catch (e) {} post('cfg', { hideMap: !!cfg.hide.map, mapVeh: cfg.mapMode === 'vehicle' }); };

function applyColors() {
  const c = cfg.colors, r = document.documentElement.style;
  if (c.accent) { r.setProperty('--accent', c.accent); r.setProperty('--accent3', mix(c.accent, '#e9e9ed', .4)); } else { r.removeProperty('--accent'); r.removeProperty('--accent3'); }
  [...ELS, 'voice'].forEach(k => {
    const n = k === 'voice' ? $('voice') : el(k), v = c[k]; if (!n) return;
    if (v) { n.style.setProperty('--accent', v); n.style.setProperty('--accent3', mix(v, '#e9e9ed', .35)); n.style.setProperty('--tc', v); }
    else ['--accent','--accent3','--tc'].forEach(p => n.style.removeProperty(p));
    n.classList.toggle('tint', !!v && k !== 'voice' && k !== 'vehicle');
  });
  const mf = $('mapFrame');
  mf.style.borderColor = c.map ? hexA(c.map, .6) : '';
  if (c.map) mf.style.setProperty('--accent', c.map); else mf.style.removeProperty('--accent');
}

const $ = id => document.getElementById(id);
const layer = $('layer'), statsEl = $('stats'), panel = $('panel'), pbody = $('pbody');
let D = null, edit = false, sel = 'vehicle', u = 1, sp = {}, tab = 'general', ctgt = 'accent';
let lastCash = null, cashDelta = 0, cashT = 0, firstSlow = null;

const fit = () => { u = innerHeight / 1080; layer.style.width = (innerWidth / u) + 'px'; layer.style.transform = `scale(${u})`; };
addEventListener('resize', fit); fit();

// ---------- statuts
const C = 116.24;
const statNodes = {};
const buildStats = () => {
  statsEl.innerHTML = '';
  DEFS.forEach(([k, label]) => {
    const d = document.createElement('div'); d.className = 'stat'; d.dataset.stat = k; d.title = tr(label);
    const ic = `<svg class="ic" viewBox="0 0 24 24"><path d="${ICONS[k]}"/></svg>`;
    d.innerHTML = cfg.style === 'rings'
      ? `<div class="ring"><svg class="rg" viewBox="0 0 42 42"><circle cx="21" cy="21" r="18.5" stroke="rgba(233,233,237,.12)"/><circle class="pv" cx="21" cy="21" r="18.5"/></svg>${ic}</div>`
      : cfg.style === 'bars' ? `<div class="bar">${ic}<div class="track"><div class="fill"></div></div></div>`
      : `<div class="min">${ic}<span class="val"></span></div>`;
    statsEl.appendChild(d); statNodes[k] = d;
  });
};
buildStats();

// ---------- rendu
const mon = n => cfg.streamer ? '$ •••••' : '$ ' + Math.round(n).toLocaleString(LOC);
const el = k => layer.querySelector(`[data-el="${k}"]`);
const setOff = (node, off) => node.classList.toggle('off', !!off);

function render() {
  if (!D) return;
  const now = Date.now(), hid = cfg.hide, sc = k => cfg.scale[k] || 1;
  $('hud').classList.toggle('hidden', D.show === false && !edit);
  const night = cfg.night && !edit && typeof D.hour === 'number' && (D.hour >= 21 || D.hour < 6);
  layer.style.opacity = night ? 0.78 : 1;
  // identité
  const fmtDate = d => d.toLocaleDateString(LOC, { day: 'numeric', month: 'long' });
  const irl = new Date();
  $('clock').textContent = fmtDate(irl) + ' · ' + irl.toTimeString().slice(0, 5);
  const gd = D.gameDate;
  $('gclock').textContent = D.gameTime ? (gd ? fmtDate(new Date(gd.year, gd.month - 1, gd.day)) + ' · ' : '') + D.gameTime : '';
  $('players').textContent = `${D.players} / ${D.maxPlayers}`;
  $('pid').textContent = cfg.streamer ? '••' : D.id;
  $('cash').textContent = mon(D.cash); $('bank').textContent = mon(D.bank);
  $('job').textContent = cfg.streamer ? tr('Emploi masqué') : (D.job || '');
  const dAge = now - cashT;
  $('cashDelta').textContent = dAge < 4000 && cashDelta && !cfg.streamer ? (cashDelta > 0 ? '+' : '−') + '$' + Math.abs(cashDelta).toLocaleString(LOC) : '';
  $('cashDelta').style.color = cashDelta > 0 ? 'var(--ok)' : DANGER;
  const mo = cfg.money === 'always' || dAge < 6000 || edit ? 1 : 0.45;
  el('cash').style.opacity = mo; el('bank').style.opacity = mo;
  const w = D.weapon || (edit ? { clip: 12, reserve: 48 } : null);
  if (w) { $('ammo').textContent = w.clip; $('ammo').style.color = w.clip <= 3 ? DANGER : ''; $('reserve').textContent = w.reserve; }
  // rue
  const hd = Math.round(D.heading || 0), dir = tr(['N','NE','E','SE','S','SO','O','NO'][Math.round(hd / 45) % 8]);
  $('heading').textContent = `${dir} ${hd}°`; $('street').textContent = D.street || ''; $('zone').textContent = D.zone || '';
  const LW = innerWidth / u, M = D.map || MAP_DEF;
  const mp = { l: M.x * LW, t: M.y * 1080, w: M.w * LW, h: M.h * 1080 };
  const mapBottom = 1080 - (mp.t + mp.h);
  const mapOff = hid.map || (cfg.mapMode === 'vehicle' && !D.veh);
  const mf = $('mapFrame');
  setOff(mf, mapOff || !cfg.frame);
  Object.assign(mf.style, { left: (mp.l + 3) + 'px', top: (mp.t - 4) + 'px', width: (mp.w - 2) + 'px', height: (mp.h + 2) + 'px' });
  const se = $('streetEl');
  se.style.left = (mapOff ? 28 : Math.max(24, mp.l + 12)) + 'px';
  se.style.bottom = (mapOff ? 30 : 1080 - mp.t + 14) + 'px';

  // statuts
  const st = D.stats || {};
  const vis = k => {
    if (hid[k]) return false; if (edit) return true; const v = st[k] ?? 100;
    if (DRUG_STATS.includes(k)) return (st[k] ?? 0) > 0;
    if (!cfg.smart) return k !== 'oxygen' || D.underwater || v < 100;
    return { health: true, armor: v > 0, hunger: v < 60, thirst: v < 60, stamina: D.sprint || v < 98, stress: v > 20, oxygen: D.underwater || v < 100 }[k];
  };
  const sty = cfg.style, layout = cfg.layout || (sty === 'bars' ? 'column' : 'row');
  const vSize = sty === 'rings' ? 42 : 26, statusLeft = mapOff ? 28 : mp.l + mp.w + 20;
  const baseY = mapOff ? 30 : Math.max(20, mapBottom + 14);
  const dW = { rings: 42, bars: 154, minimal: 48 }[sty], dH = { rings: 42, bars: 14, minimal: 18 }[sty];
  const shown = DEFS.filter(([k]) => vis(k)).map(d => d[0]);
  const items = shown.map(k => ({ k, w: dW * sc(k), h: dH * sc(k) }));
  if (!hid.voice) items.push({ k: 'voice', w: (vSize + 18) * sc('voice'), h: vSize * sc('voice') });
  const p0 = {};
  if (layout === 'row') { const gap = { rings: 8, bars: 16, minimal: 14 }[sty], rowH = Math.max(dH, vSize); let x = statusLeft; items.forEach(it => { p0[it.k] = { x, y: baseY + (rowH - it.h) / 2 }; x += it.w + gap; }); }
  else { const gap = { rings: 8, bars: 10, minimal: 10 }[sty]; let y = baseY; [...items].reverse().forEach(it => { p0[it.k] = { x: statusLeft, y }; y += it.h + gap; }); }
  sp = {}; items.forEach(it => { sp[it.k] = cfg.spos[it.k] || p0[it.k]; });
  DEFS.forEach(([k, , col]) => {
    const n = statNodes[k]; const on = shown.includes(k); setOff(n, !on); if (!on) return;
    const v = Math.round(st[k] ?? 0);
    const isStamina = k === 'stamina';
    const low = isStamina ? v < 20 : k === 'stress' ? v > 75 : DRUG_STATS.includes(k) ? v >= 70 : v < 25;
    const color = low ? DANGER : (cfg.colors[k] || (cfg.mono ? '#cfd3e5' : col));
    n.style.setProperty('--c', color); n.title = `${n.title.split(' ')[0]} ${v}%`;
    n.style.left = sp[k].x + 'px'; n.style.bottom = sp[k].y + 'px'; n.style.transform = `scale(${sc(k)})`;
    n.classList.toggle('sel', edit && sel === k);
    const pv = n.querySelector('.pv'); if (pv) pv.setAttribute('stroke-dasharray', `${(C * v / 100).toFixed(2)} ${C}`);
    const f = n.querySelector('.fill'); if (f) f.style.width = v + '%';
    const t = n.querySelector('.val'); if (t) { t.textContent = v; t.style.color = low ? DANGER : ''; }
  });
  // voix
  const vo = D.voice || {}, vn = $('voice'), vc = $('vcirc');
  setOff(vn, hid.voice);
  if (!hid.voice) {
    vn.style.left = sp.voice.x + 'px'; vn.style.bottom = sp.voice.y + 'px'; vn.style.transform = `scale(${sc('voice')})`;
    vn.classList.toggle('sel', edit && sel === 'voice');
    vc.style.width = vc.style.height = vSize + 'px';
    vc.style.background = 'transparent';
    vc.style.boxShadow = vo.talking ? 'inset 0 0 0 2px var(--accent)' : (sty === 'rings' ? 'inset 0 0 0 2.5px rgba(233,233,237,.16)' : 'none');
    vc.style.setProperty('--vc', vo.talking ? 'var(--accent3)' : '#b2b6ca');
    [...vn.querySelectorAll('.rbars i')].forEach((b, i) => b.style.background = i <= (vo.range ?? 1) ? (vo.talking ? 'var(--accent)' : '#cfd3e5') : 'rgba(233,233,237,.2)');
    $('radio').style.display = vo.radio ? '' : 'none';
  }
  // vignette vie basse
  const h = st.health ?? 100;
  $('vignette').style.background = `radial-gradient(130% 100% at 50% 50%,transparent 55%,rgba(150,30,30,${h < 30 ? (0.32 * (1 - h / 30)).toFixed(2) : 0}) 100%)`;

  renderVehicle(now, sc);

  // éléments déplaçables
  ELS.forEach(k => {
    const n = el(k), p = cfg.pos[k] || { x: 0, y: 0 };
    let off = hid[k];
    if (k === 'weapon') off = off || !w;
    if (k === 'vehicle') off = off || (!D.veh && !edit);
    setOff(n, off);
    n.style.transformOrigin = ORG[k];
    n.style.transform = `translate(${p.x}px,${p.y}px) scale(${sc(k)})`;
    n.classList.toggle('sel', edit && sel === k);
  });
}

function renderVehicle(now, sc) {
  const v = D.veh || (edit ? { cls: 'car', speed: 0, rpm: 0.2, gear: 'N', fuel: 70, engine: 100, belt: false, lights: 0, blink: 0 } : null);
  if (!v) return;
  const air = v.cls === 'heli' || v.cls === 'plane', kts = air || v.cls === 'boat', road = v.cls === 'car' || v.cls === 'moto';
  const sp = kts ? v.speed * 0.54 : cfg.unit === 'mph' ? v.speed * 0.621 : v.speed;
  const cv = x => Math.round(kts ? x * 0.54 : cfg.unit === 'mph' ? x * 0.621 : x);
  $('speed').textContent = Math.round(sp);
  $('unit').textContent = kts ? tr('NŒUDS') : cfg.unit === 'mph' ? 'MPH' : 'KM/H';
  let rpm = v.rpm || 0;
  if (v.cls === 'bike') rpm = Math.min(1, v.speed / 50);
  $('rpm').setAttribute('stroke-dasharray', `${(Math.min(1, rpm) * 100).toFixed(1)} 100`);
  $('red').style.opacity = road ? 1 : 0;
  let gear = road ? v.gear : '', gc = 'var(--accent3)';
  if (v.cls === 'boat' && v.anchor) gear = 'ANCRE JETÉE';
  if (v.cls === 'plane') { const stall = (v.alt || 0) > 50 && v.speed < 150; gear = stall ? 'DÉCROCHAGE' : v.gearDown ? 'TRAIN SORTI' : 'TRAIN RENTRÉ'; gc = stall ? DANGER : v.gearDown ? 'var(--accent3)' : 'var(--muted)'; }
  const g = $('gear'); g.textContent = tr(gear); g.style.color = gc;
  const short = /^\w$/.test(gear); g.style.fontSize = (short ? 13 : 10) + 'px'; g.style.letterSpacing = short ? '0' : '.14em';
  $('cruise').textContent = v.cruise ? (v.cruise === 'limit' ? 'LIM ' : tr('RÉG') + ' ') + cv(v.cruiseSpd) : '';
  const on = Math.floor(now / 400) % 2 === 0;
  $('bl').style.display = $('br').style.display = road ? '' : 'none';
  $('bl').style.opacity = (v.blink === 1 || v.blink === 3) && on ? 1 : 0.15;
  $('br').style.opacity = (v.blink === 2 || v.blink === 3) && on ? 1 : 0.15;
  $('altBox').style.display = air ? 'flex' : 'none';
  if (air) {
    const alt = Math.round(v.alt || 0), vs = Math.round((v.vs || 0) / 50) * 50;
    $('alt').textContent = alt.toLocaleString(LOC);
    $('vs').textContent = Math.abs(vs) < 50 ? '— stable' : (vs > 0 ? '↑ ' : '↓ ') + Math.abs(vs).toLocaleString(LOC) + ' ft/min';
    $('vs').style.color = vs < -1500 && alt < 800 ? DANGER : '#c8cbd8';
  }
  const labels = { bike: 'VÉLO', boat: 'BATEAU', heli: 'HÉLICO', plane: 'AVION' };
  $('vtLabel').textContent = tr(labels[v.cls] || '');
  const motor = v.cls !== 'bike';
  $('fuelBox').style.display = motor ? 'flex' : 'none';
  const fc = v.fuel < (v.fuelWarn || 10) ? DANGER : '#cfd3e5'; // même seuil que le bip (Config.Fuel.warn)
  const mi = cfg.unit === 'mph' && !kts, f = mi ? 0.621 : 1, u2 = mi ? ' mi' : ' km';
  const odo = typeof v.km === 'number' ? Math.floor(v.km * f).toLocaleString(LOC) + u2 : '';
  const trip = typeof v.trip === 'number' && v.trip >= 0.1 ? tr('trajet') + ' ' + (v.trip * f).toLocaleString(LOC, { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + u2 : '';
  $('odo').textContent = [odo, trip].filter(Boolean).join(' · ');
  $('fuelBox').classList.toggle('pulse', motor && v.fuel < (v.fuelWarn || 10));
  $('range').textContent = motor && v.range && v.fuel < (v.fuelRange || 25) ? '≈ ' + Math.round(v.range * f).toLocaleString(LOC) + u2 : '';
  $('fuel').style.width = Math.max(0, Math.min(100, v.fuel)) + '%'; $('fuel').style.background = fc; $('fuelIc').style.stroke = fc;
  const b = $('beltIc'); b.style.display = v.cls === 'car' ? '' : 'none';
  b.style.stroke = v.belt ? 'var(--ok)' : DANGER; b.style.opacity = v.belt ? 0.55 : (v.speed > 5 && Math.floor(now / 600) % 2 ? 0.35 : 1);
  const l = $('lightIc'); l.style.display = motor ? '' : 'none'; l.style.stroke = v.lights === 2 ? '#7f9ad9' : 'var(--ok)'; l.style.opacity = v.lights ? 1 : 0.3;
  const e = $('engIc'); e.style.display = motor ? '' : 'none'; e.style.stroke = v.engine < 40 ? DANGER : v.engine < 70 ? '#d6a35e' : 'rgba(233,233,237,.45)';
}

// ---------- données du jeu
let slow = {};
function setLang(l) {
  LANG = l === 'en' ? 'en' : 'fr'; LOC = LANG === 'en' ? 'en-US' : 'fr-FR';
  document.documentElement.lang = LANG;
  translateDom(document.body); buildStats(); if (edit) renderPanel();
}
function onSlow(d) {
  if (d.lang && d.lang !== LANG) setLang(d.lang);
  // Pas de « +$ » au chargement du personnage : l'argent passe de 0 au vrai solde dans les premières secondes
  if (firstSlow === null) firstSlow = Date.now();
  if (lastCash !== null && d.cash !== lastCash && Date.now() - firstSlow > 5000) { cashDelta = d.cash - lastCash; cashT = Date.now(); }
  lastCash = d.cash; slow = d; if (D) D = { ...D, ...slow };
}
function onData(d) { D = { ...slow, ...d }; render(); }
addEventListener('message', e => {
  const m = e.data || {};
  if (m.t === 'u') onData(m.d);
  else if (m.t === 's') onSlow(m.d);
  else if (m.t === 'edit') setEdit(true);
  else if (m.t === 'cinema') document.body.classList.toggle('cinema', !!m.on);
  else if (m.t === 'notify') notify(m.d || {});
});

// ---------- édition
function setEdit(on) {
  edit = on; document.body.classList.toggle('edit', on);
  if (on) renderPanel(); else post('close');
  render();
}
addEventListener('keydown', e => { if (e.key === 'Escape' && edit) setEdit(false); });

layer.addEventListener('pointerdown', e => {
  if (!edit) return;
  const t = e.target.closest('[data-el],[data-stat]'); if (!t) return;
  e.preventDefault();
  const isStat = !!t.dataset.stat, k = isStat ? t.dataset.stat : t.dataset.el;
  sel = k; if (tab === 'colors') ctgt = k; renderPanel();
  const start = isStat ? { ...(sp[k] || { x: 0, y: 0 }) } : { ...(cfg.pos[k] || { x: 0, y: 0 }) };
  const sx = e.clientX, sy = e.clientY; t.classList.add('drag');
  const move = ev => {
    const dx = (ev.clientX - sx) / u, dy = (ev.clientY - sy) / u;
    const p = { x: Math.round((start.x + dx) / 4) * 4, y: Math.round((start.y + (isStat ? -dy : dy)) / 4) * 4 };
    if (isStat) cfg.spos[k] = p; else cfg.pos[k] = p;
    render();
  };
  const up = () => { removeEventListener('pointermove', move); removeEventListener('pointerup', up); t.classList.remove('drag'); save(); };
  addEventListener('pointermove', move); addEventListener('pointerup', up);
});

const seg = (key, label, opts, cur) => `<div class="grp"><span>${label}</span><div class="seg">${opts.map(([v, l]) => `<button data-seg="${key}" data-v="${v}" class="${cur === v ? 'on' : ''}">${l}</button>`).join('')}</div></div>`;
function renderPanel() { renderPanelRaw(); if (LANG !== 'fr') translateDom(pbody); }
function renderPanelRaw() {
  const layout = cfg.layout || (cfg.style === 'bars' ? 'column' : 'row');
  const selLabel = (VISL.find(([k]) => k === sel) || [0, ''])[1], pct = Math.round((cfg.scale[sel] || 1) * 100);
  const tabs = `<div class="tabs">${[['general','Général'],['colors','Couleurs'],['els','Éléments']].map(([k, l]) => `<button data-tab="${k}" class="${tab === k ? 'on' : ''}">${l}</button>`).join('')}</div>`;
  if (tab === 'colors') {
    const cur = colorOf(ctgt), cl = (CT.find(([k]) => k === ctgt) || [0, ''])[1];
    pbody.innerHTML = tabs +
      `<div class="grp"><span>Thèmes</span><div class="presets">${PRESETS.map(([c, n]) => `<button class="preset" data-preset="${c}" title="${n}" style="--p:${c}"></button>`).join('')}</div></div>` +
      `<div class="grp"><span>Élément · clique aussi directement sur le HUD</span><div class="clist">${CT.map(([k, l]) => `<button class="crow ${ctgt === k ? 'on' : ''}" data-ct="${k}"><i class="sw" style="background:${colorOf(k)}"></i><span>${l}</span>${cfg.colors[k] ? '<em></em>' : ''}</button>`).join('')}</div></div>` +
      `<div class="grp"><span>Couleur · ${cl}</span><div class="pal">${PAL.map(c => `<button class="sw lg ${cur.toLowerCase() === c ? 'on' : ''}" data-col="${c}" style="background:${c}" title="${c}"></button>`).join('')}<label class="sw lg pick" title="Couleur libre"><input type="color" id="cpick" value="${cur}"></label></div>
        <div class="row" style="gap:8px"><span class="hexv">${cur.toUpperCase()}</span><span style="flex:1"></span><button class="ghost" id="cReset">Par défaut</button></div>
        <div class="row" style="gap:6px"><button class="ghost" id="cAllStats">Appliquer aux statuts</button><button class="ghost" id="cResetAll">Tout réinitialiser</button></div></div>` +
      `<span style="font-size:11px;color:var(--dim)">Les alertes (vie basse, carburant…) restent en rouge.</span>`;
    return;
  }
  if (tab === 'els') {
    pbody.innerHTML = tabs +
      `<div class="grp"><span>Taille · ${selLabel}</span>
      <div class="row"><input id="scale" type="range" min="50" max="200" step="5" value="${pct}" style="flex:1;min-width:0"><span id="scaleV" style="width:40px;text-align:right">${pct} %</span></div>
      <div class="row" style="gap:6px"><button class="ghost" id="scaleAll">Appliquer à tout</button><button class="ghost" id="scaleReset">Tailles par défaut</button></div>
      <span>Clique un élément du HUD pour le sélectionner.</span></div>` +
      `<div class="grp"><span>Éléments affichés</span><div class="vis">${VISL.map(([k, l]) => `<label class="ck"><input type="checkbox" data-vis="${k}" ${cfg.hide[k] ? '' : 'checked'}><span>${l}</span></label>`).join('')}</div></div>`;
    return;
  }
  pbody.innerHTML = tabs +
    `<div class="grp"><span>Profils</span><div class="prof">${PROF.map((n, i) => `<div><button class="sec" data-pload="${i}" ${hasProf(i) ? '' : 'disabled'}>${n}</button><button class="ghost" data-psave="${i}">Enregistrer</button></div>`).join('')}</div></div>` +
    seg('mapMode', 'Minimap', [['always','Toujours'],['vehicle','En véhicule seulement']], cfg.mapMode) +
    seg('style', 'Style des statuts', [['rings','Anneaux'],['bars','Barres'],['minimal','Minimal']], cfg.style) +
    seg('layout', 'Disposition des statuts', [['row','En ligne'],['column','Empilés']], layout) +
    seg('unit', 'Vitesse', [['kmh','km/h'],['mph','mph']], cfg.unit) +
    seg('money', 'Argent et banque', [['auto','Discret au repos'],['always','Toujours visible']], cfg.money) +
    `<span style="font-size:11px;color:var(--dim);margin-top:-6px">Discret : l’argent s’estompe et revient en plein quand il change.</span>` +
    [['night','Atténuer le HUD la nuit (heure du jeu)'],['frame','Cadre autour de la minimap'],['smart','Afficher les statuts seulement si utile'],['mono','Icônes monochromes'],['streamer','Mode streamer (masque ID, argent, emploi)']]
      .map(([k, l]) => `<label class="tg"><span>${l}</span><input type="checkbox" data-tog="${k}" ${cfg[k] ? 'checked' : ''}></label>`).join('');
}
const PROF = ['Course', 'RP calme', 'Streamer'];
const PRESETS = [['#9184d9','Violet'],['#4fb8d6','Cyan'],['#d6b25e','Or'],['#d65a6a','Rouge'],['#5fc48a','Vert'],['#d68ab3','Rose'],['#e9e9ed','Blanc']];
const profKey = i => KEY + '_prof' + i;
const hasProf = i => { try { return !!localStorage.getItem(profKey(i)); } catch (e) { return false; } };
function notify(n) {
  const box = $('notifs'), card = document.createElement('div');
  card.className = 'ntf ' + (['success','error','warning'].includes(n.type) ? n.type : 'info');
  const b = document.createElement('b'); b.textContent = n.title || ''; if (n.title) card.appendChild(b);
  const p = document.createElement('span'); p.textContent = n.text || ''; if (n.text) card.appendChild(p);
  if (!n.title && !n.text) return;
  const bar = document.createElement('i'); bar.style.animationDuration = (n.duration || 5000) + 'ms'; card.appendChild(bar);
  box.appendChild(card);
  while (box.children.length > 5) box.firstChild.remove();
  setTimeout(() => { card.classList.add('out'); setTimeout(() => card.remove(), 300); }, n.duration || 5000);
}
const setColor = (k, c) => { if (c) cfg.colors[k] = c; else delete cfg.colors[k]; applyColors(); render(); };
pbody.addEventListener('click', e => {
  const tb = e.target.closest('[data-tab]'); if (tb) { tab = tb.dataset.tab; if (tab === 'colors' && CT.some(([k]) => k === sel)) ctgt = sel; renderPanel(); return; }
  const cr = e.target.closest('[data-ct]'); if (cr) { ctgt = cr.dataset.ct; if (ELS.includes(ctgt) || SK.includes(ctgt)) sel = ctgt; renderPanel(); render(); return; }
  const pr = e.target.closest('[data-preset]'); if (pr) { cfg.colors = { accent: pr.dataset.preset, map: pr.dataset.preset, vehicle: pr.dataset.preset, voice: pr.dataset.preset }; applyColors(); render(); save(); renderPanel(); return; }
  const pl = e.target.closest('[data-pload]');
  if (pl) { try { localStorage.setItem(KEY, localStorage.getItem(profKey(pl.dataset.pload))); } catch (er) {} cfg = load(); buildStats(); applyColors(); save(); renderPanel(); render(); return; }
  const ps = e.target.closest('[data-psave]');
  if (ps) { try { localStorage.setItem(profKey(ps.dataset.psave), JSON.stringify(cfg)); } catch (er) {} notify({ title: tr('Profil enregistré'), text: tr(PROF[ps.dataset.psave]), type: 'success', duration: 2000 }); renderPanel(); return; }
  const cb = e.target.closest('[data-col]'); if (cb) { setColor(ctgt, cb.dataset.col); save(); renderPanel(); return; }
  if (e.target.id === 'cReset') { setColor(ctgt, null); save(); renderPanel(); return; }
  if (e.target.id === 'cResetAll') { cfg.colors = {}; applyColors(); render(); save(); renderPanel(); return; }
  if (e.target.id === 'cAllStats') { const c = colorOf(ctgt); DEFS.forEach(([k]) => cfg.colors[k] = c); render(); save(); renderPanel(); return; }
  const b = e.target.closest('[data-seg]');
  if (b) {
    const k = b.dataset.seg, v = b.dataset.v;
    if (k === 'layout') { cfg.layout = v; cfg.spos = {}; }
    else { cfg[k] = v; if (k === 'style') buildStats(); }
    save(); renderPanel(); render(); return;
  }
  if (e.target.id === 'scaleAll') { const v = cfg.scale[sel] || 1; [...ELS, ...SK].forEach(k => cfg.scale[k] = v); cfg.spos = {}; save(); renderPanel(); render(); }
  if (e.target.id === 'scaleReset') { cfg.scale = {}; cfg.spos = {}; save(); renderPanel(); render(); }
});
pbody.addEventListener('input', e => {
  if (e.target.id === 'scale') { cfg.scale[sel] = +e.target.value / 100; $('scaleV').textContent = e.target.value + ' %'; render(); }
  if (e.target.id === 'cpick') { setColor(ctgt, e.target.value); const h = pbody.querySelector('.hexv'); if (h) h.textContent = e.target.value.toUpperCase(); }
});
pbody.addEventListener('change', e => {
  const t = e.target;
  if (t.id === 'scale') save();
  if (t.id === 'cpick') { save(); renderPanel(); }
  if (t.dataset.vis) { if (t.checked) delete cfg.hide[t.dataset.vis]; else cfg.hide[t.dataset.vis] = true; save(); render(); }
  if (t.dataset.tog) { cfg[t.dataset.tog] = t.checked; save(); render(); }
});
$('flip').onclick = () => panel.classList.toggle('right');
$('mini').onclick = () => { const m = panel.classList.toggle('min'); $('mini').textContent = m ? '▢' : '—'; };
$('resetPos').onclick = () => { cfg.pos = {}; cfg.spos = {}; save(); render(); };
$('closeBtn').onclick = () => setEdit(false);
applyColors();
save();

// ---------- démo navigateur (hors FiveM) : double-clic = réglages
if (!IN_GAME) {
  document.body.classList.add('demo');
  let t = 0;
  setInterval(() => {
    t += 0.1; const speed = Math.max(0, 90 + Math.sin(t / 3) * 60);
    onSlow({ id: 27, players: 112, maxPlayers: 128, cash: 4520, bank: 128900, job: 'Mécanicien · Chef d’atelier', street: 'Grove Street', zone: 'Davis', gameTime: '21:37', gameDate: { year: 2026, month: 7, day: 3 } });
    onData({ show: true, id: 27, players: 112, maxPlayers: 128, cash: 4520, bank: 128900, job: 'Mécanicien · Chef d’atelier',
      stats: { health: 82, armor: 40, hunger: 55, thirst: 48, stamina: 100, stress: 30, oxygen: 100, toxicity: 35, addiction: 20, alcohol: 50 }, underwater: false,
      street: 'Grove Street', zone: 'Davis', heading: 214, weapon: null, voice: { talking: Math.sin(t) > 0.6, range: 1, radio: true },
      veh: { cls: 'car', km: 48213, trip: t / 3, speed, rpm: 0.25 + (speed % 40) / 55, gear: String(1 + Math.floor(speed / 40)), fuel: 64, engine: 92, belt: true, lights: 1, blink: 1, cruise: null } });
  }, 100);
  addEventListener('dblclick', () => setEdit(!edit));
  setTimeout(() => notify({ title: 'Livraison', text: 'Le client vous attend à Davis.', type: 'info', duration: 60000 }), 600);
  setTimeout(() => notify({ title: 'Paiement reçu', text: '+ $ 1 250', type: 'success', duration: 60000 }), 900);
}
})();
