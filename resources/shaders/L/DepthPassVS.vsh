<!--3DMove-->
<VertexShader LodDistance = "200">
	VertexShader DepthPassVS/
	EntryPoint vsMain/
	SourceFile DepthPassVS.cg/
	<VertexShaderParameters>
			ParamNameAuto worldViewProjMatrix WorldViewProjMatrix 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0/
			ParamNameAuto ZNearZFar ZNearZFarFov 0.16/
	</VertexShaderParameters>				
</VertexShader>
