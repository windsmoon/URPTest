#ifndef INPUT_CEL_PBR
#define INPUT_CEL_PBR

TEXTURE2D(_BaseMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _NormalScale)
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
    float3x3 tbnMatrix = {input.tangentWS, input.bitangentWS, input.normalWS};
    half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, input.baseUV);
    half3 normal = UnpackNormalScale(normalMap, INPUT_PROP(_NormalScale));
    normal = mul(normal, tbnMatrix);
    return normal;
}

#endif