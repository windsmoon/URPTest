using System;
using UnityEngine;

namespace CelPBR.Runtime.AtomsphereScattering
{
    [ExecuteInEditMode]
    public class AtomsphereScatteringSkybox : MonoBehaviour
    {
        #region constants
        public const string PlanetRadiusPropertyName = "_PlanetRadius";
        public const string AtomsphereHeightPropertyName = "_AtomsphereHeight";
        public const string ScatteringCoefficientAtSealevelPropertyName = "_ScatteringCoefficientAtSealevel";
        public const string ScaleHeightPropertyName = "_ScaleHeight";
        public const string SampleCountPropertyName = "_SampleCount";
        #endregion
        
        #region fields
        [SerializeField] 
        private float planetRadius = 6371000;
        [SerializeField]
        private float atomsphereHeight = 60000;
        [SerializeField]
        private Vector3 scatteringCoefficientAtSealevel;
        [SerializeField]
        private float scaleHeight = 8500;
        [SerializeField]
        [Range(1, 32)]
        private int sampleCount = 16;

        private int planetRadiusPropertyID = Shader.PropertyToID("_PlanetRadius");
        private int atomsphereHeightPropertyID = Shader.PropertyToID("_AtomsphereHeight");
        private int scatteringCoefficientAtSealevelPropertyID = Shader.PropertyToID("_ScatteringCoefficientAtSealevel");
        private int scaleHeightPropertyID = Shader.PropertyToID("_ScaleHeight");
        private int sampleCountPropertyID = Shader.PropertyToID("_SampleCount");

        private Material material;
        #endregion

        #region unity methods
        private void Update()
        {
            material = RenderSettings.skybox;
            material.SetFloat(planetRadiusPropertyID,planetRadius);
            material.SetFloat(atomsphereHeightPropertyID, atomsphereHeight);
            material.SetVector(scatteringCoefficientAtSealevelPropertyID, new Vector4(0.0000058f, 0.0000135f, 0.0000331f, 0));
            material.SetFloat(scaleHeightPropertyID, scaleHeight);
            material.SetInt(sampleCountPropertyID, sampleCount);
        }
        #endregion
    }
}

// float _PlanetRadius;
// float _AtomsphereHeight;
// float _ScatteringCoefficientAtSealevel;
// float _ScaleHeight;
// float _SampleCount;