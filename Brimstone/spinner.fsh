#ifdef GL_ES
precision highp float;
#endif

uniform float time;
uniform vec2 resolution;

float light(float r, float xc, float yc, vec2 position)
{
	float d = distance(position, vec2(xc, yc));
	return 1.0 / (1.0 + ((2.0 / r) * d) + ((1.0 / (r * r)) * (d * d)));
}

#define N 1
void main(void)
{
	vec2 position = ( gl_FragCoord.xy / resolution.xy ) - 0.5;
	position.y *= resolution.y/resolution.x;
	
	vec3 color = vec3(1.0);
		
	float lightAccumulator = 0.0;
	float speed = 3.0;
	float size = 12.0;
	float spread = 0.2;
	float intensity = spread * 15.0;
	for(int i=0; i<N; ++i)
	{
		for (int j=-1; j<=1; ++j)
		{
			float offset = float(i) * (spread / float(N)) + float(j) * 2.09439510;
			float x = cos(time * speed + offset) / size;
			float y = sin(time * speed + offset) / size;
			lightAccumulator += light(0.01, -x, y, position) * intensity;
		}
	}
	lightAccumulator /= float(N);
	color *= vec3(1.2,1.0,2.0) * (lightAccumulator * lightAccumulator);
		
		
	gl_FragColor = vec4(color, 1.0 );
}