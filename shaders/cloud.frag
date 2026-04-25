#include <flutter/runtime_effect.glsl>

// Drifting 祥云 (auspicious cloud) field via 4-octave fbm.
// Color is layered on top of whatever background is rendered behind.

uniform vec2  uSize;
uniform float uTime;
uniform float uDensity;   // 0..1
uniform float uWind;      // px per second
uniform vec4  uColor;     // cloud color

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 78.233);
  return fract(p.x * p.y);
}

float vnoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.55;
  for (int i = 0; i < 4; i++) {
    v += a * vnoise(p);
    p = p * 2.05 + vec2(2.7, 1.3);
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  // Stretch horizontally so clouds look elongated.
  vec2 p = vec2(uv.x * 1.6, uv.y * 0.8) * 3.5;
  // Drift with wind.
  p.x += uTime * (uWind / uSize.x);

  float n = fbm(p);
  float clouds = smoothstep(0.55 - uDensity * 0.15, 0.78, n);

  // Soft top-light.
  float light = mix(0.85, 1.0, smoothstep(0.0, 1.0, uv.y));

  fragColor = vec4(uColor.rgb * light, clouds * uColor.a);
}
