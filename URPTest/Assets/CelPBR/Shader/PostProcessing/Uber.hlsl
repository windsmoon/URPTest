#ifndef CEL_PBR_POSTPROCESSING_UBER_INCLUDED
#define CEL_PBR_POSTPROCESSING_UBER_INCLUDED

#include "SSR.hlsl"

TEXTURE2D(_CameraOpaqueTexture);
SAMPLER(sampler_CameraOpaqueTexture);

real4 UberFragment(Varyings input) : SV_TARGET
{
    real4 color = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, input.uv);

    #if defined(SCREEN_SPACE_REFLECTION)
        float3 posVS = GetPosVS(input.uv);
        float3 viewDirectionVS = normalize(posVS);
        float3 normalVS = GetNormalVS(input.uv);
        float3 reflectDirectionVS = reflect(viewDirectionVS, normalVS);
        float2 screenUV;

        if (viewSpaceRayMarching(posVS, reflectDirectionVS, screenUV))
        {
            // return SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV);
            color += SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV);
        }

        // return 0;
    #endif

    // return _SSRColor;
    return color;
}

#endif