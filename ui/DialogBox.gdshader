shader_type canvas_item;

uniform float speed = 0.08;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    float alpha = texture(TEXTURE, UV).a;
    vec3 color = hsv2rgb(vec3(fract(TIME * speed), 1.0, 1.0));
    COLOR = vec4(color * alpha, alpha);
}