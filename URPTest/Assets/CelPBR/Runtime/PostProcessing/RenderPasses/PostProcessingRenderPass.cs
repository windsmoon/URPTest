using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing.RenderPasses
{
    public abstract class PostProcessingRenderPass : ScriptableRenderPass, IDisposable
    {
        #region fields
        protected CommandBuffer commandBuffer;
        protected Material material;
        #endregion
        
        #region constructors
        protected PostProcessingRenderPass()
        {
            commandBuffer = new CommandBuffer();
            this.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }
        #endregion

        #region properties
        public abstract string ShaderName
        {
            get;
        }
        #endregion

        #region methods

        public void Init()
        { 
            material = new Material(Shader.Find(ShaderName));
        }
        #endregion

        #region interface impls

        public void Dispose()
        {
                        
        }
        #endregion
    }
}