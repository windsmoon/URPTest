#ifndef CEL_PRB_PASS
#define CEL_PBR_PASS

// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 baseUV : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float3 tangentWS : VAR_TANGENT;
    float3 bitangentWS : VAR_BITANGENT;
    float2 baseUV : VAR_BASE_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#include "Common.hlsl"
#include "Input.hlsl"
#include "Light.hlsl"
#include "Surface.hlsl"
#include "BRDF.hlsl"
#include "Lighting.hlsl"

Varyings CelPBRVert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionHCS = TransformWorldToHClip(output.positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
    output.bitangentWS = cross(output.normalWS, output.tangentWS) * input.tangentOS.w * GetOddNegativeScale();
    output.baseUV = TRANSFORM_TEX(input.baseUV, _BaseMap);
    return output;
}

float4 CelPBRFrag(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    
    Surface_CelPBR surface = GetSurface(input);
    LightData_CelPBR mainLightData = GetMainLightData(input);
    BRDF_CelPBR brdf = GetBRDF(surface, mainLightData);
    half3 color = GetLighting(mainLightData, surface, brdf);

    int otherLightCount = GetOtherLightCount();

    for (int i = 0; i < otherLightCount; ++i)
    {
        LightData_CelPBR lightData = GetOtherLightData(input, i);    
        color += GetLighting(lightData, surface, brdf);
    }
    // UniversalFragmentPBR
    // float3 worldNormal

    // color.rgb = surface.normal;
    // color.a = surface.color.a;
    // color.r = surface.color.a;
    // return float4(surface.normal, surface.color.r * 100);
    return float4(color, surface.color.r);
}

#endif