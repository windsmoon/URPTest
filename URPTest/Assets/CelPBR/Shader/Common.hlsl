#ifndef CEL_PBR_COMMON
#define CEL_PBR_COMMON

float3 GetHalfDirection(float3 direction1, float3 direciont2)
{
    return normalize(direction1 + direciont2);
}

real3x3 GetTBN(real3 normal, real3 tangent, real3 bitangent)
{
    float3 normalWS = normal;
    float3 tangentWS = tangent;
    float3 bitangentWS = bitangent;
    return float3x3(tangentWS, bitangentWS, normalWS);
}

float Random01(float2 seed)
{
    return 0.5 * frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453123) + 0.5;
}


#endif