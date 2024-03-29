Shader "CelPBR/CelPBR"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("_Cull" , Float) = 2
        _CelPBR("CelPBR", Range(0, 1)) = 1
        [Toggle(PERSPECTIVE_CORRECTION)] _PerspectiveCorrection("Perspective Correction", Float) = 0
        _PerspectiveCorrectionScale("Perspective Correction Scale", Float) = 1
        
        [Space(50)]
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [NoScaleOffset]_NormalMap("Normap Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Float) = 1
        [NoScaleOffset]_MaskMap("Mask Map (R:Metallic, G:Occlusion, A:Smoothness)", 2D) = "white" {}
        _MetallicScale("Metallic Scale", Range(0, 1)) = 1
        _SmoothnessScale("Smoothness Scale", Range(0, 1)) = 1
        [NoScaleOffset]_OcclusionMap("Occlusion", 2D) = "white" {}
        _OcclusionScale("Strength", Range(0.0, 1.0)) = 1.0
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "black" {}
        [HDR] _EmissionColor("Color", Color) = (0, 0, 0, 0)
        
        [Space(50)]
        [Toggle(SSS)] _SSS("SSS", Float) = 0
        [NoScaleOffset]_SSSMask("SSS Mask", 2D) = "black" {}
        [NoScaleOffset]_SSSLut("SSS Lut", 2D) = "white" {}
        _SSSLutOffset("SSS Lut Offset", Vector) = (0, 0, 1, 0)
        _SSSPower("SSS Power", Float) = 2
        _SSSDistort("SSS Distort", Range(0, 1)) = 0
        [NoScaleOffset]_ThicknessMap("Thickness Map", 2D) = "white" {}
        _ThicknessScale("Thickness Scale", Range(0, 1)) = 1
        
        [Space(50)]
        [Toggle(ENABLE_SCREEN_SPACE_REFLECTION)] _EnableScreenSpaceReflection("Enable Screen Space Reflection", Float) = 0
        [Toggle(ENABLE_PLANAR_REFLECTION)] _EnablePlanarReflection("Enable Planar Reflection", Float) = 0
        _ReflectionTexture("Reflection Texture", 2D) = "white" {}
        
        [Space(50)]
        [Toggle(KK_HIGHLIGHT)] _KKHighlight("KK Highlight", Float) = 0
        _KKHighlightOffsetMap("KK Highlight Shift Map", 2D) = "black" {}
        _KKHighlightData("KK Highlight Data, X Offset, Y Intensity, Z Shiness， D Use Tangent", Vector) = (0, 1, 128, 1) 
        [Toggle(ENABLE_KK_HIGHLIGHT_ANISO_MAP)] EnableKKHighlightAnisoMap("Enable KK Highlight Aniso Map", Float) = 0
        _KKHighlightAnisoMap("KK Highlight Aniso Map", 2D) = "gray" {}
                
        [Space(50)]
        [NoScaleOffset]_HeightMap("Height Map", 2D) = "black" {}
        [Toggle(REVERT_HEIGHT)] _RevertHeight("Revert Height", Float) = 0
        [Enum(None, 0, ParallaxMapping, 1, SteepParallaxMapping, 2, ParallaxOcclusionMapping, 3, RelifParallaxMapping, 4)] _ParallaxMappingType ("Parallax Mapping Type", Float) = 0
        _ParallaxScale("ParallaxScale Scale", float) = 0
        [Toggle(PARALLAX_SELF_SHADOW)] _ParallaxSelfShadow("Parallax Self Shadow", Float) = 0
        
        [HideInInspector] _SrcBlend("_SrcBlend", Float) = 1.0
        [HideInInspector] _DstBlend("_DstBlend", Float) = 0.0
        [HideInInspector] _ZWrite("_ZWrite", Float) = 1.0
        
        // cel shading
        [Space(50)]
        [Toggle(ENABLE_RAMP_TEXTURE)] _EnableRampTexture("Enable Ramp Texture", Float) = 0.0
        _OutlineWidth("Outline Width", Range(0.01, 2)) = 0.24
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 0)
//        _OutlineThreshold("Outline Threshold", Float) = 0.9
        _RampMap("Ramp Texture", 2D) = "gray" {}
        _CelShadeColor("Cel Shade Color", Color) = (1, 1, 1)
    	_CelShadowColor("Cel Shadow Color", Color) = (0, 0, 0)
        _CelThreshold("Cel Threshold", Range(0, 1)) = 0.5
        _CelSmoothness("Cel Smoothness", Range(0, 0.5)) = 0.1
		_CelShadowRange("Cel Shadow Range", Range(0, 1)) = 0.2
    	_CelSpecularThreshold("Cel Specular Threshold", Range(0, 1)) = 0.8
        _CelSpecularGlossiness("Cel Specular Glossiness", Float) = 128
        [Toggle(ENABLE_SINGLE_SIDE_RIM_LIGHT)] _EnableSingleSideRimLight("Enable Single Side Rim Light", Float) = 0
        _RimThreshold("Rim Threshold", Range(0.5, 1)) = 0.8
        _RimSmoothness("Rim Smothness", Range(0, 1)) = 0.3
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        
        // debug
        [Toggle(TEMP_DEBUG)] _Temp_Debug("Temp Debug", Float) = 0
        [Toggle(DEBUG_UNLIT)] _Debug_Unlit("Debug Unlit", Float) = 0
        [Toggle(DEBUG_DISABLE_DIFFUSE)] _Debug_Disable_Diffuse("Debug Disable Diffuse", Float) = 0
        [Toggle(DEBUG_DISABLE_SPECULAR)] _Debug_Disable_Specular("Debug Disable Specular", Float) = 0
        [Toggle(DEBUG_DISABLE_GI)] _Debug_Disable_GI("Debug Disable GI", Float) = 0
        [Toggle(DEBUG_DISABLE_RIM)] _Debug_Disable_Rim("Debug Disable Rim", Float) = 0
        [Toggle(DEBUG_DISABLE_OUTLINE)] _Debug_Disable_Outline("Debug Disable OUtline", Float) = 0
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline"}
        
        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]
            
