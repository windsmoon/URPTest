using UnityEngine;

namespace CelPBR.Runtime.PostProcessing
{
    public class ScreenSpaceReflectionSetting : PostProcessingSetting 
    {
        #region fields
        [SerializeField]
        [Range(0, 8)]
        private int downSampleScale = 2;
        #endregion

        #region properties
        public override string PostProcessingName
        {
            get => "Screen Space Reflection";
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