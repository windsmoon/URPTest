#ifndef CEL_PBR_BRDF
#define CEL_PBR_BRDF

struct BRDF_CelPBR
{
    half3 diffuse;
    half3 specular;
};

BRDF_CelPBR GetBRDF(Surface_CelPBR surface)
{
    BRDF_CelPBR brdf;
    brdf.diffuse = surface.color;
    brdf.specular = surface.color;
    return brdf;
}

#endif