#ifndef CEL_PRB_WATER_PASS_INCLUDED
#define CEL_PRB_WATER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float2 lightmapUV : TEXCOORD1; // todo
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float2 uv : VAR_UV;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1); // todo
};

#include "WaterInput.hlsl"

Varyings FFTWaterVert(Attributes input)
{
    Varyings output;

    input.positionOS.xyz += GetDisplacement(input.uv);
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);

    output.uv = input.uv;
    // OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV)
    return output;
}

real4 FFTWaterFrag(Varyings input) : SV_TARGET
{
    return 1;
}


#endif