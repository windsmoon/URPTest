#ifndef CEL_PBR_PARALLAX_MAPPING
#define CEL_PBR_PARALLAX_MAPPING

float2 ParallaxMapping(float2 uv, real3 viewDir)
{
    // view dir is from surface to camera
    float2 parallaxUVDir = -viewDir.xy / viewDir.z;
    // parallaxedUV.y = -1 * parallaxedUV.y;
    uv = uv + (1 - GetHeightMap(uv)) * GetParallaxScale() * parallaxUVDir * 0.01;
    return uv;
}

float2 SteepParallaxMapping(float2 uv, real3 viewDir)
{
    float2 parallaxUVDir = -viewDir.xy;
    float2 totalParallaxUVOffset = parallaxUVDir * 0.01 * GetParallaxScale();
    float layerCount = 20;
    float deltaDepth = 1 / layerCount;
    float2 deltaUV = totalParallaxUVOffset / layerCount;
    real currentDepth = 0;
    float2 parallaxedUV = 0;
    
    for (int i = 0; i <= layerCount; ++i)
    {
        // parallaxedUV = parallaxedUV + GetParallaxHeight(parallaxedUV) * parallaxUVDir * 0.01;
        parallaxedUV = uv + deltaUV * i;
        currentDepth = deltaDepth * i;
        real tempDepth = 1 - GetHeightMap(uv);
        
        if (tempDepth <= currentDepth)
        {
            break;
        }
    }
    
    return parallaxedUV;
}

float2 GetParallaxedUV(float2 uv, real3 viewDir)
{
    real parallaxMappingType = GetParallaxMappingType();

    if (parallaxMappingType == 0)
    {
        return ParallaxMapping(uv, viewDir);
    }

    else if (parallaxMappingType == 1)
    {
        return SteepParallaxMapping(uv, viewDir);
    }

    return uv;
}
#endif