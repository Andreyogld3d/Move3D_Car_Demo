<!--3DMove-->
<VertexShader LodDistance = "200">
	VertexShader ShadowCasterVS/
	EntryPoint vsMain/
    SourceFile L\DefaultVS.hlsl/

	<VertexShaderParameters>
		ParamNameAuto ModelViewProjection WorldViewProjMatrix 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0/
        ParamNameAuto MatTexture ShadowMapTextureMatrix 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0/
		ParamNameAuto LightDir ShadowMapLightDirection 0.0f 100.0f 0.0f 1.0f/
		ParamNameAuto CameraPosition CameraPosition 0.0f 0.0f 0.0f 1.0f/
        ParamName test float4 0.0 0.0 0.0 0.0/
	</VertexShaderParameters>
</VertexShader>
