#ifndef CEL_PBR_POST_PROCESSING_OUTLINE_INCLUDED
#define CEL_PBR_POST_PROCESSING_OUTLINE_INCLUDED

#include "Common.hlsl"

real3 _Outline_Color;

struct Varyings_Outline
{
    float4 positionCS : SV_POSITION;
    float2 uv[9] : VAR_UV;
};

real3 GetLuminance(real3 color)
{
    return dot(color, real3(0.2125, 0.7154, 0.0721));
}

Varyings_Outline Vertex_Outline(Attributes input)
{
    Varyings_Outline output;
    
    // Note: The pass is setup with a mesh already in CS
    // Therefore, we can just output vertex position
    output.positionCS = float4(input.positionHCS.xyz, 1.0);
    // float2 uvs[9];
    // output.uv = uvs;
    // output.uv = input.uv;
    output.uv[0] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,-1);
    output.uv[1] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,-1);
    output.uv[2] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,-1);
    output.uv[3] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,0);
    output.uv[4] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,0);
    output.uv[5] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,0);
    output.uv[6] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,1);
    output.uv[7] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,1);
    output.uv[8] = input.uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,1);

    #if UNITY_UV_STARTS_AT_TOP
        output.uv[0].y = 1 - output.uv[0].y;
        output.uv[1].y = 1 - output.uv[1].y;
        output.uv[2].y = 1 - output.uv[2].y;
        output.uv[3].y = 1 - output.uv[3].y;
        output.uv[4].y = 1 - output.uv[4].y;
        output.uv[5].y = 1 - output.uv[5].y;
        output.uv[6].y = 1 - output.uv[6].y;
        output.uv[7].y = 1 - output.uv[7].y;
        output.uv[8].y = 1 - output.uv[8].y;
    #endif

    // output.uv = input.uv;
    return output;
}

real Sobel(float2 uv)
{
    float2 uvs[9];
    uvs[0] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,-1);
    uvs[1] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,-1);
    uvs[2] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,-1);
    uvs[3] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,0);
    uvs[4] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,0);
    uvs[5] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,0);
    uvs[6] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(-1,1);
    uvs[7] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(0,1);
    uvs[8] = uv + _PostProcessing_ColorTexture_TexelSize.xy*half2(1,1);

    // #if UNITY_UV_STARTS_AT_TOP
    //     uvs[0].y = 1 - uvs[0].y;
    //     uvs[1].y = 1 - uvs[1].y;
    //     uvs[2].y = 1 - uvs[2].y;
    //     uvs[3].y = 1 - uvs[3].y;
    //     uvs[4].y = 1 - uvs[4].y;
    //     uvs[5].y = 1 - uvs[5].y;
    //     uvs[6].y = 1 - uvs[6].y;
    //     uvs[7].y = 1 - uvs[7].y;
    //     uvs[8].y = 1 - uvs[8].y;
    // #endif
    
    // todo it is wrong
    const half Gx[9] =
        {
            -1,0,1,
            -2,0,2,
            -1,0,1
        };

    const half Gy[9] =
        {
            -1,-2,-1,
            0,0,0,
            1,2,1
        };

    real3 texcol;
    // real depth = 0;
    half edgeX=0;
    half edgeY=0;

    for (int it=0;it<9;it++)
    {
        texcol = GetLuminance(GetCameraColor(uvs[it]));
        edgeX += texcol * Gx[it];
        edgeY += texcol * Gy[it];

        // depth += GetRawDepth(input.uv[it]);
        // edgeX += depth * Gx[it];
        // edgeY += depth * Gy[it];
    }

    float edge = sqrt(edgeX * edgeX + edgeY * edgeY);
    // float edge = 1-(abs(edgeX)+abs(edgeY));
    return edge;
}

real4 Fragment_Outline(Varyings_Outline input) : SV_TARGET
{
    // real edge = Sobel(input);
    // real outlineColor = edge * GetCameraColor(input.uv[4]);
    return 1;
}

#endif