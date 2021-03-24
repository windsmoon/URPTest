using CelPBR.Runtime.PostProcessing.Settings;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing.RenderPasses
{
    public class OutlineRenderPass : PostProcessingRenderPass
    {
        #region fields
        private int outlineColorID = Shader.PropertyToID("_Outline");
        #endregion
        
        #region properties
        public override string ShaderName
        {
            get
            {
                return "CelPBR/PostProcessing/Outline";
            }
        }
        #endregion
        
        #region methods
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            OutlineSetting outlineSetting = postProcessingSetting as OutlineSetting;
            uberAgent.SetColor(outlineColorID, outlineSetting.Color);
        }
        #endregion
    }
}