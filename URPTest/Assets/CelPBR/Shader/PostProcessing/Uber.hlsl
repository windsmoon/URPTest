#ifndef CEL_PBR_POSTPROCESSING_UBER_INCLUDED
#define CEL_PBR_POSTPROCESSING_UBER_INCLUDED

#include "SSR.hlsl"
#include "Outline.hlsl"

TEXTURE2D(_PostProcessing_OutlineTexture);
TEXTURE2D(_SSR_ObjectDataTexture);

// SAMPLER(sampler_SSR_ObjectDataTexture);

float4 UberFragment(Varyings input) : SV_TARGET
{
    // return float4(SAMPLE_TEXTURE2D(_PostProcessing_ColorTarget, sampler_PostProcessing_ColorTarget, input.uv));
    real3 color = SAMPLE_TEXTURE2D(_PostProcessing_ColorTexture, sampler_PostProcessing_ColorTexture, input.uv);

    #if defined(POST_PROCESSING_SCREEN_SPACE_REFLECTION)
        float4 ssrObjecetData = SAMPLE_TEXTURE2D(_SSR_ObjectDataTexture, sampler_PostProcessing_ColorTexture, input.uv);

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

    #if defined(POST_PROCESSING_OUTLINE)
        // real edge = Sobel(input.uv);
        real edgeStrength = GetEdgeStrength(input.uv);
    // return float4(edge.rrr, color.r);
        color = lerp(color, _Outline_Color.rgb * color, edgeStrength);
    #endif

    return float4(color, 1);
}

#endif