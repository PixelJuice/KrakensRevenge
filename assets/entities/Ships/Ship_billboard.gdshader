shader_type spatial;
render_mode unshaded;

uniform vec3 Outline_color: source_color;
uniform vec3 top_color: source_color;
uniform vec3 bottom_color: source_color;

uniform sampler2D Texture;
varying vec3 worldUV;

void vertex() {
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

float rand(float n){return fract(sin(n) * 43758.5453123);}

float InCircular(float t, float b, float c, float d) {
	float x = (t / d);
	return -c * (sqrt(1. - x * x) - 1.) + b;
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

float plot(vec2 st, float pct){
  float p =  smoothstep( pct-.06, pct, st.y) -
          smoothstep( pct, pct+.06, st.y);
	p = mod(p, 1.0);
	return p;
}

float draw_wave(float wave, vec2 uv, float bottom, float top, float power, float animation) {
	uv.y = 1. - uv.y;
	float freq = 1.;
	// Calculate the wave position and ensure it wraps around at 0 and 1
    //float Y = fract((uv.x * freq) + sin(TIME - (rand(wave) * 10.0)));
	float Y = fract((uv.x  * freq) + (animation * .4) + sin(TIME));
    // Adjust Y to wrap properly between 0 and 1
    Y = abs(2.0 * Y - 1.0); // Creates a sawtooth wave that wraps correctly
	//Y = mod(Y, 2.0) - 1.0;
	float wave_edge = InCircular(Y,bottom, top, power);
	float colour = InCircular(uv.y,bottom, top, power);
	//float wave_edge2 = wave_edge + wave_edge * (sin(TIME + (rand(wave) * 5.)) / 10.) * rand(wave);
	//wave_edge = lerp(wave_edge, wave_edge2, when_gt(animation, .0));
	//wave_edge = mix(wave_edge, wave_edge2, .0);
	//wave_edge = mod(wave_edge, 2.0) - 1.0;//smoothstep(0.01, .99, fract(Y + wave));
	float backgrund = when_gt(wave_edge, uv.y);
	float outline = when_gt(wave_edge, uv.y-.008);

	//float outline2 = when_gt(uv.y, wave_edge);
	//Y = fract(mod(Y, 2.0) - 1.0);
	float at_edge = plot(uv, wave_edge);
	//float outline2 = when_gt(uv.y, at_edge);
	vec3 wave_color = mix(bottom_color, top_color, at_edge);
	float alpha = at_edge;
	alpha = mix(Outline_color.r, alpha, outline);
	vec3 background_color = mix(Outline_color, wave_color, backgrund);
	return 1. - backgrund;
}

void fragment() {
	//float d = world_position.y;// - ((UV.y) / 50.);
	float wave = draw_wave(0., UV, .06, 20., 13., worldUV.x);
	vec4 color = vec4(texture(Texture, UV));

	float alpha = min(color.a,  wave);
	color = color;//mix(color, color, wave);
	ALBEDO = color.rgb;
	ALPHA = clamp(.0, 1., alpha);
	//DEPTH = d;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}