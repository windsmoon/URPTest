Shader "CelPBR/PostProcessing/Screen Space Reflection"
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
            #pragma fragment ScreenSpaceReflectionFragment

            #include "Common.hlsl"
            #include "ScreenSpaceReflection.hlsl"
            ENDHLSL
        }
    }
}
