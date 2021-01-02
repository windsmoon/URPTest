using System.Collections;
using System.Collections.Generic;
using NUnit.Framework.Constraints;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEditor;

public static class ReplaceMaterialProperties
{
    #region methods
    [MenuItem("Temp Tools/Standard to CelPBR")]
    public static void Replace()
    {
        string[] guids = Selection.assetGUIDs;

        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);

            if (path.EndsWith(".mat") == false)
            {
                continue;
            }

            Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
            Texture baseMap = material.GetTexture("_MainTex");
            Color baseColor = material.GetColor("_Color");
            Texture normalMap = material.GetTexture("_BumpMap");
            Texture maskMap = material.GetTexture("_MetallicGlossMap");
            float metallicScale = material.GetFloat("_Metallic");
            float smoothnessScale = material.GetFloat("_Glossiness");
            Texture emissionMap = material.GetTexture("_EmissionMap");
            Color emissionColor = material.GetColor("_EmissionColor");
            Texture occlusionMap = material.GetTexture("_OcclusionMap");
            float occlusionScale = material.GetFloat("_OcclusionStrength");
            Texture heightMap = material.GetTexture("_ParallaxMap");
            float mode = material.GetFloat("_Mode");

            if (mode != 0)
            {
                Debug.LogError(material.name);
                continue;
            }

            if (heightMap != null)
            {
                Debug.LogError(material.name);
                continue;
            }

            material.shader = Shader.Find("CelPBR/CelPBR");
            material.SetTexture("_BaseMap", baseMap);
            material.SetColor("_BaseColor", baseColor);
            material.SetTexture("_NormalMap", normalMap);
            material.SetTexture("_MaskMap", maskMap);

            if (maskMap == null)
            {
                material.SetFloat("_MetallicScale", metallicScale);
            }
            
            material.SetFloat("_SmoothnessScale", smoothnessScale);
            material.SetTexture("_EmissionMap", emissionMap);
            material.SetColor("_EmissionColor", emissionColor);
            material.SetTexture("_OcclusionMap", occlusionMap);
            material.SetFloat("_OcclusionScale", occlusionScale);
        }
        
        AssetDatabase.SaveAssets();
    }
    #endregion
}