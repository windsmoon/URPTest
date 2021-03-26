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
            
            Stencil 
            {
                Ref 1
                Comp Equal
            }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment OutlineFragment

            #include "Outline.hlsl"
            ENDHLSL
        }
    }
}
