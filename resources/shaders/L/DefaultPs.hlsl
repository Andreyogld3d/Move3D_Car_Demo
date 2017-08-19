//uniform sampler2D colorSampler : register(s0);
//uniform sampler2D bump : register(s1);
//uniform sampler2D ShadowMap : register(s2);

#include "Move3D.hlsl"

TEXTURE2D(albedoMap, 0);
TEXTURE2D(sky, 1);
TEXTURE2D(skySpecular, 2);

#define LIGHT
#define SPECULAR

float4x4 MOVE3D_MATRIX_W : register(c0);



float3 readIbl(float3 dir, float level){
    float2 uv = RadialCoords(dir);
    uv = FixupSphericalCoordSeam(uv);
    return sky.SampleLevel(ssky, uv, level).rgb;
   // return tex2D(sky, uv).rgb;
}

float3 readIblSpecular(float3 dir, float level){
    float2 uv = RadialCoords(dir);
    uv = FixupSphericalCoordSeam(uv);
    return skySpecular.SampleLevel(ssky, uv, level).rgb;
   // return tex2D(sky, uv).rgb;
}

float4 psMain(in PixelInput In) : COLOR {
    float3 light_color = float3(1.0f, 1.0f, 0.92f);
    float3 ambient_color = float3(0.03f, 0.03f, 0.08f);

    float4 albedo = tex2D(albedoMap, In.uv0);

#ifdef ALPHA_TEST
	if (albedo.a < 0.5f) {
		discard;
	}
#endif

    float shadow = 0;
    //sampleShadowPCF(2, In.SHADOW_COORD_NAME);

    float3 L = normalize(In.lightDir);
    float3 V = normalize(In.viewDir);
	
    float3 N = float3(0, 0, 1);
    //normalize(2.0f * tex2D(bump, In.uv0).rgb - 1.0f);
    float3 H = normalize(L + V);

    float3 worldNormal = normalize(In.normal); //TODO: get world normal!!! normalize(mul(In.normal, (float3x3) MOVE3D_MATRIX_W));


   // float3 layer1Color = float3(1.0f, 0.765557f, 0.336057f);
    float3 layer1Color = 0.9f;


    float layer1Weight = 1.0f;


    float roughnessL0 = In.materialParams0.x;
    float roughnessL1 = In.materialParams0.y;
    float metallic = In.materialParams0.z;
    float fresnelIOR = In.materialParams0.w;


    float f0 = fresnelIOR;

    float G_specular = G_CookTorrance(L, N, H, V);
    float F_specular = F_Schlick(f0, V, H);
    float D_specular0 = D_GGXIsotropic(N, H, roughnessL0);
    float D_specular1 = D_GGXIsotropic(N, H, roughnessL1);
    float kSpecular0 = BRDF_CookTorrance(L, N, V, D_specular0, F_specular, G_specular);

    float kSpecular1 = BRDF_CookTorrance(L, N, V, D_specular1, 1, G_specular); //TODO: use conductor Fresnel instead of 1


    float3 skyColorSpecular = readIblSpecular(In.worldReflection, pow(roughnessL1, 0.5f) * 8);

   // return float4(skyColorSpecular, 1);

    float3 skyColor = readIbl(In.worldReflection, pow(roughnessL0, 0.5f) * 8);

    float3 layer1Metallic = (layer1Color * albedo.rgb) * (skyColorSpecular.rgb + kSpecular1 * shadow * light_color);

    
    float F_specularIBL = F_Schlick(f0, V, N);

    float2 uvSkyDiffuse = FixupSphericalCoordSeam(RadialCoords(worldNormal));
  
    float3 iblDiffuse = sky.SampleLevel(ssky, uvSkyDiffuse, 9).rgb;
    //return float4(iblDiffuse, 1);

    float kDiffuse = max(0.0f, dot(L, N));

    float3 layer1Diffuse = (layer1Color * albedo.rgb) * (light_color * kDiffuse * shadow + iblDiffuse);

    float3 layer1 = lerp(layer1Diffuse, layer1Metallic, metallic);

    float3 layer0 = kSpecular0 * shadow * light_color + skyColor.rgb * F_specularIBL;


   // 

    //return shadow;
    return float4(lerp(layer0, layer1, layer1Weight), 0);



	
}