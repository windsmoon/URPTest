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
float CaculateNormalDistributionFunction(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    float roughness2 = surface.roughness * surface.roughness;
    float nDotH2 = tempData.nDotH * tempData.nDotH;
    float denom = nDotH2 * (roughness2 - 1) + 1; // todo
    denom *= denom;
    denom *= PI;
    return roughness2 / max(denom, FLT_MIN);
}

// F = Fresnel Equation
// use Fresnel-Schlick
// F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
float3 CaculateFresnelEquation(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    float3 f0 = lerp(0.04, surface.color, surface.metallic); // 0.04 is the average base refelction rate of dielectric
    return f0 + (1 - f0) * pow(1 - tempData.nDotV, 5);
}

float CaculateGeometrySchlickGGX(half nDot, float k)
{
    half denom = nDot * (1 - k) + k;
    return nDot / denom;
}

// G = Geometry Function
// use SchlickGGX
float CaculateGeometryFunction(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    float k = pow(surface.roughness + 1, 2) / 8;
    float gSubView = CaculateGeometrySchlickGGX(tempData.nDotV, k);
    float gSubLight = CaculateGeometrySchlickGGX(tempData.nDotL, k);
    return gSubView * gSubLight;
}

float UnityDirectBRDFSpecular(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    float specularTerm = 0;
    float roughness2 = pow(surface.roughness, 2);
    float d = pow(tempData.nDotH, 2) * (roughness2 - 1) + 1.00001f;
    float lDotH2 = pow(tempData.lDotH, 2);
    specularTerm = roughness2 / ((d * d) * max(0.1, lDotH2) * (surface.roughness * 4 + 2));
    return specularTerm;
}

// brdf = kd * lambertian + ks * cook-torrance
// labertian = albedo / (4pi)
// cook-torrance = DFG/(4 * (wo * n) * (wi * n))
BRDF_CelPBR GetBRDF(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    BRDF_CelPBR brdf;

    float kd = OneMinusReflectivityMetallic(surface.metallic);
    brdf.diffuse = surface.color * kd;
    float3 ks = lerp(kDieletricSpec.rgb, surface.color, surface.metallic);
    brdf.specular = ks * UnityDirectBRDFSpecular(surface, lightData, tempData);

    // float d = CaculateNormalDistributionFunction(surface, lightData, tempData);
    // float3 f = CaculateFresnelEquation(surface, lightData, tempData);
    // float g = CaculateGeometryFunction(surface, lightData, tempData);
    // float denom = 4 * tempData.nDotV * tempData.nDotL;
    // brdf.specular = ks * (d * f * g) / max(denom, FLT_MIN);
    
    return brdf;
}

#endif