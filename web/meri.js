window.meriRead = key => { try { return localStorage.getItem(key); } catch (_) { return null; } };
window.meriWrite = (key, value) => { try { localStorage.setItem(key, value); return true; } catch (_) { return false; } };
let audio;
window.meriSound = kind => {
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
      oscillator.start(start); oscillator.stop(start + .14);
    });
  } catch (_) { /* Audio is optional. */ }
};
window.addEventListener('load', () => {
  if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});
});
