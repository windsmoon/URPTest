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
        private int resolution = 1024;
        [SerializeField]
        private bool isRenderShadow;
        
        private Camera reflectionCamera;
        private UniversalAdditionalCameraData reflectionCameraData;
        private RenderTexture reflectionRT;
        private Material material;

        private int reflectionTexturePropertyID = Shader.PropertyToID("_ReflectionTexture");
        private int planarReflectionLayer;
        #endregion

        #region unity methods

        private void Awake()
        {
            planarReflectionLayer = LayerMask.NameToLayer("PlanarReflection");
            CreateReflectionCamera();
            material = GetComponent<MeshRenderer>().sharedMaterial;
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
            reflectionRT = RenderTexture.GetTemporary((int)(resolution * srcCamera.aspect), resolution, 0, RenderTextureFormat.Default, RenderTextureReadWrite.sRGB);
            reflectionCamera.CopyFrom(srcCamera);
            reflectionCamera.cullingMask = ~(1 << planarReflectionLayer) & reflectionCamera.cullingMask;
            reflectionCamera.useOcclusionCulling = false;
            reflectionCameraData.renderShadows = isRenderShadow; // turn off shadows for the reflection camera
            reflectionCamera.targetTexture = reflectionRT;
        }

        private Matrix4x4 CaculateReflectionMatrix()
        {
            Vector3 normal = transform.up;
            float d = -Vector3.Dot(normal, transform.position);
            Matrix4x4 reflectionMatrix = new Matrix4x4();
            reflectionMatrix.m00 = 1 - 2 * normal.x * normal.x;
            reflectionMatrix.m01 = -2 * normal.x * normal.y;
            reflectionMatrix.m02 = -2 * normal.x * normal.z;
            reflectionMatrix.m03 = -2 * d * normal.x;
 
            reflectionMatrix.m10 = -2 * normal.x * normal.y;
            reflectionMatrix.m11 = 1 - 2 * normal.y * normal.y;
            reflectionMatrix.m12 = -2 * normal.y * normal.z;
            reflectionMatrix.m13 = -2 * d * normal.y;
 
            reflectionMatrix.m20 = -2 * normal.x * normal.z;
            reflectionMatrix.m21 = -2 * normal.y * normal.z;
            reflectionMatrix.m22 = 1 - 2 * normal.z * normal.z;
            reflectionMatrix.m23 = -2 * d * normal.z;
 
            reflectionMatrix.m30 = 0;
            reflectionMatrix.m31 = 0;
            reflectionMatrix.m32 = 0;
            reflectionMatrix.m33 = 1;
            
            // reflectionMatrix *= Matrix4x4.Scale(new Vector3(1, -1, 1));
            return reflectionMatrix;
        }
        
        private void OnBeginCameraRendering(ScriptableRenderContext context, Camera camera)
        {
            if (camera.cameraType == CameraType.Reflection || camera.cameraType == CameraType.Preview)
            {
                return;
            }
            
            UpdateCamera();
            Matrix4x4 reflectionMatrix = CaculateReflectionMatrix();
            reflectionCamera.worldToCameraMatrix = srcCamera.worldToCameraMatrix * reflectionMatrix; // transform object to symmetry position first, then transform to camera space

            GL.invertCulling = true;
            UniversalRenderPipeline.RenderSingleCamera(context, reflectionCamera); // render planar reflections
            GL.invertCulling = false;
            
            material.SetTexture(reflectionTexturePropertyID, reflectionRT);
        }
        #endregion
    }
}