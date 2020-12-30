#ifndef CEL_PBR_TEMP_DATA
#define CEL_PBR_TEMP_DATA

struct TempData_CelPBR
{
    float3 halfDirection;
    float3 nDotH;
    float3 nDotL;
    float nDotV;
};

TempData_CelPBR GetTempData(Varyings input, Surface_CelPBR surface, LightData_CelPBR lightData)
{
    TempData_CelPBR tempData;
    tempData.halfDirection = SafeNormalize(surface.viewDirection + lightData.direction);
    tempData.nDotH = saturate(dot(surface.normal, tempData.halfDirection));
    tempData.nDotL = saturate(dot(surface.normal, lightData.direction));
    tempData.nDotV  = saturate(dot(surface.normal, surface.viewDirection));
    return tempData;
}

#endif