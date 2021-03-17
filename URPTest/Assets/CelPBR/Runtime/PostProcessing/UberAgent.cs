using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CelPBR.Runtime.PostProcessing
{
    public class UberAgent
    {
        #region fields
        private Dictionary<int, int> intDict;
        private Dictionary<int, float> floatDict;
        private Dictionary<int, Color> colorDict;
        private Dictionary<int, Vector4> vectorDict;
        private Dictionary<int, Texture> textureDict;
        private Dictionary<int, Matrix4x4> matrixDict;
        private HashSet<string> enabledKeywordSet;
        private HashSet<string> disabledKeywordSet;
        private List<int> rtIDList;
        private UberRenderPass uberRenderPass;
        #endregion

        #region constructors
        public UberAgent(UberRenderPass uberRenderPass)
        {
            intDict = new Dictionary<int, int>();
            floatDict = new Dictionary<int, float>();
            colorDict = new Dictionary<int, Color>();
            vectorDict = new Dictionary<int, Vector4>();
            textureDict = new Dictionary<int, Texture>();            
            matrixDict = new Dictionary<int, Matrix4x4>();
            enabledKeywordSet = new HashSet<string>();
            disabledKeywordSet = new HashSet<string>();
            rtIDList = new List<int>();
            this.uberRenderPass = uberRenderPass;
        }
        #endregion
        
        #region methods
        public void PassToUberRenderPass()
        {
            Material uberMaterial = uberRenderPass.Material;

            foreach (var pair in intDict)
            {
                uberMaterial.SetInt(pair.Key, pair.Value);
            }
            
            foreach (var pair in floatDict)
            {
                uberMaterial.SetFloat(pair.Key, pair.Value);
            }
            
            foreach (var pair in colorDict)
            {
                uberMaterial.SetColor(pair.Key, pair.Value);
            }
            
            foreach (var pair in textureDict)
            {
                uberMaterial.SetTexture(pair.Key, pair.Value);
            }
            
            foreach (var pair in matrixDict)
            {
                uberMaterial.SetMatrix(pair.Key, pair.Value);
            }
            
            foreach (var pair in intDict)
            {
                uberMaterial.SetInt(pair.Key, pair.Value);
            }

            foreach (string keyword in enabledKeywordSet)
            {
                if (uberMaterial.IsKeywordEnabled(keyword) == false)
                {
                    uberMaterial.EnableKeyword(keyword);
                }
            }

            foreach (string keyword in disabledKeywordSet)
            {
                if (uberMaterial.IsKeywordEnabled(keyword))
                {
                    uberMaterial.DisableKeyword(keyword);
                }
            }
        }

        public void Clear(CommandBuffer commandBuffer)
        {
            intDict.Clear();
            floatDict.Clear();
            colorDict.Clear();
            vectorDict.Clear();
            textureDict.Clear();
            matrixDict.Clear();
            enabledKeywordSet.Clear();
            disabledKeywordSet.Clear();

            foreach (int rtID in rtIDList)
            {
                commandBuffer.ReleaseTemporaryRT(rtID);
            }
            
            rtIDList.Clear();
        }
        
        public void RegistRT(int rtID)
        {
            rtIDList.Add(rtID);            
        }
        
        public void SetInt(int id, int value)
        {
            intDict[id] = value;
        }
        
        public void SetFloat(int id, float value)
        {
            floatDict[id] = value;
        }
        
        public void SeColor(int id, Color value)
        {
            colorDict[id] = value;
        }
        
        public void SetVector(int id, Vector4 value)
        {
            vectorDict[id] = value;
        }
        
        public void SetTexture(int id, Texture value)
        {
            textureDict[id] = value;
        }
        
        public void SetMatrix(int id, Matrix4x4 value)
        {
            matrixDict[id] = value;
        }

        public void EnableKeyword(string keyword)
        {
            disabledKeywordSet.Remove(keyword);
            enabledKeywordSet.Add(keyword);
        }

        public void DisableKeyword(string keyword)
        {
            enabledKeywordSet.Remove(keyword);
            disabledKeywordSet.Add(keyword);
        }
        #endregion
    }
}