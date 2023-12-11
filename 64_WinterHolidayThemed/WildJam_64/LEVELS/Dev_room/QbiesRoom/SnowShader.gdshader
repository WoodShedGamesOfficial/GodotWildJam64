shader_type spatial;

uniform sampler2D snow_noise;
uniform sampler2D mix_noise;
uniform sampler2D snow_normal;
uniform sampler2D snow_color_gradient;
uniform float snow_height = 0.5;
uniform sampler2D mask_texture;
uniform vec2 world_xy_anchor;
uniform vec2 world_size_anchor;
uniform vec2 scatter_range = vec2(0.6, 0.9);
uniform float scatter_amount: hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float height_occlusion: hint_range(0.0, 1.0, 0.001) = 0.2;
uniform vec4 scatter_tint : source_color = vec4(1.0);

varying vec3 view_pos;
varying float height_factor;


void vertex() {
	vec2 world_coord = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	UV = (world_coord - world_xy_anchor + vec2(world_size_anchor.x * 0.5,0.0))/world_size_anchor;
	float height = texture(mask_texture, UV).r;
	VERTEX.y += snow_height * height;
	// ANCHOR: increment
	vec2 texture_increment = 1.0 / vec2(textureSize(mask_texture, 0));
	// END: increment
	// ANCHOR: neighbour_sample
	// Approximate derivative along the z axis
	float height_up = 1.0 - texture(mask_texture, UV + vec2(0.0, texture_increment.y)).a;
	float height_down = 1.0 - texture(mask_texture, UV + vec2(0.0, -texture_increment.y)).a;
	// Approximate derivative along the x axis
	float height_left = 1.0 - texture(mask_texture, UV + vec2(-texture_increment.x, 0.0)).a;
	float height_right = 1.0 - texture(mask_texture, UV + vec2(texture_increment.x, 0.0)).a;
	// END: neighbour_sample
	// ANCHOR: lighting
	BINORMAL = normalize(vec3(1.0, height_right - height_left, 0.0));
	TANGENT = normalize(vec3(0.0, height_up - height_down, 1.0));
	NORMAL = normalize(cross(TANGENT, BINORMAL));
	//COLOR.rgb = vec3(0.7) + vec3(height) * 0.3;
	// END: lighting
}


void fragment() {
	ALBEDO.rgb = COLOR.rgb;
	view_pos = VERTEX;
}

void light(){
	float fac = dot(normalize(LIGHT), NORMAL);
	float scatter_fac = dot(LIGHT, VIEW);
	fac = clamp(-1, 1, fac);
	DIFFUSE_LIGHT += max(fac, 0) * LIGHT_COLOR * ATTENUATION  * (height_factor * height_occlusion + 1.0 - height_occlusion);
	float scatter_range_factor = 1.0 - smoothstep(scatter_range.x, scatter_range.y, fac);
	scatter_range_factor = clamp(scatter_range_factor, 0.0,1.0);
		DIFFUSE_LIGHT += (1.0 - step(0.0, fac)) *(abs(fac)) * LIGHT_COLOR * pow(ATTENUATION, 2.0)  * scatter_amount * scatter_tint.rgb * scatter_range_factor;
		DIFFUSE_LIGHT += max(-scatter_fac, 0.0) * scatter_tint.rgb * scatter_range_factor* pow(ATTENUATION, 2.0);
}
