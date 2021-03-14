#ifndef CEL_PBR_POSTPROCESSING_COMMON_INCLUDED
#define CEL_PBR_POSTPROCESSING_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct Attributes
{
    float4 positionHCS : POSITION;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : VAR_UV;
};

Varyings Vert(Attributes input)
{
    Varyings output;
    
    // Note: The pass is setup with a mesh already in CS
    // Therefore, we can just output vertex position
    output.positionCS = float4(input.positionHCS.xyz, 1.0);

    #if UNITY_UV_STARTS_AT_TOP
        output.positionCS.y *= -1;
    #endif

    output.uv = input.uv;
    return output;
}

#endif