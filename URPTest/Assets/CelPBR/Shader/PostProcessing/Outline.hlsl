#ifndef CEL_PBR_POST_PROCESSING_OUTLINE_INCLUDED
#define CEL_PBR_POST_PROCESSING_OUTLINE_INCLUDED

#include "Common.hlsl"

TEXTURE2D(_PostProcessing_ColorTexture);
TEXTURE2D(_PostProcessing_OutlineTexture);
TEXTURE2D(_SSR_ObjectDataTexture);

SAMPLER(sampler_PostProcessing_ColorTexture);

real3 _Outline_Color;
real4 _PostProcessing_ColorTexture_TexelSize;

struct Varyings_Outline
{
    float4 positionCS : SV_POSITION;
    float2 uv[9] : VAR_UV;
};


real GetLuminance(real3 color)
{
    return dot(color, real3(0.2125, 0.7154, 0.0721));
}

Varyings Vertex_Outline(Attributes input)
{
    Varyings output;
    
    // Note: The pass is setup with a mesh already in CS
    // Therefore, we can just output vertex position
    output.positionCS = float4(input.positionHCS.xyz, 1.0);
    output.uv = input.uv;

    #if UNITY_UV_STARTS_AT_TOP
        output.uv[0] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,-1));
        output.uv[1] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,-1));
        output.uv[2] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,-1));
        output.uv[3] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,0));
        output.uv[4] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,0)); //  等同于 o.uv[4]=v.uv; 即原始像素所在坐标点
        output.uv[5] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,0));
        output.uv[6] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,1));
        output.uv[7] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,1));
        output.uv[8] = 1 - (input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,1));
    #endif

    // output.uv = input.uv;
    return output;
}

real4 Fragment_Outline(Varyings input) : SV_TARGET
{
    const half Gx[9] = {-1,0,1,
        -2,0,2,
        -1,0,1};

    const half Gy[9] = {-1,-2,-1,
        0,0,0,
        1,2,1};
    return 1;
}

#endif