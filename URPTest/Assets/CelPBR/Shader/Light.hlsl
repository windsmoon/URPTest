#ifndef Light_Cel_PBR
#define Light_Cel_PBR

// struct DirectionalLight_CelPBR
// {
//     half3 color;
//     float3 direction;
// };

struct LightData_CelPBR
{
    real3 color;
    real3 direction;
    real distanceAttenuation;
    real shadowAttenuation;
};

// struct Light
// {
//     half3   direction;
//     half3   color;
//     half    distanceAttenuation;
//     half    shadowAttenuation;
// };


Light ConvertToUnityLight(LightData_CelPBR lightData)
{
    Light unityLight;
    unityLight.color = lightData.color;
    unityLight.direction = lightData.direction;
    unityLight.distanceAttenuation = lightData.distanceAttenuation;
    unityLight.shadowAttenuation = lightData.shadowAttenuation;
    return unityLight;
}

LightData_CelPBR GetMainLightData(Varyings input)
{
    Light light = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
    LightData_CelPBR lightData;
    lightData.color = light.color;
    lightData.direction = light.direction;
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