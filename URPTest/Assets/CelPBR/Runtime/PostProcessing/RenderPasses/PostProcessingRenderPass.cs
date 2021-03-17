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
        protected PostProcessingSetting postProcessingSetting;
        protected UberAgent uberAgent;
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

        public void SetData(UberAgent ubaerAgent, PostProcessingSetting postProcessingSetting)
        {
            this.uberAgent = ubaerAgent;
            this.postProcessingSetting = postProcessingSetting;
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
    }
}