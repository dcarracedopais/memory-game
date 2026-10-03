window.meriRead = key => { try { return localStorage.getItem(key); } catch (_) { return null; } };
window.meriWrite = (key, value) => { try { localStorage.setItem(key, value); return true; } catch (_) { return false; } };
let audio;
let generation = 0, speaking = false, currentClip, currentUtterance, deferredEffect;
const pronunciationQueue = [], oscillators = new Set();
const localSpanishVoice = () => {
  const voices = window.speechSynthesis?.getVoices().filter(v => v.localService && /^es(?:[-_]|$)/i.test(v.lang)) || [];
  return voices.find(v => /^es[-_]ES$/i.test(v.lang)) || voices[0];
};
// Some browsers populate voices asynchronously. Query again on each gesture.
window.speechSynthesis?.addEventListener('voiceschanged', localSpanishVoice);
window.speechSynthesis?.getVoices();
const playTone = kind => {
  try {
    audio ||= new (window.AudioContext || window.webkitAudioContext)();
    audio.resume().catch(() => {});
    const tones = {flip: [440], match: [523, 659], miss: [280, 220], win: [523, 659, 784, 1047]}[kind] || [440];
    tones.forEach((frequency, i) => {
      const oscillator = audio.createOscillator(), gain = audio.createGain();
      const start = audio.currentTime + i * .13;
      oscillator.type = 'sine'; oscillator.frequency.value = frequency;
      gain.gain.setValueAtTime(0, start);
      gain.gain.linearRampToValueAtTime(.08, start + .015);
      gain.gain.exponentialRampToValueAtTime(.001, start + .12);
      oscillator.connect(gain); gain.connect(audio.destination);
      oscillators.add(oscillator); oscillator.onended = () => oscillators.delete(oscillator);
      oscillator.start(start); oscillator.stop(start + .14);
    });
  } catch (_) { /* Audio is optional. */ }
};
window.meriSound = kind => {
  if (speaking || pronunciationQueue.length) deferredEffect = kind;
  else playTone(kind);
};
const runPronunciation = () => {
  if (speaking) return;
  const entry = pronunciationQueue.shift();
  if (!entry) {
    if (deferredEffect) { const effect = deferredEffect; deferredEffect = null; playTone(effect); }
    return;
  }
  speaking = true;
  const token = generation;
  let finished = false;
  const finish = () => {
    if (finished || token !== generation) return;
    finished = true; clearTimeout(watchdog);
    speaking = false; currentClip = null; currentUtterance = null;
    runPronunciation();
  };
  const watchdog = setTimeout(() => {
    if (token !== generation || finished) return;
    currentClip?.pause(); window.speechSynthesis?.cancel(); finish();
  }, 6000);
  let attemptedSpeech = false;
  const speak = () => {
    if (attemptedSpeech) return;
    attemptedSpeech = true;
    const voice = localSpanishVoice();
    if (!voice || !window.SpeechSynthesisUtterance) { finish(); return; }
    const utterance = new SpeechSynthesisUtterance(entry.name);
    currentUtterance = utterance;
    utterance.voice = voice; utterance.lang = voice.lang; utterance.rate = .85;
    utterance.onend = finish; utterance.onerror = finish;
    window.speechSynthesis.speak(utterance);
  };
  if (entry.asset) {
    const clip = new Audio(new URL('assets/' + entry.asset, document.baseURI).href);
    currentClip = clip;
    clip.onended = finish;
    clip.onerror = () => { if (token === generation && !finished) speak(); };
    clip.play().catch(() => { if (token === generation && !finished) speak(); });
  } else speak();
};
window.meriPronounce = (name, asset) => {
  if (!asset && (!localSpanishVoice() || !window.SpeechSynthesisUtterance)) return false;
  // Keep the current word intact and bound the backlog during quick taps.
  if (pronunciationQueue.length >= 2) pronunciationQueue.shift();
  pronunciationQueue.push({name, asset}); runPronunciation(); return true;
};
window.meriStopAudio = () => {
  generation++; pronunciationQueue.length = 0; deferredEffect = null; speaking = false;
  currentClip?.pause(); currentClip = null; currentUtterance = null;
  window.speechSynthesis?.cancel();
  for (const oscillator of oscillators) { try { oscillator.stop(); } catch (_) {} }
  oscillators.clear();
};
window.addEventListener('load', () => {
  if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});
});
