#ifndef CEL_PBR_SSR_OBJECT_PASS_INCLUDED
#define CEL_PBR_SSR_OBJECT_PASS_INCLUDED

// todo !!!!
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 baseUV : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 baseUV : VAR_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#include "Input.hlsl"
#include "Light.hlsl"
#include "Surface.hlsl"
#include "TempData.hlsl"
#include "BRDF.hlsl"
#include "GI.hlsl"

Varyings OutlineVert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.baseUV = TRANSFORM_UV(input.baseUV, _BaseMap);
    return output;
}

real4 OutlineFrag(Varyings input) : SV_TARGET
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
    return float4(gi.specular, 1);
}


#endif