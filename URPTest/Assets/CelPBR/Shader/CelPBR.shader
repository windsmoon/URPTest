Shader "CelPBR/CelPBR"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _Shinness("Shinness", Range(32, 512)) = 128
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex CelPBRVert
            #pragma fragment CelPBRFrag

            #include "CelPBRPass.hlsl"
            ENDHLSL
        }
    }
}
