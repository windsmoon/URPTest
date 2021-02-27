#ifndef CEL_PBR_GI_INCLUDED
#define CEL_PBR_GI_INCLUDED

struct GI_CelPBR
{
    real3 color;
    real3 bakedGI;
};

GI_CelPBR GetGI(Varyings input, BRDF_CelPBR brdf, Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    GI_CelPBR gi;
    gi.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, surface.normal);

    // compile error with out gi.bakeGI parameter
    // MixRealtimeAndBakedGI(ConvertToUnityLight(lightData), surface.normal, gi.bakedGI);

    #if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
        gi.bakedGI = SubtractDirectMainLightFromLightmap(ConvertToUnityLight(mainLightData), surface.normal, gi.bakedGI);
    #endif
    
    real3 indirectDiffuse = surface.occlusion * gi.bakedGI;
    real3 indirectSpecular = GlossyEnvironmentReflection(tempData.viewReflectionDirection, brdf.perceptualRoughness, surface.occlusion);
    real fresnelTerm = Pow4(1.0 - tempData.nDotV);
    BRDFData brdfData = ConvertToBRDFData(brdf);

    #if defined(KK_HIGHLIGHT)
        real3 giColor = indirectDiffuse * brdf.diffuse + indirectSpecular * brdf.specular;
    #else
        real3 giColor = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    #endif

    gi.color = giColor;

    #if defined(DEBUG_DISABLE_GI)
        gi.color = 0;
    #endif
    
    return gi;
}

#endif