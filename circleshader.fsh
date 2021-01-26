vec2 position;

vec3 ball(vec3 colour, float sizec, float xc, float yc){
    return colour * (sizec / distance(position, vec2(xc, yc)));
}

vec3 red = vec3(3, 6, 5);
vec3 green = vec3(5, 5, 2);
vec3 blue = vec3(12, 2, 4);
vec3 white = vec3(15, 15, 15);
void main( void ) {

    float time = u_time;
    vec2 resolution = u_sprite_size;
    
    position = ( gl_FragCoord.xy / resolution.xy );
    position.y = position.y * resolution.y/resolution.x + 0.25;

//    v_tex_coord
    vec3 color = vec3(0.0);
    float ratio = resolution.x / resolution.y;
    
    color *= 1.0 - distance(position, vec2(0.5, 0.5));
 //   color += ball(white, 0.0078, sin(time*14.0) / 12.0 + 0.5, cos(time*14.0) / 12.0 + 0.5);
 //   color *= ball(blue, 0.01, -sin(time*14.0) / 12.0 + 0.5, -cos(time*-14.0) / 12.0 + 0.5) + 0.5;
   	color += ball(white, 0.0078, sin(time*15.0) / 12.0 + 0.5, cos(time*15.0) / 12.0 + 0.5);
    color *= ball(white, 0.01, -sin(time*15.0) / 12.0 + 0.5, -cos(time*-15.0) / 12.0 + 0.5) + 0.5;
 
/*    vec4 tex = texture2D(u_texture, v_tex_coord)
    tex.r = tex.r*0.5;
    tex.a = 0.5;
  */  //vec4 color2 = vec4(tex.r+0.5, tex.g, tex.b, tex.a);
    
/*    vec4 texCol = texture2D(u_texture, v_tex_coord);;
    vec4 newCol = vec4((color.red + texCol.red)/2, (color.green + texCol.green)/2, (color.blue + texCol.blue)/2, (color.alpha + texCol.alpha)/2);
    gl_FragColor = texture2D(u_texture, v_tex_coord); // * v_color_mix;
  */
    gl_FragColor = vec4(color, 1.0) * texture2D(u_texture, v_tex_coord);
}
