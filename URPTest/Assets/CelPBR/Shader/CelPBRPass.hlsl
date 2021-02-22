#ifndef CEL_PRB_PASS
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
    output.kkHighlightUV = TRANSFORM_UV(input.baseUV, _KKHighlightOffsetMap);
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV)
    return output;
}

real4 CelPBRFrag(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    input.normalWS = normalize(input.normalWS);
    input.tangentWS = normalize(input.tangentWS);
    input.bitangentWS = normalize(input.bitangentWS);

    real parallaxMappingSelfShadowAttenuation = 1;
    LightData_CelPBR mainLightData = GetMainLightData(input);

    #if defined(_PARALLAXMAP)
        // todo : caculate viewDir in a hlsl file
        half3 viewDirWS = SafeNormalize(_WorldSpaceCameraPos - input.positionWS);
        half3 viewDirTS = mul(GetTBN(input.normalWS, input.tangentWS, input.bitangentWS), viewDirWS);
        float3 parallaxMappingResult = GetParallaxMappingResult(input.baseUV, viewDirTS);
        input.baseUV = parallaxMappingResult.xy;

        #if defined(PARALLAX_SELF_SHADOW)
            half3 lightDirTS = mul(GetTBN(input.normalWS, input.tangentWS, input.bitangentWS), mainLightData.direction);
            parallaxMappingSelfShadowAttenuation = GetParallaxMappingSelfShadowAttenuation(input.baseUV, lightDirTS, parallaxMappingResult.z);
        #endif
    #endif
    
    mainLightData.shadowAttenuation *= parallaxMappingSelfShadowAttenuation;
    Surface_CelPBR surface = GetSurface(input);
    TempData_CelPBR mainTempData = GetTempData(input, surface, mainLightData);

    // adjust light and surface data
    #if defined(_SCREEN_SPACE_OCCLUSION)
        AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(input.positionCS));
        mainLightData.color *= aoFactor.directAmbientOcclusion;
        surface.occlusion = min(surface.occlusion, aoFactor.indirectAmbientOcclusion);
    #endif
    
    BRDF_CelPBR brdf = GetBRDF(surface, mainLightData, mainTempData, surface.alpha);
    GI_CelPBR gi = GetGI(input, brdf, surface, mainTempData);
    // return float4(mainTempData.kkTSinH.rrr, surface.alpha);
    // return float4(surface.normal * 0.5 + 0.5, surface.alpha);

    // compile error with out gi.bakeGI parameter
    // MixRealtimeAndBakedGI(ConvertToUnityLight(mainLightData), surface.normal, gi.bakedGI);
    #if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
        gi.bakedGI = SubtractDirectMainLightFromLightmap(ConvertToUnityLight(mainLightData), surface.normal, gi.bakedGI);
    #endif
    
    // gi.color = gi.color.bbb;
    // return float4(gi.color, surface.color.r);
    real3 color = gi.color;
    // color = 0;
    color += surface.emission;
    real3 celColor = GetCelLighting(mainLightData, GetCelData(surface, brdf, mainLightData, mainTempData));
    real3 pbrColor = GetLighting(mainLightData, surface, brdf, mainTempData);

    // #if defined(CEL_SHADING)
        // color += GetCelLighting(mainLightData, GetCelData(surface, brdf, mainLightData, mainTempData));
    // #else
        // color += GetLighting(mainLightData, surface, brdf, mainTempData);
        // color += GetLighting_Old(mainLightData, surface, brdf, mainTempData);
    // #endif

    int otherLightCount = GetOtherLightCount();
    
    for (int i = 0; i < otherLightCount; ++i)
    {
        LightData_CelPBR lightData = GetOtherLightData(input, i);
        TempData_CelPBR tempData = GetTempData(input, surface, lightData);
        BRDF_CelPBR lightBRDF = GetBRDF(surface, lightData, tempData, surface.alpha);

        celColor += GetCelLighting(lightData, GetCelData(surface, lightBRDF, lightData, tempData));
        pbrColor += GetLighting(lightData, surface, lightBRDF, tempData);
        // pbrColor += GetLighting(lightData, surface, brdf, tempData);

        // #if defined(CEL_SHADING)
        //     color += GetCelLighting(lightData, GetCelData(surface, brdf, lightData, tempData));
        // #else
        //     color += GetLighting(lightData, surface, brdf, tempData);
        // // color += GetLighting_Old(mainLightData, surface, brdf, mainTempData);
        // #endif
    }

    real3 resultColor = lerp(celColor, pbrColor, surface.celPBR) + color;
    // resultColor = resultColor > 0.05 ? 1 : 0;
    return real4(resultColor, surface.alpha);
}

#endif