using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing.RenderPasses
{
    public abstract class PostProcessingRenderPass : ScriptableRenderPass
    {
        #region constructors
        protected PostProcessingRenderPass()
        {
            this.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }
        #endregion
    }
}