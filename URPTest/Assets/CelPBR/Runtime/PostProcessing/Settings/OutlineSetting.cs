using UnityEngine;

namespace CelPBR.Runtime.PostProcessing.Settings
{
    public class OutlineSetting : PostProcessingSetting
    {
        #region constants
        public const string outlineKeyword = "POST_PROCESSING_OUTLINE";
        #endregion
        
        #region fields
        [SerializeField] 
        private Color color = UnityEngine.Color.black;
        [SerializeField, Range(1, 10)]
        private int sampleDistance = 1;
        [SerializeField, Range(0, 0.01f)]
        private float depthThreshold = 0.001f;
        [SerializeField, Range(0, 0.3f)]
        private float normalThreshold = 0.2f;
        #endregion
        
        #region properties
        public override string PostProcessingName
        {
            get
            {
                return "Outline";
            }
        }

        public Color Color
        {
            get { return color; }
            set { color = value; }
        }

        public int SampleDistance
        {
            get { return sampleDistance; }
            set { sampleDistance = value; }
        }

        public float DepthThreshold
        {
            get { return depthThreshold; }
            set { depthThreshold = value; }
        }

        public float NormalThreshold
        {
            get { return normalThreshold; }
            set { normalThreshold = value; }
        }
        #endregion

        #region methods
        public override void OnEnabled()
        {
            base.OnEnabled();
            Shader.EnableKeyword(outlineKeyword);
        }

        public override void OnDisabled()
        {
            base.OnDisabled();
            Shader.DisableKeyword(outlineKeyword);
        }
        #endregion
    }
}