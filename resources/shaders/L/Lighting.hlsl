#ifndef MOVE3D_LIGHTING_INC__
#define MOVE3D_LIGHTING_INC__

#include "Constants.hlsl"
#include "Platform.hlsl"

#define SHADOW_COORD_NAME shadowCoord
#define SHADOW_COORDS(_id) float4 SHADOW_COORD_NAME : TEXCOORD##_id;
#define SHADOW_MAP_TEXTURE ShadowMap

//builtin variables
TEXTURE2D(SHADOW_MAP_TEXTURE, 4);


float roughnessToPhongPower(float roughness){
    return (2.0f / pow(roughness, 4.0f)) - 2.0f;
}

float phongNormalization(float p){
    return ((p + 2.0f) * (p + 4.0f)) / (8.0f * MOVE3D_PI * (pow(2.0f, -p / 2.0f) + p));
}


float getShadowNormalOffset(float3 N, float3 L) {
    float cosAlpha = saturate(dot(N, L));
    return sqrt(1.0f - cosAlpha * cosAlpha);
}

float sampleShadowBilinear(float4 coord) {
  
    float2 shadowMapPixelSize = float2(2048.0f, 2048.0f); // need to keep in sync with .cpp file
    float4 subPixelCoords = 0;
    subPixelCoords.xy = frac(shadowMapPixelSize * coord.xy);
    subPixelCoords.zw = 1.0f - subPixelCoords.xy;
    float4 vBilinearWeights = subPixelCoords.zxzx * subPixelCoords.wwyy;

    int3 intCoord = int3((int2) shadowMapPixelSize * coord.xy, 0);

    //Using load instead of Sample because sampler state is incorrect in engine (for depth map)
    float4 depthSamples = {
        SHADOW_MAP_TEXTURE.Load(intCoord).r,
        SHADOW_MAP_TEXTURE.Load(intCoord + int3(1, 0, 0)).r,
        SHADOW_MAP_TEXTURE.Load(intCoord + int3(0, 1, 0)).r,
        SHADOW_MAP_TEXTURE.Load(intCoord + int3(1, 1, 0)).r,
    };
  
    float4 shadowTests = (depthSamples < (coord.z - 0.00001f)) ? 0.0f : 1.0f;
    return dot(vBilinearWeights, shadowTests);
}


float sampleShadowPCF(float numKernel, float4 coord) {
	float nSum = 2.0 * numKernel;


    float sum = 0;
    float x, y;

    float n = 1.0f;
    float count = 0.0f;

    for (y = -n; y <= n; y += 1.0)
    {
        for (x = -n; x <= n; x += 1.0)
        {
            float4 c = coord;
            c.xy += float2(x, y) / 2048.0f;
            sum += sampleShadowBilinear(c);
            count += 1.0f;
        }
    }
       
    return sum / count;
}



#define PCFFilter(numKernel, map, coord) PCFFilterImpl(numKernel, map, s##map, coord)


float D_GGXIsotropic(float3 n, float3 m, float roughness){
    float a = roughness * roughness;
    float NdotM = dot(n, m);
    float d = (NdotM * NdotM) * (a * a - 1) + 1;
    return (a * a) / (MOVE3D_PI * d * d);
}

float G_CookTorrance(float3 l, float3 n, float3 h, float3 v){
    float nh = dot(n, h);
    float nv = dot(n, v);
    float nl = dot(n, l);
    float vh = dot(v, h);

    float x = (2.0f * nh) / vh;

    float a = x * nv;
    float b = x * nl;

    return min(1.0f, min(a, b));
}

float G_GGX(float3 n, float3 v, float roughness){
    float a = roughness * roughness;
    float nv = dot(n, v);
    return (2 * nv) / (nv + sqrt(a * a + (1 - a * a) * (nv * nv)));
}

float F_Schlick(float f0, float3 v, float3 h){
    return f0 + (1.0f - f0) * pow(1 - dot(v, h), 5);
}

float BRDF_CookTorrance(float3 l, float3 n, float3 v, float D, float F, float G){
    return (D * F * G) / (4.0f * dot(n, l) * dot(n, v));
}
#endif //MOVE3D_LIGHTING_INC__