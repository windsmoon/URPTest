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
    float attenuation;
};

#endif