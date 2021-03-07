Shader "CelPBR/PostProcessing/Screen Space Reflection"
{
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        struct Attributes
        {
            float4 positionHCS   : POSITION;
            float2 uv           : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings
        {
            float4  positionCS  : SV_POSITION;
            float2  uv          : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        Varyings VertDefault(Attributes input)
        {
            Varyings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            // Note: The pass is setup with a mesh already in CS
            // Therefore, we can just output vertex position
            output.positionCS = float4(input.positionHCS.xyz, 1.0);

            #if UNITY_UV_STARTS_AT_TOP
            output.positionCS.y *= -1;
            #endif

            output.uv = input.uv;

            // Add a small epsilon to avoid artifacts when reconstructing the normals
            output.uv += 1.0e-6;

            return output;
        }

        ENDHLSL

    SubShader
    {
        Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Name "SSAO_Occlusion"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment SSAO
            ENDHLSL
        }
    }
}
