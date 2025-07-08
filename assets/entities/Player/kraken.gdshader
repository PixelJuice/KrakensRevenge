shader_type spatial;
uniform vec3 shadow_colour : source_color;
uniform float max_alpha : hint_range(0.0, 1., .01) = .5;
uniform sampler2D shadow_shape;
uniform sampler2D distortion_mask;
uniform float distortion : hint_range(0.0, 1., .01) = .01;
uniform float distortion_scale : hint_range(0.0, 1., .01) = .01;
uniform float distortion_speed : hint_range(0.0, 1.0, .01) = .1;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 normal_direction = vec2(2.0, 0.0);
uniform vec2 normal_direction2 = vec2(0.0, 1.0);


varying vec3 worldUV;

void vertex() {
	worldUV = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float time = TIME * .01;
	vec2 wuv = (worldUV.xz * 0.005);
	vec4 mask = texture(distortion_mask, UV);
	vec3 shadow = texture(shadow_shape, UV).rgb;
	vec3 black = vec3(0.);
	vec3 normal1 = texture(texture_normal, (UV * distortion_scale) + (normal_direction * time * distortion_speed) + wuv).rgb;
	vec3 normal2 = texture(texture_normal2, (UV * distortion_scale) + (normal_direction2 * time * distortion_speed) + wuv).rgb;
	normal1 = (normal1 * 2.) - 1.;
	normal2 = (normal2 * 2.) - 1.;
	vec3 normal = mix(normal1, normal2, .5);
	vec3 alpha = texture(shadow_shape, (UV + (normal.rb * mask.rb))).rgb;
	//vec3 dist = mix(black, alpha, mask.r);
	ALPHA = clamp(.0, max_alpha ,alpha.r);
	ALBEDO = vec3(shadow_colour);
}