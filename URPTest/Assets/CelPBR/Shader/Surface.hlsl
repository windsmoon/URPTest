#ifndef SURFACE_CEL_PBR
#define SURFACE_CEL_PBR

struct Surface_CelPBR
{
    real celPBR;
    
    real3 color;
    real alpha;
    real3 pos;
    real3 normal;
    real3 tangent;
    real3 bitangent;
    real metallic;
    real smoothness;
    real occlusion;
    real3 emission;
    real sssMask;
    real curvature;
    real thickness;
    real kkHighlightOffset;

    // cel shading
    real3 celShadeColor;
    real3 celShadowColor;
    real celShadowRange;
    real celSpecularThreshold;
    real celSpecularGlossiness;
    real3 rimColor;
    real2 rimRange;
};

float3 GetWorldNormal(Varyings input, float3 normalTS)
{
    float3 normal = mul(normalTS.xyz, GetTBN(input.normalWS.xyz, input.tangentWS.xyz, input.bitangentWS.xyz));
    normal = normalize(normal);
    return normal;
}

Surface_CelPBR GetSurface(Varyings input)
{
    Surface_CelPBR surface;
    surface.celPBR = GetCelPBR();
    surface.color = GetBaseColor(input.baseUV).rgb;
    surface.alpha = GetBaseColor(input.baseUV).a;
    surface.pos = input.positionWS;
    surface.normal = GetWorldNormal(input, GetNormalTS(input.baseUV));
    surface.tangent = input.tangentWS;
    surface.bitangent = input.bitangentWS;
    surface.metallic = GetMetallic(input.baseUV);
    surface.smoothness = GetSmoothness(input.baseUV);
    surface.occlusion = GetOcclusion(input.baseUV);
    surface.emission = GetEmission(input.baseUV);
    surface.sssMask = GetSSSMask(input.baseUV);
    surface.curvature = GetSSSLutCurvatureScale() * length(fwidth(surface.normal)) / length(fwidth(surface.pos));
    surface.thickness = GetThickness(input.baseUV);
    surface.kkHighlightOffset = GetKKHighlightOffset(input.kkHighlightUV) + GetKKHighlightOffset();

    // cel shading
    surface.celShadeColor = GetCelShadeColor();
    surface.celShadowColor = GetCelShadowColor();
    surface.celShadowRange = GetCelShadowRange();
    surface.celSpecularThreshold = GetCelSpecularThreshold();
    surface.celSpecularGlossiness = GetCelSpecularGlossiness();
    surface.rimColor = GetRimColor();
    surface.rimRange = GetRimRange();
    return surface;
}

#endif