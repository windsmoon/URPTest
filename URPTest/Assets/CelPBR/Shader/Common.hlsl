#ifndef CEL_PBR_COMMON
#define CEL_PBR_COMMON

float3 GetHalfDirection(float3 direction1, float3 direciont2)
{
    return normalize(direction1 + direciont2);
}

#endif