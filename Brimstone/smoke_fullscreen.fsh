precision highp float;

uniform vec2 position;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand2(vec2 co){
    return fract(cos(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Rough Value noise implementation
float valueNoiseSimple(vec2 vl) {
    float minStep = 1.0 ;
    
    vec2 grid = floor(vl);
    vec2 gridPnt1 = grid;
    vec2 gridPnt2 = vec2(grid.x, grid.y + minStep);
    vec2 gridPnt3 = vec2(grid.x + minStep, grid.y);
    vec2 gridPnt4 = vec2(gridPnt3.x, gridPnt2.y);
    
    float s = rand2(grid);
    float t = rand2(gridPnt3);
    float u = rand2(gridPnt2);
    float v = rand2(gridPnt4);
    
    float x1 = smoothstep(0., 1., fract(vl.x));
    float interpX1 = mix(s, t, x1);
    float interpX2 = mix(u, v, x1);
    
    float y = smoothstep(0., 1., fract(vl.y));
    float interpY = mix(interpX1, interpX2, y);
    
    return interpY;
}

float fractalNoise(vec2 vl) {
    float persistance = 2.0;
    float amplitude = 0.5;
    float rez = 0.0;
    vec2 p = vl;
    
    for (float i = 0.0; i < 8.0; i++) {
        rez += amplitude * valueNoiseSimple(p);
        amplitude /= persistance;
        p *= persistance;
    }
    return rez;
}

float complexFBM(vec2 p) {
    float slow = u_time / 5.;
    float fast = u_time / 1.;
    vec2 offset1 = vec2(slow, 0.); // Main front
    
    // LIVE_SMOKE
    //    vec2 offset2 = vec2(valueNoiseSimple(p + fast) * 2., 0.); // sub fronts
    vec2 offset2 = vec2(sin(fast) * 0.1, 0.); // sub fronts
    
    return fractalNoise(p + offset1 + fractalNoise(
                                                    p + fractalNoise(
                                                                     p + 2. * fractalNoise(p - offset2)
                                                                     )
                                                    )
                        );
}


void main(void)
{
    vec2 uv = -gl_FragCoord.xy / resolution.xy;
    
    vec3 color1 = vec3(0.729411765, 0.607843137, 0.580392157);
    vec3 color2 = vec3(0.409803922, 0.203921569, 0.205686275);
    
    vec3 rez = mix(color2, color1, complexFBM(uv));
    
    gl_FragColor = vec4(rez, 0.3);
}