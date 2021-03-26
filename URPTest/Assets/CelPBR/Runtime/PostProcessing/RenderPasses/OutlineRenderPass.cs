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
        #endregion
        
        #region methods
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            OutlineSetting outlineSetting = postProcessingSetting as OutlineSetting;
            // commandBuffer.SetRenderTarget(maskTextureIdentifier, RenderBufferLoadAction.Clear, RenderBufferStoreAction.Store, );
            material.SetColor(colorID, outlineSetting.Color);
            commandBuffer.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 0);
            context.ExecuteCommandBuffer(commandBuffer);
            context.Submit();
            commandBuffer.Clear();
        }
        #endregion
    }
}