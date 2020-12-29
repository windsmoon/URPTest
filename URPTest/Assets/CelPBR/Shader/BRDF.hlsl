#ifndef CEL_PBR_BRDF
#define CEL_PBR_BRDF

struct BRDF_CelPBR
{
    half3 diffuse;
    half3 specular;
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
half CaculateNormalDistributionFunction(Surface_CelPBR surface)
{
    half roughness2 = surface.roughness * surface.roughness;
    // vector halfDirection = normalize(surface)
    // half nDotH = saturate(dot(surface.normal, surface))
    return 1;
}

half CaculateFresnelEquation(Surface_CelPBR surface)
{
    return 1;
}

half CaculateGeometryFunction(Surface_CelPBR surface)
{
    return 1;
}

// brdf = kd * lambertian + ks * cook-torrance
// labertian = albedo / (4pi)
// cook-torrance = DFG/(4 * (wo * n) * (wi * n))
BRDF_CelPBR GetBRDF(Surface_CelPBR surface)
{
    BRDF_CelPBR brdf;
    brdf.diffuse = surface.color;
    brdf.specular = surface.color;
    return brdf;
}

#endif