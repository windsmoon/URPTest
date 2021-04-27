using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;
using Random = UnityEngine.Random;

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
        private Vector4 WindAndSeed = new Vector4(1f, 1f, 0.6f, 0.8f);// xy is wind direcction, zw is random seed
        [SerializeField]
        private ComputeShader computeShader;
        [SerializeField, Range(0, 12)]
        private int controlStage = 12;
        [SerializeField]
        private bool isControlHorizontal = true;  //是否控制横向FFT，否则控制纵向FFT
        [SerializeField]
        private RawImage debugRawImage;
        
        private int fftTextureSize;
        private float time = 0;
        private int[] vertexIndexs;
        private Vector3[] positions;
        private Vector2[] uvs;
        private Mesh mesh;
        private MeshFilter meshFilter;
        private MeshRenderer meshRenderer;
        private Material fftWaveMaterial;

        private int kernelComputeGaussianRandom;
        private int kernelComputeHeightFrequencySpectrum;
        private int kernelComputeDisplaceFrequencySpectrum;
        private int kernelFFTHorizontal;
        private int kernelFFTHorizontalEnd;
        private int kernelFFTVertical;
        private int kernelFFTVerticalEnd;
        private int kernelComputeDisplace;
        private int kernelComputeNormalAndBubble;
        
        // int N; // fft texture size
        // float WaterSize;
        // float A; //phillips spectrum parameter, influence the wave height
        // float4 WindAndSeed; // xy is wind, zw is two random seed
        // float Time;
        // int Ns;	//Ns = pow(2,m-1); m is stage number
        // float Lambda; // influence offset
        // float HeightScale;
        // float BubbleScale;
        // float BubbleThreshold;
        //
        // RWTexture2D<float4> GaussianRandomRT; // gaussian random rt
        // RWTexture2D<float4> HeightFrequencySpectrumRT;
        // RWTexture2D<float4> DisplaceXSpectrumRT;
        // RWTexture2D<float4> DisplaceZSpectrumRT;
        // RWTexture2D<float4> DisplaceRT;
        // RWTexture2D<float4> InputRT;
        // RWTexture2D<float4> OutputRT;
        // RWTexture2D<float4> NormalRT;
        // RWTexture2D<float4> BubbleRT;
        private int nID = Shader.PropertyToID("N");
        private int waterSizeID = Shader.PropertyToID("WaterSize");
        private int aID = Shader.PropertyToID("A");
        private int windAndSeedID = Shader.PropertyToID("WindAndSeed");
        private int timeID = Shader.PropertyToID("Time");
        private int nsID = Shader.PropertyToID("Ns");
        private int lambdaID = Shader.PropertyToID("Lambda");
        private int heightScaleID = Shader.PropertyToID("HeightScale");
        private int bubbleScaleID = Shader.PropertyToID("BubbleScale");
        private int bubbleThresholdID = Shader.PropertyToID("BubbleThreshold");

        private int gaussianRandomRTID = Shader.PropertyToID("_GaussianRandomRT");
        private int heightFrequencySpectrumRTID = Shader.PropertyToID("_HeightFrequencySpectrumRT");
        private int displaceXFrequencySpectrumRTID = Shader.PropertyToID("_DisplaceXFrequencySpectrumRT");
        private int displaceZFrequencySpectrumRTID = Shader.PropertyToID("_DisplaceZFrequencySpectrumRT");
        private int displaceRTID = Shader.PropertyToID("_DisplaceRT");
        private int inputRTID = Shader.PropertyToID("_InputRT");
        private int outputRTID = Shader.PropertyToID("_OutputRT");
        private int normalRTID = Shader.PropertyToID("_NormalRT");
        private int bubbleRTID = Shader.PropertyToID("_BubbleRT");
        
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
            fftWaveMaterial = new Material(Shader.Find("CelPBR/Water/FFTWave"));
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
            ComputeWaterData();
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
            kernelComputeHeightFrequencySpectrum = computeShader.FindKernel("ComputeHeightFrequencySpectrum");
            kernelComputeDisplaceFrequencySpectrum = computeShader.FindKernel("ComputeDisplaceFrequencySpectrum");
            kernelFFTHorizontal = computeShader.FindKernel("FFTHorizontal");
            kernelFFTHorizontalEnd = computeShader.FindKernel("FFTHorizontalEnd");
            kernelFFTVertical = computeShader.FindKernel("FFTVertical");
            kernelFFTVerticalEnd = computeShader.FindKernel("FFTVerticalEnd");
            kernelComputeDisplace = computeShader.FindKernel("ComputeDisplace");
            kernelComputeNormalAndBubble = computeShader.FindKernel("ComputeNormalAndBubble");
            
            computeShader.SetInt(nID, fftTextureSize);
            computeShader.SetFloat(waterSizeID, meshSize);
            
            computeShader.SetTexture(kernelComputeGaussianRandom, gaussianRandomRTID, gaussianRandomRT);
            computeShader.Dispatch(kernelComputeGaussianRandom, fftTextureSize / 8, fftTextureSize / 8, 1);
        }

        private void ComputeWaterData()
        {
            computeShader.SetFloat(aID, phillipsParameter);
            WindAndSeed.z = Random.Range(1, 10f);
            WindAndSeed.w = Random.Range(1, 10f);
            Vector2 wind = new Vector2(WindAndSeed.x, WindAndSeed.y);
            wind.Normalize();
            wind *= windsScale;
            computeShader.SetVector(windAndSeedID, new Vector4(wind.x, wind.y, WindAndSeed.z, WindAndSeed.w));
            computeShader.SetFloat(timeID, time);
            computeShader.SetFloat(lambdaID, lambda);
            computeShader.SetFloat(heightScaleID, heightScale);
            computeShader.SetFloat(bubbleScaleID, bubbleScale);
            computeShader.SetFloat(bubbleThresholdID,bubbleThreshold);
    
            // generate height frequency spectrum
            computeShader.SetTexture(kernelComputeHeightFrequencySpectrum, gaussianRandomRTID, gaussianRandomRT);
            computeShader.SetTexture(kernelComputeHeightFrequencySpectrum, heightFrequencySpectrumRTID, heightFrequencySpectrumRT);
            computeShader.Dispatch(kernelComputeHeightFrequencySpectrum, fftTextureSize / 8, fftTextureSize / 8, 1);
    
            // generate displace spectrum
            computeShader.SetTexture(kernelComputeDisplaceFrequencySpectrum, heightFrequencySpectrumRTID, heightFrequencySpectrumRT);
            computeShader.SetTexture(kernelComputeDisplaceFrequencySpectrum, displaceXFrequencySpectrumRTID, displaceXFrequencySpectrumRT);
            computeShader.SetTexture(kernelComputeDisplaceFrequencySpectrum, displaceZFrequencySpectrumRTID, displaceZFrequencySpectrumRT);
            computeShader.Dispatch(kernelComputeDisplaceFrequencySpectrum, fftTextureSize / 8, fftTextureSize / 8, 1);
    
    
            if (controlStage == 0)
            {
                SetMaterialTex();
                return;
            }
    
            // horizontal fft
            for (int m = 1; m <= fftPower; m++)
            {
                int ns = (int)Mathf.Pow(2, m - 1);
                computeShader.SetInt(nsID, ns);
                
                // todo
                // final stage is special
                if (m != fftPower)
                {
                    ComputeFFT(kernelFFTHorizontal, ref heightFrequencySpectrumRT);
                    ComputeFFT(kernelFFTHorizontal, ref displaceXFrequencySpectrumRT);
                    ComputeFFT(kernelFFTHorizontal, ref displaceZFrequencySpectrumRT);
                }
                else
                {
                    ComputeFFT(kernelFFTHorizontalEnd, ref heightFrequencySpectrumRT);
                    ComputeFFT(kernelFFTHorizontalEnd, ref displaceXFrequencySpectrumRT);
                    ComputeFFT(kernelFFTHorizontalEnd, ref displaceZFrequencySpectrumRT);
                }
                
                if (isControlHorizontal && controlStage == m)
                {
                    SetMaterialTex();
                    return;
                }
            }
            
            // vertical fft
            for (int m = 1; m <= fftPower; m++)
            {
                int ns = (int)Mathf.Pow(2, m - 1);
                computeShader.SetInt(nsID, ns);
                
                // todo
                // final stage is special
                if (m != fftPower)
                {
                    ComputeFFT(kernelFFTVertical, ref heightFrequencySpectrumRT);
                    ComputeFFT(kernelFFTVertical, ref displaceXFrequencySpectrumRT);
                    ComputeFFT(kernelFFTVertical, ref displaceZFrequencySpectrumRT);
                }
                else
                {
                    ComputeFFT(kernelFFTVerticalEnd, ref heightFrequencySpectrumRT);
                    ComputeFFT(kernelFFTVerticalEnd, ref displaceXFrequencySpectrumRT);
                    ComputeFFT(kernelFFTVerticalEnd, ref displaceZFrequencySpectrumRT);
                }
                if (!isControlHorizontal && controlStage == m)
                {
                    SetMaterialTex();
                    return;
                }
            }

            // debugRawImage.texture = heightFrequencySpectrumRT;
            
            // compute displace texture
            computeShader.SetTexture(kernelComputeDisplace, heightFrequencySpectrumRTID, heightFrequencySpectrumRT);
            computeShader.SetTexture(kernelComputeDisplace, displaceXFrequencySpectrumRTID, displaceXFrequencySpectrumRT);
            computeShader.SetTexture(kernelComputeDisplace, displaceZFrequencySpectrumRTID, displaceZFrequencySpectrumRT);
            computeShader.SetTexture(kernelComputeDisplace, displaceRTID, displaceRT);
            computeShader.Dispatch(kernelComputeDisplace, fftTextureSize / 8, fftTextureSize / 8, 1);
            
            // compute normal and bubble
            computeShader.SetTexture(kernelComputeNormalAndBubble, displaceRTID, displaceRT);
            computeShader.SetTexture(kernelComputeNormalAndBubble, normalRTID, normalRT);
            computeShader.SetTexture(kernelComputeNormalAndBubble, bubbleRTID, bubbleRT);
            computeShader.Dispatch(kernelComputeNormalAndBubble, fftTextureSize / 8, fftTextureSize / 8, 1);

            SetMaterialTex();
        }
        
        private RenderTexture CreateRT(int size)
        {
            RenderTexture rt = new RenderTexture(size, size, 0, RenderTextureFormat.ARGBFloat);
            rt.enableRandomWrite = true;
            rt.Create();
            return rt;
        }
        
        private void ComputeFFT(int kernel, ref RenderTexture input)
        {
            computeShader.SetTexture(kernel, inputRTID, input);
            computeShader.SetTexture(kernel, outputRTID, outputRT);
            computeShader.Dispatch(kernel, fftTextureSize / 8, fftTextureSize / 8, 1);

            RenderTexture rt = input;
            input = outputRT;
            outputRT = rt;
        }
        
        private void SetMaterialTex()
        {
            fftWaveMaterial.SetTexture(displaceRTID, displaceRT);
            fftWaveMaterial.SetTexture(normalRTID, normalRT);
            fftWaveMaterial.SetTexture(bubbleRTID, bubbleRT);

            // DisplaceXMat.SetTexture("_MainTex", DisplaceXSpectrumRT);
            // DisplaceYMat.SetTexture("_MainTex", HeightSpectrumRT);
            // DisplaceZMat.SetTexture("_MainTex", DisplaceZSpectrumRT);
            // DisplaceMat.SetTexture("_MainTex", DisplaceRT);
            // NormalMat.SetTexture("_MainTex", NormalRT);
            // BubblesMat.SetTexture("_MainTex", BubblesRT);
        }
        #endregion
    }
}

