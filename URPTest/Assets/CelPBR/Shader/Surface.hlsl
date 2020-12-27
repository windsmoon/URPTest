#ifndef SURFACE_CEL_PBR
#define SURFACE_CEL_PBR

struct Surface_CelPBR
{
    half3 color;
    float3 pos;
    float3 normal;
    float3 viewDirection;
};

Surface_CelPBR GetSurface(Varyings input)
{
    Surface_CelPBR surface;
    surface.color = GetBaseColor(input).xyz;
    surface.pos = input.positionWS;
    surface.normal = GetWorldNormal(input);
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
    return surface;
}

#endif