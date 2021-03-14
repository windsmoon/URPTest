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

            #include "Common.hlsl"
            #include "Uber.hlsl"
            ENDHLSL
        }
    }
}
