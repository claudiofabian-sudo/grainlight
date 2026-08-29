import React from 'react';
import {
  AbsoluteFill,
  OffthreadVideo,
  Sequence,
  interpolate,
  staticFile,
  useCurrentFrame,
} from 'remotion';
import {
  Body,
  C,
  DARK_BG,
  DISPLAY,
  Display,
  EASE,
  EASE_IO,
  Index,
  LIGHT_BG,
  Label,
  Mask,
  TEXT,
  Ticker,
  Vignette,
  Wordmark,
  pop,
  ramp,
  useFps,
  window3,
} from './theme';

const FULL: React.CSSProperties = {width: '100%', height: '100%', objectFit: 'cover'};

/** Todos los planos van en bucle: ninguno se queda congelado al final. */
const Clip: React.FC<{
  src: string;
  style?: React.CSSProperties;
}> = ({src, style}) => (
  <OffthreadVideo src={staticFile(src)} muted loop style={{...FULL, ...style}} />
);

/* ================================================================== */
/* 1 · APERTURA — papel                                                */
/* ================================================================== */

export const Open: React.FC = () => {
  const f = useCurrentFrame();
  const rule = interpolate(ramp(f, 26, 34), [0, 1], [0, 560]);

  return (
    <AbsoluteFill style={{background: LIGHT_BG}}>
      {[0, 1].map((i) => {
        const p = ramp(f, 2 + i * 6, 40, EASE_IO);
        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: `${-40 + p * 140}%`,
              top: i === 0 ? 300 : 796,
              width: '52%',
              height: 1.5,
              background: i === 0 ? C.amber : C.inkFaint,
              opacity: window3(f, i * 6, 14, 62, 24),
            }}
          />
        );
      })}

      <AbsoluteFill style={{alignItems: 'center', justifyContent: 'center'}}>
        <Mask at={12} dur={34}>
          <Wordmark size={158} />
        </Mask>
        <div
          style={{
            width: rule,
            height: 2,
            background: `linear-gradient(90deg, rgba(233,162,59,0), ${C.amber}, rgba(233,162,59,0))`,
            margin: '28px 0 24px',
          }}
        />
        <Mask at={34} dur={28}>
          <Label size={19} color={C.inkSoft}>
            Project your films with an analog soul
          </Label>
        </Mask>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

/* ================================================================== */
/* 2 · EL PROBLEMA                                                     */
/* ================================================================== */

