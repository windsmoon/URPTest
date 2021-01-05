#ifndef CEL_PBR_META_PASS
#define CEL_PBR_META_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float2 uv2          : TEXCOORD2;
    #ifdef _TANGENT_TO_WORLD
    float4 tangentOS     : TANGENT;
    #endif
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 baseUV           : TEXCOORD0;
};

#include "Input.hlsl"


Varyings MetaVertexMeta(Attributes input)
{
    Varyings output;
    output.positionCS = MetaVertexPosition(input.positionOS, input.uv1, input.uv2, unity_LightmapST, unity_DynamicLightmapST);
    output.baseUV = TRANSFORM_TEX(input.uv0, _BaseMap);
    return output;
}

float4 MetaFragmentMeta(Varyings input) : SV_Target
{
    // InitializeStandardLitSurfaceData(input.uv, surfaceData);

    BRDFData brdfData;
    real4 baseColor = GetBaseColor(input);
    InitializeBRDFData(baseColor.rgb, GetMetallic(input), 0, GetSmoothness(input), baseColor.a, brdfData);

    MetaInput metaInput;
    metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.SpecularColor = 0;
    metaInput.Emission = GetEmission(input);
    return MetaFragment(metaInput);
}


#endif