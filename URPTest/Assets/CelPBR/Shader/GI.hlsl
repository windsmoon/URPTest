#ifndef CEL_PBR_GI_INCLUDED
#define CEL_PBR_GI_INCLUDED

struct GI_CelPBR
{
    real3 color;
};

GI_CelPBR GetGI(Varyings input, BRDF_CelPBR brdf, Surface_CelPBR surface, TempData_CelPBR tempData)
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

    real3 bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, surface.normal);
    GI_CelPBR gi;
    real3 indirectDiffuse = surface.occlusion * bakedGI;
    real3 indirectSpecular = GlossyEnvironmentReflection(tempData.viewReflectionDirection, brdf.perceptualRoughness, surface.occlusion);
    real fresnelTerm = Pow4(1.0 - tempData.nDotV);
    BRDFData brdfData = ConvertToBRDFData(brdf);
    real3 giColor = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    gi.color = giColor;
    return gi;
}

#endif