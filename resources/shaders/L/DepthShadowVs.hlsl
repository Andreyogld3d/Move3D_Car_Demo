
uniform float4x4 lightMatrix : register(c0);
uniform float4 LightDir : register(c4);
uniform float4 CameraPosition : register(c5);
uniform float4x4 WorldInverseMatrix : register(c6);
uniform float4x4 WorldMatrix : register(c10);

#include "Move3D.hlsl"

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 Depth: TEXCOORD0;
}; 

VS_OUTPUT vsMain(in float4 Pos: POSITION)
{
    float4x4 test = mul(WorldMatrix, WorldInverseMatrix);
    float4 pos = float4(Pos.xyz, 1.0f);


    float3 worldPos = mul(pos, WorldMatrix);

    float3 L = normalize(CameraPosition.xyz - worldPos);

    float3x3 normalMatrix = transpose((float3x3) WorldInverseMatrix);



	VS_OUTPUT Out;
	
  
	Out.Pos = mul(pos, lightMatrix);    
    Out.Depth.xy = Out.Pos.zz;
	return Out;
}
