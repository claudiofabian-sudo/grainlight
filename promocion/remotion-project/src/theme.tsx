import React from 'react';
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {loadFont as loadDisplay} from '@remotion/google-fonts/SpaceGrotesk';
import {loadFont as loadText} from '@remotion/google-fonts/Inter';

/* Titulares con carácter técnico; textos en una grotesca neutra. */
const {fontFamily: DISPLAY_FF} = loadDisplay();
const {fontFamily: TEXT_FF} = loadText();
export const DISPLAY = DISPLAY_FF;
export const TEXT = TEXT_FF;

/* ------------------------------------------------------------------ */
/*  PALETA — dos modos: papel y tinta, una sola luz                    */
/* ------------------------------------------------------------------ */
export const C = {
  paper: '#FFFFFF',
  bone: '#F1EFEA',
  ink: '#0B0B0D',
  inkSoft: 'rgba(11,11,13,0.55)',
  inkFaint: 'rgba(11,11,13,0.16)',
  snow: '#F7F5F1',
  snowSoft: 'rgba(247,245,241,0.56)',
  snowFaint: 'rgba(247,245,241,0.20)',
  amber: '#E9A23B',
  ember: '#F6CE8E',
};

/** degradado de sección clara: papel con una brisa cálida */
export const LIGHT_BG =
  'radial-gradient(120% 90% at 18% 0%, #FFFFFF 0%, #F5F3EE 46%, #EDEAE3 100%)';
/** degradado de sección oscura */
export const DARK_BG =
  'radial-gradient(120% 90% at 20% 0%, #16161A 0%, #0C0C0F 52%, #060607 100%)';

export const EASE = Easing.bezier(0.16, 1, 0.3, 1);
export const EASE_IO = Easing.bezier(0.76, 0, 0.24, 1);

export const ramp = (frame: number, from: number, dur: number, easing = EASE) =>
  interpolate(frame, [from, from + dur], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing,
  });

export const window3 = (
  frame: number,
  inAt: number,
  inDur: number,
  outAt: number,
  outDur: number
) => Math.min(ramp(frame, inAt, inDur), 1 - ramp(frame, outAt, outDur));

export const pop = (frame: number, at: number, fps: number, damping = 16) =>
  spring({
    frame: frame - at,
    fps,
    config: {damping, mass: 0.7, stiffness: 130},
    durationInFrames: 42,
  });

