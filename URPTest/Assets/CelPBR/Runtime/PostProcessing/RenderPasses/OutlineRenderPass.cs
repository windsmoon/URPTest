using CelPBR.Runtime.PostProcessing.Settings;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing.RenderPasses
{
    public class OutlineRenderPass : PostProcessingRenderPass
    {
        #region fields
        private int colorID = Shader.PropertyToID("_Outline_Color");
        private static int outlineTextureID = Shader.PropertyToID("_PostProcessing_OutlineTexture");
        private RenderTargetIdentifier outlineTextureIdentifier = new RenderTargetIdentifier(outlineTextureID, 0, CubemapFace.Unknown, -1);
        // private static int maskTextureID = Shader.PropertyToID("_Outline_MaskTexture"); 
        // private RenderTargetIdentifier maskTextureIdentifier = new RenderTargetIdentifier(maskTextureID, 0, CubemapFace.Unknown, -1);
        #endregion
        
        #region properties
        public override string ShaderName
        {
            get
            {
                return "CelPBR/PostProcessing/Outline";
            }
        }

        public override string CommandBufferName
        {
            get
            {
                return "Post Processing Outline";
            }
        }
        #endregion
        
        #region methods
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            // RenderTextureDescriptor renderTextureDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            // // todo RenderTextureFormat.R8
            // commandBuffer.GetTemporaryRT(outlineTextureID, renderTextureDescriptor.width, renderTextureDescriptor.height, 0, FilterMode.Point, RenderTextureFormat.R8);
            // commandBuffer.SetRenderTarget(outlineTextureIdentifier, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
            // commandBuffer.ClearRenderTarget(true, true, new Color(0, 0, 0, 0));
            OutlineSetting outlineSetting = postProcessingSetting as OutlineSetting;
            uberAgent.SetColor(colorID, outlineSetting.Color);
            // commandBuffer.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 0);
            // context.ExecuteCommandBuffer(commandBuffer);
            // context.Submit();
            // commandBuffer.Clear();
            // uberAgent.RegistRT(outlineTextureID);
        }
        #endregion
    }
}