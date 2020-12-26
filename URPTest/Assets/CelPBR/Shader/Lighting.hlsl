#ifndef CEL_PBR_LIGHTING
#define CEL_PBR_LIGHTING

half3 GetLighting(LightData_CelPBR lightData, Surface_CelPBR surface, BRDF_CelPBR brdf)
{
    // return saturate(dot(surface.normal, light.direction)) * light.color * GetDirectBRDF(surface, brdfLight, light) * light.attenuation;
    float nDotL = saturate(dot(surface.normal, lightData.direction));
    float3 halfVector = normalize(surface.viewDirection + lightData.direction);
    float nDotH = saturate(dot(surface.normal, halfVector));
    float posNDotH = pow(nDotH, _Shinness);
    return lightData.color * lightData.attenuation * (nDotL + posNDotH);
}

#endif