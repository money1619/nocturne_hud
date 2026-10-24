// Tests hors jeu de html/app.js (1.7.1) sous Node, avec un faux DOM permissif et un faux AudioContext.
// Couvre : sons de ceinture (WebAudio) et migration des réglages localStorage → KVP (rappel NUI « ready »).
// Ce n'est PAS un essai dans le navigateur de FiveM (CEF) ni dans GTA.
// Usage (depuis nocturne_hud/) : node tests/app_test.js
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const SRC = fs.readFileSync(process.env.APP_JS || path.join(__dirname, '..', 'html', 'app.js'), 'utf8');
let passed = 0, failed = 0;
function check(name, cond) { if (cond) passed++; else failed++; console.log((cond ? 'PASS ' : 'FAIL ') + name); }

// Élément de DOM « tout accepte » : propriétés mémorisées, méthodes inconnues sans effet
function element() {
  const style = { setProperty() {}, removeProperty() {}, getPropertyValue: () => '' };
  const store = { style, dataset: {}, children: [], classList: { add() {}, remove() {}, toggle() { return false; }, contains() { return false; } } };
  const fn = function () {};
  const proxy = new Proxy(fn, {
    get(t, k) {
      if (k in store) return store[k];
      if (k === Symbol.toPrimitive) return () => '';
      if (k === 'nextNode') return () => null;
      if (k === 'querySelectorAll') return () => [];
      if (k === 'querySelector' || k === 'closest') return () => element();
      if (k === 'getBoundingClientRect') return () => ({ left: 0, top: 0, width: 100, height: 100, right: 100, bottom: 100 });
      if (k === 'appendChild') return c => { store.children.push(c); return c; };
      if (k === 'firstChild') return store.children[0];
      if (k === 'then') return undefined;
      return (...a) => element();
    },
    set(t, k, v) { store[k] = v; return true; },
    apply() { return element(); },
  });
  return proxy;
}

// Charge app.js dans un contexte neuf ; renvoie les poignées du test
function load(opts) {
  const nodes = new Map();
  const handlers = {};
  const tones = [], posts = [];
  const ls = new Map(Object.entries(opts.localStorage || {}));
  let clock = 1_000_000;
  const timers = [];
  class FakeAudio {
    constructor() { this.currentTime = 0; this.destination = {}; FakeAudio.count++; }
    createOscillator() { const o = { frequency: { value: 0 }, connect() {}, start() { tones.push(o.frequency.value); }, stop() {} }; return o; }
    createGain() { return { gain: { value: 0, exponentialRampToValueAtTime() {} }, connect() {} }; }
  }
  FakeAudio.count = 0;
  const document = element();
  document.getElementById = id => { if (!nodes.has(id)) nodes.set(id, element()); return nodes.get(id); };
  document.createElement = () => element();
  document.createTreeWalker = () => ({ nextNode: () => null });
  document.body = element(); document.documentElement = element();
  const ctx = {
    console: { log() {}, warn() {}, error: console.error },
    document,
    NodeFilter: { SHOW_TEXT: 4 },
    localStorage: { getItem: k => (ls.has(k) ? ls.get(k) : null), setItem: (k, v) => ls.set(k, String(v)), removeItem: k => ls.delete(k) },
    addEventListener: (n, f) => { handlers[n] = f; },
    removeEventListener() {},
    setInterval: (f, ms) => { timers.push({ f, ms }); return timers.length; },
    setTimeout: (f) => 0, clearTimeout() {}, clearInterval() {},
    requestAnimationFrame() {}, innerWidth: 1920, innerHeight: 1080, devicePixelRatio: 1,
    getComputedStyle: () => ({ getPropertyValue: () => '' }),
    AudioContext: FakeAudio,
    Date: class extends Date { static now() { return clock; } },
    Promise, JSON, Math, Object, Array, String, Number, Set, Map, isNaN, parseFloat, parseInt,
  };
  if (opts.inGame) {
    ctx.GetParentResourceName = () => 'nocturne_hud';
    ctx.fetch = (url, o) => {
      const name = url.split('/').pop(); const body = JSON.parse(o.body || '{}');
      posts.push({ name, body });
      if (name === 'ready') return opts.readyFails ? Promise.reject(new Error('panne')) : Promise.resolve({ json: () => Promise.resolve(opts.ready || {}) });
      return Promise.resolve({ json: () => Promise.resolve({}) });
    };
  }
  ctx.window = ctx;
  vm.createContext(ctx);
  vm.runInContext(SRC, ctx, { filename: 'html/app.js' });
  return {
    send: m => handlers.message && handlers.message({ data: m }),
    tick: ms => { clock += ms; },
    flush: () => new Promise(r => setImmediate(r)),
    tones, posts, ls, audio: () => FakeAudio.count,
    renderTimer: () => timers.find(t => t.ms === 200),
    node: id => document.getElementById(id),
  };
}

const VEH = (o) => ({ cls: 'car', speed: 0, rpm: 0.2, gear: 'N', fuel: 70, engine: 100, belt: false, lights: 0, blink: 0, ...o });
const SLOW = (o) => ({ id: 1, players: 1, maxPlayers: 4, cash: 0, bank: 0, job: '', street: '', zone: '', lang: 'fr', ...o });

