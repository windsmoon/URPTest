#ifndef CEL_PBR_LIGHTING
#define CEL_PBR_LIGHTING


// float nDotL = saturate(dot(surface.normal, lightData.direction));
// float3 halfVector = normalize(tempData.viewDirection + lightData.direction);
// float nDotH = saturate(dot(surface.normal, halfVector));
// float powNDotH = pow(nDotH, 256);
// half3 diffuseColor = lightData.color * nDotL * lightData.distanceAttenuation * surface.color;
// half3 specularColor = lightData.color * powNDotH * lightData.distanceAttenuation * surface.color; 
// return (diffuseColor + specularColor) * lightData.shadowAttenuation;

real3 GetLighting(LightData_CelPBR lightData, Surface_CelPBR surface, BRDF_CelPBR brdf, TempData_CelPBR tempData)
{
    return (brdf.diffuse + brdf.specular) * lightData.color * lightData.distanceAttenuation * lightData.shadowAttenuation * tempData.nDotL;

    // for debug
    // BRDFData brdfData = ConvertToBRDFData(brdf);
    // BRDFData brdfDataClearCoat = (BRDFData)0;
    // Light light = ConvertToUnityLight(lightData);
    // real3 color = GlobalIllumination(brdfData, brdfDataClearCoat, 0,
    //                                  0, surface.occlusion,
    //                                  surface.normal, tempData.viewDirection);
    // color *= INPUT_PROP(_MetallicScale);
    // color = LightingPhysicallyBased(brdfData, brdfDataClearCoat, light, surface.normal, tempData.viewDirection, 0, false);
    // return color;
}

#endif