export const Problem: React.FC = () => {
  const f = useCurrentFrame();
  const k = interpolate(f, [0, 144], [1.03, 1.11], {easing: EASE_IO});

  return (
    <AbsoluteFill style={{background: DARK_BG}}>
      <AbsoluteFill>
        <Clip
          src="wave-clean.mp4"
          style={{transform: `scale(${k})`, filter: 'brightness(0.52)'}}
        />
        <Vignette strength={0.6} />
      </AbsoluteFill>

      <AbsoluteFill style={{padding: '0 130px', justifyContent: 'center'}}>
        <div style={{marginBottom: 32}}>
          <Index n="01" at={6} />
        </div>
        <Mask at={12} dur={32}>
          <Display size={150}>PERFECT PIXELS.</Display>
        </Mask>
        <div style={{height: 10}} />
        <Mask at={30} dur={32}>
          <Display size={150} color={C.snowSoft}>
            ZERO SOUL.
          </Display>
        </Mask>
      </AbsoluteFill>

      <AbsoluteFill
        style={{padding: '0 130px', justifyContent: 'flex-end', paddingBottom: 86}}
      >
        <Mask at={50} dur={26}>
          <Label size={15}>Interstellar · IMAX 4K remux · untouched</Label>
        </Mask>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

/* ================================================================== */
/* 3 · EL BARRIDO — tres películas, la misma prueba                    */
/* ================================================================== */

export const SweepShot: React.FC<{
  clean: string;
  grain: string;
  film: string;
  index: string;
  /** el último remata con el titular */
  last?: boolean;
}> = ({clean, grain, film, index, last}) => {
  const f = useCurrentFrame();
  /*
   * El barrido se toma su tiempo: primero deja ver el máster casi un
   * segundo, cruza despacio, retrocede a media pantalla para que se
   * pueda comparar, y termina de pasar. Sin prisa no se nota nada.
   */
  const p = Math.max(
    0,
    Math.min(
      1,
      ramp(f, 26, 56, EASE_IO) -
        ramp(f, 88, 26, EASE_IO) * 0.55 +
        ramp(f, 120, 34, EASE_IO) * 0.55
    )
  );
  const x = p * 1920;
  const on = window3(f, 18, 10, last ? 250 : 150, 12);

  return (
    <AbsoluteFill style={{background: DARK_BG}}>
      <AbsoluteFill>
        <Clip src={clean} />
        <AbsoluteFill style={{clipPath: `inset(0 ${(1 - p) * 100}% 0 0)`}}>
          <Clip src={grain} />
        </AbsoluteFill>

        <div
          style={{
            position: 'absolute',
            left: x - 2,
            top: 0,
            bottom: 0,
            width: 4,
            background: C.amber,
            opacity: on,
            boxShadow: `0 0 66px 16px rgba(233,162,59,${on * 0.55})`,
          }}
        />
        <div
          style={{
            position: 'absolute',
            left: Math.max(46, x - 258),
            top: 66,
            opacity: on * Math.min(1, Math.max(0, (p - 0.12) * 4)),
          }}
        >
          <Label size={16} color={C.amber}>
            Grainlight
          </Label>
        </div>
        <div
          style={{
            position: 'absolute',
            left: Math.min(1716, x + 44),
            top: 66,
            opacity: on * Math.min(1, Math.max(0, (0.9 - p) * 4)),
          }}
        >
          <Label size={16} color={C.snow}>
            Master
          </Label>
        </div>
        <Vignette strength={0.32} />
      </AbsoluteFill>

      {/* pie: índice y película */}
      <AbsoluteFill
        style={{padding: '0 130px', justifyContent: 'flex-end', paddingBottom: 68}}
      >
        {last ? (
          <>
            <Mask at={150} dur={30}>
              <Display size={92}>REAL 35 MM. LIVE.</Display>
            </Mask>
            <div style={{height: 14}} />
            <Mask at={166} dur={26}>
              <Label size={15}>GPU shaders · nothing re-encoded · file untouched</Label>
            </Mask>
          </>
        ) : (
          <div style={{display: 'flex', alignItems: 'center', gap: 26}}>
            <Index n={index} of="03" at={8} />
            <div style={{opacity: ramp(f, 12, 22)}}>
              <Label size={15}>{film}</Label>
            </div>
          </div>
        )}
      </AbsoluteFill>

      {last ? (
        <AbsoluteFill style={{padding: '0 130px', paddingTop: 62}}>
          <div style={{opacity: ramp(f, 8, 20)}}>
            <Label size={15}>{film}</Label>
          </div>
        </AbsoluteFill>
      ) : null}
    </AbsoluteFill>
  );
};

/* ================================================================== */
/* 4 · ZOOM — el grano, sobre el Hobbit                                */
/* ================================================================== */

const Card: React.FC<{src: string; zoom: number; label: string; hot?: boolean}> = ({
  src,
  zoom,
  label,
  hot,
}) => (
  <div style={{display: 'flex', flexDirection: 'column', alignItems: 'center'}}>
    <div
      style={{
        width: 844,
        height: 552,
        borderRadius: 18,
        overflow: 'hidden',
        position: 'relative',
        border: hot
          ? `1.5px solid rgba(233,162,59,0.45)`
          : '1.5px solid rgba(247,245,241,0.13)',
        boxShadow: hot
          ? '0 40px 110px rgba(233,162,59,0.16)'
          : '0 40px 110px rgba(0,0,0,0.62)',
      }}
    >
      <Clip src={src} style={{transform: `scale(${zoom})`, transformOrigin: '46% 34%'}} />
    </div>
    <div style={{marginTop: 18}}>
      <Label size={15} color={hot ? C.amber : C.snowSoft}>
        {label}
      </Label>
    </div>
  </div>
);

export const GrainZoom: React.FC = () => {
  const f = useCurrentFrame();
  const fps = useFps();
  const zoom = interpolate(f, [14, 186], [1, 5], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: EASE_IO,
  });
  const sL = pop(f, 0, fps);
  const sR = pop(f, 6, fps);
  const glow = ramp(f, 10, 40);

  return (
    <AbsoluteFill style={{background: DARK_BG}}>
      {/* el fondo no es negro plano: hay una sala detrás.
          Un halo cálido tras el panel tratado y dos filetes de encuadre. */}
      <AbsoluteFill
        style={{
          background:
            'radial-gradient(52% 44% at 74% 46%, rgba(233,162,59,0.13) 0%, rgba(233,162,59,0) 62%)',
          opacity: glow,
        }}
      />
      <AbsoluteFill
        style={{
          background:
            'radial-gradient(46% 40% at 24% 52%, rgba(120,150,190,0.07) 0%, rgba(0,0,0,0) 66%)',
        }}
      />
      <AbsoluteFill style={{alignItems: 'center', justifyContent: 'center'}}>
        <div style={{display: 'flex', gap: 14}}>
          <div style={{transform: `translateX(${(1 - sL) * -430}px)`, opacity: sL}}>
            <Card src="hob-clean.mp4" zoom={zoom} label="Digital master" />
          </div>
          <div style={{transform: `translateX(${(1 - sR) * 430}px)`, opacity: sR}}>
            <Card src="hob-grain.mp4" zoom={zoom} label="Grainlight" hot />
          </div>
        </div>
      </AbsoluteFill>

      <AbsoluteFill style={{alignItems: 'center', paddingTop: 52}}>
        <Mask at={8} dur={28} outAt={164} outDur={16}>
          <Display size={80}>LOOK CLOSER.</Display>
        </Mask>
        <Mask at={172} dur={28}>
          <Display size={80}>GRAIN THAT BREATHES.</Display>
        </Mask>
      </AbsoluteFill>

      <AbsoluteFill
        style={{alignItems: 'center', justifyContent: 'flex-end', paddingBottom: 38}}
      >
        <div
          style={{opacity: ramp(f, 18, 22), display: 'flex', alignItems: 'baseline', gap: 18}}
        >
          <Ticker value={zoom} suffix="×" size={62} />
          <Label size={14}>The Hobbit</Label>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

/* ================================================================== */
/* 5 · LOS CUATRO PRESETS — sección clara                              */
/* ================================================================== */

const PRESETS: [string, string, string][] = [
  ['dra-p1.mp4', '01', 'SUBTLE'],
  ['dra-p2.mp4', '02', '2000s CINEMA'],
  ['dra-p3.mp4', '03', 'WORN PRINT'],
  ['dra-p4.mp4', '04', 'BALANCED'],
];

export const Presets: React.FC = () => {
  const f = useCurrentFrame();
  const fps = useFps();

  return (
    <AbsoluteFill style={{background: LIGHT_BG, padding: '58px 96px'}}>
      <div style={{display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between'}}>
        <div>
          <div style={{marginBottom: 20}}>
            <Index n="04" at={2} dim={C.inkFaint} />
          </div>
          <Mask at={6} dur={30}>
            <Display size={88} color={C.ink}>
              FOUR WAYS TO PROJECT.
            </Display>
          </Mask>
        </div>
        <div style={{paddingBottom: 12, opacity: ramp(f, 26, 24)}}>
          <Label size={14} color={C.inkSoft}>
            House of the Dragon · same frame
          </Label>
        </div>
      </div>

      <div
        style={{
          marginTop: 42,
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gridTemplateRows: '1fr 1fr',
          gap: 18,
          flex: 1,
          minHeight: 0,
        }}
      >
        {PRESETS.map(([src, n, name], i) => {
          const sp = pop(f, 30 + i * 8, fps, 17);
          return (
            <div
              key={src}
              style={{
                position: 'relative',
                borderRadius: 14,
                overflow: 'hidden',
                minHeight: 0,
                background: C.ink,
                opacity: sp,
                transform: `translateY(${(1 - sp) * 34}px) scale(${0.97 + sp * 0.03})`,
                boxShadow: '0 26px 60px rgba(11,11,13,0.16)',
              }}
            >
              <Clip src={src} />
              <div
                style={{
                  position: 'absolute',
                  left: 22,
                  bottom: 18,
                  display: 'flex',
                  alignItems: 'baseline',
                  gap: 12,
                }}
              >
                <span
                  style={{
                    fontFamily: DISPLAY,
                    fontSize: 21,
                    fontWeight: 700,
                    color: C.amber,
                    letterSpacing: '-0.02em',
                  }}
                >
                  {n}
                </span>
                <span
                  style={{
                    fontFamily: TEXT,
                    fontSize: 16,
                    fontWeight: 600,
                    letterSpacing: '0.22em',
                    color: C.snow,
                  }}
                >
                  {name}
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

/* ================================================================== */
/* 6 · AMBIENT LIGHT — tres películas, el mismo vacío                  */
/* ================================================================== */

const BAR = 138;

/**
 * El relleno se escala un pelo: el grafo de ambient deja una fila de
 * píxeles negros en el borde y así queda fuera de cuadro.
 */
const AMB_FIX: React.CSSProperties = {transform: 'scale(1.008)'};

export const Ambient: React.FC = () => {
  const f = useCurrentFrame();
  const spill = ramp(f, 54, 44, EASE_IO);
  const inset = (1 - spill) * BAR;
  const rotk = ramp(f, 150, 14);
  const sw = ramp(f, 218, 14);

  return (
    <AbsoluteFill style={{background: '#000'}}>
      {/* Hobbit: las barras se abren y el relleno se derrama */}
      <AbsoluteFill style={{clipPath: `inset(${inset}px 0 ${inset}px 0)`}}>
        <Clip src="hobbit-ambient.mp4" style={AMB_FIX} />
      </AbsoluteFill>

      {/* y lo mismo en otras dos películas: cada una arranca su propio
          plano al entrar, para que siempre haya movimiento en pantalla */}
      <AbsoluteFill style={{opacity: rotk}}>
        <Sequence from={148} layout="none">
          <Clip src="rotk-ambient.mp4" style={AMB_FIX} />
        </Sequence>
      </AbsoluteFill>
      <AbsoluteFill style={{opacity: sw}}>
        <Sequence from={216} layout="none">
          <Clip src="starwars-ambient.mp4" style={AMB_FIX} />
        </Sequence>
      </AbsoluteFill>

      {[0, 1].map((i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            top: i === 0 ? BAR : undefined,
            bottom: i === 1 ? BAR : undefined,
            height: 1.5,
            background: C.amber,
            opacity: window3(f, 10, 14, 60, 22) * 0.9,
          }}
        />
      ))}

      <AbsoluteFill style={{padding: '0 130px', justifyContent: 'center'}}>
        <div style={{opacity: 1 - ramp(f, 142, 12)}}>
          <div style={{marginBottom: 26}}>
            <Index n="05" at={4} />
          </div>
          <Mask at={8} dur={28} outAt={84} outDur={18}>
            <Label size={18} color={C.snow}>
              21:9 on a 16:9 screen
            </Label>
          </Mask>
          <div style={{height: 18}} />
          <Mask at={62} dur={30}>
            <Display size={132}>AMBIENT LIGHT</Display>
          </Mask>
          <div style={{height: 18}} />
          <Mask at={84} dur={26}>
            <Label size={17} color={C.ember}>
              The bars fill with the film itself
            </Label>
          </Mask>
        </div>
      </AbsoluteFill>

      {/* rótulo de la película que se ve en cada momento */}
      <AbsoluteFill
        style={{padding: '0 130px', justifyContent: 'flex-end', paddingBottom: 66}}
      >
        <div style={{opacity: rotk - sw}}>
          <Label size={15} color={C.snow}>
            The Return of the King
          </Label>
        </div>
        <div style={{position: 'absolute', left: 130, bottom: 66, opacity: sw}}>
          <Label size={15} color={C.snow}>
            The Force Awakens · every scope film, edge to edge
          </Label>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

/* ================================================================== */
/* 7 · EL SISTEMA — sección clara                                      */
/* ================================================================== */

const FEATURES: [string, string][] = [
  ['Organic grain', 'Silver-halide texture, generated per frame'],
  ['Gate weave & flicker', 'The mechanical life of a projector'],
  ['Halation', 'Light blooming through the film base'],
  ['Dust, hairs, cue marks', 'Reel changes every twelve minutes'],
  ['Analog audio', '35 mm optical track or vinyl warmth'],
  ['Cinema subtitles', 'Typeset into the emulsion'],
];

const THUMBS = ['rotk-grain.mp4', 'spi-grain.mp4', 'wave-grain.mp4', 'hob-grain.mp4'];

export const System: React.FC = () => {
  const f = useCurrentFrame();
  const fps = useFps();

  return (
    <AbsoluteFill style={{background: LIGHT_BG, padding: '72px 96px 60px'}}>
      <Mask at={0} dur={30}>
        <Display size={92} color={C.ink}>
          ONE PLAYER. ANALOG SIMULATION.
        </Display>
      </Mask>

      <div
        style={{
          marginTop: 52,
          display: 'grid',
          gridTemplateColumns: '1fr 1fr 1fr',
          columnGap: 54,
          rowGap: 30,
        }}
      >
        {FEATURES.map(([t, s], i) => {
          const sp = pop(f, 22 + i * 6, fps, 18);
          return (
            <div
              key={t}
              style={{
                opacity: sp,
                transform: `translateY(${(1 - sp) * 22}px)`,
                borderTop: `1px solid ${C.inkFaint}`,
                paddingTop: 16,
              }}
            >
              <div
                style={{
                  fontFamily: DISPLAY,
                  fontSize: 30,
                  fontWeight: 700,
                  letterSpacing: '-0.025em',
                  color: C.ink,
                }}
              >
                {t}
              </div>
              <Body size={19} color={C.inkSoft} style={{marginTop: 7}}>
                {s}
              </Body>
            </div>
          );
        })}
      </div>

      <div style={{marginTop: 'auto', display: 'flex', gap: 14}}>
        {THUMBS.map((src, i) => {
          const at = 66 + i * 6;
          const sp = pop(f, at, fps, 18);
          return (
            <div
              key={src}
              style={{
                flex: 1,
                height: 306,
                borderRadius: 12,
                overflow: 'hidden',
                opacity: sp,
                transform: `translateY(${(1 - sp) * 26}px)`,
                boxShadow: '0 20px 46px rgba(11,11,13,0.14)',
              }}
            >
              {/* cada miniatura arranca su plano al aparecer: si empezara
                  con la escena, los clips cortos llegarían al final
                  congelados justo cuando se ven */}
              <Sequence from={at} layout="none">
                <Clip src={src} />
              </Sequence>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

/* ================================================================== */
/* 8 · CIERRE                                                          */
/* ================================================================== */

export const Closing: React.FC = () => {
  const f = useCurrentFrame();
  const rule = interpolate(ramp(f, 18, 32), [0, 1], [0, 560]);

  return (
    <AbsoluteFill
      style={{background: LIGHT_BG, alignItems: 'center', justifyContent: 'center'}}
    >
      <Mask at={0} dur={32}>
        <Wordmark size={158} />
      </Mask>
      <div
        style={{
          width: rule,
          height: 2,
          background: `linear-gradient(90deg, rgba(233,162,59,0), ${C.amber}, rgba(233,162,59,0))`,
          margin: '28px 0 24px',
        }}
      />
      <Mask at={24} dur={28}>
        <Label size={19} color={C.inkSoft}>
          Project your films with an analog soul
        </Label>
      </Mask>
      <div style={{height: 40}} />
      <Mask at={44} dur={26}>
        <Label size={15} color={C.amber}>
          Free and open source
        </Label>
      </Mask>
    </AbsoluteFill>
  );
};
