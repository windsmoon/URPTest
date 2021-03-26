using System;
using System.Globalization;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing
{
    public class PrePostProcessingRenderPass : ScriptableRenderPass, IDisposable
    {
        #region fields
        private CommandBuffer commandBuffer;
        private RenderTexture colorTexture;
        private static int colorTextureID = Shader.PropertyToID("_PostProcessing_ColorTexture");
        private static int colorTargetID = Shader.PropertyToID("_PostProcessing_ColorTarget");
        private RenderTargetIdentifier colorTextureIdentifier = new RenderTargetIdentifier(colorTextureID, 0, CubemapFace.Unknown, -1);
        private RenderTargetIdentifier colorTargetIdentifier = new RenderTargetIdentifier(colorTargetID, 0, CubemapFace.Unknown, -1);
        private ScriptableRenderer scriptableRenderer;
        #endregion

        #region constructors
        public PrePostProcessingRenderPass(ScriptableRenderer scriptableRenderer)
        {
            commandBuffer = new CommandBuffer();
            commandBuffer.name = "Pre Post Processing";
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
            this.scriptableRenderer = scriptableRenderer;
        }
        #endregion
        
        #region interface impls
        public void Dispose()
        {
        }
        #endregion
        
        #region methods
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            // todo : depth
            commandBuffer.GetTemporaryRT(colorTextureID, renderingData.cameraData.cameraTargetDescriptor);
            commandBuffer.GetTemporaryRT(colorTargetID, renderingData.cameraData.cameraTargetDescriptor);
            // commandBuffer.Blit(new RenderTargetIdentifier("_CameraColorTexture"), colorTextureIdentifier);
            // commandBuffer.SetRenderTarget(colorTargetIdentifier, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
            commandBuffer.SetRenderTarget(colorTargetIdentifier, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store,
                scriptableRenderer.cameraDepthTarget, RenderBufferLoadAction.Load, RenderBufferStoreAction.Store);
            context.ExecuteCommandBuffer(commandBuffer);
            context.Submit();
            commandBuffer.Clear();
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            base.OnCameraCleanup(cmd);
            commandBuffer.ReleaseTemporaryRT(colorTextureID);
            commandBuffer.ReleaseTemporaryRT(colorTargetID);
        }

        #endregion
    }
}