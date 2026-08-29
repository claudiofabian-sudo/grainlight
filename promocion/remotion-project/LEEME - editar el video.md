# Editar el promo de GRAINLIGHT

Este es el proyecto completo y funcional: código, dependencias y metraje.
Todo lo que necesitas está aquí.

## Lo más rápido

| Quiero… | Haz esto |
|---------|----------|
| **Ver y trastear el vídeo** | Doble clic en **`ABRIR ESTUDIO.bat`** |
| **Volver a generar el MP4** | Doble clic en **`RENDERIZAR VIDEO.bat`** |
| **Cambiar la música** | Sustituye `public\bed.m4a` por tu archivo (mismo nombre) y renderiza |

## Remotion Studio

`ABRIR ESTUDIO.bat` abre un editor en el navegador con:

- La **línea de tiempo** completa: arrastra el cursor y ve cualquier momento.
- **Vista previa en vivo**: si editas un archivo y guardas, el vídeo se
  actualiza solo, sin re-renderizar nada.
- Un botón de **render** para exportar desde ahí.

No es After Effects: no se arrastran capas con el ratón, se editan valores en
el código. Pero para cambiar tiempos, textos o colores es cómodo y ves el
resultado al instante.

## La música

El archivo `public\bed.m4a` es el rumor de sala que suena ahora. Para cambiarlo:

1. Renombra tu canción a `bed.m4a` y déjala en `public\` (sobrescribe).
   Vale casi cualquier formato de audio aunque la extensión diga `.m4a`.
2. Renderiza.

Si prefieres conservar el nombre original de tu archivo, cámbialo en
`src\Promo.tsx`, línea del `<Audio ... />`:

```tsx
<Audio src={staticFile('mi-cancion.mp3')} volume={0.85} />
```

El `volume` va de 0 a 1. El vídeo dura 62 segundos.

## Dónde tocar cada cosa

| Archivo | Qué controla |
|---------|--------------|
| `src\Promo.tsx` | **El montaje**: en qué fotograma empieza cada escena (a 30 fps) y las transiciones |
| `src\scenes.tsx` | **Las escenas**: textos, qué clip usa cada una, el barrido, el zoom, la rejilla |
| `src\theme.tsx` | **El diseño**: colores de marca, tipografías, tamaños, curvas de animación |
| `public\*.mp4` | El metraje ya procesado |

Los textos están en las escenas, en inglés y entre comillas — se cambian
directamente. Ejemplo, en `scenes.tsx`:

```tsx
<Display size={150}>PERFECT PIXELS.</Display>
```

## Regenerar el metraje

Si quieres otras películas u otros momentos:

1. `extract2.ps1` / `capture6.ps1` — edita las rutas y los tiempos de dentro.
   El primero corta el fragmento del remux; el segundo lo reproduce en tu
   reproductor real con los shaders puestos y guarda cada fotograma.
2. Los clips resultantes van a `public\`.

Durante la captura no bloquees la pantalla: el script maneja una ventana de
mpv y le hace capturas.

## Nota

`node_modules` pesa unos 400 MB y `public` unos 700 MB de metraje. Por eso el
proyecto vive aquí, en `C:\glpromo`, y no dentro de OneDrive. La copia que hay
en `promocion\remotion-project` es solo el código, para archivar.
