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
    float minLayerCount = 4;
    float maxLayerCont = 16;
    float layerCount = lerp(maxLayerCont, minLayerCount, saturate(dot(viewDir, real3(0, 0, 1))));
    
    float deltaDepth = 1 / layerCount;
    float2 totalParallaxUVOffset = parallaxUVDir * GetParallaxScale() * 0.01;
    float2 deltaUV = totalParallaxUVOffset / layerCount;
    real currentLayerDepth = 0;
    float2 currentUV = uv;
    
    for (int i = 0; i <= layerCount; ++i)
    {
        // parallaxedUV = parallaxedUV + GetParallaxHeight(parallaxedUV) * parallaxUVDir * 0.01;
        currentUV = uv + deltaUV * i;
        currentLayerDepth = deltaDepth * i;
        real depthMapValue = 1 - GetHeightMap(currentUV);
        
        if (depthMapValue <= currentLayerDepth)
        {
            break;
        }
    }
    
    return currentUV;
}

float2 GetParallaxOcclusionMapping(float2 uv, real3 viewDir)
{
    float2 parallaxUVDir = -viewDir.xy;
    float minLayerCount = 4;
    float maxLayerCont = 16;
    float layerCount = lerp(maxLayerCont, minLayerCount, saturate(dot(viewDir, real3(0, 0, 1))));
    
    float deltaDepth = 1 / layerCount;
    float2 totalParallaxUVOffset = parallaxUVDir * GetParallaxScale() * 0.01;
    float2 deltaUV = totalParallaxUVOffset / layerCount;

    float preLayerDepth = 0;
    float2 preUV = uv;
    float preDepthMapValue = 0;
    
    // first step
    float currentLayerDepth = 0;;
    float2 currentUV = uv;
    float currentDepthMapValue = 1 - GetHeightMap(currentUV);
    
    for (int i = 1; i <= layerCount; ++i)
    {
        preLayerDepth = currentLayerDepth;
        preUV = currentUV;
        preDepthMapValue = currentDepthMapValue;
        currentLayerDepth = deltaDepth * i;
        currentUV = uv + deltaUV * i;
        currentDepthMapValue = 1 - GetHeightMap(currentUV);
        
        if (currentDepthMapValue <= currentLayerDepth)
        {
            break;
        }
    }

    float preDepthDiff = preDepthMapValue - preLayerDepth;
    float currentDepthDiff = currentLayerDepth - currentDepthMapValue;
    float weight = currentDepthDiff / (currentDepthDiff + preDepthDiff);
    float2 finalUV = (1 - weight) * currentUV + weight * preUV;
    return finalUV;
}

float2 GetParallaxedUV(float2 uv, real3 viewDir)
{
    real parallaxMappingType = GetParallaxMappingType();

    if (parallaxMappingType == 0)
    {
        return uv;
    }
    
    if (parallaxMappingType == 1)
    {
        return ParallaxMapping(uv, viewDir);
    }

    if (parallaxMappingType == 2)
    {
        return SteepParallaxMapping(uv, viewDir);
    }

    if (parallaxMappingType == 3)
    {
        return GetParallaxOcclusionMapping(uv, viewDir);
    }

    return uv;
}
#endif