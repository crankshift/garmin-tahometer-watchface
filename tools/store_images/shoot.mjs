// Captures each .slide in store.html to docs/images/<data-file>.png at 1x.
import { spawn } from 'node:child_process';
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const HS = process.env.CHROME ?? `${process.env.HOME}/Library/Caches/ms-playwright/chromium_headless_shell-1228/chrome-headless-shell-mac-arm64/chrome-headless-shell`;
const port = 9334;
const chrome = spawn(HS, [`--remote-debugging-port=${port}`, '--no-sandbox', '--hide-scrollbars', '--allow-file-access-from-files', '--window-size=1500,4000', 'about:blank'], { stdio: 'ignore' });
const sleep = ms => new Promise(r => setTimeout(r, ms));
let targets;
for (let i = 0; i < 50; i++) { try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); if (targets.length) break; } catch {} await sleep(200); }
const ws = new WebSocket(targets.find(t => t.type === 'page').webSocketDebuggerUrl);
await new Promise(r => (ws.onopen = r));
let id = 0; const pending = new Map();
ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } };
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
await send('Emulation.setDeviceMetricsOverride', { width: 1500, height: 4000, deviceScaleFactor: 1, mobile: false });
await send('Page.navigate', { url: new URL('store.html', import.meta.url).href });
await sleep(1500);
await send('Runtime.evaluate', { expression: 'document.fonts.ready.then(() => 1)', awaitPromise: true });
const only = process.argv.slice(2);
const r = await send('Runtime.evaluate', { expression: `JSON.stringify([...document.querySelectorAll('.slide')].map(s => { const b = s.getBoundingClientRect(); return { id: s.id, file: s.dataset.file, x: b.x, y: b.y + scrollY, w: b.width, h: b.height }; }))`, returnByValue: true });
for (const s of JSON.parse(r.result.result.value)) {
  if (only.length && !only.includes(s.id)) continue;
  const shot = await send('Page.captureScreenshot', { format: 'png', clip: { x: s.x, y: s.y, width: s.w, height: s.h, scale: 1 }, captureBeyondViewport: true });
  writeFileSync(fileURLToPath(new URL(`../../docs/images/${s.file}.png`, import.meta.url)), Buffer.from(shot.result.data, 'base64'));
  console.log('wrote', s.id);
}
ws.close(); chrome.kill();
