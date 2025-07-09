shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;
uniform vec3 Outline_color: source_color;
uniform vec3 top_color: source_color;
uniform vec3 bottom_color: source_color;


//varying vec3 worldUV;

float rand(float n){return fract(sin(n) * 43758.5453123);}

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
varying vec2 worldUV;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xz;
}

float noise(float p){
	float fl = floor(p);
  	float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

vec3 when_gt(vec3 x, vec3 y) {
  return max(sign(x - y), 0.0);
}

float when_gt(float x, float y) {
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

float lerp(float a, float b, float w) {
	return a + w * (b - a);
}

float border(vec2 uv, float border_width)
{
	vec2 bottom_left = step(vec2(border_width), uv);
	vec2 top_right = step(vec2(border_width), 1.0 - uv);
	return bottom_left.x * bottom_left.y * top_right.x * top_right.y;
}

float plot(vec2 st, float pct){
  float p =  smoothstep( pct-.06, pct, st.y) -
          smoothstep( pct, pct+.06, st.y);
	p = mod(p, 1.0);
	return p;
}

float OutSine(float time, float start, float end, float power) {
	return end * sin(time / power * (PI /2.)) + start;
}

float InSine(float t, float b, float c, float d) {
	return -c * cos(t / d * (PI /2.)) + c + b;
}

float InCubic(float t, float b, float c, float d) {
	float x = (t / d);
	return c * x * x * x + b;
}

float InCircular(float t, float b, float c, float d) {
	float x = (t / d);
	return -c * (sqrt(1. - x * x) - 1.) + b;
}

float draw_line(vec2 uv) {
	return (1. - smoothstep(0., .01, abs(uv.y)));
}

vec4 draw_wave(float wave, vec2 uv, float bottom, float top, float power, float animation) {
	float freq = 15.;
	// Calculate the wave position and ensure it wraps around at 0 and 1
    float Y = fract((uv.x * freq) + sin(TIME - (rand(wave) * 10.0)));
    // Adjust Y to wrap properly between 0 and 1
    Y = abs(2.0 * Y - 1.0); // Creates a sawtooth wave that wraps correctly
	//Y = mod(Y, 2.0) - 1.0;
	float wave_edge = InCircular(Y,bottom, top, power);
	float colour = InCircular(uv.y,bottom, top, power);
	float wave_edge2 = wave_edge + wave_edge * (sin(TIME + (rand(wave) * 5.)) / 10.) * noise(wave);
	//wave_edge = lerp(wave_edge, wave_edge2, when_gt(animation, .0));
	wave_edge = lerp(wave_edge, wave_edge2, .0);
	//wave_edge = mod(wave_edge, 2.0) - 1.0;//smoothstep(0.01, .99, fract(Y + wave));
	float backgrund = when_gt(wave_edge, uv.y);
	float outline = when_gt(wave_edge, uv.y-.008);

	//float outline2 = when_gt(uv.y, wave_edge);
	//Y = fract(mod(Y, 2.0) - 1.0);
	float at_edge = plot(uv, wave_edge);
	float outline2 = when_gt(uv.y, at_edge);
	vec3 wave_color = mix(bottom_color, top_color, at_edge);
	float alpha = at_edge;
	alpha = mix(Outline_color.r, alpha, outline);
	vec3 background_color = mix(Outline_color, wave_color, backgrund);
	return vec4(vec3(background_color), alpha);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;

	//float depth2 = FRAGCOORD.z;
	//vec2 frag_ndc = ((FRAGCOORD.xy / VIEWPORT_SIZE) * 2.0) - 1.0;
	//vec2 world_modifier = fract(worldUV.xy / 1100.);
	vec2 uv = fract(vec2(UV.x, UV.y ) + (TIME * .1));
	vec4 first_wave = draw_wave(0., uv, .95, .3, 1.8, 0.);
	vec4 second_wave = draw_wave(0., uv, -.05, .3, 1.8, 1.);
	vec4 colours = mix(first_wave, second_wave, second_wave.a);
	for (float i = .9; i > -0.; i -= .06) {
		second_wave = draw_wave(rand(i * 1000. * rand(i)), uv, fract(i), .3, 1.8, 1.);
		colours = mix(colours, second_wave, second_wave.a);
	}
	if (depth > .0) {
		discard;
	}
	/*first_wave = draw_wave(0., uv, .95, .3, 1.8, 0.);
	second_wave = draw_wave(0., uv, -.05, .3, 1.8, 1.);
	colours = mix(first_wave, colours, colours.a);*/
	first_wave = draw_wave(.5, uv, 2.0, .3, 1.8, 1.);
	colours = mix(first_wave, colours, colours.a);

	//colours = lerp(vec4(bottom_color, 1.), colours, 1.);
	ALBEDO = colours.rgb;//mix(bottom_color, colours.rgb, colours.a);
	//ALBEDO = vec3(background_color);
	//ALBEDO = mix(Outline_color, background_color, backgrund);
	//ALBEDO = vec3(b);
	//ALPHA = colours.a;
}
