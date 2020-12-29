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
half CaculateNormalDistributionFunction(Surface_CelPBR surface, LightData_CelPBR lightData)
{
    half roughness2 = surface.roughness * surface.roughness;
    float3 halfDirection = GetHalfDirection(surface.normal, lightData.direction);
    float nDotH = saturate(dot(surface.normal, halfDirection));
    float nDotH2 = nDotH * nDotH;
    float denom = nDotH2 * (roughness2 - 1) + 1.00001; // todo
    denom *= denom;
    denom *= PI;
    return roughness2 / denom;
}

// F = Fresnel Equation
// use Fresnel-Schlick
half3 CaculateFresnelEquation(Surface_CelPBR surface, LightData_CelPBR lightData)
{
    half3 f0 = lerp(0.04, surface.color, surface.metallic); // 0.04 is the average base refelction rate of dielectric
    return f0 + (1 - f0) * pow(1 - saturate(dot(surface.normal, surface.viewDirection)), 5); // no need to saturate
}

half CaculateGeometrySchlickGGX(half nDot, float k)
{
    half denom = nDot * (1 - k) + k;
    return nDot / denom;
}

// G = Geometry Function
// use SchlickGGX
half CaculateGeometryFunction(Surface_CelPBR surface, LightData_CelPBR lightData)
{
    half k = pow(surface.roughness + 1, 2) / 8;
    half nDotV = saturate(dot(surface.normal, surface.viewDirection));
    half nDotL = saturate(dot(surface.normal, lightData.direction));
    half gSubView = CaculateGeometrySchlickGGX(nDotV, k);
    half gSubLight = CaculateGeometrySchlickGGX(nDotL, k);
    return gSubView * gSubLight;
}

// brdf = kd * lambertian + ks * cook-torrance
// labertian = albedo / (4pi)
// cook-torrance = DFG/(4 * (wo * n) * (wi * n))
BRDF_CelPBR GetBRDF(Surface_CelPBR surface, LightData_CelPBR lightData)
{
    BRDF_CelPBR brdf;
    half d = CaculateNormalDistributionFunction(surface, lightData);
    half3 f = CaculateFresnelEquation(surface, lightData);
    half g = CaculateGeometryFunction(surface, lightData);
    half denom = 4 * saturate(dot(surface.normal, surface.viewDirection)) * saturate(dot(surface.normal, lightData.direction));
    brdf.specular = (d * f * g) / max(denom, 0.0001);
    half3 diffuse = (1 - f) * (1 - surface.metallic);
    brdf.diffuse = diffuse * surface.color / PI;
    // brdf.debug = d * f * g;
    return brdf;
}

#endif