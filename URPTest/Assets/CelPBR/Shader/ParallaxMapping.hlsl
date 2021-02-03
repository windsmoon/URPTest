#ifndef CEL_PBR_PARALLAX_MAPPING
#define CEL_PBR_PARALLAX_MAPPING

float2 ParallaxMapping(float2 uv, real3 viewDir)
{
    float2 parallaxedUV = uv;
    float2 parallaxUVDir = viewDir.xy / viewDir.z;
    parallaxedUV = parallaxedUV - GetParallaxHeight(parallaxedUV) * parallaxUVDir * 0.1;
    return parallaxedUV;
}

float2 SteepParallaxMapping(float2 uv, real3 viewDir)
{
    float2 parallaxedUV = uv;
    float2 parallaxUVOffset = viewDir.xy * GetParallaxScale();
    float layerCount = 10;
    float deltaHeight = 1 / layerCount;
    float2 deltaUV = parallaxUVOffset * 0.1 / layerCount;
    real currentHeight = 0;
    
    for (int i = 0; i < layerCount; ++i)
    {
        // parallaxedUV = parallaxedUV + GetParallaxHeight(parallaxedUV) * parallaxUVDir * 0.01;
        parallaxedUV -= deltaUV * i;
        currentHeight += deltaHeight;
        real tempHeight = GetHeightMap(parallaxedUV);
        
        if (currentHeight >= tempHeight)
        {
            break;
        }
    }
    
    return parallaxedUV;
}

float2 GetParallaxedUV(float2 uv, real3 viewDir)
{
    return ParallaxMapping(uv, viewDir);
    // return SteepParallaxMapping(uv, viewDir);
}
#endif