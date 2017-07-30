//
uniform mat4 worldViewProjMatrix;
uniform vec4 ZNearZFar;

attribute vec4 POSITION;

#ifdef INSTANCING
attribute vec4 TRANSFORM0;
attribute vec4 TRANSFORM1;
attribute vec4 TRANSFORM2;
#endif

varying vec4 Pos;
varying vec3 Depth;

void main()
{
	vec4 position = vec4(POSITION.xyz, 1.0);
#ifdef INSTANCING
	mat4 WorldMatrix = mat4(vec4(TRANSFORM0.x, TRANSFORM1.x, TRANSFORM2.x, 0.0), 
								vec4(TRANSFORM0.y, TRANSFORM1.y, TRANSFORM2.y, 0.0), 
								vec4(TRANSFORM0.z, TRANSFORM1.z, TRANSFORM2.z, 0.0), 
								vec4(TRANSFORM0.w, TRANSFORM1.w, TRANSFORM2.w, 1.0));
	position = WorldMatrix * position;
#endif
	gl_Position = worldViewProjMatrix * position;
	Depth = vec3(gl_Position.z, ZNearZFar.x, ZNearZFar.y);
}
