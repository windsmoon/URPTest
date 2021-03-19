#ifndef CEL_PBR_SCREEN_SPACE_REFLECTION
#define CEL_PBR_SCREEN_SPACE_REFLECTION

float _SSR_MaxRayMarchingStep;
float _SSR_MaxRayMarchingDistance;
float _SSR_DepthThickness;

bool CheckDepthCollision(float3 posVS, out float2 screenPos)
{
    float4 posHCS = TransformWViewToHClip(posVS);
    float4 posCS = posHCS / posHCS.w;
    screenPos = posCS * 0.5 + 0.5;
    float depthToPosVS = GetEyeDepth(screenPos);
    return screenPos.x > 0 && screenPos.y > 0 && screenPos.x < 1.0 && screenPos.y < 1.0 && depthToPosVS < posVS.z;
}

bool viewSpaceRayMarching(float3 original, float3 direction, out float2 hitScreenPos)
{
    float rayMarchingStepSize = _SSR_MaxRayMarchingDistance / _SSR_MaxRayMarchingStep;

    UNITY_LOOP
    for(int i = 1; i < _SSR_MaxRayMarchingStep; i++)
    {
        float3 currentPos = original + direction * rayMarchingStepSize * i;
        // if (length(original - currentPos) > _ScreenSpaceReflection_MaxRayMarchingDistance)
        //     return false;
        
        if (CheckDepthCollision(currentPos, hitScreenPos))
        {
            return true;
        }
    }
    
    return false;
}


real4 ScreenSpaceReflectionFragment(Varyings input) : SV_TARGET
{
    return 1;
}

#endif