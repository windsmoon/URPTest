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
    real3 kkHighlightAnisoDirection;

    // cel shading
    // real outlineThreshold;
    real3 celShadeColor;
    real3 celShadowColor;
    real celSmoothness;
    real celThreshold;
    real celShadowRange;
    real celSpecularThreshold;
    real celSpecularGlossiness;
    real rimThreshold;
    real rimSmoothness;
    real3 rimColor;
};

float3 GetWorldNormal(Varyings input, float3 normalTS)
{
    float3 normal = mul(normalTS.xyz, GetTBN(input.normalWS.xyz, input.tangentWS.xyz, input.bitangentWS.xyz));
    normal = normalize(normal);
    return normal;
}

real3 GetWorldKKGHighlightAnisoDirection(Varyings input)
{
    real3 anisoDireciton = real3(GetKKHighlightAnisoDirection(input.baseUV).rg, 0);
    anisoDireciton = mul(anisoDireciton, GetTBN(input.normalWS.xyz, input.tangentWS.xyz, input.bitangentWS.xyz));
    // anisoDireciton = input.tangentWS.xyz * anisoDireciton.x + input.bitangentWS.xyz * anisoDireciton.y;

    anisoDireciton = normalize(anisoDireciton);
    return anisoDireciton;
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
    surface.kkHighlightAnisoDirection = GetWorldKKGHighlightAnisoDirection(input);

    // cel shading
    // surface.outlineThreshold = GetOutlineThreshold();
    surface.celShadeColor = GetCelShadeColor();
    surface.celShadowColor = GetCelShadowColor();
    surface.celThreshold = GetCelThreshold();
    surface.celSmoothness = GetCelSmoothness();
    surface.celShadowRange = GetCelShadowRange();
    surface.celSpecularThreshold = GetCelSpecularThreshold();
    surface.celSpecularGlossiness = GetCelSpecularGlossiness();
    surface.rimThreshold = GetRimThreshold();
    surface.rimSmoothness = GetRimSmoothness();
    surface.rimColor = GetRimColor();
    return surface;
}

#endif