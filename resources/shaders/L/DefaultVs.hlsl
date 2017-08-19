#define CALCULATE_BINORMAL

#define SHADOW_MAP_TEXTURE_SLOT 3
#include "Move3D.hlsl"

uniform float4x4 MOVE3D_MATRIX_WVP : register(c0);
uniform float4x4 MatTexture : register(c4);
uniform float4 LightDir : register(c8); 
uniform float4 CameraPosition : register(c9);
uniform float4 test : register(c10);

uniform float4 materialParams0;

#ifndef INSTANSING
uniform float4x4 WorldMatrix;
#endif



PixelInput vsMain(VertexInput input){

    PixelInput vsOut;

    vsOut.materialParams0 = materialParams0;

    input.normal = normalize(input.normal); //TODO: remove me after tests

	vsOut.normal = input.normal;
	vsOut.tangent = input.tangent;
	

    float4 pos = float4(input.position.xyz, 1.0f);
#ifdef INSTANCING
	const float4x4 MOVE3D_MATRIX_W = GET_INSTANCE_MATRIX(input);
	
	float4 WorldPos = mul(pos, MOVE3D_MATRIX_W);
	vsOut.position = mul(WorldPos, MOVE3D_MATRIX_WVP);
	vsOut.SHADOW_COORD_NAME = mul(WorldPos, MatTexture);
#else
    vsOut.position = mul(pos, MOVE3D_MATRIX_WVP);
    vsOut.SHADOW_COORD_NAME = mul(pos, MatTexture);
    float4 WorldPos = mul(pos, MOVE3D_MATRIX_W);
#endif

	vsOut.uv0 = input.uv0;

    vsOut.viewDir = CameraPosition.xyz - WorldPos.xyz;

	vsOut.lightDir = -LightDir.xyz;


  //  vsOut.worldReflection = abs(frac(WorldPos.xyz));
    vsOut.worldReflection = -normalize(reflect(vsOut.viewDir, vsOut.normal));


	float3 binormal = cross(input.normal, input.tangent.xyz) * input.tangent.w;

    float3x3 tbnMatrix = float3x3(
        normalize(input.tangent.xyz), 
        normalize(binormal), 
        normalize(input.normal)); 
	
	//Move view and light directons to tangent space
    vsOut.lightDir = mul(tbnMatrix, vsOut.lightDir.xyz);
    vsOut.viewDir = mul(tbnMatrix, vsOut.viewDir);

	return vsOut;
}

