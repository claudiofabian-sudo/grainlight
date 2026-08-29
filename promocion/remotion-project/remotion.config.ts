import {Config} from '@remotion/cli/config';

Config.setVideoImageFormat('jpeg');
Config.setJpegQuality(97);
Config.setCodec('h264');
Config.setCrf(15);
Config.setConcurrency(3);
