shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// NEW: Use this instead of the built-in TIME
uniform float local_time = 0.0; 

group_uniforms Noise_Settings;
uniform float noise_opacity : hint_range(0.0, 1.0) = 0.25; 
uniform float noise_speed = 25.0;                         
uniform float shake_power = 0.01;                       

group_uniforms Red_Horror;
uniform float red_strength : hint_range(1.0, 5.0) = 2.0;  

float random(vec2 uv) {
    // The fract(sin()) math remains the same, but local_time keeps it stable
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // Replaced TIME with local_time
    float time_step = floor(local_time * noise_speed);
    vec2 uv = SCREEN_UV;

    uv.x += (random(vec2(time_step, uv.y)) - 0.5) * shake_power;

    vec4 screen_color = texture(SCREEN_TEXTURE, uv);
    
    float grain = random(uv + time_step);
    
    float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
    
    float final_texture = mix(gray, grain, noise_opacity);
    
    vec3 red_static = vec3(final_texture * red_strength, gray * 0.1, gray * 0.1);

    float dist = distance(SCREEN_UV, vec2(0.5));
    float vignette = smoothstep(0.8, 0.4, dist);
    
    COLOR = vec4(red_static * vignette, 1.0);
}