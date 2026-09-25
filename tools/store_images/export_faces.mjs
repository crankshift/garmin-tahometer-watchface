// Renders watch face states from prototype/index.html in headless Chrome and writes 4x PNGs to bin/store/faces.
import { spawn } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const HS = process.env.CHROME ?? `${process.env.HOME}/Library/Caches/ms-playwright/chromium_headless_shell-1228/chrome-headless-shell-mac-arm64/chrome-headless-shell`;
const PROTO = new URL('../../prototype/index.html', import.meta.url).href;
const OUT = fileURLToPath(new URL('../../bin/store/faces', import.meta.url));
mkdirSync(OUT, { recursive: true });
const port = 9333;

const base = { h: 10, m: 36, s: 42, battery: 76, solar: 0, charging: false, minuteStyle: 'sweepTip',
  slots: { top: 'date', left: 'steps', right: 'heartRate', bottom: 'weather' } };
const states = {
  overview: {},
  needle: { minuteStyle: 'needle' },
  sweep: { minuteStyle: 'sweep' },
  sweeptip: { minuteStyle: 'sweepTip' },
  redline: { h: 4, m: 53, s: 47 },
  fuel_full: { battery: 100, solar: 40 },
  fuel_half: { battery: 50 },
  fuel_20: { battery: 20 },
  fuel_10: { battery: 10 },
  fuel_charging: { battery: 45, charging: true },
  slots_b: { slots: { top: 'bodyBattery', left: 'sun', right: 'notifications', bottom: 'battery' } },
};

const chrome = spawn(HS, [`--remote-debugging-port=${port}`, '--no-sandbox', '--hide-scrollbars', 'about:blank'], { stdio: 'ignore' });
const sleep = ms => new Promise(r => setTimeout(r, ms));
let targets;
for (let i = 0; i < 50; i++) {
  try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); if (targets.length) break; } catch {}
  await sleep(200);
}
const ws = new WebSocket(targets.find(t => t.type === 'page').webSocketDebuggerUrl);
await new Promise(r => (ws.onopen = r));
let id = 0; const pending = new Map();
ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } };
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
const evaluate = async expression => {
  const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
  if (r.result.exceptionDetails) throw new Error(JSON.stringify(r.result.exceptionDetails));
  return r.result.result.value;
};

await send('Page.navigate', { url: PROTO });
await sleep(1500);
for (const [name, over] of Object.entries(states)) {
  const st = { ...base, ...over };
  const url = await evaluate(`(() => {
    const st = ${JSON.stringify(st)};
    S.playing = false; S.awake = true;
    S.t = new Date(2026, 8, 25, st.h, st.m, st.s);
    S.battery = st.battery; S.solar = st.solar; S.charging = st.charging; S.minuteStyle = st.minuteStyle; S.slots = st.slots;
    render();
    const src = document.getElementById('small');
    const c = document.createElement('canvas'); c.width = c.height = 1040;
    const x = c.getContext('2d'); x.imageSmoothingEnabled = false; x.drawImage(src, 0, 0, 1040, 1040);
    return c.toDataURL('image/png');
  })()`);
  writeFileSync(`${OUT}/${name}.png`, Buffer.from(url.split(',')[1], 'base64'));
  console.log('wrote', name);
}
ws.close(); chrome.kill();
