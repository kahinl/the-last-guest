shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float dizziness_strength : hint_range(0.0, 5.0) = 1.0; 
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0; 

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// 1. حساب نقطة ارتكاز الدوخة (تدور ببطء حول المركز)
	vec2 center_orbit = vec2(0.5, 0.5);
	center_orbit.x += sin(TIME * wave_speed * 0.5) * 0.05 * dizziness_strength;
	center_orbit.y += cos(TIME * wave_speed * 0.5) * 0.05 * dizziness_strength;
	
	// 2. تطبيق تموج (Swirl) لإعطاء شعور أن الغرفة تميل
	float dist_orbit = distance(uv, center_orbit);
	float swirl = dist_orbit * sin(TIME * wave_speed) * 0.02 * dizziness_strength;
	uv += vec2(swirl, -swirl);
	
	// 3. نظام الضبابية المتحركة (Dynamic Blur)
	float current_blur = dist_orbit * 0.015 * dizziness_strength;
	vec4 color = vec4(0.0);
	float samples = 6.0; 

	for (float i = 1.0; i < samples; i++) {
		vec2 dir = normalize(uv - center_orbit);
		color += texture(SCREEN_TEXTURE, uv + dir * current_blur * i);
		color += texture(SCREEN_TEXTURE, uv - dir * current_blur * i);
	}
	
	color /= (samples * 2.0);
	
	// تم حذف نبضات التعتيم (Pulsing) والـ Vignette للحفاظ على سطوع الشاشة الطبيعي
	
	COLOR = color;
}