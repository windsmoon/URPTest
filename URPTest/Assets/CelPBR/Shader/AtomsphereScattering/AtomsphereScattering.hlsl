#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING
#define CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING

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

#endif