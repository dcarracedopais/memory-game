# Pronunciación de letras

No se incluyen grabaciones de terceros. La aplicación usa primero una grabación
local si existe y, en su defecto, una voz española instalada en el navegador/SO.
Las voces remotas no se usan. No hacen falta archivos si hay una voz local española.
En navegadores sin ella, añade grabaciones propias o con licencia compatible.

Formato: MP3, una palabra pronunciada por archivo; nombres a.mp3, b.mp3, c.mp3,
d.mp3, e.mp3, f.mp3, g.mp3, h.mp3, i.mp3, j.mp3, k.mp3, l.mp3, m.mp3, n.mp3,
enye.mp3, o.mp3, p.mp3, q.mp3, r.mp3, s.mp3, t.mp3, u.mp3, v.mp3, w.mp3, x.mp3,
y.mp3, z.mp3. Faltan las 27 grabaciones opcionales.

Correspondencia explícita en lib/models/content.dart: h = hache, j = jota,
enye = eñe, r = erre, w = uve doble, y = ye. El resto usa el nombre habitual.
Vuelve a generar la web al añadir audios. La reproducción de MP3 puede requerir conexión la primera vez.
