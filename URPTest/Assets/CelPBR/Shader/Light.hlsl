#ifndef Light_Cel_PBR
#define Light_Cel_PBR

struct DirectionalLight_CelPBR
{
    half3 color;
    float3 direction;
};

struct LightData_CelPBR
{
    half3 color;
    float3 direction;
    float distanceAttenuation;
    float shadowAttenuation;
};

LightData_CelPBR GetMainLightData(Varyings input)
{
    // DirectionalLight_CelPBR directionalLight;
    // directionalLight.color = _MainLightColor.xyz;
    // directionalLight.direction = _MainLightPosition.xyz;
    // directionalLigh
    Light light = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
    LightData_CelPBR lightData;
    lightData.color = _MainLightColor.xyz;
    lightData.direction = _MainLightPosition.xyz;
    lightData.distanceAttenuation = 1;
    lightData.shadowAttenuation = light.shadowAttenuation;
    return lightData;
}

int GetOtherLightCount()
{
    return GetAdditionalLightsCount();
}

LightData_CelPBR GetOtherLightData(Varyings input, int index)
{
    Light light = GetAdditionalLight(index, input.positionWS);
    LightData_CelPBR lightData;
    lightData.color = light.color;
    lightData.direction = light.direction;
    lightData.distanceAttenuation = light.distanceAttenuation;
    lightData.shadowAttenuation = light.shadowAttenuation; // urp 10.x do not support additional shadow ?
    lightData.shadowAttenuation = AdditionalLightRealtimeShadow(index, input.positionWS);
    return lightData;
}

#endif