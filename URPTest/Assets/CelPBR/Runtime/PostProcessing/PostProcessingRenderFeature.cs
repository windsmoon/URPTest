using System.Collections.Generic;
using CelPBR.Runtime.PostProcessing.RenderPasses;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing
{
    #region fields
    public class PostProcessingRenderFeature : ScriptableRendererFeature
    {
        #region fields
        [SerializeField, HideInInspector]
        private Shader shader;
        
        private Material material;
        private List<PostProcessingType> existPostProcessingTypeList;
        private static Dictionary<int, PostProcessingRenderPass> postProcessingRenderPassDict;
        #endregion

        #region constructors
        static PostProcessingRenderFeature()
        {
            // todo : need be optimized
            // can use reflection
            postProcessingRenderPassDict = new Dictionary<int, PostProcessingRenderPass>();
            postProcessingRenderPassDict[(int)PostProcessingType.ScreenSpaceRelfection] = new ScreenSpaceRelfectionRenderPass();
        }
        #endregion

        #region methods
        public override void Create()
        {
            if (shader == null)
            {
                shader = Shader.Find("CelPBR/PostProcessing/ScreenSpaceReflection");
            }
            
            if (material == null)
            {
                material = new Material(shader);
            }
            
            existPostProcessingTypeList = new List<PostProcessingType>();
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
            PostProcessingSetting postProcessingSetting;

            for (int i = 0; i < existCount; ++i)
            {
                PostProcessingType type = existPostProcessingTypeList[i];

                if (postProcessingConfig.GetPostProcessingSetting(type, out postProcessingSetting) == false)
                {
                    continue;
                }

                if (postProcessingSetting.IsEnabled() == false)
                {
                    continue;
                }
                
                EnqueuePass(renderer, type);
            }
        }
        
        protected override void Dispose(bool disposing)
        {
            CoreUtils.Destroy(material);
        }

        private static void EnqueuePass(ScriptableRenderer renderer, PostProcessingType type)
        {
            renderer.EnqueuePass(postProcessingRenderPassDict[(int)type]);
        }
        #endregion
    }
    #endregion
}