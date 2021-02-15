#ifndef CEL_PBR_PARALLAX_MAPPING
#define CEL_PBR_PARALLAX_MAPPING

bool GetParallaxMappingSelfShadowAttenuation(float2 uv, real3 lightDir, real depth)
{
    float2 parallaxUVDir = lightDir.xy;
    float minLayerCount = 4;
    float maxLayerCont = 16;
    float layerCount = lerp(maxLayerCont, minLayerCount, saturate(dot(lightDir, real3(0, 0, 1))));

    float deltaDepth = depth / layerCount;
    float2 totalParallaxUVOffset = parallaxUVDir * (depth / lightDir.z) *  GetParallaxScale() * 0.01;
    float2 deltaUV = totalParallaxUVOffset / layerCount;

    real currentLayerDepth = depth;
    float2 currentUV = uv;
    float currentDepthMapValue = depth;

    for (int i = 0; i <= layerCount; ++i)
    {
        // parallaxedUV = parallaxedUV + GetParallaxHeight(parallaxedUV) * parallaxUVDir * 0.01;
        currentUV += deltaUV;
        currentLayerDepth -= deltaDepth;
        currentDepthMapValue = 1 - GetHeightMap(currentUV);
        
        if ((currentDepthMapValue + 0.05 ) < currentLayerDepth)
        {
            return 0;
        }
    }

    return 1;
}

float3 ParallaxMapping(float2 uv, real3 viewDir)
{
    // view dir is from surface to camera
    float2 parallaxUVDir = -viewDir.xy / viewDir.z;
    // parallaxedUV.y = -1 * parallaxedUV.y;
    uv = uv + (1 - GetHeightMap(uv)) * GetParallaxScale() * parallaxUVDir * 0.01;
    float depth = 1 - GetHeightMap(uv);
    return float3(uv, depth);
}

float3 SteepParallaxMapping(float2 uv, real3 viewDir)
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
    float currentDepthMapValue = 0;
    
    for (int i = 0; i <= layerCount; ++i)
    {
        // parallaxedUV = parallaxedUV + GetParallaxHeight(parallaxedUV) * parallaxUVDir * 0.01;
        currentUV = uv + deltaUV * i;
        currentLayerDepth = deltaDepth * i;
        currentDepthMapValue = 1 - GetHeightMap(currentUV);
        
        if (currentDepthMapValue <= currentLayerDepth)
        {
            break;
        }
    }
    
    return float3(currentUV, currentDepthMapValue);
}

float3 GetParallaxOcclusionMapping(float2 uv, real3 viewDir)
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
    float finalDepth = (1 - weight) * currentDepthMapValue + weight * preDepthMapValue;
    return float3(finalUV, finalDepth);
}

float3 GetRelifParallaxMapping(float2 uv, real3 viewDir)
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

    float startDepth = preLayerDepth;
    float endDepth = currentLayerDepth;
    float2 startUV = preUV;
    float2 endUV = currentUV;
    
    // binary search
    float minSearchStepCount = 4;
    float maxSearchStepCount = 16;
    float searchStepCount = lerp(maxSearchStepCount, minSearchStepCount, saturate(dot(viewDir, real3(0, 0, 1))));

    for (int i = 0; i < searchStepCount; ++i)
    {
        float midDepth = 0.5 * (startDepth + endDepth);
        float2 midUV = 0.5 * (startUV + endUV);
        float midDepthMapValue = 1 - GetHeightMap(midUV);
    
        if (midDepth > midDepthMapValue) // inside surface
        {
            endDepth = midDepth;
            endUV = midUV;
        }
    
        else if (midDepth < midDepthMapValue)
        {
            startDepth = midDepth;
            startUV = midUV;
        }
    
        else // equal
        {
            return float3(midUV, midDepth);
        }
    }
    
    return float3(startUV + endUV, startDepth = endDepth) * 0.5;
}

float3 GetParallaxMappingResult(float2 uv, real3 viewDir)
{
    real parallaxMappingType = GetParallaxMappingType();

    if (parallaxMappingType == 0)
    {
        return float3(uv, 1);
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

    if (parallaxMappingType == 4)
    {
        return GetRelifParallaxMapping(uv, viewDir);
    }

    return float3(uv, 1);
}
#endif