#ifndef CEL_PBR_GI_INCLUDED
#define CEL_PBR_GI_INCLUDED

struct GI_CelPBR
{
    half3 diffuseColor;
    half3 specularColor;
};

GI_CelPBR GetGI(Surface_CelPBR surface, BRDF_CelPBR brdf, TempData_CelPBR tempData)
{
    // half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    // half NoV = saturate(dot(normalWS, viewDirectionWS));
    // half fresnelTerm = Pow4(1.0 - NoV);
    //
    // half3 indirectDiffuse = bakedGI * occlusion;
    // half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);
    //
    // half3 color = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    //

    GI_CelPBR gi;
    float diffuse = surface.occlusion; // todo multiply the baked gi
    float fresnelTerm = Pow4(1.0 - tempData.nDotV);
    float specular = GlossyEnvironmentReflection(tempData.viewReflectionDirection, surface.perceptualRoughness, surface.occlusion);

    // from EnvironmentBRDF(...)
    gi.diffuseColor = diffuse * brdf.diffuse;

    // from = EnvironmentBRDFSpecular
    float surfaceReduction = 1.0 / (pow(surface.roughness, 2) + 1.0);
    half oneMinusReflectivity = OneMinusReflectivityMetallic(surface.metallic);
    half reflectivity = 1.0 - oneMinusReflectivity;
    gi.specularColor = specular * surfaceReduction * lerp(brdf.specular, saturate(surface.smoothness + reflectivity), fresnelTerm);
    return gi;
}

#endif