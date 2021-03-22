using UnityEngine;
using UnityEngine.Experimental.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing.RenderPasses
{
    public class ScreenSpaceRelfectionRenderPass : PostProcessingRenderPass
    {
        #region fields
        private static int maxRayMarchingStepID = Shader.PropertyToID("_SSR_MaxRayMarchingStep");
        private static int maxRayMarchingDistanceID = Shader.PropertyToID("_SSR_MaxRayMarchingDistance");
        private static int rayMarchingStepDistanceID = Shader.PropertyToID("_SSR_RayMarchingStepDistance");
        private static int depthThicknessID = Shader.PropertyToID("_SSR_DepthThickness");
        private static int objectDataTextureID = Shader.PropertyToID("_SSR_ObjectDataTexture");

        private RenderTargetIdentifier objectDataTextureIdentifier = new RenderTargetIdentifier(objectDataTextureID, 0, CubemapFace.Unknown, -1);
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

            int width = renderingData.cameraData.cameraTargetDescriptor.width;
            int height = renderingData.cameraData.cameraTargetDescriptor.height;
            int depth = renderingData.cameraData.cameraTargetDescriptor.depthBufferBits;
            // // commandBuffer.GetTemporaryRT(objectDataTextureID, renderingData.cameraData.cameraTargetDescriptor, FilterMode.Point);
            // commandBuffer.GetTemporaryRT(objectDataTextureID, width, height, depth, FilterMode.Point, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            //
            // commandBuffer.SetRenderTarget(objectDataTextureIdentifier, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store, 
            //     objectDataTextureIdentifier, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
            //
            // commandBuffer.ClearRenderTarget(true, true, new Color(0, 0, 0, 0));
            // context.ExecuteCommandBuffer(commandBuffer);
            // context.Submit();
            RenderSSRObject(ssrSetting, context, ref renderingData);
            commandBuffer.Clear();
            // todo
            commandBuffer.SetRenderTarget(new RenderTargetIdentifier("_CameraColorTexture"));
            context.ExecuteCommandBuffer(commandBuffer);
            context.Submit();
            commandBuffer.Clear();
            // uberAgent.RegistRT(objectDataTextureID);
            ConfigureInput(ScriptableRenderPassInput.Normal);
            uberAgent.SetInt(maxRayMarchingStepID, ssrSetting.MaxRayMarchingStep);
            uberAgent.SetFloat(maxRayMarchingDistanceID, ssrSetting.MaxRayMarchingDistance);
            uberAgent.SetFloat(rayMarchingStepDistanceID, ssrSetting.RayMarchingStepDistance);
            uberAgent.SetFloat(depthThicknessID, ssrSetting.DepthThickness);
            // uberAgent.SetTexture(objectDataTextureID, object);
            // uberAgent.EnableKeyword(ScreenSpaceRelfectionKeyword);
        }

        private void RenderSSRObject(SSRSetting ssrSetting, ScriptableRenderContext context, ref RenderingData renderingData)
        {
            SortingCriteria sortingCriteria = renderingData.cameraData.defaultOpaqueSortFlags;
            DrawingSettings drawingSettings = CreateDrawingSettings(null, ref renderingData, sortingCriteria);
            drawingSettings.SetShaderPassName(0, new ShaderTagId("SSRObjectData"));
            FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque, ssrSetting.SSRObjectLayer.value);
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
        }
        #endregion
    }
}