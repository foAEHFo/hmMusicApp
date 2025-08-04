import image from '@ohos.multimedia.image';
import { effectKit } from '@kit.ArkGraphics2D';

export async function getAverageColor(context:Context,picture:Uint8Array): Promise<effectKit.Color> {
  const buffer = picture.buffer;

  const imageSource = image.createImageSource(buffer);
  const pixelMap = await imageSource.createPixelMap();

  const colorPicker = await effectKit.createColorPicker(pixelMap);
  const color = await colorPicker.getAverageColor()

  pixelMap.release();

  return color
}

export function interpolateChannel(startVal: number, endVal: number, ratio: number): number {
  return Math.round(startVal + (endVal - startVal) * ratio);
}

export function parseColor(color: string): number[] {
  let hex = color.replace('#', '');
  if (hex.length === 6) hex = 'FF' + hex;
  return [
    parseInt(hex.substring(0, 2), 16), // A
    parseInt(hex.substring(2, 4), 16), // R
    parseInt(hex.substring(4, 6), 16), // G
    parseInt(hex.substring(6, 8), 16)  // B
  ];
}

function rgbToHex(r: number, g: number, b: number): string {
  const toHex = (c: number) => {
    const hex = c.toString(16);
    return hex.length === 1 ? '0' + hex : hex;
  };
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

export function interpolateColors(startColor: string, endColor: string, ratio: number): string {
  const startArr = parseColor(startColor);
  const endArr = parseColor(endColor);
  const newArr = startArr.map((channel, index) =>
  interpolateChannel(channel, endArr[index], ratio)
  );
  return `#${newArr.map(v => v.toString(16).padStart(2, '0')).join('')}`;
}

export function getLighterColor(color:string,factor:number):string{
  const tempColor = parseColor(color);
  const a = tempColor[0];
  const r = tempColor[1];
  const g = tempColor[2];
  const b = tempColor[3];

  const newR = Math.min(255, Math.floor(r + (255 - r) * factor));
  const newG = Math.min(255, Math.floor(g + (255 - g) * factor));
  const newB = Math.min(255, Math.floor(b + (255 - b) * factor));

  return rgbToHex(newR, newG, newB);
}

export function getDeeperColor(color:string,factor:number):string{
  const tempColor = parseColor(color);
  const a = tempColor[0];
  const r = tempColor[1];
  const g = tempColor[2];
  const b = tempColor[3];

  const newR = Math.max(0, Math.floor(r * (1 - factor)));
  const newG = Math.max(0, Math.floor(g * (1 - factor)));
  const newB = Math.max(0, Math.floor(b * (1 - factor)));

  return rgbToHex(newR, newG, newB);
}

export async function createPixelMapFromBuffer(buffer: ArrayBuffer): Promise<image.PixelMap> {
  const imageSource = image.createImageSource(buffer);
  const decodingOptions: image.DecodingOptions = {
    desiredSize: { width: 100, height: 100 } // 可选：限制解码尺寸提升性能
  };
  return await imageSource.createPixelMap(decodingOptions);
}

export function adjustToBrightnessThreshold(
  color: effectKit.Color,
  targetBrightness: number = 150
): effectKit.Color {
  const getLuminance = (r: number, g: number, b: number) =>
  0.2126 * r + 0.7152 * g + 0.0722 * b;

  const currentLuminance = getLuminance(color.red, color.green, color.blue);

  const adjustRatio = currentLuminance > 0
    ? targetBrightness / currentLuminance
    : 1;

  const clamp = (value: number) => Math.max(0, Math.min(255, Math.round(value))); // 钳制函数确保值在[0,255][6,8](@ref)

  return {
    red: clamp(color.red * adjustRatio),
    green: clamp(color.green * adjustRatio),
    blue: clamp(color.blue * adjustRatio),
    alpha:1
  };
}