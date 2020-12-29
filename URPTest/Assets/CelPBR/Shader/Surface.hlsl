#ifndef SURFACE_CEL_PBR
#define SURFACE_CEL_PBR

struct Surface_CelPBR
{
    half3 color;
    float3 pos;
    float3 normal;
    half metallic;
    half smoothness;
    half roughness;
    float3 viewDirection;
    float3 halfDirection;
};

Surface_CelPBR GetSurface(Varyings input)
{
    Surface_CelPBR surface;
    surface.color = GetBaseColor(input).xyz;
    surface.pos = input.positionWS;
    surface.normal = GetWorldNormal(input);
    surface.metallic = GetMetallic(input);
    surface.smoothness = GetSmoothness(input);
    float roughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness); // ?? this is come from disney, i do not know why
    surface.roughness = PerceptualRoughnessToRoughness(roughness);
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
    return surface;
}

#endif