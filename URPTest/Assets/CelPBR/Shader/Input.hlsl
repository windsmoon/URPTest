#ifndef INPUT_CEL_PBR
#define INPUT_CEL_PBR

TEXTURE2D(_BaseMap);
TEXTURE2D(_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _NormalScale)
    UNITY_DEFINE_INSTANCED_PROP(half, _MetallicScale)
    UNITY_DEFINE_INSTANCED_PROP(half, _SmoothnessScale)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define INPUT_PROP(name) UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, name)

half4 GetBaseColor(Varyings input)
{
    half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);
    baseColor *= INPUT_PROP(_BaseColor);
    return baseColor;
}

float3 GetWorldNormal(Varyings input)
{
    float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, input.baseUV);
    float3 normalTS = UnpackNormalScale(normalMap, INPUT_PROP(_NormalScale));
    float3 normalWS = SafeNormalize(input.normalWS.xyz);
    float3 tangentWS = SafeNormalize(input.tangentWS.xyz);
    float3 bitangentWS = cross(normalWS, tangentWS) * input.tangentWS.w;
    float3 normal = TransformTangentToWorld(normalTS, half3x3(tangentWS, bitangentWS, normalWS));
    return normal;
}

half GetMetallic(Varyings input)
{
    half metallic = SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, input.baseUV).r;
    metallic *= INPUT_PROP(_MetallicScale);
    return metallic;
}

half GetOcclusion(Varyings input)
{
    half occlusion = SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, input.baseUV).g;
    return occlusion;
}

half GetSmoothness(Varyings input)
{
    half smoothness = SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, input.baseUV).a;
    smoothness *= INPUT_PROP(_SmoothnessScale);
    return smoothness;
}

#endif