#ifndef CEL_PBR_BRDF
#define CEL_PBR_BRDF

struct BRDF_CelPBR
{
    half3 diffuse;
    half3 specular;
    half3 debug;
};


// float DistributionGGX(vec3 N, vec3 H, float a)
// {
//     float a2     = a*a;
//     float NdotH  = max(dot(N, H), 0.0);
//     float NdotH2 = NdotH*NdotH;
// 	
//     float nom    = a2;
//     float denom  = (NdotH2 * (a2 - 1.0) + 1.0);
//     denom        = PI * denom * denom;
// 	
//     return nom / denom;
// }




// D = Normal Distribution Function
// use Trowbridge-Reitz GGX
// F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
half CaculateNormalDistributionFunction(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    half roughness2 = surface.roughness * surface.roughness;
    float nDotH2 = tempData.nDotH * tempData.nDotH;
    float denom = nDotH2 * (roughness2 - 1) + 1.00001; // todo
    denom *= denom;
    denom *= PI;
    return roughness2 / denom;
}

// F = Fresnel Equation
// use Fresnel-Schlick
half3 CaculateFresnelEquation(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    half3 f0 = lerp(0.04, surface.color, surface.metallic); // 0.04 is the average base refelction rate of dielectric
    return f0 + (1 - f0) * pow(1 - tempData.nDotL, 5);
}

half CaculateGeometrySchlickGGX(half nDot, float k)
{
    half denom = nDot * (1 - k) + k;
    return nDot / denom;
}

// G = Geometry Function
// use SchlickGGX
half CaculateGeometryFunction(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    half k = pow(surface.roughness + 1, 2) / 8;
    // half nDotV = saturate(dot(surface.normal, surface.viewDirection));
    // half nDotL = saturate(dot(surface.normal, lightData.direction));
    half gSubView = CaculateGeometrySchlickGGX(tempData.nDotV, k);
    half gSubLight = CaculateGeometrySchlickGGX(tempData.nDotL, k);
    return gSubView * gSubLight;
}

// brdf = kd * lambertian + ks * cook-torrance
// labertian = albedo / (4pi)
// cook-torrance = DFG/(4 * (wo * n) * (wi * n))
BRDF_CelPBR GetBRDF(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    BRDF_CelPBR brdf;
    half d = CaculateNormalDistributionFunction(surface, lightData, tempData);
    half3 f = CaculateFresnelEquation(surface, lightData, tempData);
    half g = CaculateGeometryFunction(surface, lightData, tempData);
    half denom = 4 * tempData.nDotV * tempData.nDotL;
    brdf.specular = (d * f * g) / max(denom, 0.0001);
    // float oneMinusReflectivity = OneMinusReflectivityMetallic(surface.metallic);
    half3 diffuse = (1 - f) * (1 - surface.metallic);
    brdf.diffuse = diffuse * surface.color;
    // brdf.diffuse = 0;
    // brdf.debug = d * f * g;
    brdf.debug.rgb = d * f * g;
    // brdf.specular = 0;
    // brdf.debug = f;
    return brdf;
}

#endif