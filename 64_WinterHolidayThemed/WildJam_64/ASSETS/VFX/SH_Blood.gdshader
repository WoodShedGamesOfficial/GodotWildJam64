shader_type spatial;
//render_mode unshaded;
render_mode cull_disabled;

uniform sampler2D albedo_tex;
uniform sampler2D normalmap: hint_normal;
uniform sampler2D erosion_tex;
uniform sampler2D gradient: source_color;
uniform float roughness = 1.0;
uniform float specular = 1.0;

	uniform int particles_anim_h_frames = 1;
	uniform int particles_anim_v_frames = 1;
	uniform bool particles_anim_loop = false;
instance uniform vec4 tint: source_color = vec4(1.0);
instance uniform int billboard_type=0;
instance uniform vec3 pivot_offset = vec3(0.);

varying vec4 custom;

void vertex(){
	vec4 custom_custom = INSTANCE_CUSTOM;
	if (billboard_type == 1){
		mat4 mat_world = mat4(normalize(INV_VIEW_MATRIX[0]), normalize(INV_VIEW_MATRIX[1]) ,normalize(INV_VIEW_MATRIX[2]), MODEL_MATRIX[3]);
		mat_world = mat_world * mat4(vec4(cos(custom_custom.x), -sin(custom_custom.x), 0.0, 0.0), vec4(sin(custom_custom.x), cos(custom_custom.x), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}else if(billboard_type == 2){
		vec3 new_x_axis = cross(normalize(MODEL_MATRIX[1].xyz), inverse(VIEW_MATRIX)[2].xyz);
		vec3 new_z_axis = cross(new_x_axis, normalize(MODEL_MATRIX[1].xyz));
		mat3 rot = mat3(new_x_axis, normalize(MODEL_MATRIX[1].xyz), new_z_axis);
		mat4 new_model = mat4(rot);
		new_model[3] = MODEL_MATRIX[3];
		MODELVIEW_MATRIX = VIEW_MATRIX * new_model;
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
		float h_frames = float(particles_anim_h_frames);
	float v_frames = float(particles_anim_v_frames);
	float particle_total_frames = float(particles_anim_h_frames * particles_anim_v_frames);
	float particle_frame = floor(custom_custom.z * float(particle_total_frames));
	if (!particles_anim_loop) {
		particle_frame = clamp(particle_frame, 0.0, particle_total_frames - 1.0);
	} else {
		particle_frame = mod(particle_frame, particle_total_frames);
	}
	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(particle_frame, h_frames) / h_frames, floor((particle_frame + 0.5) / h_frames) / v_frames);
	VERTEX += pivot_offset;
}

void fragment() {
	vec2 albedo_col = texture(albedo_tex, UV).ra;
	float erosion_val = texture(erosion_tex, UV).r;
	float erosion = (1.0 - COLOR.a * tint.a * albedo_col.y);
	vec4 color = texture(gradient, vec2(albedo_col.r));
	ALBEDO = color.rgb * COLOR.rgb;
	ALPHA_SCISSOR_THRESHOLD = erosion;
	ALPHA = erosion_val;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	NORMAL = mix(-NORMAL, NORMAL, float(FRONT_FACING));
	NORMAL_MAP = texture(normalmap, UV).rgb;
}
