#ifndef CEL_PBR_LIGHTING
#define CEL_PBR_LIGHTING

half3 GetLighting(LightData_CelPBR lightData, Surface_CelPBR surface, BRDF_CelPBR brdf)
{
    float nDotL = saturate(dot(surface.normal, lightData.direction));

    // return  brdf.specular;
    // return 
    return (brdf.diffuse + brdf.specular) * lightData.color * lightData.distanceAttenuation * lightData.shadowAttenuation * nDotL;
    // InitializeInputData
    // float3 halfVector = normalize(surface.viewDirection + lightData.direction);
    // float nDotH = saturate(dot(surface.normal, halfVector));
    // float powNDotH = pow(nDotH, 256);
    // half3 diffuseColor = lightData.color * nDotL * lightData.distanceAttenuation * surface.color;
    // half3 specularColor = lightData.color * powNDotH * lightData.distanceAttenuation * surface.color; 
    // return (diffuseColor + specularColor) * lightData.shadowAttenuation;

}

#endif