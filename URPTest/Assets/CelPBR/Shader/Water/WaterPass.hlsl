#ifndef CEL_PRB_WATER_PASS_INCLUDED
#define CEL_PRB_WATER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float2 lightmapUV : TEXCOORD1; // todo
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float2 uv : VAR_UV;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1); // todo
};

#include "../Common.hlsl"
#include "WaterInput.hlsl"

real3 CaculateSSS(Varyings input, float3 lightDirectionWS, float3 viewDirectionWS, float3 normalWS)
{
    real waterDeep = GetWaterDeep(input.uv);
    real3 lightNormal = lightDirectionWS + normalWS * Random(input.uv * 100) * 10;
    // real3 sss = pow(saturate(dot(viewDirectionWS, -lightNormal)), GetSSSPower()) * GetSSSScale() * waterDeep;
    real3 sss = pow(saturate(dot(viewDirectionWS, lightDirectionWS) + dot(normalWS, -lightDirectionWS)), GetSSSPower()) * GetSSSScale() * waterDeep;
    return sss;
}

Varyings FFTWaterVert(Attributes input)
{
    Varyings output;

    input.positionOS.xyz += GetDisplacement(input.uv);
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);

    output.uv = Tilling(input.uv);
    // output.uv = input.uv;

    // OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV)
    return output;
}

real4 FFTWaterFrag(Varyings input) : SV_TARGET
{
    real3 color;
    
    Light light = GetMainLight(TransformWorldToShadowCoord(input.positionWS));

    real3 normalWS = GetNormalWS(input.uv);
    real3 viewWS = SafeNormalize(_WorldSpaceCameraPos - input.positionWS);
    real nDotL = saturate(dot(normalWS, light.direction));
    real3 halfDirectionWS = SafeNormalize(viewWS + light.direction);
    real nDotH = saturate(dot(normalWS, halfDirectionWS));

    real fresnelScale = GetFresnelScale();
    real3 gi = GlossyEnvironmentReflection(reflect(-viewWS, normalWS), 0, 1);
    real fresnel = saturate(fresnelScale + (1 - fresnelScale) * pow(1 - dot(normalWS, viewWS), 5));

    real3 waterColor = GetWaterColor(saturate(dot(viewWS, normalWS)));
    real3 bubbleColor = GetBubbleColor();
    real bubbleStrength = GetBubbleStrength(input.uv);
    real3 diffuse = lerp(waterColor, bubbleColor, bubbleStrength);

    real3 specular = GetSpecular() * pow(nDotH, GetGlossy());
    
    color = lerp(light.color * nDotL * (specular + diffuse), gi, fresnel);
    color += light.color * nDotL * CaculateSSS(input, light.direction, viewWS, normalWS);
    // color = normalWS.xyz * 0.5 + 0.5;
    color =  CaculateSSS(input, light.direction, viewWS, normalWS);
    return real4(color, 1);
}


#endif