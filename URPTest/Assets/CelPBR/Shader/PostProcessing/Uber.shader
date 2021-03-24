Shader "CelPBR/PostProcessing/Uber"
{
    SubShader
    {
        Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment UberFragment

            #pragma multi_compile_fragment _ POST_PROCESSING_SCREEN_SPACE_REFLECTION
            #pragma multi_compile_fragment _ POST_PROCESSING_OUTLINE

            #include "Common.hlsl"
            #include "Uber.hlsl"
            ENDHLSL
        }
    }
}
