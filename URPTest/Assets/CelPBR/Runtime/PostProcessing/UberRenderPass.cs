using System;
using System.Globalization;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing
{
    public class UberRenderPass : ScriptableRenderPass, IDisposable
    {
        #region delegates
        public delegate void BeforeUberRenderPassExecuteDelegate();
        public delegate void OnUberRenderPassExecutedDelegate(CommandBuffer commandBuffer);
        public BeforeUberRenderPassExecuteDelegate BeforeUberRenderPassExecute;
        public OnUberRenderPassExecutedDelegate OnUberRenderPassExecuted;
        #endregion
        
        #region fields
        private CommandBuffer commandBuffer;
        private Material material;
        #endregion

        #region constructors
        public UberRenderPass()
        {
            this.commandBuffer = new CommandBuffer();
            this.commandBuffer.name = "Postprocessing Uber";
            this.material = new Material(Shader.Find("CelPBR/PostProcessing/Uber"));;
            // this.material = new Material(Shader.Find("CelPBR/PostProcessing/Uber"));
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }
        #endregion
        
        #region Properties
        public Material Material
        {
            get => material;
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
            if (BeforeUberRenderPassExecute != null)
            {
                BeforeUberRenderPassExecute();
            }
            
            ConfigureInput(ScriptableRenderPassInput.Normal);
            commandBuffer.SetRenderTarget(PostProcessingRenderFeature.CameraColorIdentifier);
            commandBuffer.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, (int) 0);

            // this step is essential or the rts will be leak in memory
            if (OnUberRenderPassExecuted != null)
            {
                OnUberRenderPassExecuted(commandBuffer);
            }

            context.ExecuteCommandBuffer(commandBuffer);
            commandBuffer.Clear();
        }
        #endregion
    }
}