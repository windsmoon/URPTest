#ifndef SURFACE_CEL_PBR
#define SURFACE_CEL_PBR

struct Surface_CelPBR
{
    real3 color;
    real3 pos;
    real3 normal;
    real metallic;
    real smoothness;
    real occlusion;
    // real perceptualRoughness;
    // real roughness;
    // real roughness2;
    // real occlusion;
    // real3 viewDirection;
    // real nDotV;
    // real3 viewReflectionDirection;
    // real oneMinusReflectivity;
    // real reflectivity;
    // real grazingTerm;
    // // We save some light invariant BRDF terms so we don't have to recompute
    // // them in the light loop. Take a look at DirectBRDF function for detailed explaination.
    // real normalizationTerm;     // roughness * 4.0 + 2.0
    // real roughness2MinusOne;    // roughness^2 - 1.0
};

Surface_CelPBR GetSurface(Varyings input)
{
    Surface_CelPBR surface;
    surface.color = GetBaseColor(input).rgb;
    surface.pos = input.positionWS;
    surface.normal = GetWorldNormal(input);
    surface.metallic = GetMetallic(input);
    surface.smoothness = GetSmoothness(input);
    surface.occlusion = GetOcclusion(input);
    return surface;
}

#endif