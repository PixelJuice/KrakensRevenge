shader_type spatial;

// Uniforms for customization
uniform vec3 shallow_color : source_color  = vec3(0.0, 0.6, 1.0); // Color for shallow water
uniform vec3 deep_color : source_color  = vec3(0.0, 0.2, 0.5);    // Color for deep water
uniform float depth_fade = 10.0; // Controls how quickly the color fades with depth
uniform float wave_speed = 1.0;  // Speed of the water waves
uniform float wave_height = 0.2; // Height of the waves
uniform float wave_scale = 5.0;  // Scale of the waves
uniform float outline_thickness = 0.02; // Thickness of the outline

void vertex() {
    // Add wave effect to the vertex position
    float wave_x = sin(TIME * wave_speed + VERTEX.x * wave_scale) * wave_height;
    float wave_z = cos(TIME * wave_speed + VERTEX.z * wave_scale) * wave_height;
    VERTEX.y += wave_x + wave_z;
}

void fragment() {
    // Get the depth value (distance from camera)
    float depth = abs(DEPTH);

    // Calculate depth-based color blending
    float depth_factor = clamp(depth / depth_fade, 0.0, 1.0);
    vec3 water_color = mix(shallow_color.rgb, deep_color.rgb, depth_factor);

    // Apply the water color
    ALBEDO = water_color;

    // Add edge outlines for a cartoon effect
    float edge = dot(NORMAL, vec3(0.0, 1.0, 0.0)); // Highlight edges based on upward normal direction
    edge = smoothstep(1.0 - outline_thickness, 1.0, edge);
    ALBEDO += vec3(edge * 0.3); // Add a subtle outline effect
}