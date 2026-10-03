const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');

let timer = 0;
const timers = new Map(), spoken = [], clips = [];
const synthesis = {
  getVoices: () => [{localService: true, lang: 'es-ES'}],
  addEventListener() {}, cancel() {},
  speak(utterance) { spoken.push(utterance); },
};
class Utterance { constructor(text) { this.text = text; } }
class Clip {
  constructor(url) { this.url = url; clips.push(this); }
  play() { return Promise.resolve(); }
  pause() { this.paused = true; }
}
const context = {
  window: {speechSynthesis: synthesis, SpeechSynthesisUtterance: Utterance, addEventListener() {}},
  SpeechSynthesisUtterance: Utterance, Audio: Clip,
  navigator: {}, document: {baseURI: 'http://localhost/'}, URL,
  setTimeout(fn) { timers.set(++timer, fn); return timer; },
  clearTimeout(id) { timers.delete(id); },
};
vm.createContext(context);
vm.runInContext(fs.readFileSync('web/meri.js', 'utf8'), context);
const bridge = context.window;
for (const name of ['hache', 'jota', 'eñe', 'erre', 'uve doble', 'ye']) {
  assert.equal(bridge.meriPronounce(name, null), true);
  assert.equal(spoken.at(-1).text, name);
  assert.equal(spoken.at(-1).voice.lang, 'es-ES');
  spoken.at(-1).onend();
}
bridge.meriPronounce('uve doble', null);
const oldTimeout = [...timers.values()][0];
bridge.meriStopAudio();
bridge.meriPronounce('hache', null);
oldTimeout();
assert.equal(vm.runInContext('speaking', context), true, 'old timeout must not cancel new speech');
bridge.meriStopAudio();
assert.equal(vm.runInContext('speaking', context), false);
assert.equal(vm.runInContext('pronunciationQueue.length', context), 0);
synthesis.getVoices = () => [{localService: false, lang: 'es-ES'}];
assert.equal(bridge.meriPronounce('eñe', null), false, 'never use remote voices');

// Own recordings work without any installed voice and stop immediately on mute.
assert.equal(bridge.meriPronounce('eñe', 'assets/audio/letters/enye.mp3'), true);
assert.equal(clips.at(-1).url, 'http://localhost/assets/assets/audio/letters/enye.mp3');
bridge.meriStopAudio();
assert.equal(clips.at(-1).paused, true);
assert.equal(vm.runInContext('speaking', context), false);
console.log('Letter names, local voices/MP3, cancellation and remote-voice rejection: passed');
