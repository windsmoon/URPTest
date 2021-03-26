#ifndef CEL_PBR_POSTPROCESSING_UBER_INCLUDED
#define CEL_PBR_POSTPROCESSING_UBER_INCLUDED

#include "SSR.hlsl"

TEXTURE2D(_PostProcessing_ColorTexture);
TEXTURE2D(_SSR_ObjectDataTexture);
TEXTURE2D(_PostProcessing_ColorTarget);

SAMPLER(sampler_PostProcessing_ColorTexture);
SAMPLER(sampler_SSR_ObjectDataTexture);
SAMPLER(sampler_PostProcessing_ColorTarget);

float4 UberFragment(Varyings input) : SV_TARGET
{
    return float4(SAMPLE_TEXTURE2D(_PostProcessing_ColorTarget, sampler_PostProcessing_ColorTarget, input.uv));
    real3 color = SAMPLE_TEXTURE2D(_PostProcessing_ColorTexture, sampler_PostProcessing_ColorTexture, input.uv);

    #if defined(POST_PROCESSING_SCREEN_SPACE_REFLECTION)
        float4 ssrObjecetData = SAMPLE_TEXTURE2D(_SSR_ObjectDataTexture, sampler_SSR_ObjectDataTexture, input.uv);

        if (ssrObjecetData.a > 0)
        {
            float3 posVS = GetPosVS(input.uv);
            float3 viewDirectionVS = normalize(posVS);
            float3 normalVS = GetNormalVS(input.uv);
            float3 reflectDirectionVS = reflect(viewDirectionVS, normalVS);
            float2 screenUV;

            if (viewSpaceRayMarching(posVS, reflectDirectionVS, screenUV))
            {
                color = color + ssrObjecetData.rgb * SAMPLE_TEXTURE2D(_PostProcessing_ColorTexture, sampler_PostProcessing_ColorTexture, screenUV).rgb;
            }
        }
    #endif

    // #if defined(POST_PROCESSING_OUTLINE)
    //     color = 1;
    // #endif

    // return _SSRColor;
    return float4(color, 1);
}

#endif