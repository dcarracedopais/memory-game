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

## Desplegar en Vercel desde GitHub

Importa `dcarracedopais/memory-game` en Vercel y conecta el repositorio con permisos de lectura. Configura la rama de producción como `main`: sus pushes generarán despliegues de producción y las otras ramas podrán generar previews.

| Campo | Valor |
| --- | --- |
| Application Preset / Framework Preset | **Other** |
| Root Directory | **Raíz del repositorio (`.`)**; deja el selector en su valor raíz, sin subcarpeta |
| Build Command | `bash scripts/vercel-build.sh` |
| Output Directory | `build/web` |
| Install Command | `true` |

Activa **Override** en los campos de comandos y salida si la interfaz lo requiere. `vercel.json` ya fija estos mismos valores (y tiene prioridad sobre los ajustes de build del panel). `true` no instala paquetes Node: el script se ocupa de las dependencias Dart. No se necesita `package.json`, variables secretas, backend ni una acción de GitHub adicional.

El script descarga el SDK oficial **Flutter 3.41.4** en una carpeta temporal, ejecuta `flutter pub get --enforce-lockfile` y construye la versión release con CanvasKit local y el service worker propio. No depende de Flutter preinstalado. Necesita Bash, Git, las herramientas Linux habituales y acceso a GitHub y a los repositorios oficiales de Flutter/Dart durante la build. La descarga del SDK se repite en cada build para mantener la configuración sencilla. Para actualizar Flutter, cambia `FLUTTER_VERSION` en `scripts/vercel-build.sh`, actualiza el lockfile si corresponde y vuelve a verificar.

Para reproducir exactamente la build de Vercel en Linux:

```bash
bash scripts/vercel-build.sh
```

El SDK temporal se elimina al terminar; solo se publica `build/web`. El fallback SPA devuelve `index.html` para rutas sin archivo, respetando primero los archivos existentes (JS, imágenes, manifest y service worker). El base href `/` permite cargar assets al abrir o recargar una ruta profunda. La aplicación actual usa el menú interno de Flutter y no necesita rutas adicionales.

Los archivos se revalidan antes de reutilizarse desde la caché HTTP para evitar versiones antiguas entre despliegues. Esto mantiene la caché offline del service worker; sigue incrementando su versión `CACHE` cuando publiques cambios. Vercel proporciona HTTPS, necesario para instalar la PWA. Los récords pertenecen al origen del navegador: localhost, previews y dominio de producción tienen registros separados.

Referencias: [configuración de Vercel](https://vercel.com/docs/project-configuration/vercel-json), [ajustes de build](https://vercel.com/docs/builds/configure-a-build) y [build y despliegue Flutter Web](https://docs.flutter.dev/deployment/web).

## Presentación y tablero responsive

La entrada muestra una portada con acceso al sonido y el botón **Jugar**. Después se elige la dificultad. Desde la partida o la victoria se puede volver a la selección; la flecha del menú vuelve a la portada. **Jugar otra vez** mantiene la dificultad.

El tablero compara filas y columnas según el número de cartas y el ancho y alto disponibles. Maximiza el tamaño de las cartas, penaliza filas incompletas y mantiene una proporción de 0,88 y un máximo de 190 px de ancho. Centra el conjunto y la última fila; las parejas desaparecidas conservan su espacio. En horizontal, los controles pasan al lateral cuando hay ancho suficiente. Solo ventanas excepcionalmente pequeñas necesitan desplazamiento dentro del tablero.

Los fondos usan gradientes y formas suaves dibujadas por Flutter, sin imágenes ni dependencias nuevas. Durante la partida son más discretos. El service worker usa la versión de caché `merimemory-v2` para esta iteración.

Los tests cubren también el centrado y los límites del tablero para todas las dificultades en 320×568, 390×844, 768×1024, 1440×900 y 844×390, además de la navegación desde la portada y la conservación de cartas al girar el dispositivo.

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
