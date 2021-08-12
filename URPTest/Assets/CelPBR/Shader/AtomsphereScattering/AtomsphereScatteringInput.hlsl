#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT
#define CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT

float _PlanetRadius;
float _AtomsphereHeight;
float3 _ScatteringCoefficientAtSealevel;
float _ScaleHeight;
float _SampleCount;

float GetPlanetRadius()
{
    return _PlanetRadius;
}

float GetAtomsphereHeight()
{
    return _AtomsphereHeight;
}

float3 GetScatteringCoefficientAtSealevel()
{
    return _ScatteringCoefficientAtSealevel;
}

float GetScaleHeight()
{
    return _ScaleHeight;
}

float GetAtomsphereScatteringSampleCount()
{
    return _SampleCount;
}

#endif