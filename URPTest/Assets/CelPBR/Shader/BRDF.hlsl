#ifndef CEL_PBR_BRDF
#define CEL_PBR_BRDF

struct BRDF_CelPBR
{
    real3 kd;
    real3 ks;
    real3 ksss;
    real3 diffuse;
    real3 specular;
    real3 sss;

    real perceptualRoughness;
    real roughness;
    real roughness2;
    real oneMinusReflectivity;
    real reflectivity;
    real grazingTerm;
    // We save some light invariant BRDF terms so we don't have to recompute
    // them in the light loop. Take a look at DirectBRDF function for detailed explaination.
    real normalizationTerm;     // roughness * 4.0 + 2.0
    real roughness2MinusOne;    // roughness^2 - 1.0
};

BRDFData ConvertToBRDFData(BRDF_CelPBR brdf)
{
    BRDFData brdfData;
    brdfData.diffuse = brdf.diffuse;
    brdfData.specular = brdf.ks;
    brdfData.reflectivity = brdf.reflectivity;
    brdfData.perceptualRoughness = brdf.perceptualRoughness;
    brdfData.roughness = brdf.roughness;
    brdfData.roughness2 = brdf.roughness2;
    brdfData.grazingTerm = brdf.grazingTerm;
    brdfData.normalizationTerm = brdf.normalizationTerm;
    brdfData.roughness2MinusOne = brdf.roughness2MinusOne;
    return brdfData;
}


// // D = Normal Distribution Function
// // use Trowbridge-Reitz GGX
// float CaculateNormalDistributionFunction(BRDF_CelPBR brdf, Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
// {
//     float roughness2 = brdf.roughness * brdf.roughness;
//     float nDotH2 = tempData.nDotH * tempData.nDotH;
//     float denom = nDotH2 * (roughness2 - 1) + 1; // todo
//     denom *= denom;
//     denom *= PI;
//     return roughness2 / max(denom, FLT_MIN);
// }
//
// // F = Fresnel Equation
// // use Fresnel-Schlick
// // F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
// float3 CaculateFresnelEquation(BRDF_CelPBR brdf, Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
// {
//     float3 f0 = lerp(0.04, surface.color, surface.metallic); // 0.04 is the average base refelction rate of dielectric
//     return f0 + (1 - f0) * pow(1 - tempData.nDotV, 5);
// }
//
// float CaculateGeometrySchlickGGX(half nDot, float k)
// {
//     half denom = nDot * (1 - k) + k;
//     return nDot / denom;
// }
//
// // G = Geometry Function
// // use SchlickGGX
// float CaculateGeometryFunction(BRDF_CelPBR brdf, Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
// {
//     float k = pow(brdf.roughness + 1, 2) / 8;
//     float gSubView = CaculateGeometrySchlickGGX(tempData.nDotV, k);
//     float gSubLight = CaculateGeometrySchlickGGX(tempData.nDotL, k);
//     return gSubView * gSubLight;
// }
//

