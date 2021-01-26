uniform vec2 position;

uniform float glow;
uniform float mult;

float pyth(float a, float b) {
    return sqrt(a*a + b*b);
}

vec3 glowCol(float x, float y, float glow) {
    float intensity = glow/distance(vec2(x, y), gl_FragCoord.xy);
    return vec3(intensity/3., intensity/2., intensity);
}

void main( void ) {
    float x = resolution.x/2.;
    float y = resolution.y/2.;
    float glow = 120.0;//u_glow; 20.0;
    
    float mult = abs(sin(u_time));
  //  float divider = mult*5.;
    
    float dx = distance(x, gl_FragCoord.x);
    float dy = distance(y, gl_FragCoord.y);
    float intensity = glow/pyth(dx/(20.*mult), dy/mult);
    
    vec3 color = glowCol(x, y, glow)/2. + vec3(intensity/10., intensity/10., intensity/10.)/2.; ///divider;
    gl_FragColor = vec4(color, 0.5);
}
