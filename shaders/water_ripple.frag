#include <flutter/runtime_effect.glsl>

// Concentric water ripples from a touch point on the sea/pond.
// Tinted by `uTint`, fades after `uProgress` reaches 1.

uniform vec2  uSize;
uniform float uTime;
uniform vec2  uCenter;
uniform float uProgress;
uniform vec4  uTint;

out vec4 fragColor;

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float r = length(frag - uCenter);
  float maxR = max(uSize.x, uSize.y) * 0.6;
  float rN = r / maxR;

  // Three rings expanding outward, lagged by uProgress.
  float ringSum = 0.0;
  for (float i = 0.0; i < 3.0; i += 1.0) {
    float t = clamp(uProgress * 1.6 - i * 0.18, 0.0, 1.4);
    float c = abs(rN - t);
    ringSum += smoothstep(0.04, 0.0, c) * (1.0 - t / 1.4);
  }

  // Fade edges.
  float fade = 1.0 - smoothstep(0.6, 1.0, rN);
  float a = clamp(ringSum * fade, 0.0, 1.0) * (1.0 - uProgress * 0.5);

  fragColor = vec4(uTint.rgb, a * uTint.a);
}
