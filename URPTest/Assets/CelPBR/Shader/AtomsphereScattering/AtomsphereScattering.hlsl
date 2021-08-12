#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING
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

float CaculateDensityRatio(float height)
{
    return exp(-height / GetScaleHeight());
}

float CaculateOpticalDepth(float3 startPoint, float3 rayDirection, float rayLength, float3 planentCenter)
{
    int sampleCount = GetAtomsphereScatteringSampleCount();
    float stepLength = rayLength / sampleCount;
    float3 stepVector = stepLength * rayDirection;
    float3 currentPoint = startPoint + stepVector * 0.5;
    float opticalDepth = 0;
    
    for (int i = 0; i < sampleCount; ++i)
    {
        float currentHeight = distance(planentCenter, currentPoint) - GetPlanetRadius();
        opticalDepth += CaculateDensityRatio(currentHeight) * stepLength;
        currentPoint += stepVector;
    }

    return opticalDepth;
}

float3 CaculateSingleScattering(float3 viewRayOriginal, float3 viewRayDirection, float viewRayLength, float3 planetCenter)
{
    int sampleCount = GetAtomsphereScatteringSampleCount();
    float stepLength = viewRayLength / sampleCount;
    float3 stepVector = viewRayDirection * stepLength;
    float3 currentPoint = viewRayOriginal + stepVector * 0.5;
    float3 result = 0;
    float3 lightDirection = GetMainLight().direction;
    float opticalDepthViewPoint = 0; // to optimize the caculate times

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
                result += 0;
                continue;;
            }
        }

        // always should has intersections
        RaySphereIntersection(currentPoint, lightDirection, planetCenter, GetPlanetRadius() + GetAtomsphereHeight(), intersectionParameters);
        float opticalDepth = CaculateOpticalDepth(currentPoint, lightDirection, intersectionParameters.y, planetCenter);
        // opticalDepthViewPoint += CaculateDensityRatio(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;
        opticalDepthViewPoint = CaculateOpticalDepth(viewRayOriginal, viewRayDirection, stepLength * (i + 1), planetCenter);

        float totalOpticalDepth = opticalDepth + opticalDepthViewPoint;
        result += exp(-GetScatteringCoefficientAtSealevel() * totalOpticalDepth) * CaculateDensityRatio(distance(currentPoint, planetCenter) - GetPlanetRadius()) * stepLength;
        currentPoint += stepVector;
    }

    result = GetMainLight().color * GetScatteringCoefficientAtSealevel() * 3 / (16 * PI) * (1 + pow(dot(viewRayDirection, lightDirection), 2)) * result;
    return result;
}

#endif