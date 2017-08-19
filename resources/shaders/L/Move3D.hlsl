#ifndef MOVE3D_ENGINE_INTERFACE__
#define MOVE3D_ENGINE_INTERFACE__

#include "Constants.hlsl"
#include "Platform.hlsl"
#include "Instancing.hlsl"
#include "Lighting.hlsl"

struct VertexInput {
    float4 position : POSITION;
    float2 uv0		: TEXCOORD0;
    float3 normal	: NORMAL;
    float4 tangent	: TANGENT;

    VERTEX_INSTANCE_DATA
};

struct PixelInput
{
    float4 position : POSITION; // position in projection space
    float2 uv0 : TEXCOORD0; // texture coordinate
    float3 lightDir : TEXCOORD1; // texture coordinat;
    SHADOW_COORDS(2)
    float3 viewDir : TEXCOORD3;
    float3 normal : TEXCOORD4;
    float3 tangent : TEXCOORD5;
    float3 worldReflection : TEXCOORD6;

    float4 materialParams0 : TEXCOORD7;

/*#ifdef ALPAHA_TEST
	//float AlphaRef :  TEXCOORD4;
#endif
#ifdef FOG
	float  fogExponent  : TEXCOORD5;
#endif*/
};


inline float2 RadialCoords(float3 a_coords)
{
    float3 a_coords_n = normalize(a_coords);
    float lon = atan2(a_coords_n.z, a_coords_n.x);
    float lat = acos(a_coords_n.y);
    float2 sphereCoords = float2(lon, lat) * (1.0 / MOVE3D_PI);
    return float2(sphereCoords.x * 0.5 + 0.5, sphereCoords.y);
}

inline float2 FixupSphericalCoordSeam(float2 uv0)
{
    float2 uv1 = uv0;
    if (uv1.x < 0.25)
    {
        uv1.x += 1.0f;
    }

    float2 d0 = ddx(uv0) + ddy(uv0);
    float2 d1 = ddx(uv1) + ddy(uv1);
    return lerp(uv0, uv1, dot(d0, d0) > dot(d1, d1));
}

#endif //MOVE3D_ENGINE_INTERFACE__