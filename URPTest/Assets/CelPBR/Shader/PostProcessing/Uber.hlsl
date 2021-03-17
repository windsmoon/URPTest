#ifndef CEL_PBR_POSTPROCESSING_UBER_INCLUDED
#define CEL_PBR_POSTPROCESSING_UBER_INCLUDED

#include "ScreenSpaceReflection.hlsl"

real4 UberFragment(Varyings input) : SV_TARGET
{
    #if defined(SCREEN_SPACE_REFLECTION)
        return _SSRColor;
    #endif

    // return _SSRColor;
    return real4(GetPosVS(input.uv), 1);
}

#endif