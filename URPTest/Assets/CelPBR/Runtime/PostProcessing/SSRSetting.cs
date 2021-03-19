using UnityEngine;

namespace CelPBR.Runtime.PostProcessing
{
    public class SSRSetting : PostProcessingSetting 
    {
        #region fields
        [SerializeField, Min(1)] 
        private int maxRayMarchingStep = 16;
        [SerializeField, Min(0.001f)]
        private float maxRayMarchingDistance = 10;
        [SerializeField, Min(0.001f)] 
        private float thickness = 0.001f;
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

        public float Thickness
        {
            get => thickness;
            set => thickness = value;
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