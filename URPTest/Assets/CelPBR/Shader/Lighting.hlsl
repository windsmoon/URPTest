#ifndef CEL_PBR_LIGHTING
#define CEL_PBR_LIGHTING


// float nDotL = saturate(dot(surface.normal, lightData.direction));
// float3 halfVector = normalize(tempData.viewDirection + lightData.direction);
// float nDotH = saturate(dot(surface.normal, halfVector));
// float powNDotH = pow(nDotH, 256);
// half3 diffuseColor = lightData.color * nDotL * lightData.distanceAttenuation * surface.color;
// half3 specularColor = lightData.color * powNDotH * lightData.distanceAttenuation * surface.color; 
// return (diffuseColor + specularColor) * lightData.shadowAttenuation;

#if defined(CEL_SHADING)
real3 GetLighting(LightData_CelPBR lightData, Surface_CelPBR surface, BRDF_CelPBR brdf, TempData_CelPBR tempData)
{
    // return (brdf.diffuse + brdf.specular) * lightData.color * lightData.distanceAttenuation * lightData.shadowAttenuation * tempData.nDotL;

    float nDotL = dot(surface.normal, lightData.direction);
    float nDotV = dot(surface.normal, tempData.viewDirection);

    // diffuse
    float halfLambert = nDotL * 0.5 + 0.5;
    half ramp = GetRamp(halfLambert * lightData.distanceAttenuation * (saturate(lightData.shadowAttenuation + 0.2)) - GetShadowRange()); // todo : edge light ?
    // half ramp = smoothstep(0, _ShadowSmooth, halfLambert -  GetShadowRange());
    // float3 diffuse = halfLambert >  GetShadowRange() ? GetCelShadeColor() : GetShadowColor();
    float3 diffuse = lerp(GetShadowColor(), GetCelShadeColor(), ramp);

    // rim light
    float f = 1 - tempData.nDotV;
    // f = f * (nDotL * 0.5 + 0.5); // (nDotL * 0.5 + 0.5) make rim light range bigger
    f = f * tempData.nDotL;
    float2 rimRange = GetRimRange();
    float4 rimColor = GetRimColor();
    f = smoothstep(rimRange.x, rimRange.y, f);
    float3 rim = f * rimColor.rgb;
    rim = lerp(brdf.reflectivity, rim, rimColor.a);
    real3 color = (diffuse * brdf.diffuse + brdf.specular + rim) * lightData.color;
    // float3 color = (diffuse * GetDirectBRDF(surface, brdfLight, light) + rim) * light.color;
    return color;
}

#else
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
#endif