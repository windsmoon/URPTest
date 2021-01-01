#ifndef CEL_PBR_TEMP_DATA
#define CEL_PBR_TEMP_DATA

struct TempData_CelPBR
{
    real3 viewDirection;
    real3 halfDirection;
    real nDotH;
    real nDotL;
    real lDotH;
    real3 lightReflectionDirection;
    real nDotV;
    real3 viewReflectionDirection;
};

TempData_CelPBR GetTempData(Varyings input, Surface_CelPBR surface, LightData_CelPBR lightData)
{
    TempData_CelPBR tempData;
    tempData.viewDirection = SafeNormalize(_WorldSpaceCameraPos - input.positionWS);
    tempData.halfDirection = SafeNormalize(tempData.viewDirection + lightData.direction);
    tempData.nDotH = max(dot(surface.normal, tempData.halfDirection), 0.0);
    tempData.nDotL = max(dot(surface.normal, lightData.direction), 0.0);
    tempData.lDotH = max(dot(lightData.direction, tempData.halfDirection), 0.0);
    tempData.lightReflectionDirection = reflect(-lightData.direction, surface.normal);
    tempData.nDotV = max(dot(surface.normal, tempData.viewDirection), 0.0);
    tempData.viewReflectionDirection = reflect(-tempData.viewDirection, surface.normal);
    return tempData;
}

#endif