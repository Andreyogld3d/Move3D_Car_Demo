<!--3DMove-->
<VertexShader LodDistance = "200">
	VertexShader DepthShadowVS/
	EntryPoint vsMain/
	SourceFile L\DepthShadowVS.hlsl/
	<VertexShaderParameters>
            ParamNameAuto lightMatrix ShadowMapLightWorldViewProjMatrix 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0/
            ParamNameAuto LightDir ShadowMapLightDirection 0.0f 100.0f 0.0f 1.0f/
            ParamNameAuto CameraPosition CameraPosition 0.0f 0.0f 0.0f 1.0f/
            ParamNameAuto WorldInverseMatrix WorldInverseMatrix 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0/
            ParamNameAuto WorldMatrix WorldMatrix 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0/
	</VertexShaderParameters>				
</VertexShader>
