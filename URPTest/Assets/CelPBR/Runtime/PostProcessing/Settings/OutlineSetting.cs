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
        private Color color;
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
            get
            {
                return color;
            }
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