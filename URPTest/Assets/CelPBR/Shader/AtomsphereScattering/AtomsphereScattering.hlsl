﻿#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING
#define CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING

#include "AtomsphereScatteringInput.hlsl"

//-----------------------------------------------------------------------------------------
// thought is come from https://github.com/PZZZB/Atmospheric-Scattering-URP
// 
// RaySphereIntersection
// sphere equation (P-C)^2 = R^2
// ray equation P = P0 + d * t
// Solve quadratic equations with one variable
// return t1 and t2 in a float2 result and t1 is less than t2
// t is also the lenght of the original point and 
// if t1 or t2 are less than 0, then the intersection is behind the start point
//-----------------------------------------------------------------------------------------
bool RaySphereIntersection(float3 rayOrigin, float3 rayDirection, float3 sphereCenter, float sphereRadius, out float2 intersectionParameters)
{
    rayOrigin -= sphereCenter;
    float a = dot(rayDirection, rayDirection);
    float b = 2.0 * dot(rayOrigin, rayDirection);
    float c = dot(rayOrigin, rayOrigin) - (sphereRadius * sphereRadius);
    float t = b * b - 4 * a * c;
    
    if (t < 0)
    {
        return false;
    }
    
    else
    {
        t = sqrt(t);
        intersectionParameters = float2(-b - t, -b + t) / (2 * a);
        return true;
    }
}

float CaculateDensityRatio_Ray(float height)
{
    return exp(-height / GetScaleHeight_Ray());
}

float CaculateDensityRatio_Mie(float height)
{
    return exp(-height / GetScaleHeight_Mie());
}

float CaculateOpticalDepth_Ray(float3 startPoint, float3 rayDirection, float rayLength, float3 planentCenter)
{
    int sampleCount = GetAtomsphereScatteringSampleCount();
    float stepLength = rayLength / sampleCount;
    float3 stepVector = stepLength * rayDirection;
    float3 currentPoint = startPoint + stepVector * 0.5;
    float opticalDepth = 0;
    
    for (int i = 0; i < sampleCount; ++i)
    {
        float currentHeight = distance(planentCenter, currentPoint) - GetPlanetRadius();
        opticalDepth += CaculateDensityRatio_Ray(currentHeight) * stepLength;
        currentPoint += stepVector;
    }

    return opticalDepth;
}


float CaculateOpticalDepth_Mie(float3 startPoint, float3 rayDirection, float rayLength, float3 planentCenter)
{
    int sampleCount = GetAtomsphereScatteringSampleCount();
    float stepLength = rayLength / sampleCount;
    float3 stepVector = stepLength * rayDirection;
    float3 currentPoint = startPoint + stepVector * 0.5;
    float opticalDepth = 0;
    
    for (int i = 0; i < sampleCount; ++i)
    {
        float currentHeight = distance(planentCenter, currentPoint) - GetPlanetRadius();
        opticalDepth += CaculateDensityRatio_Mie(currentHeight) * stepLength;
        currentPoint += stepVector;
    }

    return opticalDepth;
}

float CaculatePhaseFunction_Ray(float cosTheta)
{
    return 3 / (16 * PI) * (1 + pow(cosTheta, 2));
}

float CaculatePhaseFunction_Mie(float cosTheta)
{
    float g = GetMieG();
    float g2 = g * g;
    float cosTheta2 = cosTheta * cosTheta;
    float a = 3 * (1 - g2) * (1 + cosTheta2);
    float norm = (8 * PI) * (2 + g2) * pow((1 + g2 - 2 * g * cosTheta), 1.5);
    return a / norm;

    // float a = 1 - g2;
    // float norm = 4 * PI * pow(1 + g2 - 2 * g * cosTheta, 1.5);
    // return a / norm;
}

float3 CaculateSingleScattering(float3 viewRayOriginal, float3 viewRayDirection, float viewRayLength, float3 planetCenter)
{
    int sampleCount = GetAtomsphereScatteringSampleCount();
    float stepLength = viewRayLength / sampleCount;
    float3 stepVector = -viewRayDirection * stepLength;
    float3 currentPoint = viewRayOriginal + stepVector * 0.5;
    float3 result_Ray = 0;
    float3 result_Mie = 0;
    float3 lightDirection = GetMainLight().direction;
    float opticalDepthViewPoint_Ray = 0; // to optimize the caculate times
    float opticalDepthViewPoint_Mie = 0; // to optimize the caculate times

    for (int i = 0; i < sampleCount; ++i)
    {
        // first caculate the intersection of light ray and atomsphere
        float2 intersectionParameters;
        
        if (RaySphereIntersection(currentPoint, lightDirection, planetCenter, GetPlanetRadius(), intersectionParameters))
        {
            // if the two intersections are all in the light direction
            // then the light will be blocked by the planet
            if (intersectionParameters.x >= 0 && intersectionParameters.y >= 0)
            {
                result_Ray += 0;
                result_Mie += 0;
                opticalDepthViewPoint_Ray += CaculateDensityRatio_Ray(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;
                opticalDepthViewPoint_Mie += CaculateDensityRatio_Mie(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;
                currentPoint += stepVector;
                continue;;
            }
        }

        opticalDepthViewPoint_Ray += CaculateDensityRatio_Ray(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;
        opticalDepthViewPoint_Mie += CaculateDensityRatio_Mie(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;

        // always should has intersections
        RaySphereIntersection(currentPoint, lightDirection, planetCenter, GetPlanetRadius() + GetAtomsphereHeight(), intersectionParameters);
        float opticalDepth_Ray = CaculateOpticalDepth_Ray(currentPoint, lightDirection, intersectionParameters.y, planetCenter);
        float opticalDepth_Mie = CaculateOpticalDepth_Mie(currentPoint, lightDirection, intersectionParameters.y, planetCenter);

        float totalOpticalDepth_Ray = opticalDepth_Ray + opticalDepthViewPoint_Ray;
        float totalOpticalDepth_Mie = opticalDepth_Mie + opticalDepthViewPoint_Mie;
        result_Ray += exp(-GetScatteringCoefficientAtSealevel_Ray() * totalOpticalDepth_Ray) * CaculateDensityRatio_Ray(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;
        result_Mie += exp(-GetScatteringCoefficientAtSealevel_Mie() * totalOpticalDepth_Mie) * CaculateDensityRatio_Mie(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;
        currentPoint += stepVector;
    }

    float cosTheta = dot(-viewRayDirection, lightDirection);
    float phaseFunction_Ray = CaculatePhaseFunction_Ray(cosTheta);
    float phaseFunction_Mie = CaculatePhaseFunction_Mie(cosTheta);
    // float3 result = GetMainLight().color * GetScatteringCoefficientAtSealevel() * phaseFunction_Ray * result_Ray;
    float3 result = GetMainLight().color * (GetScatteringCoefficientAtSealevel_Ray() * phaseFunction_Ray * result_Ray + GetScatteringCoefficientAtSealevel_Mie() * phaseFunction_Mie * result_Mie);
    // result = GetMainLight().color * GetScatteringCoefficientAtSealevel_Mie() * phaseFunction_Mie * result_Mie;
    return float4(result, 1);
   
}

#endif