//            Cull Off

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            // #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
            // #pragma shader_feature_local_fragment _EMISSION
            // #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            // #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local _ _PARALLAXMAP
            // #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            // #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            // #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            // #pragma shader_feature_local_fragment _SPECULAR_SETUP
            // #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            #define _NORMALMAP
            #define _METALLICSPECGLOSSMAP
            #define _OCCLUSIONMAP
            #define _EMISSION
            #define _PARALLAXMAP
                        
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS // ?? do not find the usage
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // custom defined keywords
            #pragma multi_compile_local _ PERSPECTIVE_CORRECTION
            #pragma multi_compile_local _ REVERT_HEIGHT
            #pragma multi_compile_local_fragment _ PARALLAX_SELF_SHADOW
            #pragma multi_compile_local_fragment _ SSS
            #pragma multi_compile_local_fragment _ ENABLE_PLANAR_REFLECTION
            #pragma multi_compile_local_fragment _ KK_HIGHLIGHT
            #pragma multi_compile_local_fragment _ ENABLE_KK_HIGHLIGHT_ANISO_MAP
            #pragma multi_compile_fragment _ ENABLE_SCREEN_SPACE_REFLECTION
            #pragma multi_compile_fragment _ SCREEN_SPACE_REFLECTION
            // cel shading
            #pragma multi_compile_local_fragment _ ENABLE_RAMP_TEXTURE
            #pragma multi_compile_local_fragment _ ENABLE_SINGLE_SIDE_RIM_LIGHT


            // custom defined debug keywords
            #pragma multi_compile_local _ TEMP_DEBUG
            #pragma multi_compile_local_fragment _ DEBUG_UNLIT
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_DIFFUSE
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_SPECULAR
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_RIM
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_GI

            #pragma vertex CelPBRVert
            #pragma fragment CelPBRFrag

            #include "CelPBRPass.hlsl"
            ENDHLSL
        }
        
        Pass
        {
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "ShadowCasterPass.hlsl"
            ENDHLSL
        }
        
        Pass
        {
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            // #pragma exclude_renderers gles gles3 glcore
            // #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "DepthOnlyPass.hlsl"
            ENDHLSL
        }
        
        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On

            HLSLPROGRAM
            // #pragma exclude_renderers gles gles3 glcore
            // #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            // #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #define _NORMALMAP

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "DepthNormalsPass.hlsl"
            ENDHLSL
        }
        
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma vertex MetaVertexMeta
            #pragma fragment MetaFragmentMeta

            // #pragma shader_feature_local_fragment _SPECULAR_SETUP
            // #pragma shader_feature_local_fragment _EMISSION
            // #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            //
            // #pragma shader_feature_local_fragment _SPECGLOSSMAP

            // #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

            #define _NORMALMAP
            #define _METALLICSPECGLOSSMAP
            #define _OCCLUSIONMAP
            #define _EMISSION   
            
            #include "MetaPass.hlsl"

            ENDHLSL
        }
        
        Pass
        {
            Name "Outline"
            Tags{"LightMode" = "Outline"}

            Cull Front
            ZWrite On
            
//            Stencil 
//            {
//                Ref 1
//                Comp Always
//                Pass Replace 
//                ZFail Replace
//            }
            
            HLSLPROGRAM

            // custom defined keywords
            #pragma shader_feature_local _ DEBUG_DISABLE_OUTLINE
            
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag

            #include "OutlinePass.hlsl"
            ENDHLSL    
        }
        
        Pass
        {
            Name "SSRObjectData"
            Tags{"LightMode" = "SSRObjectData"}
            
//            ZWrite Off
//            ZWrite[_ZWrite]
            Cull[_Cull]
//            blend One One
//            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex SSRObjectDataVert
            #pragma fragment SSRObjectDataFrag

            #include "SSRObjectData.hlsl"
            ENDHLSL    
        }
    }
    
    CustomEditor "CelPBR.Editor.CelPBRShaderGUI"
}
