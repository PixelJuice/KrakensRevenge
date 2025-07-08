shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;
uniform vec3 top_color: source_color;
uniform vec3 bottom_color: source_color;


//varying vec3 worldUV;

float rand(float n){return fract(sin(n) * 43758.5453123);}

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float noise(float p){
	float fl = floor(p);
  	float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

vec3 when_gt(vec3 x, vec3 y) {
  return max(sign(x - y), 0.0);
}

float fmod(float x, float y) {
	return x - floor(x / y) * y;
}

vec4 lerp(vec4 a, vec4 b, float w) {
	return a + w * (b - a);
}

vec3 lerp(vec3 a, vec3 b, float w) {
	return a + w * (b - a);
}

float border(vec2 uv, float border_width)
{
	vec2 bottom_left = step(vec2(border_width), uv);
	vec2 top_right = step(vec2(border_width), 1.0 - uv);
	return bottom_left.x * bottom_left.y * top_right.x * top_right.y;
}

float plot(vec2 st, float pct){
  return  smoothstep( pct-.1, pct, st.y) -
          smoothstep( pct, pct+.1, st.y);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	if (depth > .0) {
		discard;
	}
	float wave_numbers = 15.;
	float wave = floor(UV.y * wave_numbers);
	float wave2 = fract(UV.y * (wave_numbers));
	float X = abs(sin(UV.x * wave_numbers + sin(TIME + wave-5.))) ;
	//float wave_edge = fract(UV.y * 10. + X);
	float wave_edge = fract((UV.y) * (wave_numbers) + X);
	float b = border(vec2(wave_edge), .1);
	vec3 wave_colour = mix(bottom_color, top_color, wave_edge-X+.9);
	ALBEDO = mix(vec3(0), wave_colour ,  b);
}
