using UnityEngine;
using UnityEngine.Serialization;

namespace CelPBR.Runtime.PostProcessing
{
    public class SSRSetting : PostProcessingSetting 
    {
        #region fields
        [SerializeField, Min(1)] 
        private int maxRayMarchingStep = 16;
        [SerializeField, Min(0.001f)]
        private float maxRayMarchingDistance = 10;
        [SerializeField]
        private float rayMarchingStepDistance = 0.5f;
        [SerializeField]
        private float depthThickness = 0.1f;
        [SerializeField] 
        private LayerMask ssrObjectLayer = -1;
        #endregion

        #region properties
        public override string PostProcessingName
        {
            get => "Screen Space Reflection";
        }
        
        public int MaxRayMarchingStep
        {
            get => maxRayMarchingStep;
            set => maxRayMarchingStep = value;
        }

        public float MaxRayMarchingDistance
        {
            get => maxRayMarchingDistance;
            set => maxRayMarchingDistance = value;
        }

        public float RayMarchingStepDistance
        {
            get { return rayMarchingStepDistance; }
            set { rayMarchingStepDistance = value; }
        }

        public float DepthThickness
        {
            get => depthThickness;
            set => depthThickness = value;
        }

        public LayerMask SSRObjectLayer
        {
            get { return ssrObjectLayer; }
            set { ssrObjectLayer = value; }
        }
        #endregion

        #region methods
        public override bool IsEnabled()
        {
            return base.IsEnabled();
        }
        #endregion
    }
}