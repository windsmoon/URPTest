#ifndef CE_PBR_INPUT
#define CE_PBR_INPUT

TEXTURE2D(_BaseMap);
TEXTURE2D(_NormalMap);
TEXTURE2D(_MaskMap);
TEXTURE2D(_OcclusionMap);
TEXTURE2D(_EmissionMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(real, _Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(real, _NormalScale)
    UNITY_DEFINE_INSTANCED_PROP(half, _MetallicScale)
    UNITY_DEFINE_INSTANCED_PROP(half, _SmoothnessScale)
    UNITY_DEFINE_INSTANCED_PROP(real, _OcclusionScale)
    UNITY_DEFINE_INSTANCED_PROP(real4, _EmissionColor)
    UNITY_DEFINE_INSTANCED_PROP(real4, _OutlineColor)
    UNITY_DEFINE_INSTANCED_PROP(real, _OutlineWidth)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define INPUT_PROP(name) UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, name)

half4 GetBaseColor(Varyings input)
{
    real4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);
    baseColor *= INPUT_PROP(_BaseColor);

    #if defined(_ALPHATEST_ON)
        clip(baseColor.a - INPUT_PROP(_Cutoff));
    #endif

    return baseColor;
}

real4 GetOutline(Varyings input)
{
    return real4(INPUT_PROP(_OutlineColor).rgb, INPUT_PROP(_OutlineWidth));
}

half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    return UnpackNormalScale(n, scale);
}

float3 GetNormalTS(Varyings input)
{
    // return input.normalWS;
    // float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.baseUV);

    // float3 normalTS = SampleNormal(input.normalUV, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), INPUT_PROP(_NormalScale));
    float4 normalTS = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, input.baseUV);
    normalTS.xyz = UnpackNormalScale(normalTS, INPUT_PROP(_NormalScale));
    return normalTS.xyz;
}

half GetMetallic(Varyings input)
{
    half metallic = SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, input.baseUV).r;
    metallic *= INPUT_PROP(_MetallicScale);
    return metallic;
}

half GetSmoothness(Varyings input)
{
    half smoothness = SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, input.baseUV).a;
    smoothness *= INPUT_PROP(_SmoothnessScale);
    return smoothness;
}

half GetOcclusion(Varyings input)
{
    half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_BaseMap, input.baseUV).g;

    // LerpWhiteTo(occlusion, INPUT_PROP(_OcclusionScale));
    // equals
    return lerp(1, occlusion, INPUT_PROP(_OcclusionScale));
}

half3 GetEmission(Varyings input)
{
    half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_BaseMap, input.baseUV).rgb;
    emission *= INPUT_PROP(_EmissionColor).rgb;
    return emission;
}


#endif