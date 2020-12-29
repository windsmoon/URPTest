#ifndef CEL_PBR_LIGHTING
#define CEL_PBR_LIGHTING

half3 GetLighting(LightData_CelPBR lightData, Surface_CelPBR surface, BRDF_CelPBR brdf)
{
    // return saturate(dot(surface.normal, light.direction)) * light.color * GetDirectBRDF(surface, brdfLight, light) * light.attenuation;
    float nDotL = saturate(dot(surface.normal, lightData.direction));
    float3 halfVector = normalize(surface.viewDirection + lightData.direction);
    float nDotH = saturate(dot(surface.normal, halfVector));
    float powNDotH = pow(nDotH, 256);
    half3 diffuseColor = lightData.color * nDotL * lightData.distanceAttenuation * brdf.diffuse * (1 -surface.metallic);
    half3 specularColor = lightData.color * powNDotH * lightData.distanceAttenuation * brdf.specular * surface.metallic; 
    return (diffuseColor + specularColor) * lightData.shadowAttenuation;
}

#endif