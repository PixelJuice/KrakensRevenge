shader_type spatial;
group_uniforms glitter;
uniform vec3 glitter_colour : source_color;
uniform float glitter_alpha : hint_range(0.0, 1., .01) = .16;
uniform float glitter1_size : hint_range(0.0, 100, .5) = 10.;
uniform float glitter2_size : hint_range(0.0, 100, .5) = 10.;
uniform float glitter_mix : hint_range(0.0, 1., .01) = .5;
uniform float glitter_mask_size : hint_range(0.0, 100, .5) = 10.;
uniform vec2 glitter_1_direction = vec2(2.0, 0.0);
uniform vec2 glitter_2_direction = vec2(2.0, 0.0);
uniform vec2 glitter_mask_direction = vec2(2.0, 0.0);
uniform vec2 glitter_mask2_direction = vec2(2.0, 0.0);
uniform float glitter_threshold : hint_range(0.0, 1., .001) = .16;
//uniform float glitter_threshold2 : h
uniform sampler2D glitter_mask;
uniform sampler2D glitter_mask2;
uniform float masking_mix : hint_range(0.0, 1., .01) = .5;
uniform sampler2D glitter_1;
uniform sampler2D glitter_2;
group_uniforms colour;
uniform vec3 light_colour : source_color;
uniform vec3 dark_colour : source_color;
uniform vec3 darkness_colour : source_color;
uniform float depth : hint_range(0.0, 1., .01) = .05;
uniform float distortion : hint_range(0.0, 1.0, .01) = .3;
uniform float distortion_bottom : hint_range(0.0, 1.0, .01) = .1;
uniform float distortion_speed : hint_range(0.0, 1.0, .01) = .1;
uniform float water_alpha : hint_range(0.0, 1.0, .01) = .8;
uniform sampler2D colour_variation;
uniform sampler2D darkness;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 normal_direction = vec2(2.0, 0.0);
uniform vec2 normal_direction2 = vec2(0.0, 1.0);
group_uniforms waves;
uniform float wave_amplitude = 10.0;
uniform float wave_frequency = 5.0;
uniform float wave_speed = 2.0;
varying vec3 worldUV;

void vertex() {
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += sin(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
}

vec3 remap_value(vec3 value, vec3 old_min, vec3 old_max, vec3 new_min, vec3 new_max){
	// Scale the value from old range to 0 - 1
    vec3 normalized = (value - old_min) / (old_max - old_min);
    // Scale to new range
    vec3 remapped_value = new_min + (normalized * (new_max - new_min));
    return remapped_value;
}


void fragment() {
	float time = TIME * .01;
	vec2 wuv = (worldUV.xz * 0.005);
	vec3 black = vec3(.0);
	vec3 normal_1 = texture(texture_normal, wuv + (normal_direction * time * distortion_speed)).rgb;
	vec3 normal_2 = texture(texture_normal2, wuv + (normal_direction2 * time * distortion_speed)).rgb;



	vec3 normal = mix(normal_1, normal_2, 0.5);
	normal = remap_value(normal, vec3(0.), vec3( 1.), vec3(-1.), vec3(1.));
	vec3 glitter_1_color = texture(glitter_1, wuv * (glitter1_size / 10.) + ( glitter_1_direction * time)).rgb;
	vec3 glitter_2_color = texture(glitter_2, wuv * (glitter2_size / 10.) + (time * glitter_2_direction)).rgb;
	vec3 glitter_m = texture(glitter_mask, wuv * (glitter_mask_size/ 10.) - (time * glitter_mask_direction)).rgb;
	vec3 glitter_m2 = texture(glitter_mask2, wuv * (glitter_mask_size/ 10.) - (time * -glitter_mask_direction)).rgb;
	vec3 glitter_masking = mix(glitter_m, glitter_m2, masking_mix);
	vec3 colour = texture(colour_variation, wuv + (normal.rb * distortion)).rgb;
	colour = mix(dark_colour, light_colour, colour);
	colour = mix(colour, darkness_colour, texture(darkness, ((wuv * depth) + UV + (normal.rb * distortion_bottom)) + TIME * .002).rgb);
	vec3 glitter = mix(glitter_1_color, glitter_2_color, glitter_mix);
	vec3 g_alpha = mix(black, glitter.rgb, glitter_alpha);
	glitter = mix(colour, glitter, g_alpha.r);

	vec3 g_colour = mix(glitter_colour, colour, smoothstep(.0, glitter_masking.r, glitter_threshold));

	g_colour = mix(colour, g_colour, g_alpha);
	float alpha = mix(water_alpha, 1., glitter_masking.r);
	colour = g_colour;
	ALBEDO = vec3(colour.rgb);
	ALPHA = water_alpha;
}
