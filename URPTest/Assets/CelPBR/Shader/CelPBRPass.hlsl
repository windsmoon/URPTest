﻿#ifndef CEL_PRB_PASS
#define CEL_PBR_PASS

// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

// #include "URPTestLighting.hlsl" 

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 baseUV : TEXCOORD0;
    float2 lightmapUV : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float3 tangentWS : VAR_TANGENT;
    float3 bitangentWS : VAR_BITANGENT;
    float2 baseUV : VAR_BASE_UV;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#include "Common.hlsl"
#include "Input.hlsl"
#include "Light.hlsl"
#include "Surface.hlsl"
#include "TempData.hlsl"
#include "BRDF.hlsl"
#include "GI.hlsl"
#include "Lighting.hlsl"

Varyings CelPBRVert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentWS.xyz = TransformObjectToWorldDir(input.tangentOS.xyz);
    output.bitangentWS = cross(output.normalWS.xyz, output.tangentWS.xyz) * input.tangentOS.w * GetOddNegativeScale();
    output.baseUV = TRANSFORM_UV(input.baseUV, _BaseMap);
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV)
    return output;
}

real4 CelPBRFrag(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    
    Surface_CelPBR surface = GetSurface(input);
    LightData_CelPBR mainLightData = GetMainLightData(input);
    TempData_CelPBR mainTempData = GetTempData(input, surface, mainLightData);

    // adjust light and surface data
    #if defined(_SCREEN_SPACE_OCCLUSION)
        AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(input.positionCS));
        mainLightData.color *= aoFactor.directAmbientOcclusion;
        surface.occlusion = min(surface.occlusion, aoFactor.indirectAmbientOcclusion);
    #endif
    
    BRDF_CelPBR brdf = GetBRDF(surface, mainLightData, mainTempData, surface.alpha);
    GI_CelPBR gi = GetGI(input, brdf, surface, mainTempData);

    // compile error with out gi.bakeGI parameter
    // MixRealtimeAndBakedGI(ConvertToUnityLight(mainLightData), surface.normal, gi.bakedGI);
    #if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
        gi.bakedGI = SubtractDirectMainLightFromLightmap(ConvertToUnityLight(mainLightData), surface.normal, gi.bakedGI);
    #endif
    
    // gi.color = gi.color.bbb;
    // return float4(gi.color, surface.color.r);
    real3 color = gi.color;
    color += surface.emission;
    color += GetLighting(mainLightData, surface, brdf, mainTempData);

    int otherLightCount = GetOtherLightCount();
    
    for (int i = 0; i < otherLightCount; ++i)
    {
        LightData_CelPBR lightData = GetOtherLightData(input, i);
        TempData_CelPBR tempData = GetTempData(input, surface, lightData);
        color += GetLighting(lightData, surface, brdf, tempData);
    }

    return real4(color, surface.alpha);
}

#endif