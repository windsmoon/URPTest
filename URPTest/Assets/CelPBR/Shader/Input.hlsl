#ifndef CE_PBR_INPUT
#define CE_PBR_INPUT

TEXTURE2D(_BaseMap);
TEXTURE2D(_NormalMap);
TEXTURE2D(_MaskMap);
TEXTURE2D(_OcclusionMap);
TEXTURE2D(_EmissionMap);
TEXTURE2D(_SSSMask);
TEXTURE2D(_SSSLut);
TEXTURE2D(_ThicknessMap);
TEXTURE2D(_KKHighlightOffsetMap);
TEXTURE2D(_KKHighlightAnisoMap);
TEXTURE2D(_HeightMap);
SAMPLER(sampler_BaseMap);
SAMPLER(sampler_SSSLut);
SAMPLER(sampler_KKHighlightOffsetMap);

TEXTURE2D(_RampMap);
// TEXTURE2D(_CelSpecularRamp);
SAMPLER(sampler_RampMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(real, _CelPBR)
    UNITY_DEFINE_INSTANCED_PROP(real, _PerspectiveCorrectionScale)

    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(real, _Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(real, _NormalScale)
    UNITY_DEFINE_INSTANCED_PROP(half, _MetallicScale)
    UNITY_DEFINE_INSTANCED_PROP(half, _SmoothnessScale)
    UNITY_DEFINE_INSTANCED_PROP(real, _OcclusionScale)
    UNITY_DEFINE_INSTANCED_PROP(real4, _EmissionColor)
    UNITY_DEFINE_INSTANCED_PROP(float4, _SSSLutOffset)
    UNITY_DEFINE_INSTANCED_PROP(real, _SSSPower)
    UNITY_DEFINE_INSTANCED_PROP(real, _SSSDistort)
    UNITY_DEFINE_INSTANCED_PROP(real, _ThicknessScale)
    UNITY_DEFINE_INSTANCED_PROP(real4, _KKHighlightOffsetMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(real4, _KKHighlightData)
    UNITY_DEFINE_INSTANCED_PROP(real, _ParallaxMappingType)
    UNITY_DEFINE_INSTANCED_PROP(real, _ParallaxScale)

    // cel shading
    UNITY_DEFINE_INSTANCED_PROP(real, _OutlineWidth)
    UNITY_DEFINE_INSTANCED_PROP(real4, _OutlineColor)
    UNITY_DEFINE_INSTANCED_PROP(real4, _CelShadeColor)
    UNITY_DEFINE_INSTANCED_PROP(real4, _CelShadowColor)
    UNITY_DEFINE_INSTANCED_PROP(real, _CelShadowRange)
    UNITY_DEFINE_INSTANCED_PROP(real, _CelSpecularThreshold)
    UNITY_DEFINE_INSTANCED_PROP(real, _CelSpecularGlossiness)
    UNITY_DEFINE_INSTANCED_PROP(real4, _RimColor)
    UNITY_DEFINE_INSTANCED_PROP(real4, _RimRange)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#define INPUT_PROP(name) UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, name)

#define TRANSFORM_UV(tex, name) ((tex.xy) * INPUT_PROP(name##_ST).xy + INPUT_PROP(name##_ST).zw)

real GetCelPBR()
{
    return INPUT_PROP(_CelPBR);
}

real GetPerspectiveCorrectionScale()
{
    return INPUT_PROP(_PerspectiveCorrectionScale) * 0.01;
}

half4 GetBaseColor(float2 uv)
{
    real4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    baseColor *= INPUT_PROP(_BaseColor);

    #if defined(_ALPHATEST_ON)
        clip(baseColor.a - INPUT_PROP(_Cutoff));
    #endif

    return baseColor;
}

real GetCutoff()
{
    return INPUT_PROP(_Cutoff);
}

half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    return UnpackNormalScale(n, scale);
}

float3 GetNormalTS(float2 uv)
{
    // return input.normalWS;
    // float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.baseUV);

    // float3 normalTS = SampleNormal(input.normalUV, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), INPUT_PROP(_NormalScale));
    float4 normalTS = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, uv);
    normalTS.xyz = UnpackNormalScale(normalTS, INPUT_PROP(_NormalScale));
    return normalTS.xyz;
}

half GetMetallic(float2 uv)
{
    half metallic = SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, uv).r;
    metallic *= INPUT_PROP(_MetallicScale);
    return metallic;
}

