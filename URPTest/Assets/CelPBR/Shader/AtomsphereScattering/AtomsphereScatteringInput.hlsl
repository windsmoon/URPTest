#ifndef CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT
#define CEL_PBR_ATOMSPHERE_SCATTERING_ATOMSPHERE_SCATTERING_INPUT

float _PlanetRadius;
float _AtomsphereHeight;
float3 _ScatteringCoefficientAtSealevel_Ray;
float _ScatteringCoefficientAtSealevel_Mie;
float _MieG;
float2 _ScaleHeight;
float _SampleCount;

float GetPlanetRadius()
{
    return _PlanetRadius;
}

float GetAtomsphereHeight()
{
    return _AtomsphereHeight;
}

float3 GetScatteringCoefficientAtSealevel_Ray()
{
    return _ScatteringCoefficientAtSealevel_Ray;
}

float3 GetScatteringCoefficientAtSealevel_Mie()
{
    return _ScatteringCoefficientAtSealevel_Mie;
}

float GetMieG()
{
    return _MieG;
}

float GetScaleHeight_Ray()
{
    return _ScaleHeight.x;
}

float GetScaleHeight_Mie()
{
    return _ScaleHeight.y;
}

float GetAtomsphereScatteringSampleCount()
{
    return _SampleCount;
}

#endif