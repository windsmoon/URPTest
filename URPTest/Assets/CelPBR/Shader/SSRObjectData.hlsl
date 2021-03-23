#ifndef CEL_PBR_SSR_OBJECT_DATA_PASS_INCLUDED
#define CEL_PBR_SSR_OBJECT_DATA_PASS_INCLUDED

// todo !!!!
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

struct Attributes
{
    float4 positionOS : POSITION;
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
    float3 positionVS : VAR_POSTION_VS;
    float4 positionSS : VAR_SCREEN_POSITION;
    float4 screenPos : VAR_SCREEN_POS;
    float3 normalWS : VAR_NORMAL;
    float3 tangentWS : VAR_TANGENT;
    float3 bitangentWS : VAR_BITANGENT;
    float2 baseUV : VAR_BASE_UV;
    float2 kkHighlightUV : VAR_KK_HIGHLIGHT_UV;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#include "Common.hlsl"
#include "Input.hlsl"
#include "ParallaxMapping.hlsl"
#include "Light.hlsl"
#include "Surface.hlsl"
#include "TempData.hlsl"
#include "BRDF.hlsl"
#include "GI.hlsl"
#include "Lighting.hlsl"

float RawToEyeDepth(float rawDepth)
{
    #if defined(_ORTHOGRAPHIC)
    #if UNITY_REVERSED_Z
    return ((_ProjectionParams.z - _ProjectionParams.y) * (1.0 - rawDepth) + _ProjectionParams.y);
    #else
    return ((_ProjectionParams.z - _ProjectionParams.y) * (rawDepth) + _ProjectionParams.y);
    #endif
    #else
    return LinearEyeDepth(rawDepth, _ZBufferParams);
    #endif
}

Varyings SSRObjectDataVert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.positionVS = TransformWorldToView(TransformObjectToWorld(input.positionOS));
    output.baseUV = TRANSFORM_UV(input.baseUV, _BaseMap);
    output.screenPos = ComputeScreenPos(output.positionCS);

    return output;
}

real4 SSRObjectDataFrag(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    LightData_CelPBR mainLightData = GetMainLightData(input);
    Surface_CelPBR surface = GetSurface(input);
    TempData_CelPBR mainTempData = GetTempData(input, surface, mainLightData);

    // adjust light and surface data
    #if defined(_SCREEN_SPACE_OCCLUSION)
        AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(input.positionCS));
        mainLightData.color *= aoFactor.directAmbientOcclusion;
        surface.occlusion = min(surface.occlusion, aoFactor.indirectAmbientOcclusion);
    #endif
    
    BRDF_CelPBR brdf = GetBRDF(surface, mainLightData, mainTempData, surface.alpha);
    GI_CelPBR gi = GetGI(input, brdf, surface, mainLightData, mainTempData);
    float2 screenUV = input.screenPos.xy / input.screenPos.w;
    float depth = SampleSceneDepth(screenUV);
    float depthVS = RawToEyeDepth(depth);
    float zVS = -input.positionVS.z;

    if (depthVS < zVS)
    {
        discard;
    }

    return float4(gi.specular, 1);
}


#endif