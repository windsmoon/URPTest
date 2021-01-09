#ifndef CEL_PBR_OUTLINE_PASS
#define CEL_PBR_OUTLINE_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#include "Input.hlsl"

Varyings OutlineVert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    output.positionCS = TransformObjectToHClip(input.positionOS);

    // #if defined(CEL_SHADING)
        float3 outlineDirection = TransformObjectToWorldNormal(input.normalOS);
        outlineDirection = TransformWorldToViewDir(outlineDirection);
        float2 ndcNormal = normalize(TransformWViewToHClip(outlineDirection).xy) * output.positionCS.w;
        float ratio = _ScreenParams.y / _ScreenParams.x;
        ndcNormal.x *= ratio;
        output.positionCS.xy += 0.01 * GetOutline().a * ndcNormal;
    // #endif

    return output;
}

real4 OutlineFrag(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    return GetOutline();
}

#endif