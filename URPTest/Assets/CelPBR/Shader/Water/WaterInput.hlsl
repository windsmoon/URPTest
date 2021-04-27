#ifndef CELPBR_WATER_WATERINPUT_INCLUDED
#define CELPBR_WATER_WATERINPUT_INCLUDED

TEXTURE2D(_DisplaceRT);
TEXTURE2D(_NormalRT);
TEXTURE2D(_BubbleRT);

SAMPLER(sampler_DisplaceRT);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(real, _CelPBR)
    UNITY_DEFINE_INSTANCED_PROP(real, _PerspectiveCorrectionScale)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define INPUT_PROP(name) UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, name)

#define TRANSFORM_UV(tex, name) ((tex.xy) * INPUT_PROP(name##_ST).xy + INPUT_PROP(name##_ST).zw)

real3 GetDisplacement(float2 uv)
{
    return SAMPLE_TEXTURE2D_LOD(_DisplaceRT, sampler_DisplaceRT, uv, 0).xyz;
}

#endif