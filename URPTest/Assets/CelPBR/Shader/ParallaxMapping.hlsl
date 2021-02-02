#ifndef CEL_PBR_PARALLAX_MAPPING
#define CEL_PBR_PARALLAX_MAPPING

float2 GetParallaxedUV(float2 uv, real3 viewDir)
{
    float2 parallaxedUV = uv;
    // todo : caculate in a hlsl file
    float2 parallaxUVDir = viewDir.xy / viewDir.z;

    for (int i = 0; i < 10; ++i)
    {
        parallaxedUV = parallaxedUV + GetParallaxHeight(parallaxedUV) * parallaxUVDir * 0.01;
    }

    return parallaxedUV;
}
#endif