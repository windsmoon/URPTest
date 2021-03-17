using UnityEngine;
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
        private int ssrColorID = Shader.PropertyToID("_SSRColor");
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
            uberAgent.SetFloat(ssrColorID, 0.4f);
            uberAgent.EnableKeyword(ScreenSpaceRelfectionKeyword);
            commandBuffer.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, (int) 0);
            context.ExecuteCommandBuffer(commandBuffer);
            commandBuffer.Clear();
            // uberMaterial.EnableKeyword(ScreenSpaceRelfectionKeyword);
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            base.Configure(cmd, cameraTextureDescriptor);
        }

        #endregion
    }
}