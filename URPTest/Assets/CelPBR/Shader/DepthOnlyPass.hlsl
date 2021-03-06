#ifndef CEL_PBR_DEPTH_ONLY_PASS
#define CEL_PBR_DEPTH_ONLY_PASS

#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// the vertex properties is come form unity urp DepthOnlyPass
struct Attributes
{
    float4 position     : POSITION;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 baseUV           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#include "Input.hlsl"

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.baseUV = TRANSFORM_UV(input.texcoord, _BaseMap);
    output.positionCS = TransformObjectToHClip(input.position.xyz);
    return output;
}

real4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    real4 baseColor = GetBaseColor(input.baseUV);
    clip(baseColor.a - GetCutoff());
    // Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    return 0;
}
#endif


#endif