#ifndef CELPBR_WATER_WATERINPUT_INCLUDED
#define CELPBR_WATER_WATERINPUT_INCLUDED

TEXTURE2D(_DisplaceRT);
TEXTURE2D(_NormalRT);
TEXTURE2D(_BubbleRT);
TEXTURE2D(_TangentRT);
TEXTURE2D(_BiangentRT);
TEXTURE2D(_WaterDepthMap);

SAMPLER(sampler_DisplaceRT);
SAMPLER(sampler_NormalRT);
SAMPLER(sampler_WaterDepthMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(real4, _NormalMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(real4, _ShallowWaterColor)
    UNITY_DEFINE_INSTANCED_PROP(real4, _DeepWaterColor)
    UNITY_DEFINE_INSTANCED_PROP(real4, _WaterDepthRange01)
    UNITY_DEFINE_INSTANCED_PROP(real4, _BubbleColor)
    UNITY_DEFINE_INSTANCED_PROP(real4, _Specular)
    UNITY_DEFINE_INSTANCED_PROP(real, _FresnelScale)
    UNITY_DEFINE_INSTANCED_PROP(real, _Glossy)
    UNITY_DEFINE_INSTANCED_PROP(real, _WaterDeepScale)
    UNITY_DEFINE_INSTANCED_PROP(real4, _Tilling)
    UNITY_DEFINE_INSTANCED_PROP(real, _SSSScale)
    UNITY_DEFINE_INSTANCED_PROP(real, _SSSPower)
    UNITY_DEFINE_INSTANCED_PROP(real, _SSSAmbient)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define INPUT_PROP(name) UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, name)

// #define TRANSFORM_UV(tex, name) ((tex.xy) * INPUT_PROP(name##_ST).xy + INPUT_PROP(name##_ST).zw)

real3 GetDisplacement(float2 uv)
{
    return SAMPLE_TEXTURE2D_LOD(_DisplaceRT, sampler_DisplaceRT, uv, 0).xyz;
}

real3 GetNormalWS(float2 uv)
{
    real3 normalOS = SAMPLE_TEXTURE2D(_NormalRT, sampler_NormalRT, uv).xyz;
    return TransformObjectToWorldNormal(normalOS, false);
}

real3 GetBubbleColor()
{
    return INPUT_PROP(_BubbleColor);
}

real GetBubbleStrength(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BubbleRT, sampler_NormalRT, uv).x;
}

real3 GetWaterColor(float deep)
{
    return lerp(INPUT_PROP(_ShallowWaterColor), INPUT_PROP(_DeepWaterColor), deep).rgb;
}

real3 GetSpecular()
{
    return INPUT_PROP(_Specular).rgb;
}

real GetFresnelScale()
{
    return INPUT_PROP(_FresnelScale);
}

real GetGlossy()
{
    return INPUT_PROP(_Glossy);
}

real GetMaxWaterDepth()
{
    return INPUT_PROP(_WaterDeepScale);
}

real GetWaterDepth(float2 uv, float y)
{
    // real2 depthRange01 = INPUT_PROP(_WaterDepthRange01);
    float deep = INPUT_PROP(_WaterDeepScale) * SAMPLE_TEXTURE2D(_WaterDepthMap, sampler_WaterDepthMap, uv).x;;
    // deep = smoothstep(depthRange01.x, depthRange01.y, deep)
    return deep + y;
}

real2 Tilling(float2 uv)
{
    return uv * INPUT_PROP(_Tilling).xy;
}

real GetSSSScale()
{
    return INPUT_PROP(_SSSScale);
}

real GetSSSPower()
{
    return INPUT_PROP(_SSSPower);
}

real GetSSSAmbient()
{
    return INPUT_PROP(_SSSAmbient);
}

#endif