#ifndef CEL_PBR_SCREEN_SPACE_REFLECTION
#define CEL_PBR_SCREEN_SPACE_REFLECTION

float _SSR_MaxRayMarchingStep;
float _SSR_MaxRayMarchingDistance;
float _SSR_RayMarchingStepDistance;
float _SSR_DepthThickness;

bool CheckDepthCollision(float3 posVS, out float2 screenPos)
{
    float3 realPosVS = posVS;
    realPosVS.z *= -1;
    float4 posHCS = TransformWViewToHClip(realPosVS);
    float4 posCS = posHCS / posHCS.w;
    screenPos = posCS * 0.5 + 0.5;
    float depthToPosVS = GetEyeDepth(screenPos);
    return screenPos.x > 0 && screenPos.y > 0 && screenPos.x < 1.0 && screenPos.y < 1.0 && depthToPosVS < posVS.z && (depthToPosVS + _SSR_DepthThickness) > posVS.z;
}

bool viewSpaceRayMarching(float3 original, float3 direction, out float2 hitScreenPos)
{
    // float rayMarchingStepSize = _SSR_MaxRayMarchingDistance / _SSR_MaxRayMarchingStep;

    UNITY_LOOP
    for(int i = 1; i <= _SSR_MaxRayMarchingStep; i++)
    {
        float3 currentPos = original + direction * _SSR_RayMarchingStepDistance * i;

        if (_SSR_RayMarchingStepDistance > _SSR_MaxRayMarchingDistance)
        {
            return false;
        }
        
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