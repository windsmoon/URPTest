using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CelPBR.Runtime
{
    public class FFTWave : MonoBehaviour
    {
        #region fields
        [SerializeField]
        private Texture texture;
        [SerializeField]
        private RenderTexture rt;
        [SerializeField]
        private ComputeShader computeShader;
        #endregion

        #region unity methods
        private void Awake()
        {
            rt = new RenderTexture(texture.width, texture.height, 24);
            rt.enableRandomWrite = true;
            rt.Create();

            int kernel = computeShader.FindKernel("Gray");
            computeShader.SetTexture(kernel, "inputTexture", texture);
            computeShader.SetTexture(kernel, "Result", rt);
            computeShader.Dispatch(kernel, texture.width / 8, texture.height / 8, 1);
        }
        #endregion
    }
}

