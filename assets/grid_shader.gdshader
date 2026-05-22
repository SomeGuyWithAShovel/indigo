// https://godotshaders.com/shader/synthwave-grid-shader/

shader_type spatial;

render_mode blend_mix, unshaded, depth_draw_always, cull_disabled; //, depth_test_disabled;

uniform vec4 grid_color       : source_color = vec4(0.00, 0.00, 0.00, 1.0);
uniform vec4 background_color : source_color = vec4(0.00, 0.00, 0.00, 0.0);
uniform float line_thickness = 0.02;
uniform float grid_spacing = 1;
uniform vec2  grid_offset = vec2(0.0, 0.0);
uniform float glow_strength = 1.3;

varying vec3 world_pos;

void vertex()
{
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float filtered_grid(float coord, float spacing, float thickness)
{
	float coord_mod = mod(coord, spacing);
	float dist = min(coord_mod, spacing - coord_mod);
	float scale = fwidth(coord);
	return smoothstep(thickness + scale, thickness - scale, dist);
}

void fragment()
{
	float grid_x = filtered_grid(world_pos.x + grid_offset.x, grid_spacing, line_thickness);
	float grid_z = filtered_grid(world_pos.z + grid_offset.y, grid_spacing, line_thickness);

	float line_intensity = max(grid_x, grid_z);
	float glow = pow(line_intensity, glow_strength);

	ALBEDO = mix(background_color.rgb, grid_color.rgb, glow);
	ALPHA = mix(background_color.a, grid_color.a, glow);
}
