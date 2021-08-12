#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT
#define CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT

float _PlanetRadius;
float _AtomsphereHeight;
float _ScatteringCoefficientAtSealevel;
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

float GetScatteringCoefficientAtSealevel()
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