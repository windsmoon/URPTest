#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT
#define CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT

float _PlanetRadius;
float _AtomsphereHeight;
float3 _ScatteringCoefficientAtSealevel;
float3 _ScatteringCoefficientAtSealevel_Mie;
float _MieG;
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

float3 GetScatteringCoefficientAtSealevel_Mie()
{
    return _ScatteringCoefficientAtSealevel_Mie;
}

float GetMieG()
{
    return _MieG;
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