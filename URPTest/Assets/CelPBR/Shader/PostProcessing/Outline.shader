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
//            
//            Stencil 
//            {
//                Ref 1
//                Comp Equal
//            }

            HLSLPROGRAM
            #pragma vertex Vertex_Outline
            #pragma fragment Fragment_Outline

            #include "Outline.hlsl"
            ENDHLSL
        }
    }
}
