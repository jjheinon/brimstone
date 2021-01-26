precision highp float;
highp float rand(highp vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

highp float rand2(highp vec2 co){
    return fract(cos(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Rough Value noise implementation
highp float valueNoiseSimple(vec2 vl) {
    highp float minStep = 1.0 ;
    
    highp vec2 grid = floor(vl);
    highp vec2 gridPnt1 = grid;
    highp vec2 gridPnt2 = vec2(grid.x, grid.y + minStep);
    highp vec2 gridPnt3 = vec2(grid.x + minStep, grid.y);
    highp vec2 gridPnt4 = vec2(gridPnt3.x, gridPnt2.y);
    
    highp float s = rand2(grid);
    highp float t = rand2(gridPnt3);
    highp float u = rand2(gridPnt2);
    highp float v = rand2(gridPnt4);
    
    highp float x1 = smoothstep(0., 1., fract(vl.x));
    highp float interpX1 = mix(s, t, x1);
    highp float interpX2 = mix(u, v, x1);
    
    highp float y = smoothstep(0., 1., fract(vl.y));
    highp float interpY = mix(interpX1, interpX2, y);
    
    return interpY;
}

highp float fractalNoise(highp vec2 vl) {
    highp float persistance = 2.0;
    highp float amplitude = 0.5;
    highp float rez = 0.0;
    highp vec2 p = vl;
    
    for (float i = 0.0; i < 8.0; i++) {
        rez += amplitude * valueNoiseSimple(p);
        amplitude /= persistance;
        p *= persistance;
    }
    return rez;
}

highp float complexFBM(highp vec2 p) {
    highp float slow = -u_time / 1.;
    highp float fast = -u_time / 0.5;
    highp vec2 offset1 = vec2(slow, 0.); // Main front
    
    highp vec2 offset2 = vec2(sin(fast) * 0.1, 0.); // sub fronts
    
    return fractalNoise( p + offset1 + fractalNoise(
                                                    p + fractalNoise(
                                                                     p + 2. * fractalNoise(p - offset2)
                                                                     )
                                                    )
                        );
}


void main(void)
{
    highp vec2 uv = gl_FragCoord.xy / resolution.xy;
    
    highp vec3 blueColor = vec3(0.529411765, 0.807843137, 0.980392157);
    highp vec3 orangeColor2 = vec3(0.01509803922, 0.01503921569, 0.015686275);
    
    highp vec3 rez = mix(orangeColor2, blueColor, complexFBM(uv));
    
    gl_FragColor = vec4(rez, 0.1);
}