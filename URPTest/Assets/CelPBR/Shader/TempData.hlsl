#ifndef CEL_PBR_TEMP_DATA
#define CEL_PBR_TEMP_DATA

struct TempData_CelPBR
{
    real3 viewDirection;
    real3 halfDirection;
    real nDotH;
    real nDotL;
    real halfNDotL;
    real lDotH;
    real3 lightReflectionDirection;
    real nDotV;
    real3 viewReflectionDirection;
    real backLDotV;
    real sssFactor;
    real kkTDotH;
    real kkTSinH;
};

TempData_CelPBR GetTempData(Varyings input, Surface_CelPBR surface, LightData_CelPBR lightData)
{
    TempData_CelPBR tempData;
    tempData.viewDirection = SafeNormalize(_WorldSpaceCameraPos - input.positionWS);
    tempData.halfDirection = SafeNormalize(tempData.viewDirection + lightData.direction);
    tempData.nDotH = max(dot(surface.normal, tempData.halfDirection), 0.0);
    real tempNDotL = dot(surface.normal, lightData.direction);
    tempData.nDotL = max(tempNDotL, 0.0);
    tempData.halfNDotL = 0.5 * tempNDotL + 0.5;
    tempData.lDotH = max(dot(lightData.direction, tempData.halfDirection), 0.0);
    tempData.lightReflectionDirection = reflect(-lightData.direction, surface.normal);
    tempData.nDotV = max(dot(surface.normal, tempData.viewDirection), 0.0);
    tempData.viewReflectionDirection = reflect(-tempData.viewDirection, surface.normal);
    tempData.backLDotV = max(dot(-lightData.direction, tempData.viewDirection), 0.0);
    real3 sssDirection = -SafeNormalize(lightData.direction + surface.normal * GetSSSDistort());
    tempData.sssFactor = pow(max(dot(sssDirection, tempData.viewDirection), 0.0), GetSSSPower());

    // kk
    #if defined(ENABLE_KK_HIGHLIGHT_ANISO_MAP)
        real3 usedTangent = surface.kkHighlightAnisoDirection;
    #else
        real3 usedTangent = GetKKHighlightUseTangent() == 1 ? surface.tangent : surface.bitangent;
    #endif


    // real3 offsetDir = surface.normal * GetKKHighlightOffset(input.kkHighlightUV);
    // real3 direction = normalize(usedTangent + offsetDir);
    real3 direction = normalize(usedTangent + surface.normal * surface.kkHighlightOffset);
    tempData.kkTDotH = dot(direction, tempData.halfDirection);
    tempData.kkTSinH = sqrt(1 - tempData.kkTDotH * tempData.kkTDotH);
    return tempData;
}

#endif