/* ------------------------------------------------------------------ */
/*  Revelado por máscara: el texto sube desde detrás de un borde       */
/* ------------------------------------------------------------------ */
export const Mask: React.FC<{
  at: number;
  dur?: number;
  outAt?: number;
  outDur?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({at, dur = 30, outAt, outDur = 18, children, style}) => {
  const f = useCurrentFrame();
  const p = ramp(f, at, dur);
  const q = outAt === undefined ? 0 : ramp(f, outAt, outDur, EASE_IO);
  return (
    <div style={{overflow: 'hidden', paddingBottom: '0.12em', ...style}}>
      <div
        style={{
          transform: `translateY(${(1 - p) * 118 - q * 118}%)`,
          willChange: 'transform',
        }}
      >
        {children}
      </div>
    </div>
  );
};

/** Titular */
export const Display: React.FC<{
  size?: number;
  color?: string;
  weight?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({size = 128, color = C.snow, weight = 700, children, style}) => (
  <div
    style={{
      fontFamily: DISPLAY,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: '-0.04em',
      lineHeight: 0.99,
      color,
      whiteSpace: 'nowrap',
      ...style,
    }}
  >
    {children}
  </div>
);

/**
 * La marca: GRAIN en el color del texto, LIGHT en el ámbar de la
 * lámpara. Es la firma de la identidad, no se compone a mano.
 */
export const Wordmark: React.FC<{size?: number; onDark?: boolean}> = ({
  size = 158,
  onDark = false,
}) => (
  <div
    style={{
      fontFamily: DISPLAY,
      fontSize: size,
      fontWeight: 700,
      letterSpacing: '-0.04em',
      lineHeight: 0.99,
      whiteSpace: 'nowrap',
    }}
  >
    <span style={{color: onDark ? C.snow : C.ink}}>GRAIN</span>
    <span style={{color: C.amber}}>LIGHT</span>
  </div>
);

/** Etiqueta técnica */
export const Label: React.FC<{
  color?: string;
  size?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({color = C.snowSoft, size = 17, children, style}) => (
  <div
    style={{
      fontFamily: TEXT,
      fontSize: size,
      fontWeight: 600,
      letterSpacing: '0.26em',
      textTransform: 'uppercase',
      color,
      ...style,
    }}
  >
    {children}
  </div>
);

/** Párrafo corto */
export const Body: React.FC<{
  color?: string;
  size?: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({color = C.snowSoft, size = 24, children, style}) => (
  <div
    style={{
      fontFamily: TEXT,
      fontSize: size,
      fontWeight: 400,
      letterSpacing: '-0.01em',
      color,
      ...style,
    }}
  >
    {children}
  </div>
);

/** Índice numerado con filete ámbar */
export const Index: React.FC<{
  n: string;
  of?: string;
  at: number;
  dim?: string;
}> = ({n, of = '05', at, dim = C.snowFaint}) => {
  const f = useCurrentFrame();
  const p = ramp(f, at, 26);
  return (
    <div style={{display: 'flex', alignItems: 'center', gap: 15, opacity: p}}>
      <div style={{width: interpolate(p, [0, 1], [0, 52]), height: 2, background: C.amber}} />
      <Label color={C.amber} size={16}>
        {n}
      </Label>
      <Label color={dim} size={16}>
        / {of}
      </Label>
    </div>
  );
};

/** Banda que cubre y destapa: la transición entre modos claro y oscuro */
export const BlockWipe: React.FC<{
  at: number;
  dur?: number;
  color?: string;
  dir?: 'left' | 'right' | 'up';
}> = ({at, dur = 26, color = C.ink, dir = 'right'}) => {
  const f = useCurrentFrame();
  const p = ramp(f, at, dur, EASE_IO);
  const cover = p < 0.5 ? p * 2 : 1;
  const uncover = p < 0.5 ? 0 : (p - 0.5) * 2;
  const size = `${Math.max(0, cover - uncover) * 100}%`;
  const box: React.CSSProperties = {position: 'absolute', background: color};
  if (dir === 'up') {
    box.left = 0;
    box.right = 0;
    box.height = size;
    box.bottom = `${uncover * 100}%`;
  } else {
    box.top = 0;
    box.bottom = 0;
    box.width = size;
    if (dir === 'right') box.left = `${uncover * 100}%`;
    else box.right = `${uncover * 100}%`;
  }
  return (
    <AbsoluteFill style={{pointerEvents: 'none'}}>
      <div style={box} />
    </AbsoluteFill>
  );
};

/**
 * Transición: la escena entrante se descubre sobre la anterior. No hay
 * banda opaca de por medio — el contenido nuevo ya está ahí desde el
 * primer fotograma del barrido, así que nunca se ve un hueco negro.
 */
export const SlideIn: React.FC<{
  dur?: number;
  dir?: 'left' | 'right' | 'up';
  children: React.ReactNode;
}> = ({dur = 22, dir = 'right', children}) => {
  const f = useCurrentFrame();
  const p = ramp(f, 0, dur, EASE_IO);
  const gap = (1 - p) * 100;
  const inset =
    dir === 'right' ? `0 ${gap}% 0 0` : dir === 'left' ? `0 0 0 ${gap}%` : `${gap}% 0 0 0`;
  const edge: React.CSSProperties = {
    position: 'absolute',
    top: 0,
    bottom: 0,
    width: 3,
    background: C.amber,
    boxShadow: '0 0 50px 12px rgba(233,162,59,0.45)',
  };
  if (dir === 'left') edge.left = 0;
  else edge.right = 0;
  return (
    <AbsoluteFill style={{clipPath: `inset(${inset})`}}>
      {children}
      {dir !== 'up' && p > 0.001 && p < 0.999 ? <div style={edge} /> : null}
    </AbsoluteFill>
  );
};

/**
 * Empuje vertical: la escena saliente sube y se va, y la entrante la
 * sigue desde abajo con el mismo tiempo. Vistas juntas parecen un solo
 * movimiento continuo — nada de fundidos.
 */
export const PushOut: React.FC<{
  at: number;
  dur?: number;
  children: React.ReactNode;
}> = ({at, dur = 30, children}) => {
  const f = useCurrentFrame();
  const p = ramp(f, at, dur, EASE_IO);
  return (
    <AbsoluteFill style={{transform: `translateY(${-p * 100}%)`}}>{children}</AbsoluteFill>
  );
};

export const PushIn: React.FC<{dur?: number; children: React.ReactNode}> = ({
  dur = 30,
  children,
}) => {
  const f = useCurrentFrame();
  const p = ramp(f, 0, dur, EASE_IO);
  return (
    <AbsoluteFill style={{transform: `translateY(${(1 - p) * 100}%)`}}>
      {children}
      {p > 0.001 && p < 0.999 ? (
        <div
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            top: 0,
            height: 3,
            background: C.amber,
            boxShadow: '0 0 50px 12px rgba(233,162,59,0.45)',
          }}
        />
      ) : null}
    </AbsoluteFill>
  );
};

/** Contador */
export const Ticker: React.FC<{
  value: number;
  suffix?: string;
  size?: number;
  color?: string;
}> = ({value, suffix = '', size = 76, color = C.amber}) => (
  <div
    style={{
      fontFamily: DISPLAY,
      fontSize: size,
      fontWeight: 700,
      letterSpacing: '-0.04em',
      color,
      fontVariantNumeric: 'tabular-nums',
      lineHeight: 1,
    }}
  >
    {value.toFixed(1)}
    <span style={{fontSize: size * 0.4, marginLeft: 5}}>{suffix}</span>
  </div>
);

/** Grano de marca sobre toda la pieza */
export const FilmGrain: React.FC<{opacity?: number}> = ({opacity = 0.045}) => {
  const frame = useCurrentFrame();
  const jump = (n: number) => ((Math.sin(n) * 43758.5453) % 1) * 320;
  return (
    <AbsoluteFill
      style={{
        backgroundImage: `url(${staticFile('noise.png')})`,
        backgroundRepeat: 'repeat',
        backgroundPosition: `${jump(frame * 1.37)}px ${jump(frame * 2.11 + 7)}px`,
        opacity,
        mixBlendMode: 'overlay',
        pointerEvents: 'none',
      }}
    />
  );
};

export const Vignette: React.FC<{strength?: number}> = ({strength = 0.5}) => (
  <AbsoluteFill
    style={{
      background: `radial-gradient(126% 80% at 50% 46%, rgba(0,0,0,0) 40%, rgba(0,0,0,${strength}) 100%)`,
      pointerEvents: 'none',
    }}
  />
);

export const useFps = () => useVideoConfig().fps;
