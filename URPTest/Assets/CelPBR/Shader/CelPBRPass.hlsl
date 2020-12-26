#ifndef CEL_PRB_PASS
#define CEL_PBR_PASSS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"     
#include "CelPBRInput.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 baseUV : TEXCOORD0;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float2 baseUV : VAR_BASE_UV;
};

float _Shinness;

Varyings CelPBRVert(Attributes input)
{
    Varyings output;
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionHCS = TransformWorldToHClip(output.positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.baseUV = TRANSFORM_TEX(input.baseUV, _BaseMap);
    return output;
}

float4 CelPBRFrag(Varyings input) : SV_TARGET
{
    // blinn phong
    float4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);
    
    float3 lightDirWS = _MainLightPosition.xyz; // no need for normalize
    float nDotL = dot(input.normalWS, lightDirWS);
    float saturatedNDotL = saturate(nDotL);
    // float3 temp = _WorldSpaceCameraPos.xyz - input.positionWS;
    // float3 viewDirWS= temp / sqrt(temp.x * temp.x + temp.y + temp.y + temp.z * temp.z);
    float3 viewDirWS = normalize(_WorldSpaceCameraPos.xyz - input.positionWS);
    float3 halfVectorWS = normalize(lightDirWS + viewDirWS);
    float nDotH = dot(halfVectorWS, input.normalWS);
    float saturatedNDotH = saturate(nDotH);
    float powSaturatedNDotH = pow(saturatedNDotH, _Shinness);
    float3 color = 0;
    float3 diffuseColor = _MainLightColor * baseColor * saturatedNDotL;
    float3 specularColor = _MainLightColor * baseColor * powSaturatedNDotH;
    color = diffuseColor + specularColor;
    return float4(color, 1);
    
}


#endif