// reference to DirectBRDFSpecular
float UnityDirectBRDFSpecular(BRDF_CelPBR brdf, Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    real3 halfDirection = tempData.halfDirection;
    real nDotH = tempData.nDotH;
    real lDotH = tempData.lDotH;
    real d = nDotH * nDotH * brdf.roughness2MinusOne + 1.00001h;
    real lDotH2 = lDotH * lDotH;
    real specularTerm = brdf.roughness2 / ((d * d) * max(0.1h, lDotH2) * brdf.normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specularTerm = specularTerm - HALF_MIN;
        specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
    #endif

    return specularTerm;
}

// brdf = kd * lambertian + ks * cook-torrance
// labertian = albedo / (4pi)
// cook-torrance = DFG/(4 * (wo * n) * (wi * n))
BRDF_CelPBR GetBRDF(Surface_CelPBR surface, LightData_CelPBR lightData, TempData_CelPBR tempData, out real alpha)
{
    // half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
    // half reflectivity = 1.0 - oneMinusReflectivity;
    BRDF_CelPBR brdf;
    brdf.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness); // ?? this is come from disney, i do not know why
    brdf.roughness = max(PerceptualRoughnessToRoughness(brdf.perceptualRoughness), HALF_MIN_SQRT);
    brdf.roughness2 = max(brdf.roughness * brdf.roughness, HALF_MIN);
    float oneMinusReflectivity = OneMinusReflectivityMetallic(surface.metallic);
    brdf.oneMinusReflectivity = oneMinusReflectivity;
    brdf.reflectivity = 1.0h - oneMinusReflectivity;
    brdf.grazingTerm = saturate(surface.smoothness + brdf.reflectivity);
    brdf.normalizationTerm = brdf.roughness * 4.0h + 2.0h;
    brdf.roughness2MinusOne = brdf.roughness2 - 1.0h;

    #if defined(SSS)
        // brdf.kt = 1 - surface.thickness;
        brdf.ksss = surface.sssMask;
        brdf.kd = oneMinusReflectivity * (1 - surface.sssMask);
    #else
        brdf.kd = oneMinusReflectivity;
        brdf.ksss = 0;
    #endif
    
    // brdf.kd = oneMinusReflectivity;
    brdf.diffuse = surface.color * brdf.kd;
    brdf.sss = surface.color * GetSSSLut(float2(tempData.halfNDotL, surface.curvature) + GetSSSLutOffset()) * brdf.ksss;
    // brdf.transmit = surface.color * brdf.kt;

    #if defined(_ALPHAPREMULTIPLY_ON)
        brdf.diffuse *= surface.alpha;
        alpha = surface.alpha * oneMinusReflectivity + brdf.reflectivity; // ?? NOTE: alpha modified and propagated up.
        // alpha = alpha * (1 - reflectivity) + reflectivity
        //       = alpha + (1 - alpha) * reflectivity
        //       = lerp(alpha, 1, reflectivity)
    #else
        alpha = surface.alpha;
    #endif
    
    brdf.ks = lerp(kDieletricSpec.rgb, surface.color, surface.metallic);
    brdf.specular = brdf.ks * UnityDirectBRDFSpecular(brdf, surface, lightData, tempData);
    
    
    // float d = CaculateNormalDistributionFunction(surface, lightData, tempData);
    // float3 f = CaculateFresnelEquation(surface, lightData, tempData);
    // float g = CaculateGeometryFunction(surface, lightData, tempData);
    // float denom = 4 * tempData.nDotV * tempData.nDotL;
    // brdf.specular = ks * (d * f * g) / max(denom, FLT_MIN);
    
    return brdf;
}

struct CelData_CelPBR
{
    // real3 kd;
    // real3 ks;
    real3 diffuse;
    real3 specular;
    real rim;

    // real oneMinusReflectivity;
    // real reflectivity;
};

CelData_CelPBR GetCelData(Surface_CelPBR surface, BRDF_CelPBR brdf, LightData_CelPBR lightData, TempData_CelPBR tempData)
{
    #if defined(CEL_SHADING)
        CelData_CelPBR celData;
        real halfLambert = tempData.nDotL * 0.5 + 0.5;
        real diffuseRampUV = halfLambert - surface.celShadowRange;
        celData.diffuse = GetRamp(diffuseRampUV) * surface.color;
        real specular = pow(tempData.nDotH, surface.celSpecularGlossiness);
        celData.specular = specular < surface.celSpecularThreshold ? 0 : 1;
        celData.specular *= brdf.ks;
        float f = 1 - tempData.nDotV;
        f = f * tempData.nDotL;
        real2 rimRange = surface.rimRange;
        real3 rimColor = surface.rimColor;
        f = smoothstep(rimRange.x, rimRange.y, f);
        float3 rim = f * rimColor.rgb;
        celData.rim = rim * brdf.ks;
        return celData;
    #else
        CelData_CelPBR celData;
        real halfLambert = tempData.nDotL;
        real diffuseRampUV = halfLambert - surface.celShadowRange;
        celData.diffuse = GetRamp(diffuseRampUV) * brdf.diffuse;
        celData.specular = brdf.specular < surface.celSpecularThreshold ? 0 : 1;
        
        float f = 1 - tempData.nDotV;
        f = f * tempData.nDotL;
        real2 rimRange = surface.rimRange;
        real3 rimColor = surface.rimColor;
        f = smoothstep(rimRange.x, rimRange.y, f);
        float3 rim = f * rimColor.rgb;
        celData.rim = rim * brdf.ks;
        return celData;
    #endif
}

#endif