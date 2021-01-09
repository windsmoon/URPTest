#ifndef SURFACE_CEL_PBR
#define SURFACE_CEL_PBR

struct Surface_CelPBR
{
    real3 color;
    real alpha;
    real3 pos;
    real3 normal;
    real metallic;
    real smoothness;
    real occlusion;
    real3 emission;

    // cel shading
    real3 celShadeColor;
    real3 celShadowColor;
    real celShadowRange;
    real3 rimColor;
    real2 rimRange;
};

float3 GetWorldNormal(Varyings input, float3 normalTS)
{
    float3 normalWS = SafeNormalize(input.normalWS.xyz);
    float3 tangentWS = SafeNormalize(input.tangentWS.xyz);
    float3 bitangentWS = SafeNormalize(input.bitangentWS.xyz);
    // float3 normal = TransformTangentToWorld(normalTS, half3x3(tangentWS, bitangentWS, normalWS));
    float3 normal = mul(normalTS.xyz, float3x3(tangentWS, bitangentWS, normalWS));
    normal = normalize(normal);
    return normal;
}

Surface_CelPBR GetSurface(Varyings input)
{
    Surface_CelPBR surface;
    surface.color = GetBaseColor(input.baseUV).rgb;
    surface.alpha = GetBaseColor(input.baseUV).a;
    surface.pos = input.positionWS;
    surface.normal = GetWorldNormal(input, GetNormalTS(input.baseUV));
    surface.metallic = GetMetallic(input.baseUV);
    surface.smoothness = GetSmoothness(input.baseUV);
    surface.occlusion = GetOcclusion(input.baseUV);
    surface.emission = GetEmission(input.baseUV);

    // cel shading
    surface.celShadeColor = GetCelShadeColor();
    surface.celShadowColor = GetCelShadowColor();
    surface.celShadowRange = GetCelShadowRange();
    surface.rimColor = GetRimColor();
    surface.rimRange = GetRimRange();
    return surface;
}

#endif