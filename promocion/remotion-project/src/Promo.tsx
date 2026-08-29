import React from 'react';
import {AbsoluteFill, Audio, Sequence, staticFile} from 'remotion';
import {C, FilmGrain, PushIn, PushOut, SlideIn} from './theme';
import {
  Ambient,
  Closing,
  GrainZoom,
  Open,
  Presets,
  Problem,
  SweepShot,
  System,
} from './scenes';

/**
 * 30 fps.
 *
 * Las escenas se solapan: la entrante se descubre por encima de la
 * saliente (SlideIn), así nunca aparece una banda opaca ni un hueco
 * negro entre planos. Por eso cada escena dura OV fotogramas más que
 * su hueco en el montaje.
 */
const OV = 22; // solape de la transición

const at = {
  open: 0,
  problem: 96,
  sweep1: 250,
  sweep2: 420,
  sweep3: 590,
  zoom: 810,
  presets: 1030,
  ambient: 1200,
  system: 1490,
  closing: 1730,
};

export const TOTAL = at.closing + 132; // 1862 = 62 s

export const GrainlightPromo: React.FC = () => (
  <AbsoluteFill style={{backgroundColor: C.ink}}>
    <Audio src={staticFile('bed.m4a')} volume={0.85} />

    <Sequence from={at.open} durationInFrames={at.problem - at.open + OV}>
      <Open />
    </Sequence>

    <Sequence from={at.problem} durationInFrames={at.sweep1 - at.problem + OV}>
      <SlideIn dir="right">
        <Problem />
      </SlideIn>
    </Sequence>

    {/* la misma prueba, tres películas, sin prisa */}
    <Sequence from={at.sweep1} durationInFrames={at.sweep2 - at.sweep1 + OV}>
      <SlideIn dir="right" dur={18}>
        <SweepShot
          clean="spi-clean.mp4"
          grain="spi-grain.mp4"
          film="Spider-Man: No Way Home"
          index="01"
        />
      </SlideIn>
    </Sequence>
    <Sequence from={at.sweep2} durationInFrames={at.sweep3 - at.sweep2 + OV}>
      <SlideIn dir="right" dur={18}>
        <SweepShot
          clean="wave-clean.mp4"
          grain="wave-grain.mp4"
          film="Interstellar"
          index="02"
        />
      </SlideIn>
    </Sequence>
    <Sequence from={at.sweep3} durationInFrames={at.zoom - at.sweep3 + OV}>
      <SlideIn dir="right" dur={18}>
        <SweepShot
          clean="rotk-clean.mp4"
          grain="rotk-grain.mp4"
          film="The Lord of the Rings"
          index="03"
          last
        />
      </SlideIn>
    </Sequence>

    <Sequence from={at.zoom} durationInFrames={at.presets - at.zoom + OV}>
      <SlideIn dir="up" dur={24}>
        <GrainZoom />
      </SlideIn>
    </Sequence>

    <Sequence from={at.presets} durationInFrames={at.ambient - at.presets + OV}>
      <SlideIn dir="left">
        <Presets />
      </SlideIn>
    </Sequence>

    <Sequence from={at.ambient} durationInFrames={at.system - at.ambient + OV}>
      <SlideIn dir="right">
        <Ambient />
      </SlideIn>
    </Sequence>

    {/*
      Cierre: la sección del sistema sube y sale mientras el logo la
      sigue desde abajo. Los dos movimientos comparten tiempo y curva,
      así que se leen como un solo desplazamiento.
    */}
    <Sequence from={at.system} durationInFrames={at.closing - at.system + 34}>
      <SlideIn dir="left">
        <PushOut at={at.closing - at.system} dur={30}>
          <System />
        </PushOut>
      </SlideIn>
    </Sequence>

    <Sequence from={at.closing} durationInFrames={132}>
      <PushIn dur={30}>
        <Closing />
      </PushIn>
    </Sequence>

    <FilmGrain opacity={0.045} />
  </AbsoluteFill>
);
