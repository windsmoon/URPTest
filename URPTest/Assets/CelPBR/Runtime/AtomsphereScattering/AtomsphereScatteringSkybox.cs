using System;
using UnityEngine;
using UnityEngine.Serialization;

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
        private float atomsphereHeight = 100000;
        [FormerlySerializedAs("scatteringCoefficientAtSealevel")] 
        [SerializeField]
        private Vector3 scatteringCoefficientAtSealevel_Ray = new Vector3(5.8f, 13.5f, 33.1f);
        [SerializeField]
        private float scatteringCoefficientAtSealevel_Mie = 2f;
        [SerializeField]
        private Vector2 scaleHeight = new Vector2(7994, 1200);
        [SerializeField, Range(-1, 1)]
        private float mieG = 0.625f;
        [SerializeField]
        [Range(1, 32)]
        private int sampleCount = 16;

        private int planetRadiusPropertyID = Shader.PropertyToID("_PlanetRadius");
        private int atomsphereHeightPropertyID = Shader.PropertyToID("_AtomsphereHeight");
        private int scatteringCoefficientAtSealevel_RayPropertyID = Shader.PropertyToID("_ScatteringCoefficientAtSealevel_Ray");
        private int scatteringCoefficientAtSealevel_MiePropertyID = Shader.PropertyToID("_ScatteringCoefficientAtSealevel_Mie");
        private int mieGPropertyID = Shader.PropertyToID("_MieG");
        private int scaleHeightPropertyID = Shader.PropertyToID("_ScaleHeight");
        private int sampleCountPropertyID = Shader.PropertyToID("_SampleCount");

        private Material material;
        #endregion

        #region unity methods
        private void Update()
        {
            // 5.8f, 13.5f, 33.1f
            // (2.0f, 2.0f, 2.0f);
            // mieG = 0.625f;
            //             var rCoef = this.rCoef * 0.000001f;
            // var mCoef = this.mCoef * 0.00001f;
            material = RenderSettings.skybox;
            Vector3 scatteringCoefficient = scatteringCoefficientAtSealevel_Ray * 0.000001f;
            material.SetFloat(planetRadiusPropertyID,planetRadius);
            material.SetFloat(atomsphereHeightPropertyID, atomsphereHeight);
            material.SetVector(scatteringCoefficientAtSealevel_RayPropertyID, scatteringCoefficient);
            material.SetFloat(scatteringCoefficientAtSealevel_MiePropertyID, scatteringCoefficientAtSealevel_Mie * 0.00001f);
            material.SetFloat(mieGPropertyID, mieG);
            material.SetVector(scaleHeightPropertyID, scaleHeight);
            material.SetInt(sampleCountPropertyID, sampleCount);
        }
        #endregion

        #region methods
        private void SetPropertiesForEarty()
        {
        }
        #endregion
    }
}

// float _PlanetRadius;
// float _AtomsphereHeight;
// float _ScatteringCoefficientAtSealevel;
// float _ScaleHeight;
// float _SampleCount;