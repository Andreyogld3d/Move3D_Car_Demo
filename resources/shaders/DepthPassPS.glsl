//

#ifdef GL_ES
precision mediump float;
#endif

varying vec3 Depth;

vec4 StoreZValueToColor(float z, float zNear, float zFar)
{
#if 1
	z = (zNear + z) / zFar;
#endif
	return vec4(z, z, z, 1.0);
}

void main()
{
	//gl_FragColor = vec4(zNear / zFar + In.Depth / zFar, 0.0, 0.0, 0.0);
	gl_FragColor = StoreZValueToColor(Depth.x, Depth.y, Depth.z);
	//gl_FragColor = vec4(In.Depth, 0.0f, 0.0f, 0.0);
	//gl_FragColor = vec4(0.5f, 0.0, 0.0, 0.0);
	//gl_FragColor = vec4(In.Depth.xxx / In.Depth.yyy, 1.0);
}