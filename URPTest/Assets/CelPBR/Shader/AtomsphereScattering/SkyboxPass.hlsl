#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_SKYBOX_PASS
#define CEL_PBR_ATOMSPHERE_SCATTERING_SKYBOX_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 
#include "AtomsphereScattering.hlsl"

#define SAMPLECOUNT_KSYBOX 64
            
struct Attribute
{
    float3 positionOS: POSITION;
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    float3 positionOS: TEXCOORD0;
};

Varyings vert(Attribute input)
{
    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.positionOS = input.positionOS;
    return output;
}

half4 frag(Varyings input): SV_Target
{
    // todo need a common resolution
    // suppose the camera is near the planet and the ground's y is 0
    // the distance between camera and ground can be ignore relative to the atomshpere
    float3 viewRayOriginal = _WorldSpaceCameraPos.xyz;
    float3 viewRayDirection = normalize(TransformObjectToWorld(input.positionOS)); // dont know wether unity skybox has rotation
    float3 planetCenter = float3(0, - GetPlanetRadius(), 0);
    float3 lightDir = GetMainLight().direction;
    float2 intersectionAtAtomsphere;
    // always has intersection bewteen view ray and atomsphere
    RaySphereIntersection(viewRayOriginal, viewRayDirection, planetCenter, GetPlanetRadius() + GetAtomsphereHeight(), intersectionAtAtomsphere); // intersection of ray and atomsphere
    float rayLength = intersectionAtAtomsphere.y; // the camera is near the planet, it means the camera is in the atomsphere, so the t2 is the intersection toward the ray

    float3 resultColor = CaculateSingleScattering(viewRayOriginal, viewRayDirection, rayLength, planetCenter);
    return float4(resultColor, 1);
}

#endif