(async () => {
  // ---------- sons de ceinture
  {
    const h = load({});
    h.send({ t: 's', d: SLOW({}) });
    h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 10 }) } });
    check('ceinture : pas de son à l\'arrêt relatif (10 km/h) ni au premier état', h.tones.length === 0);
    h.tick(100); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 40 }) } });
    check('ceinture détachée à 40 km/h : bip d\'alerte 880 Hz', h.tones.length === 1 && h.tones[0] === 880);
    h.tick(500); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 40 }) } });
    check('alerte limitée : pas de second bip avant 1,5 s', h.tones.length === 1);
    h.tick(1100); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 40 }) } });
    check('second bip après 1,5 s', h.tones.length === 2 && h.tones[1] === 880);
    h.tick(100); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 40, belt: true }) } });
    check('ceinture attachée : clic 1800 Hz, plus d\'alerte', h.tones.at(-1) === 1800);
    const n = h.tones.length;
    h.tick(3000); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 60, belt: true }) } });
    check('ceinture attachée à 60 km/h : silence', h.tones.length === n);
    h.tick(100); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 60, belt: false }) } });
    check('ceinture détachée : clic 1100 Hz', h.tones.includes(1100));
    check('un seul AudioContext pour tous les sons', h.audio() === 1);
  }
  {
    const h = load({});
    h.send({ t: 's', d: SLOW({ beltSounds: false }) });
    h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 80 }) } });
    h.tick(2000); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 80 }) } });
    check('sons coupés (beltSounds = false) : aucun son', h.tones.length === 0);
  }
  {
    const h = load({});
    h.send({ t: 's', d: SLOW({}) });
    h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ cls: 'moto', speed: 80 }) } });
    h.tick(2000); h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ cls: 'moto', speed: 80 }) } });
    check('moto : pas de son de ceinture', h.tones.length === 0);
  }

  // ---------- 1.7.1 : décrochage décidé par le client Lua, plus de trajet affiché
  {
    const h = load({});
    h.send({ t: 's', d: SLOW({}) });
    const P = o => VEH({ cls: 'plane', alt: 500, vs: -800, gearDown: false, ...o });
    h.send({ t: 'u', d: { show: true, stats: {}, veh: P({ speed: 120, stall: false }) } });
    check('avion lent sans drapeau stall : TRAIN RENTRÉ (plus de seuil fixe à 150 km/h)', h.node('gear').textContent === 'TRAIN RENTRÉ');
    h.send({ t: 'u', d: { show: true, stats: {}, veh: P({ speed: 70, stall: true }) } });
    check('drapeau stall du client : DÉCROCHAGE', h.node('gear').textContent === 'DÉCROCHAGE');
    h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 50, trip: 12.3 }) } });
    check('trajet en cours jamais affiché', h.node('odo').textContent === '');
    h.send({ t: 'u', d: { show: true, stats: {}, veh: VEH({ speed: 50, km: 48213 }) } });
    check('kilométrage du HUD toujours affiché', /48\s?213 km/.test(String(h.node('odo').textContent).replace(/\u202f|\u00a0/g, ' ')));
  }

  // ---------- migration des réglages
  const KEY = 'nocturne_hud_cfg_v1';
  {
    // 1.6 → 1.7 : réglages locaux, KVP vide → la copie locale part en KVP (rappel « cfg » avec full)
    const old = { style: 'bars', hide: { map: true }, colors: { accent: '#ff0000' } };
    const h = load({ inGame: true, localStorage: { [KEY]: JSON.stringify(old) }, ready: {} });
    await h.flush(); await h.flush();
    const cfgPost = h.posts.filter(p => p.name === 'cfg').at(-1);
    check('migration : « ready » demandé au démarrage', h.posts[0] && h.posts[0].name === 'ready');
    check('migration : réglages locaux envoyés au KVP (cfg.full)', cfgPost && cfgPost.body.full && cfgPost.body.full.style === 'bars');
    check('migration : hideMap transmis au client Lua', cfgPost && cfgPost.body.hideMap === true);
  }
  {
    // KVP présent : il fait foi et remplace la copie locale
    const kvp = { style: 'rings', hide: {}, colors: { accent: '#00ff00' } };
    const h = load({ inGame: true, localStorage: { [KEY]: JSON.stringify({ style: 'bars' }) }, ready: { cfg: kvp, profiles: [null, { style: 'bars' }, null] } });
    await h.flush(); await h.flush();
    const local = JSON.parse(h.ls.get(KEY) || '{}');
    check('KVP présent : il remplace la copie locale', local.style === 'rings');
    check('KVP présent : profil 1 recopié en local', h.ls.has('nocturne_hud_prof1') || [...h.ls.keys()].some(k => /prof.*1/.test(k)));
  }
  {
    // Rappel « ready » en panne : le HUD démarre quand même et garde la copie locale
    const h = load({ inGame: true, localStorage: { [KEY]: JSON.stringify({ style: 'bars' }) }, readyFails: true });
    await h.flush(); await h.flush();
    const cfgPost = h.posts.filter(p => p.name === 'cfg').at(-1);
    check('« ready » en panne : réglages locaux gardés et sauvegardés quand même', cfgPost && cfgPost.body.full && cfgPost.body.full.style === 'bars');
  }
  {
    // Hors jeu (démo navigateur) : aucun appel réseau
    const h = load({ inGame: false });
    await h.flush();
    check('hors jeu : aucun rappel NUI envoyé', h.posts.length === 0);
    check('rendu régulier toutes les 200 ms programmé', !!h.renderTimer());
  }

  console.log(`RESULT ${passed} passed, ${failed} failed ; app.js sous Node avec faux DOM et faux AudioContext, pas un essai CEF/GTA`);
  process.exit(failed ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
