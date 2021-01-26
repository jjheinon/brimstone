void main( void ) {
    float size = 0.15;
    float dist = 0.1;
    float ang = 1.0;
    vec2 pos = vec2(0.0,0.0);
    vec3 color = vec3(0.1);
    
    vec2 surfacePosition = ( gl_FragCoord.xy / resolution.xy );
    surfacePosition.x = surfacePosition.x - 1.0;
    surfacePosition.y = surfacePosition.y - 1.0;
    for(int i=0; i<5; i++){
        float r = 0.06;
        ang += 3.14159265358979 / (float(5)*0.25)+(u_time*3.0/50.0);
        pos = vec2(cos(ang),sin(ang))*r*sin(u_time*3.+ang/0.6);
        dist += size / distance(pos,surfacePosition);
        vec3 c = vec3(0.153, 0.06, 0.1);
        color = c.yzx*dist;
    }
    gl_FragColor = vec4(color, 1.0);
}