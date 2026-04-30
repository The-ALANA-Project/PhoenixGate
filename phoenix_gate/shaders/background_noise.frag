#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec4 uBaseColor;
uniform vec4 uGlowColor;

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 345.45));
  p += dot(p, p + 34.345);
  return fract(p.x * p.y);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);

  float a = hash(i + vec2(0.0, 0.0));
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));

  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;

  for (int i = 0; i < 2; i++) {
    value += amplitude * valueNoise(p);
    p = p * 2.0 + vec2(17.13, 8.97);
    amplitude *= 0.6;
  }

  return value;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution.xy;

  float aspect = uResolution.x / uResolution.y;
  vec2 p = (uv - 0.5) * vec2(aspect, 1.0);

  float t = uTime * 0.08;
  float n1 = fbm(p * 2.8 + vec2(t * 0.9, -t * 0.6));
  float n2 = fbm(p * 5.2 + vec2(-t * 1.3, t * 0.8));

  float smoothField = 0.65 * n1 + 0.35 * n2;
  float glow = smoothstep(0.40, 0.92, smoothField);

  vec3 color = mix(uBaseColor.rgb, uGlowColor.rgb, glow * 0.85);

  float vignette = smoothstep(1.15, 0.15, length(p));
  color *= 0.90 + 0.10 * vignette;

  fragColor = vec4(color, 1.0);
}
