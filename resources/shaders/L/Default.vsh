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
        ParamName materialParams0 float4 0.0 0.0 0.0 0.0/
		ParamName materialParams1 float4 0.0 0.0 0.0 0.0/
		ParamName layer1Color float4 0.0 0.0 0.0 0.0/
        ParamNameAuto WorldMatrix WorldMatrix 1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0/
	</VertexShaderParameters>
</VertexShader>
