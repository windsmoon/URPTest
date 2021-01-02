﻿#ifndef CEL_PBR_GI_INCLUDED
#define CEL_PBR_GI_INCLUDED

struct GI_CelPBR
{
    real3 color;
    real3 bakedGI;
};

GI_CelPBR GetGI(Varyings input, BRDF_CelPBR brdf, Surface_CelPBR surface, TempData_CelPBR tempData)
{
    GI_CelPBR gi;
    gi.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, surface.normal);
    real3 indirectDiffuse = surface.occlusion * gi.bakedGI;
    real3 indirectSpecular = GlossyEnvironmentReflection(tempData.viewReflectionDirection, brdf.perceptualRoughness, surface.occlusion);
    real fresnelTerm = Pow4(1.0 - tempData.nDotV);
    BRDFData brdfData = ConvertToBRDFData(brdf);
    real3 giColor = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    gi.color = giColor;
    return gi;
}

#endif