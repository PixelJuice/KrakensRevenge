shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;
uniform vec3 top_color: source_color;
uniform vec3 bottom_color: source_color;


//varying vec3 worldUV;

float rand(float n){return fract(sin(n) * 43758.5453123);}

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
varying vec3 worldUV;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
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
	vec2 bottom_left = smoothstep(vec2(0.), vec2(border_width), 1. - uv);
	vec2 top_right = smoothstep(vec2(0.), vec2(border_width) , uv);
	return top_right.x * top_right.y* bottom_left.x * bottom_left.y;
}

float plot(vec2 st, float pct){
  return  smoothstep( pct-.1, pct, st.y) -
          smoothstep( pct, pct+.1, st.y);
}

float InCircular(float t, float b, float c, float d) {
	float x = (t / d);
	return -c * (sqrt(1. - x * x) - 1.) + b;
}

void fragment() {
	vec2 uv = fract(vec2(SCREEN_UV.x, -SCREEN_UV.y));
	vec2 uv_modifier = vec2(TIME) * .1;
	//vec2 uv = UV;
	float flipped_y = (1. - uv.y);
	float wave_numbers = 20.;
	float wave = fract(ceil(UV.y * wave_numbers + uv_modifier.y * wave_numbers) * .1);
	
	float depth = texture(depth_texture, SCREEN_UV).x;
	float check_this = (ceil((SCREEN_UV.y) * wave_numbers + 1.) / wave_numbers) ;
	float check_next = (ceil(SCREEN_UV.y * wave_numbers) / wave_numbers);
	float check_before = (floor(SCREEN_UV.y * wave_numbers) / wave_numbers) ;

	check_this = (check_this );
	check_before = (check_before);
	check_next = (check_next);
	//check_this = mix(check_this, check_next, 1. - fract(uv_modifier.y));
	//check_before = mix(check_this, check_before, fract(uv_modifier.y));
	
	float X = ((abs(sin(uv.x * wave_numbers + sin(TIME + rand(wave)) + uv_modifier.x)) * 0.8) + .1);
	float wave_edge = fract((uv.y + fract(uv_modifier.y )) * (wave_numbers) + X );
	float b = border(vec2(wave_edge, wave_edge), .06 );
	vec3 wave_colour = mix(bottom_color, top_color, wave_edge-X+.9);
	vec3 color = mix(vec3(0) ,wave_colour, b);
	color = wave_colour;//vec3(wave_edge);
	float check = step(wave_edge, X);
	b = 1.;

	float check_value = mix(check_this, check_before, check);
	if (depth > check_value) {
		ALPHA = 0.;
	}
	ALBEDO = vec3( mix(vec3(.0), vec3(check_value), b) );
}
