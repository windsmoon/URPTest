using UnityEngine;
using UnityEngine.Experimental.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing.RenderPasses
{
    public class ScreenSpaceRelfectionRenderPass : PostProcessingRenderPass
    {
        #region constants
        public const string ScreenSpaceRelfectionKeyword = "SCREEN_SPACE_REFLECTION";
        #endregion

        #region fields
        private int maxRayMarchingStepID = Shader.PropertyToID("_SSR_MaxRayMarchingStep");
        private int maxRayMarchingDistanceID = Shader.PropertyToID("_SSR_MaxRayMarchingDistance");
        private int rayMarchingStepDistanceID = Shader.PropertyToID("_SSR_RayMarchingStepDistance");
        private int depthThicknessID = Shader.PropertyToID("_SSR_DepthThickness");
        #endregion

        #region properties
        public override string ShaderName
        {
            get => "CelPBR/PostProcessing/Screen Space Reflection";
        }
        #endregion
        
        #region methods
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            SSRSetting ssrSetting = postProcessingSetting as SSRSetting;
            RenderSSRObject(ssrSetting, context, ref renderingData);
            ConfigureInput(ScriptableRenderPassInput.Normal);
            uberAgent.SetInt(maxRayMarchingStepID, ssrSetting.MaxRayMarchingStep);
            uberAgent.SetFloat(maxRayMarchingDistanceID, ssrSetting.MaxRayMarchingDistance);
            uberAgent.SetFloat(rayMarchingStepDistanceID, ssrSetting.RayMarchingStepDistance);
            uberAgent.SetFloat(depthThicknessID, ssrSetting.DepthThickness);
            uberAgent.EnableKeyword(ScreenSpaceRelfectionKeyword);
        }

        private void RenderSSRObject(SSRSetting ssrSetting, ScriptableRenderContext context, ref RenderingData renderingData)
        {
            SortingCriteria sortingCriteria = renderingData.cameraData.defaultOpaqueSortFlags;
            DrawingSettings drawingSettings = CreateDrawingSettings(null, ref renderingData, sortingCriteria);
            drawingSettings.SetShaderPassName(0, new ShaderTagId("SSRObject"));
            FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque, ssrSetting.SSRObjectLayer.value);
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
        }
        #endregion
    }
}