shader_type spatial;
render_mode cull_disabled;

uniform sampler2D snow_noise;
uniform sampler2D mix_noise;
uniform sampler2D snow_normal;
uniform sampler2D snow_color_gradient: source_color, repeat_disable;
uniform float snow_height = 0.5;
uniform sampler2D mask_texture;
uniform vec2 world_xy_anchor;
uniform vec2 world_size_anchor;
uniform vec2 scatter_range = vec2(0.6, 0.9);
uniform float scatter_amount: hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float height_occlusion: hint_range(0.0, 1.0, 0.001) = 0.2;
uniform vec4 scatter_tint : source_color = vec4(1.0);
uniform float normal_depth = 1.0;
uniform float mix_noise_size = 0.1;

varying vec2 world_uv;
varying float height_factor;
varying vec3 view_pos;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}


void vertex() {
	vec2 world_coord = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	world_uv = world_coord;
	UV = (world_coord - world_xy_anchor + vec2(world_size_anchor.x * 0.5,0.0))/world_size_anchor;
	float height = texture(mask_texture, UV).r;
	height_factor = 1.0;
	VERTEX.y += snow_height * height;
	// ANCHOR: increment
	vec2 texture_increment = 1.0 / vec2(textureSize(mask_texture, 0));
	// END: increment
	// ANCHOR: neighbour_sample
	// Approximate derivative along the z axis
	float height_up = 1.0 - texture(mask_texture, UV + vec2(0.0, texture_increment.y)).r;
	float height_down = 1.0 - texture(mask_texture, UV + vec2(0.0, -texture_increment.y)).r;
	// Approximate derivative along the x axis
	float height_left = 1.0 - texture(mask_texture, UV + vec2(-texture_increment.x, 0.0)).r;
	float height_right = 1.0 - texture(mask_texture, UV + vec2(texture_increment.x, 0.0)).r;
	// END: neighbour_sample
	// ANCHOR: lighting
	BINORMAL = normalize(vec3(1.0,( height_right - height_left ) , 0.0));
	TANGENT = normalize(vec3(0.0, (height_up - height_down) , 1.0));
	NORMAL = normalize(cross(TANGENT, BINORMAL));
	//COLOR.rgb = vec3(0.7) + vec3(height) * 0.3;
	// END: lighting
}


void fragment() {
	ALBEDO.rgb = COLOR.rgb;
	NORMAL_MAP = texture(snow_normal,world_uv).rgb;
	vec2 uv =world_uv * 0.1;
	vec2 rotated_uv =rotate(fract(uv), floor(vec2(0.0)), 6.28* noise(floor(uv) * 0.11)) + vec2(0.5);
	NORMAL_MAP = textureLod(snow_normal, rotated_uv,0).rgb;
	NORMAL_MAP_DEPTH = normal_depth;
	float mix_noise_fac = texture(mix_noise, rotated_uv).r;
	ALBEDO = textureLod(snow_color_gradient, vec2(height_factor +mix_noise_size * mix_noise_fac),0).rgb;
	//ALBEDO = vec3(rotated_uv,1.0);
	view_pos = VERTEX;
	SSS_STRENGTH = height_factor;
	SSS_TRANSMITTANCE_COLOR = scatter_tint;
//	SSS_TRANSMITTANCE_DEPTH = 0.3;
//	SSS_TRANSMITTANCE_BOOST = 0.5;
}

void light(){
	float fac = dot(normalize(LIGHT), NORMAL);
	float scatter_fac = dot(LIGHT, VIEW);
	fac = clamp(-1, 1, fac);
	DIFFUSE_LIGHT += max(pow(fac,1.0), 0) * LIGHT_COLOR * ATTENUATION  * (height_factor * height_occlusion + 1.0 - height_occlusion);
	float negative_fac= (1.0 -pow((fac + 1.0) * 0.5, 3.0));
	float scatter_range_factor = 1.0 - smoothstep(scatter_range.x, scatter_range.y, fac);
	scatter_range_factor = clamp(scatter_range_factor, 0.0,1.0);

	DIFFUSE_LIGHT +=  LIGHT_COLOR   * scatter_amount * scatter_tint.rgb *ATTENUATION* scatter_range_factor;
	DIFFUSE_LIGHT += negative_fac * scatter_tint.rgb * scatter_range_factor * pow(ATTENUATION, 1.0);

	}
