//uniform float time;

//uniform vec2 position;
//varying vec2 surfacePosition;

#define PI 3.14159265358979
#define N 10
void main( void ) {
    
    
    float size = 0.05;
    float dist = 0.01;
    float ang = 0.0;
    vec3 color = vec3(0.1);
    float delta = 0.0;
    
    
    float t = u_time*7.0;
    
    vec2 position = ( (gl_FragCoord.xy/2.-resolution.xy/4.) / resolution.xy );
    float aspect = resolution.x / resolution.y;
    
    for(int i=0; i<N; i++){
        float r = 0.1;
        ang += PI / (float(N)*0.5)+(u_time/60.0);
        vec2 pos = 0.25*vec2(cos(ang),sin(ang)*aspect)*r*sin(t+ang/0.5);
        dist += size / distance(pos,position);
    }
    
    delta = sin(t/2.1) * 1.0;
    
    //vec3 c = vec3(0.03 + delta, 0.05 + delta, 0.1);
    vec3 c = vec3(/*sin(time) + */ 0.1 + delta, 0.04 + delta, 0.01 + delta);
    
    color = c*dist;
    
    
    gl_FragColor = vec4(color/2., 0.5) * texture2D(u_texture, v_tex_coord);
}
