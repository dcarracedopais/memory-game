# MeriMemory

Un juego de Memory para disfrutar en móvil, tablet y escritorio, hecho con Flutter Web. Interfaz en español, cuatro dificultades (5, 10, 15 y 20 parejas), vista inicial de 5 segundos, giros animados, parejas que desaparecen y celebración final.

## Ejecutar

Requiere Flutter estable (verificado con 3.41.4 y Dart 3.11.1).

```bash
flutter pub get
flutter run -d chrome
```

## Verificar y generar web

```bash
flutter analyze
flutter test
flutter build web --no-web-resources-cdn --pwa-strategy=none
python3 -m http.server 8080 --directory build/web
```

Abre http://localhost:8080. Publica el contenido de `build/web` en un hosting estático HTTPS.

La build estándar `flutter build web` también funciona. La variante anterior mantiene CanvasKit local y usa nuestro service worker en lugar del generado por Flutter.

## Cartas personalizadas

Añade imágenes PNG, JPG/JPEG, WebP o GIF directamente en `assets/cards/` y vuelve a generar la aplicación. No necesitas cambiar código ni declarar cada archivo. Todas las imágenes disponibles participan en la selección aleatoria; cada partida elige las necesarias sin repetir identidades. Si faltan imágenes, se completan con placeholders de letras mayúsculas. Las imágenes se muestran sin distorsión. Consulta `assets/cards/README.md`.

## Juego y récords

El tiempo empieza después de ocultar la vista inicial. Cada intento de dos cartas cuenta como un movimiento. Las interacciones se bloquean durante giros y comparaciones; reiniciar invalida operaciones pendientes. El tiempo continúa si cambias de pestaña.

Puntuación: máximo entre cero y `parejas × 1000 − movimientos × 50 − segundos × 5`.

Los mejores tiempos y movimientos se guardan **independientemente** para cada dificultad en localStorage, junto con la preferencia de sonido. Persisten tras recargar en el mismo navegador y origen. Borrar los datos del sitio los elimina. Si el navegador bloquea el almacenamiento, puedes seguir jugando y se indica que no se guardó el resultado.

Los sonidos se sintetizan localmente con Web Audio, sin descargas ni paquetes. El primer toque desbloquea el audio; las restricciones del navegador pueden impedirlo y nunca interrumpen el juego.

## PWA

Incluye manifest, iconos propios y service worker (`web/sw.js`). La instalación depende del navegador y requiere HTTPS o localhost. Abre la aplicación una vez con conexión antes de usarla sin conexión. Las fotos personalizadas se almacenan al cargarlas; solo las que ya hayas usado estarán disponibles offline. Incrementa la versión `CACHE` del service worker al publicar actualizaciones. El código del juego se sirve desde la red cuando está disponible y usa la caché sin conexión.

## Organización y pruebas

- `lib/models/game.dart`: reglas, temporizador y cancelación de operaciones.
- `lib/screens/`: menú, partida y resultado.
- `lib/widgets/`: carta animada.
- `lib/services/`: descubrimiento de assets, récords y puente de navegador.
- `test/`: parejas, bloqueos, coincidencias, reinicio, victoria y flujo completo de interfaz en tamaños móvil/tablet/escritorio.

Sin backend, cuentas ni servicios externos. La única dependencia adicional es la fuente estándar `cupertino_icons`, necesaria para evitar avisos de iconos en widgets internos de Flutter.
