#ifndef CEL_PRB_PASS
#define CEL_PBR_PASSS

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 baseUV : TEXCOORD0;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float2 baseUV : VAR_BASE_UV;
};

float _Shinness;

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"     
#include "Input.hlsl"
#include "Surface.hlsl"
#include "Light.hlsl"
#include "BRDF.hlsl"
#include "Lighting.hlsl"

Varyings CelPBRVert(Attributes input)
{
    Varyings output;
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionHCS = TransformWorldToHClip(output.positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.baseUV = TRANSFORM_TEX(input.baseUV, _BaseMap);
    return output;
}

Surface_CelPBR GetSurface(Varyings input)
{
    Surface_CelPBR surface;
    surface.color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);
    surface.pos = input.positionWS;
    surface.normal = input.normalWS;
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
    return surface;
}

LightData_CelPBR GetMainLightData()
{
    // DirectionalLight_CelPBR directionalLight;
    // directionalLight.color = _MainLightColor.xyz;
    // directionalLight.direction = _MainLightPosition.xyz;
    // directionalLigh
    LightData_CelPBR lightData;
    lightData.color = _MainLightColor.xyz;
    lightData.direction = _MainLightPosition.xyz;
    lightData.attenuation = 1;
    return lightData;
}

float4 CelPBRFrag(Varyings input) : SV_TARGET
{
    Surface_CelPBR surface = GetSurface(input);
    LightData_CelPBR mainLightData = GetMainLightData();
    half3 color = GetLighting(mainLightData, surface, GetBRDF(surface));
    return half4(color, 1);
}




#endif