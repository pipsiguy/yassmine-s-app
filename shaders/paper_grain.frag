#include <flutter/runtime_effect.glsl>

// Layered rice-paper grain, with subtle long fibres and a tonal vignette.
// Output is the paper background itself — composite the rest on top.

uniform vec2  uSize;
uniform float uTime;     // unused but kept for hot-reload signature parity
uniform vec4  uPaper;    // base paper color
uniform float uIntensity; // 0..1

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 78.233);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize;

  // Fine grain.
  float g1 = noise(frag * 1.6) * 0.08;
  // Medium fibres (stretched vertically).
  float g2 = noise(vec2(frag.x * 0.3, frag.y * 4.0)) * 0.05;
  // Soft tonal blotches.
  float g3 = noise(frag * 0.04) * 0.10;

  float grain = (g1 + g2 + g3) * uIntensity;

  // Vignette toward edges.
  float v = distance(uv, vec2(0.5)) * 1.2;
  v = smoothstep(0.7, 1.1, v) * 0.18;

  vec3 col = uPaper.rgb - vec3(grain) - vec3(v);
  fragColor = vec4(col, uPaper.a);
}
