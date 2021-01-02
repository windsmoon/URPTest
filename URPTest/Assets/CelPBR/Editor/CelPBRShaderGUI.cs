using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

using RenderMode = CelPBR.Runtime.RenderMode;

namespace CelPBR.Editor
{
    public class CelPBRShaderGUI : ShaderGUI
    {
        #region fields
        private static Dictionary<RenderMode, RenderModeData> renderModeDataDict;
        private MaterialEditor materialEditor;
        private Material material;
        private Object[] materialObjects;
        #endregion

        #region constructors
        static CelPBRShaderGUI()
        {
            renderModeDataDict = new Dictionary<RenderMode, RenderModeData>();
            
            RenderModeData opaqueRenderModeData = new RenderModeData()
            {
                RenderQueue = (int) RenderQueue.Geometry, SrcBlend = BlendMode.One, DstBlend = BlendMode.Zero
            };
            
            RenderModeData transparentModeData = new RenderModeData()
            {
                RenderQueue = (int) RenderQueue.Transparent, SrcBlend = BlendMode.SrcAlpha,
                DstBlend = BlendMode.OneMinusSrcAlpha
            };
            
            renderModeDataDict[RenderMode.Opaque] = opaqueRenderModeData;
            renderModeDataDict[RenderMode.Transparent] = transparentModeData;
        }
        #endregion
        
        #region methods
        public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] properties)
        {
            this.materialEditor = materialEditorIn;
            this.material = materialEditorIn.target as Material;
            this.materialObjects = materialEditorIn.targets;
            base.OnGUI(materialEditorIn, properties);

            if (GUILayout.Button("Opaque"))
            {
                SetRenderMode(RenderMode.Opaque);
            }
            
            else if (GUILayout.Button("Transparent"))
            {
                SetRenderMode(RenderMode.Transparent);
            }
        }

        private void SetRenderMode(RenderMode renderMode)
        {
            RenderModeData renderModeData = renderModeDataDict[renderMode];
            
            foreach (Object materialObject in materialObjects)
            {
                material = materialObject as Material;
                material.renderQueue = renderModeData.RenderQueue;
                material.SetFloat("_ScrBlend", (int)renderModeData.SrcBlend);
                material.SetFloat("_DstBlend", (int)renderModeData.DstBlend);
            }
        }
        #endregion
    }
    
    #region structs
    struct RenderModeData
    {
        #region fields
        public int RenderQueue;
        public BlendMode SrcBlend;
        public BlendMode DstBlend;
        #endregion
    }
    #endregion
}