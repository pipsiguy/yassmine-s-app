#include <flutter/runtime_effect.glsl>

// Ink bleed shader.
// A drop spreads from `uCenter` over time, with fibrous edges and a paper
// grain overlay. Used during note creation and onboarding.

uniform vec2  uSize;       // canvas size (px)
uniform float uTime;       // seconds since start
uniform vec2  uCenter;     // drop center in px
uniform float uProgress;   // 0..1, animated by Dart side
uniform vec4  uInk;        // ink color (rgba 0..1)
uniform vec4  uPaper;      // paper bg (rgba 0..1)

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
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p *= 2.0;
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize;

  // Distance from drop center, normalised to the longer side.
  float r = length(frag - uCenter) / max(uSize.x, uSize.y);

  // Animated front: progress drives an expanding circle with noisy edge.
  float front = uProgress * 0.65;
  float edge  = front - 0.04 - fbm(frag * 0.012 + uTime * 0.05) * 0.06;

  // Filled ink mask (1 inside, 0 outside, fuzzy at the edge).
  float ink = smoothstep(front, edge, r);

  // Hairline fibers radiating outward from center.
  vec2  d   = frag - uCenter;
  float ang = atan(d.y, d.x);
  float fib = step(0.93, fbm(vec2(ang * 6.0, length(d) * 0.02)));
  ink = max(ink, fib * smoothstep(front + 0.08, front, r));

  // Paper grain — slight darkening in the fibers.
  float grain = noise(frag * 1.4) * 0.06;
  vec4 paper = uPaper - vec4(vec3(grain), 0.0);

  fragColor = mix(paper, uInk, ink);
}
