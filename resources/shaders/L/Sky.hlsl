#include "Move3D.hlsl"

TEXTURE2D(cloud, 0);

uniform float4x4 worldViewProj : register(c0);
uniform float time : register(c4);

struct PsInput {
	float4 position  : POSITION;
	float3 localPos  : TEXCOORD3;
};

PsInput vsMain(in float4 position : POSITION, in float2 texCoord0 : TEXCOORD0) {
    PsInput o;
    o.position = half4(mul(position, worldViewProj));
    o.localPos = position.xyz;
    return o;
}

float4 psMain(in PsInput input) : COLOR {
    float2 uv = RadialCoords(normalize(input.localPos));
    float2 uv0 = FixupSphericalCoordSeam(uv);
    float4 skyColor = tex2D(cloud, uv0);
	return skyColor;
}