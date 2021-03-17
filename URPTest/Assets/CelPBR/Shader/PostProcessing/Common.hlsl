#ifndef CEL_PBR_POSTPROCESSING_COMMON_INCLUDED
#define CEL_PBR_POSTPROCESSING_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"

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

// ordinary projectin camera
float3 ReconstructViewPos(float2 uv, float viewZ)
{
    float2 p11_22 = 1 / float2(unity_CameraProjection._11, unity_CameraProjection._22);
    // 13_23 should be 0 in most cases
    float2 p13_23 = float2(unity_CameraProjection._13, unity_CameraProjection._23);

    // todo : this code may be wrong, it should be care for the different api
    // #if defined(_ORTHOGRAPHIC)
    // float3 viewPos = float3(((uv.xy * 2.0 - 1.0 - p13_31) * p11_22), viewZ);
    // #else
    // float3 viewPos = float3(viewZ * ((uv.xy * 2.0 - 1.0 - p13_31) * p11_22), viewZ);
    // #endif
    
    #if defined(_ORTHOGRAPHIC)
        float3 viewPos = float3(((uv.xy * 2.0 - 1.0) * p11_22), viewZ);
    #else
        float3 viewPos = float3(viewZ * ((uv.xy * 2.0 - 1.0) * p11_22), viewZ);
    #endif

    return viewPos;
}

float3 GetPosVS(float2 screenUV)
{
    float rawDepth = SampleSceneDepth(screenUV.xy).r;
    float viewZ = RawToEyeDepth(rawDepth);
    return ReconstructViewPos(screenUV, viewZ);
}

#endif