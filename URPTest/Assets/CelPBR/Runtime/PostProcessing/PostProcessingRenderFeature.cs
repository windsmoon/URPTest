using System.Collections.Generic;
using CelPBR.Runtime.PostProcessing.RenderPasses;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Serialization;

namespace CelPBR.Runtime.PostProcessing
{
    #region fields
    public class PostProcessingRenderFeature : ScriptableRendererFeature
    {
        #region fields
        // private Shader uberShader;
        // private Material uberMaterial;
        // private CommandBuffer uberCommandBuffer;
        private UberRenderPass uberRenderPass;
        private PrePostProcessingRenderPass prePostProcessingRenderPass;
        private UberAgent uberAgent;
        private List<PostProcessingType> existPostProcessingTypeList;
        private Dictionary<int, PostProcessingRenderPass> postProcessingRenderPassDict;
        private static RenderTargetIdentifier cameraColorIdentifier = new RenderTargetIdentifier("_CameraColorTexture");
        #endregion

        #region properties
        public static RenderTargetIdentifier CameraColorIdentifier
        {
            get { return cameraColorIdentifier; }
        }
        #endregion

        #region methods
        public override void Create()
        {
            // if (uberShader == null)
            // {
            //     uberShader = Shader.Find("CelPBR/PostProcessing/Uber");
            // }
            //
            // if (uberMaterial == null)
            // {
            //     uberMaterial = new Material(uberShader);
            // }

            // if (uberCommandBuffer == null)
            // {
            //     uberCommandBuffer = new CommandBuffer();
            // }

            postProcessingRenderPassDict = new Dictionary<int, PostProcessingRenderPass>();
            postProcessingRenderPassDict[(int)PostProcessingType.ScreenSpaceRelfection] = new ScreenSpaceRelfectionRenderPass();
            postProcessingRenderPassDict[(int)PostProcessingType.Outline] = new OutlineRenderPass();
            uberRenderPass = new UberRenderPass();
            // prePostProcessingRenderPass = new PrePostProcessingRenderPass();
            uberAgent = new UberAgent(uberRenderPass);
            existPostProcessingTypeList = new List<PostProcessingType>();

            foreach (var pair in postProcessingRenderPassDict)
            {
                pair.Value.Init();
            }
            
            uberRenderPass.BeforeUberRenderPassExecute += BeforeUberRenderPassExecute;
            uberRenderPass.OnUberRenderPassExecuted += OnUberRenderPassExecuted;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            CameraData cameraData = renderingData.cameraData;

            if (cameraData.postProcessEnabled == false)
            {
                return;
            }

            Camera camera = cameraData.camera;
            PostProcessingConfig postProcessingConfig = camera.GetComponent<PostProcessingConfig>();

            if (postProcessingConfig == null)
            {
                return;
            }

            int existCount = postProcessingConfig.GetExistPostProcessingTypeList(existPostProcessingTypeList);

            if (existCount == 0)
            {
                return;
            }
            
            PostProcessingSetting postProcessingSetting;
            int enabledCount = 0;

            for (int i = 0; i < existCount; ++i)
            {
                PostProcessingType type = existPostProcessingTypeList[i];

                // todo : can be removed
                if (postProcessingConfig.GetPostProcessingSetting(type, out postProcessingSetting) == false)
                {
                    continue;
                }

                if (postProcessingSetting.IsEnabled() == false)
                {
                    continue;
                }

                ++enabledCount;
                EnqueuePass(renderer, type, postProcessingSetting);
            }

            if (enabledCount > 0)
            {
                prePostProcessingRenderPass = new PrePostProcessingRenderPass(renderer);
                renderer.EnqueuePass(prePostProcessingRenderPass);
                renderer.EnqueuePass(uberRenderPass);
            }
        }
        
        /*protected override void Dispose(bool disposing)
        {
            if (uberMaterial != null)
            {
#if UNITY_EDITOR
                if (Application.isPlaying)
                    Destroy(uberMaterial);
                else
                    DestroyImmediate(uberMaterial);
#else
                UnityObject.Destroy(obj);
#endif
            }
        }*/

        private void EnqueuePass(ScriptableRenderer renderer, PostProcessingType type, PostProcessingSetting postProcessingSetting)
        {
            PostProcessingRenderPass renderPass = postProcessingRenderPassDict[(int) type];
            renderPass.SetData(uberAgent, postProcessingSetting);
            renderer.EnqueuePass(renderPass);
        }
        
        private void BeforeUberRenderPassExecute()
        {
            uberAgent.PassToUberRenderPass();
        }
        
        private void OnUberRenderPassExecuted(CommandBuffer commandbuffer)
        {
            uberAgent.Clear(commandbuffer);
        }
        #endregion
    }
    #endregion
}