Shader "CelPBR/Water/FFTWave"
{
    Properties
    {
        _ShallowWaterColor ("Shallow Water Color", Color) = (1, 1, 1, 1)
        _DeepWaterColor ("Deep Water Color", Color) = (1, 1, 1, 1)
        _BubbleColor ("Bubble Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5 
        _Glossy ("Glossy", Float) = 128
        _Tilling ("Tilling", Vector) = (1, 1, 1, 1)
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
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS // ?? do not find the usage
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog

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
