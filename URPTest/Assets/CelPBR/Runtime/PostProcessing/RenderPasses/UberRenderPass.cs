using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing.RenderPasses
{
    public class UberRenderPass : ScriptableRenderPass, IDisposable
    {
        #region constants
        #endregion

        #region fields
        private CommandBuffer commandBuffer;
        private Material material;
        #endregion

        #region constructors

        public UberRenderPass(CommandBuffer commandBuffer)
        {
            this.commandBuffer = commandBuffer;
            this.material = new Material(Shader.Find("CelPBR/PostProcessing/Uber"));
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }
        #endregion

        #region interface impls

        public void Dispose()
        {
            if (material != null)
            {
#if UNITY_EDITOR
                if (Application.isPlaying)
                {
                    UnityEngine.Object.Destroy(material);
                }

                else
                {
                    UnityEngine.Object.DestroyImmediate(material);
                }
#else
                UnityEngine.Object.Destroy(obj);
#endif
            }   
        }
        #endregion
        
        #region methods
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            commandBuffer.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, (int) 0);
            context.ExecuteCommandBuffer(commandBuffer);
            commandBuffer.Clear();
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            base.Configure(cmd, cameraTextureDescriptor);
        }
        #endregion
    }
}