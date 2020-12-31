#ifndef SURFACE_CEL_PBR
#define SURFACE_CEL_PBR

struct Surface_CelPBR
{
    real3 color;
    real3 pos;
    real3 normal;
    real metallic;
    real smoothness;
    real roughness;
    real perceptualRoughness;
    real occlusion;
    real3 viewDirection;
    real nDotV;
};

Surface_CelPBR GetSurface(Varyings input)
{
    Surface_CelPBR surface;
    surface.color = GetBaseColor(input).xyz;
    surface.pos = input.positionWS;
    surface.normal = GetWorldNormal(input);
    surface.metallic = GetMetallic(input);
    surface.smoothness = GetSmoothness(input);
    surface.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness); // ?? this is come from disney, i do not know why
    surface.roughness = max(PerceptualRoughnessToRoughness(surface.perceptualRoughness), HALF_MIN_SQRT);
    surface.occlusion = GetOcclusion(input);
    surface.viewDirection = SafeNormalize(_WorldSpaceCameraPos - input.positionWS);
    surface.nDotV = max(dot(surface.normal, surface.viewDirection), 0.0);
    return surface;
}

#endif