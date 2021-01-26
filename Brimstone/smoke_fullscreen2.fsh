precision highp float;

highp float rand(in highp vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

highp float rand2(in highp vec2 co){
    return fract(cos(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

highp float valueNoiseSimple(in highp vec2 vl) {
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

highp float fractalNoise(in highp vec2 vl) {
    highp float persistance = 2.5;
    highp float amplitude = 0.6;
    highp float rez = 0.0;
    highp vec2 p = vl;
    
    for (float i = 0.0; i < 4.0; i++) {
        rez += amplitude * valueNoiseSimple(p);
        amplitude /= persistance;
        p *= persistance;
    }
    return rez;
}

highp float complexFBM(in highp vec2 p) {
    highp float currTime = currentTimeUniform;
    
    highp float slow = currTime / 12.;
    highp float fast = currTime / 2.;
    highp vec2 offset1 = vec2(0., slow); // Main front
    
    highp vec2 offset2 = vec2(sin(fast) * 0.1, 0.); // sub fronts
    
    return fractalNoise(p + offset1 + fractalNoise(
                                                   p + fractalNoise(
                                                                    p + 2. * fractalNoise(p - offset2)
                                                                    )
                                                   )
                        );
}


void main(void ){
    highp vec2 uv = -gl_FragCoord.xy / resolution.xy;
  //  pos.x = pos.x + resolution.x;
  
//    vec2 uv = pos / resolution.xy;
    
//    vec2 uv = -gl_FragCoord.xy / resolution.xy;
    
    
    highp vec3 color1 = vec3(0.829411765, 0.707843137, 0.680392157);
    highp vec3 color2 = vec3(0.029803922, 0.023921569, 0.025686275);
    
    highp vec3 rez = mix(color2, color1, complexFBM(uv));
    
    gl_FragColor = vec4(rez, 1.0);//  * texture2D(u_texture, v_tex_coord);
}

