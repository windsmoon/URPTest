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
        private Shader uberShader;
        private Material uberMaterial;
        private CommandBuffer uberCommandBuffer;
        private List<PostProcessingType> existPostProcessingTypeList;
        private Dictionary<int, PostProcessingRenderPass> postProcessingRenderPassDict;
        private UberRenderPass uberRenderPass;
        private bool needInit = true;
        #endregion

        #region methods
        public override void Create()
        {
            if (needInit = false)
            {
                Debug.Log("2222");
                return;
            }
            
            Debug.Log("111111");
            
            if (uberShader == null)
            {
                uberShader = Shader.Find("CelPBR/PostProcessing/Uber");
            }
            
            if (uberMaterial == null)
            {
                uberMaterial = new Material(uberShader);
            }

            if (uberCommandBuffer == null)
            {
                uberCommandBuffer = new CommandBuffer();
            }
            
            postProcessingRenderPassDict = new Dictionary<int, PostProcessingRenderPass>();
            postProcessingRenderPassDict[(int)PostProcessingType.ScreenSpaceRelfection] = new ScreenSpaceRelfectionRenderPass();
            uberRenderPass = new UberRenderPass(uberCommandBuffer);
            existPostProcessingTypeList = new List<PostProcessingType>();

            foreach (var pair in postProcessingRenderPassDict)
            {
                pair.Value.Init();
            }
            
            needInit = false;
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
                renderer.EnqueuePass(uberRenderPass);
            }
        }
        
        protected override void Dispose(bool disposing)
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
        }

        private void EnqueuePass(ScriptableRenderer renderer, PostProcessingType type, PostProcessingSetting postProcessingSetting)
        {
            PostProcessingRenderPass renderPass = postProcessingRenderPassDict[(int) type];
            renderPass.SetData(uberCommandBuffer, postProcessingSetting);
            renderer.EnqueuePass(renderPass);
        }
        #endregion
    }
    #endregion
}