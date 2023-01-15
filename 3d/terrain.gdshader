// via https://www.youtube.com/watch?v=x7ti3AEhV18 tutorial
shader_type spatial;

uniform sampler2D lowdesert_texture;
uniform sampler2D highdesert_texture;
uniform sampler2D rock_texture;

uniform sampler2D lowdesert_texture_n;
uniform sampler2D highdesert_texture_n;
uniform sampler2D rock_texture_n;

uniform float min_rock_slope:hint_range(0.0f,1.0f) = 0.5;
uniform float max_high_slope:hint_range(0.0f,1.0f) = 0.9;
uniform float min_rockhigh_height = -8.0f;
uniform float max_low_height = -6.0f;
uniform float uv_scale = 16.0f;

varying float normal_y;
varying float vertex_y;

void vertex(){
	normal_y = NORMAL.y;
	vertex_y = VERTEX.y;
}

void fragment() {
	vec3 low_albedo = texture(lowdesert_texture,UV*uv_scale).xyz;
	vec3 rock_albedo = texture(rock_texture,UV*uv_scale).xyz;
	vec3 high_albedo = texture(highdesert_texture,UV*uv_scale).xyz;
	
	vec3 low_normal = texture(lowdesert_texture_n,UV*uv_scale).xyz;
	vec3 rock_normal = texture(rock_texture_n,UV*uv_scale).xyz;
	vec3 high_normal = texture(highdesert_texture_n,UV*uv_scale).xyz;
	
	//Weights
	float rock_high_weight = normal_y;
	float low_rockhigh_weight = vertex_y;
	//Calculating Rock/Grass Weight
	rock_high_weight = max(min_rock_slope, rock_high_weight);
	rock_high_weight = min(max_high_slope, rock_high_weight);
	rock_high_weight -= min_rock_slope;
	rock_high_weight /= max_high_slope - min_rock_slope;
	//Calculating Sand/RockGrass Weight
	low_rockhigh_weight = max(min_rockhigh_height, low_rockhigh_weight);
	low_rockhigh_weight = min(max_low_height, low_rockhigh_weight);
	low_rockhigh_weight -= min_rockhigh_height;
	low_rockhigh_weight /= max_low_height - min_rockhigh_height;
	//Mixing and Assigning Albedo
	vec3 rockhigh_albedo = mix(rock_albedo, high_albedo, rock_high_weight);
	vec3 rockhigh_normal = mix(rock_normal, high_normal, rock_high_weight);
	ALBEDO = mix(low_albedo, rockhigh_albedo, low_rockhigh_weight);
	//NORMAL = mix(low_normal, rockhigh_normal, low_rockhigh_weight);
}
