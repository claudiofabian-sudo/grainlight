import React from 'react';
import {Composition} from 'remotion';
import {GrainlightPromo, TOTAL} from './Promo';

export const RemotionRoot: React.FC = () => (
  <Composition
    id="GrainlightPromo"
    component={GrainlightPromo}
    durationInFrames={TOTAL}
    fps={30}
    width={1920}
    height={1080}
  />
);
