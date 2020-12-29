#ifndef COMMON_CEL_PBR
#define COMMON_CEL_PBR

float3 GetHalfDirection(float3 direction1, float3 direciont2)
{
    return normalize(direction1 + direciont2);
}

#endif