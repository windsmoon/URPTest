#ifndef CEL_PRB_WATER_PASS_INCLUDED
#define CEL_PRB_WATER_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 


Varyings FFTWaterVert(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    input.positionOS.xyz += GetDisplace(input.baseUV);
    output.positionWS = TransformObjectToWorld(input.positionOS);

    #if defined(PERSPECTIVE_CORRECTION)
    float3 positionVS = mul(UNITY_MATRIX_MV, float4(input.positionOS.xyz, 1)).xyz;
    float zOffset = UNITY_MATRIX_MV[2][3];
    positionVS.z = (positionVS.z - zOffset) / GetPerspectiveCorrectionScale() + zOffset;
    // positionVS.z = positionVS.z;

    output.positionCS = TransformWViewToHClip(positionVS);
    #else
    output.positionCS = TransformWorldToHClip(output.positionWS);
    #endif

    output.positionSS = ComputeScreenPos(output.positionCS); 
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentWS.xyz = TransformObjectToWorldDir(input.tangentOS.xyz);
    output.bitangentWS = cross(output.normalWS.xyz, output.tangentWS.xyz) * input.tangentOS.w * GetOddNegativeScale();
    output.baseUV = TRANSFORM_UV(input.baseUV, _BaseMap);
    output.kkHighlightUV = TRANSFORM_UV(input.baseUV, _KKHighlightOffsetMap);
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV)
    return output;
}

#endif