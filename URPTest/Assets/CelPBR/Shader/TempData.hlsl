#ifndef CEL_PBR_TEMP_DATA
#define CEL_PBR_TEMP_DATA

struct TempData_CelPBR
{
    float3 halfDirection;
    float nDotH;
    float nDotL;
    float nDotV;
    float lDotH;
};

TempData_CelPBR GetTempData(Varyings input, Surface_CelPBR surface, LightData_CelPBR lightData)
{
    TempData_CelPBR tempData;
    tempData.halfDirection = SafeNormalize(surface.viewDirection + lightData.direction);
    tempData.nDotH = max(dot(surface.normal, tempData.halfDirection), 0.0);
    tempData.nDotL = max(dot(surface.normal, lightData.direction), 0.0);
    tempData.nDotV = max(dot(surface.normal, surface.viewDirection), 0.0);
    tempData.lDotH = max(dot(lightData.direction, tempData.halfDirection), 0.0);
    return tempData;
}

#endif