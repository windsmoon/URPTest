#ifndef CEL_PBR_POST_PROCESSING_OUTLINE_INCLUDED
#define CEL_PBR_POST_PROCESSING_OUTLINE_INCLUDED

#include "Common.hlsl"

real3 _Outline_Color;
TEXTURE2D(_PostProcessing_ColorTexture);
SAMPLER(sampler_PostProcessing_ColorTexture);

real4 OutlineFragment(Varyings input) : SV_TARGET
{
    return real4(_Outline_Color, 1);
}

#endif