half GetSmoothness(float2 uv)
{
    half smoothness = SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, uv).a;
    smoothness *= INPUT_PROP(_SmoothnessScale);
    return smoothness;
}

half GetOcclusion(float2 uv)
{
    half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_BaseMap, uv).g;

    // LerpWhiteTo(occlusion, INPUT_PROP(_OcclusionScale));
    // equals
    return lerp(1, occlusion, INPUT_PROP(_OcclusionScale));
}

half3 GetEmission(float2 uv)
{
    half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_BaseMap, uv).rgb;
    emission *= INPUT_PROP(_EmissionColor).rgb;
    return emission;
}

real GetSSSMask(float2 uv)
{
    return SAMPLE_TEXTURE2D(_SSSMask, sampler_BaseMap, uv).r;
}

real3 GetSSSLut(float2 uv)
{
    return SAMPLE_TEXTURE2D(_SSSLut, sampler_SSSLut, uv).rgb;
}

float2 GetSSSLutOffset()
{
    return INPUT_PROP(_SSSLutOffset).xy;
}

float GetSSSLutCurvatureScale()
{
    return INPUT_PROP(_SSSLutOffset).z;
}

real GetSSSPower()
{
    return INPUT_PROP(_SSSPower);
}

real GetSSSDistort()
{
    return INPUT_PROP(_SSSDistort);
}

real GetThickness(float2 uv)
{
    return SAMPLE_TEXTURE2D(_ThicknessMap, sampler_BaseMap, uv).r * INPUT_PROP(_ThicknessScale);
}

real GetKKHighlightOffset(float2 uv)
{
    real offset = SAMPLE_TEXTURE2D(_KKHighlightOffsetMap, sampler_KKHighlightOffsetMap, uv).r * 2 - 1;
    real2 data = INPUT_PROP(_KKHighlightData);
    return offset * data.y; 
}

real2 GetKKHighlightAnisoDirection(float2 uv)
{
    return SAMPLE_TEXTURE2D(_KKHighlightAnisoMap, sampler_BaseMap, uv) * 2 - 1;
}

real GetKKHighlightOffset()
{
    return INPUT_PROP(_KKHighlightData).x;
}

real GetKKHighlightShiness()
{
    return INPUT_PROP(_KKHighlightData).z;
}

real GetKKHighlightUseTangent()
{
    return INPUT_PROP(_KKHighlightData).w;
}

real GetHeightMap(float2 uv)
{
    real height = SAMPLE_TEXTURE2D(_HeightMap, sampler_BaseMap, uv);

    #if defined(REVERT_HEIGHT)
        height = 1 - height;
    #endif
        
    return height;
}

real GetParallaxMappingType()
{
    return INPUT_PROP(_ParallaxMappingType);        
}

real GetParallaxScale()
{
    return INPUT_PROP(_ParallaxScale);
}

// cel shading

real4 GetOutline()
{
    return real4(INPUT_PROP(_OutlineColor).rgb, INPUT_PROP(_OutlineWidth));
}

float GetRamp(float rampUV)
{
    return SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampUV, 0.5)).r;
}

float3 GetCelShadeColor()
{
    return INPUT_PROP(_CelShadeColor).rgb;
}

float3 GetCelShadowColor()
{
    return INPUT_PROP(_CelShadowColor).rgb;
}

float GetCelShadowRange()
{
    return INPUT_PROP(_CelShadowRange);
}

real GetCelSpecularThreshold()
{
    // return SAMPLE_TEXTURE2D(_CelSpecularRamp, sampler_RampMap, float2(rampUV, 0.5)).r;
    return INPUT_PROP(_CelSpecularThreshold);
}

real GetCelSpecularGlossiness()
{
    return INPUT_PROP(_CelSpecularGlossiness);
}

float4 GetRimColor()
{
    return INPUT_PROP(_RimColor);
}

// x min, y max
float2 GetRimRange()
{
    return INPUT_PROP(_RimRange); 
}

#endif