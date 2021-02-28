using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime
{
    [ExecuteInEditMode]
    public class PlanarReflection : MonoBehaviour
    {
        #region fields
        [SerializeField]
        private Camera srcCamera;
        [SerializeField] 
        [Range(0.01f, 1)]
        private float resolutionScale = 0.5f;
        [SerializeField]
        private LayerMask cullingMask = -1;
        [SerializeField]
        private bool isRenderShadow;

        private CommandBuffer commandBuffer;
        private Camera reflectionCamera;
        private UniversalAdditionalCameraData reflectionCameraData;
        private RenderTexture reflectionRT;
        private new Renderer renderer;
        private Material material;

        private int reflectionTexturePropertyID = Shader.PropertyToID("_ReflectionTexture");
        private int planarReflectionLayer;
        #endregion

        #region unity methods

        private void Awake()
        {
            commandBuffer = new CommandBuffer();
            commandBuffer.name = "PlanarReflection";
            planarReflectionLayer = LayerMask.NameToLayer("PlanarReflection");
            CreateReflectionCamera();
            renderer = GetComponent<Renderer>();
            material = renderer.sharedMaterial;
        }

        private void OnEnable()
        {
            RenderPipelineManager.beginCameraRendering += OnBeginCameraRendering;
        }

        private void OnDisable()
        {
            RenderPipelineManager.beginCameraRendering -= OnBeginCameraRendering;
        }

        private void OnDestroy()
        {
            if (Application.isPlaying)
            {
                Destroy(reflectionCamera.gameObject);
            }

            else
            {
                DestroyImmediate(reflectionCamera.gameObject);
            }
            
            RenderTexture.ReleaseTemporary(reflectionRT);
        }

        #endregion

        #region methods
        private void CreateReflectionCamera()
        {
            GameObject go = new GameObject("Planar Reflection",typeof(Camera));
            reflectionCameraData = go.AddComponent(typeof(UniversalAdditionalCameraData)) as UniversalAdditionalCameraData;
            reflectionCameraData.requiresColorOption = CameraOverrideOption.Off;
            reflectionCameraData.requiresDepthOption = CameraOverrideOption.Off;
            reflectionCameraData.SetRenderer(0);
            reflectionCamera = go.GetComponent<Camera>();
            // reflectionCamera.transform.SetPositionAndRotation(transform.position, transform.rotation);
            reflectionCamera.depth = -10;
            reflectionCamera.enabled = false;
            go.hideFlags = HideFlags.HideAndDontSave;
        }

        private void UpdateCamera()
        {
            if (srcCamera == null)
            {
                return;
            }

            RenderTexture.ReleaseTemporary(reflectionRT);
            reflectionRT = RenderTexture.GetTemporary((int)(srcCamera.pixelWidth * resolutionScale), (int)(srcCamera.pixelHeight * resolutionScale), 0, RenderTextureFormat.Default, RenderTextureReadWrite.sRGB);
            reflectionCamera.CopyFrom(srcCamera);
            reflectionCamera.cullingMask = ~(1 << planarReflectionLayer) & cullingMask;
            reflectionCamera.useOcclusionCulling = false;
            reflectionCameraData.renderShadows = isRenderShadow; // turn off shadows for the reflection camera
            reflectionCamera.targetTexture = reflectionRT;
            
        }

        private static void CalculateReflectionMatrix(out Matrix4x4 reflectionMatrix, Vector4 plane)
        {
            reflectionMatrix.m00 = (1F - 2F * plane[0] * plane[0]);
            reflectionMatrix.m01 = (-2F * plane[0] * plane[1]);
            reflectionMatrix.m02 = (-2F * plane[0] * plane[2]);
            reflectionMatrix.m03 = (-2F * plane[3] * plane[0]);

            reflectionMatrix.m10 = (-2F * plane[1] * plane[0]);
            reflectionMatrix.m11 = (1F - 2F * plane[1] * plane[1]);
            reflectionMatrix.m12 = (-2F * plane[1] * plane[2]);
            reflectionMatrix.m13 = (-2F * plane[3] * plane[1]);

            reflectionMatrix.m20 = (-2F * plane[2] * plane[0]);
            reflectionMatrix.m21 = (-2F * plane[2] * plane[1]);
            reflectionMatrix.m22 = (1F - 2F * plane[2] * plane[2]);
            reflectionMatrix.m23 = (-2F * plane[3] * plane[2]);

            reflectionMatrix.m30 = 0F;
            reflectionMatrix.m31 = 0F;
            reflectionMatrix.m32 = 0F;
            reflectionMatrix.m33 = 1F;
        }
        
        private void OnBeginCameraRendering(ScriptableRenderContext context, Camera camera)
        {
            if (renderer.isVisible == false)
            {
                return;
            }

            if (camera != srcCamera)
            {
                return;;
            }
            
            // if (camera.cameraType == CameraType.Reflection || camera.cameraType == CameraType.Preview)
            // {
                // return;
            // }
            
            UpdateCamera();
            Vector3 normal = transform.up;
            float d = -Vector3.Dot(normal, transform.position);
            Vector4 plane = new Vector4(normal.x, normal.y, normal.z, d);
            Matrix4x4 reflectionMatrix;
            CalculateReflectionMatrix(out reflectionMatrix, plane);
            reflectionCamera.worldToCameraMatrix = srcCamera.worldToCameraMatrix * reflectionMatrix; // transform object to symmetry position first, then transform to camera space
            
            Vector4 viewSpacePlane = reflectionCamera.worldToCameraMatrix.inverse.transpose * plane;
            Matrix4x4 clipMatrix = reflectionCamera.CalculateObliqueMatrix(viewSpacePlane);
            reflectionCamera.projectionMatrix = clipMatrix;
            
            GL.invertCulling = true;
            UniversalRenderPipeline.RenderSingleCamera(context, reflectionCamera); // render planar reflections
            GL.invertCulling = false;
            
            material.SetTexture(reflectionTexturePropertyID, reflectionRT);
        }
        #endregion
    }
}