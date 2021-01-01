#ifndef CEL_PBR_GI_INCLUDED
#define CEL_PBR_GI_INCLUDED

struct GI_CelPBR
{
    half3 diffuseColor;
    half3 specularColor;
};

GI_CelPBR GetGI(BRDF_CelPBR brdf, Surface_CelPBR surface, TempData_CelPBR tempData)
{
    // GI_CelPBR gi;
    // float diffuse = surface.occlusion; // todo multiply the baked gi
    // float fresnelTerm = Pow4(1.0 - tempData.nDotV);
    // float specular = GlossyEnvironmentReflection(tempData.viewReflectionDirection, brdf.perceptualRoughness, surface.occlusion);
    //
    // // from EnvironmentBRDF(...)
    // gi.diffuseColor = diffuse * brdf.diffuse;
    //
    // // from = EnvironmentBRDFSpecular
    // float surfaceReduction = 1.0 / (pow(brdf.roughness, 2) + 1.0);
    // half oneMinusReflectivity = OneMinusReflectivityMetallic(surface.metallic);
    // half reflectivity = 1.0 - oneMinusReflectivity;
    // gi.specularColor = specular * surfaceReduction * lerp(brdf.specular, saturate(surface.smoothness + reflectivity), fresnelTerm);
    // return gi;

    GI_CelPBR gi;
    gi.diffuseColor = 0;
    gi.specularColor = 0;
    return gi;
}

#endif