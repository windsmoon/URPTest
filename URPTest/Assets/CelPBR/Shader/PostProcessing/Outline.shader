Shader "CelPBR/PostProcessing/Outline"
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
            #pragma fragment OutlineFragment

            #include "Outline.hlsl"
            ENDHLSL
        }
    }
}
