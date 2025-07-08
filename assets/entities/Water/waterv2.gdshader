shader_type spatial;

uniform vec3 top_color: source_color;
uniform vec3 bottom_color: source_color;

//varying vec3 worldUV;

float rand(float n){return fract(sin(n) * 43758.5453123);}


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

void fragment() {
	//float X = abs(sin((UV.x + sin(TIME))*2.0));

	/*if (X < UV.y) {
		ALBEDO = vec3(0,0,1);
	}
	else {
		ALBEDO = vec3(0,0,0);
	}*/
	
	float wave_numbers = float(20);
	float wave = floor(UV.y * wave_numbers);
	float effective_wave_amp = .9 / wave_numbers;
	float d = fmod(UV.y, 1.0 / wave_numbers);
	
	//wave = abs(sin((floor(UV.y * wave_numbers) + sin(TIME))*2.0));
	float vi = floor(UV.y * wave_numbers + wave_numbers * effective_wave_amp);
	//float s = effective_wave_amp * sin((UV.x+TIME* max(1.0 / wave_numbers, noise(wave_numbers)) * vi / wave_numbers) * 2.0 * 3.14 * 4.0);
	float s = (effective_wave_amp - wave / (wave_numbers * 100.)) *  -abs(sin((UV.x*(90. * (max(1.5, wave/8.))))*noise(wave_numbers) + sin(TIME + rand(wave) * wave) + wave));
	//if (d < s + 1.01 / wave_numbers) wave = 0.0;
	if (d < s) wave--;
	if (d < s) {
		ALBEDO = vec3(1);
	} else {
	
		if (d > s + 1.0 / wave_numbers ) wave++;
	
		ALBEDO = lerp(top_color, bottom_color, wave / (wave_numbers - 1.0));
	}
}

