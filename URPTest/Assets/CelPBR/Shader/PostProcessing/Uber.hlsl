#ifndef CEL_PBR_POSTPROCESSING_UBER_INCLUDED
#define CEL_PBR_POSTPROCESSING_UBER_INCLUDED

real4 UberFragment(Varyings input) : SV_TARGET
{
    return real4(GetPosVS(input.uv), 1);
}

#endif