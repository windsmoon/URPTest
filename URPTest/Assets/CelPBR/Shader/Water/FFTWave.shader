Shader "CelPBR/Water/FFTWave"
{
    Properties
    {
        [Space(50)]
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_NormalMap("Normap Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Float) = 1
        [NoScaleOffset]_MaskMap("Mask Map (R:Metallic, G:Occlusion, A:Smoothness)", 2D) = "white" {}
        _MetallicScale("Metallic Scale", Range(0, 1)) = 1
        _SmoothnessScale("Smoothness Scale", Range(0, 1)) = 1
        
        [Space(50)]
        [Toggle(ENABLE_SCREEN_SPACE_REFLECTION)] _EnableScreenSpaceReflection("Enable Screen Space Reflection", Float) = 0
        [Toggle(ENABLE_PLANAR_REFLECTION)] _EnablePlanarReflection("Enable Planar Reflection", Float) = 0
        _ReflectionTexture("Reflection Texture", 2D) = "white" {}
        
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

            HLSLPROGRAM
            // #pragma target 4.5
            
            // -------------------------------------
            // Material Keywords
            #define _NORMALMAP
            #define _METALLICSPECGLOSSMAP
                        
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS // ?? do not find the usage
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog

            #pragma multi_compile_local_fragment _ ENABLE_PLANAR_REFLECTION
            #pragma multi_compile_fragment _ ENABLE_SCREEN_SPACE_REFLECTION
            #pragma multi_compile_fragment _ SCREEN_SPACE_REFLECTION

            // custom defined debug keywords
            #pragma multi_compile_local _ TEMP_DEBUG
            #pragma multi_compile_local_fragment _ DEBUG_UNLIT
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_DIFFUSE
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_SPECULAR
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_RIM
            #pragma multi_compile_local_fragment _ DEBUG_DISABLE_GI

            #pragma vertex FFTWaterVert
            #pragma fragment FFTWaterFrag

            #include "WaterPass.hlsl"
            
            ENDHLSL
        }
        
        Pass
        {
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            // #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "../DepthOnlyPass.hlsl"
            ENDHLSL
        }
        
        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On

            HLSLPROGRAM
            // #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            #include "../DepthNormalsPass.hlsl"
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

            #define _NORMALMAP
            #define _METALLICSPECGLOSSMAP
            
            #include "../MetaPass.hlsl"

            ENDHLSL
        }
        
        Pass
        {
            Name "SSRObjectData"
            Tags{"LightMode" = "SSRObjectData"}
            
            Cull[_Cull]
            
            HLSLPROGRAM
            #pragma vertex SSRObjectDataVert
            #pragma fragment SSRObjectDataFrag

            #include "../SSRObjectData.hlsl"
            ENDHLSL    
        }
    }
    
    CustomEditor "CelPBR.Editor.CelPBRShaderGUI"
}
