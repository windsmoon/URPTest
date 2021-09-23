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
        private Vector3 scatteringCoefficientAtSealevel_Mie;
        [SerializeField]
        private float scaleHeight = 8500;
        [SerializeField, Range(-1, 1)]
        private float mieG = 0.625f;
        [SerializeField]
        [Range(1, 32)]
        private int sampleCount = 16;

        private int planetRadiusPropertyID = Shader.PropertyToID("_PlanetRadius");
        private int atomsphereHeightPropertyID = Shader.PropertyToID("_AtomsphereHeight");
        private int scatteringCoefficientAtSealevelPropertyID = Shader.PropertyToID("_ScatteringCoefficientAtSealevel");
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
            
            material.SetFloat(planetRadiusPropertyID,planetRadius);
            material.SetFloat(atomsphereHeightPropertyID, atomsphereHeight);
            material.SetVector(scatteringCoefficientAtSealevelPropertyID, new Vector4(0.00000519673f, 0.0000121427f, 0.0000296453f, 0));
            // material.SetVector(scatteringCoefficientAtSealevel_MiePropertyID, new Vector4(0.0021f, 0.0021f, 0.0021f, 0));
            material.SetVector(scatteringCoefficientAtSealevel_MiePropertyID, new Vector4(0.000021f, 0.000021f, 0.000021f, 0));
            material.SetFloat(mieGPropertyID, mieG);
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