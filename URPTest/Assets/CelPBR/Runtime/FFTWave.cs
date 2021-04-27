using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Serialization;

namespace CelPBR.Runtime
{
    public class FFTWave : MonoBehaviour
    {
        #region fields
        [SerializeField, Range(3, 12)]
        private int fftPower; // fft texture size is 2^ fftPower 
        [SerializeField, Range(20, 500)]
        private int meshVertexCount = 250; 
        [SerializeField, Min(1)]
        private float meshSize = 10;
        [SerializeField]
        private float phillipsParameter = 10; // influence wave height
        [SerializeField]
        private float lambda = -1; // to control offset
        [SerializeField]
        private float heightScale = 1;
        [SerializeField]
        private float bubbleScale = 1;
        [SerializeField]
        private float bubbleThreshold = 1;
        [SerializeField]
        private float windsScale = 2;
        [SerializeField]
        private ComputeShader computeShader;
        [SerializeField]
        private Material fftWaveMaterial;
        [SerializeField, Range(0, 12)]
        private int controlStage = 12;
        
        private int fftTextureSize;
        private float time = 0;
        private int[] vertexIndexs;
        private Vector3[] positions;
        private Vector2[] uvs;
        private Mesh mesh;
        private MeshFilter meshFilter;
        private MeshRenderer meshRenderer;

        private int kernelComputeGaussianRandom;
        private int kernelComputeHeightFrequencySpectrum;
        private int kernelComputeDisplaceFrequencySpectrum;
        private int kernelFFTHorizontal;
        private int kernelFFTHorizontalEnd;
        private int kernelFFTVertical;
        private int kernelFFTVerticalEnd;
        private int kernelComputeDisplace;
        private int kernelComputeNormalBubble;
        
        private RenderTexture gaussianRandomRT;  
        private RenderTexture heightFrequencySpectrumRT;
        private RenderTexture displaceXFrequencySpectrumRT;
        private RenderTexture displaceZFrequencySpectrumRT;
        private RenderTexture displaceRT;        
        private RenderTexture outputRT;          
        private RenderTexture normalRT;          
        private RenderTexture bubbleRT;         
        #endregion

        #region unity methods
        private void Awake()
        {
            meshFilter = gameObject.GetComponent<MeshFilter>();

            if (meshFilter == null)
            {
                meshFilter = gameObject.AddComponent<MeshFilter>();
            }

            meshRenderer = gameObject.GetComponent<MeshRenderer>();

            if (meshRenderer == null)
            {
                meshRenderer = gameObject.AddComponent<MeshRenderer>();
            }

            meshFilter.mesh = CreateMesh();
            meshRenderer.sharedMaterial = fftWaveMaterial;
            InitCSData();
        }

        private void OnDestroy()
        {
            gaussianRandomRT.Release();
            heightFrequencySpectrumRT.Release();
            displaceXFrequencySpectrumRT.Release();
            displaceZFrequencySpectrumRT.Release();
            displaceRT.Release();
            outputRT.Release();
            normalRT.Release();
            bubbleRT.Release();
        }

        private void Update()
        {
            time += Time.deltaTime;
        }
        #endregion

        #region methods
        private Mesh CreateMesh()
        {
            mesh = new Mesh();
            //fftSize = (int)Mathf.Pow(2, FFTPow);
            vertexIndexs = new int[(meshVertexCount  - 1) * (meshVertexCount - 1) * 6]; // the grid has (meshVertexCount - 1) ^ 2 quad
            positions = new Vector3[meshVertexCount * meshVertexCount];
            uvs = new Vector2[meshVertexCount * meshVertexCount];
            int inx = 0;
            
            for (int i = 0; i < meshVertexCount; i++)
            {
                for (int j = 0; j < meshVertexCount; j++)
                {
                    int vertexIndex = i * meshVertexCount + j;
                    positions[vertexIndex] = new Vector3((j - meshVertexCount / 2.0f) * meshSize / meshVertexCount, 0, (i - meshVertexCount / 2.0f) * meshSize / meshVertexCount);
                    uvs[vertexIndex] = new Vector2(j / (meshVertexCount - 1.0f), i / (meshVertexCount - 1.0f));

                    if (i != meshVertexCount - 1 && j != meshVertexCount - 1)
                    {
                        // CCW first triangle
                        vertexIndexs[inx++] = vertexIndex;
                        vertexIndexs[inx++] = vertexIndex + meshVertexCount;
                        vertexIndexs[inx++] = vertexIndex + meshVertexCount + 1;
                        
                        // CCW second triangle
                        vertexIndexs[inx++] = vertexIndex;
                        vertexIndexs[inx++] = vertexIndex + meshVertexCount + 1;
                        vertexIndexs[inx++] = vertexIndex + 1;
                    }
                }
            }
            
            mesh.vertices = positions;
            mesh.SetIndices(vertexIndexs, MeshTopology.Triangles, 0);
            mesh.uv = uvs;
            return mesh;
        }

        private void InitCSData()
        {
            fftTextureSize = (int)Mathf.Pow(2, fftPower);
            
            gaussianRandomRT = CreateRT(fftTextureSize);
            heightFrequencySpectrumRT = CreateRT(fftTextureSize);
            displaceXFrequencySpectrumRT = CreateRT(fftTextureSize);
            displaceZFrequencySpectrumRT = CreateRT(fftTextureSize);
            displaceRT = CreateRT(fftTextureSize);
            outputRT = CreateRT(fftTextureSize);
            normalRT = CreateRT(fftTextureSize);
            bubbleRT = CreateRT(fftTextureSize);
            
            kernelComputeGaussianRandom = computeShader.FindKernel("ComputeGaussianRandom");
            kernelComputeHeightFrequencySpectrum = computeShader.FindKernel("kernelComputeHeightFrequencySpectrum");
            kernelComputeDisplaceFrequencySpectrum = computeShader.FindKernel("ComputeDisplaceFrequencySpectrum");
            kernelFFTHorizontal = computeShader.FindKernel("FFTHorizontal");
            kernelFFTHorizontalEnd = computeShader.FindKernel("FFTHorizontalEnd");
            kernelFFTVertical = computeShader.FindKernel("FFTVertical");
            kernelFFTVerticalEnd = computeShader.FindKernel("FFTVerticalEnd");
            kernelComputeDisplace = computeShader.FindKernel("ComputeDisplace");
            kernelComputeNormalBubble = computeShader.FindKernel("ComputeNormalBubble");
            
            computeShader.SetInt("N", fftTextureSize);
            computeShader.SetFloat("WaterSize", meshSize);
            
            computeShader.SetTexture(kernelComputeGaussianRandom, "GaussianRandomRT", gaussianRandomRT);
            computeShader.Dispatch(kernelComputeGaussianRandom, fftTextureSize / 8, fftTextureSize / 8, 1);
        }
        
        private RenderTexture CreateRT(int size)
        {
            RenderTexture rt = new RenderTexture(size, size, 0, RenderTextureFormat.ARGBFloat);
            rt.enableRandomWrite = true;
            rt.Create();
            return rt;
        }
        #endregion
    }
}

