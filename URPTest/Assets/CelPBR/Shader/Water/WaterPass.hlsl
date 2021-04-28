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

#include "WaterInput.hlsl"

Varyings FFTWaterVert(Attributes input)
{
    Varyings output;

    input.positionOS.xyz += GetDisplacement(input.uv);
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);

    output.uv = input.uv;
    // OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV)
    return output;
}

real4 FFTWaterFrag(Varyings input) : SV_TARGET
{
    real3 color;
    Light light = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
    real3 normalWS = GetNormalWS(input.uv);
    real bubble = GetBubbleStrength(input.uv);

    real3 viewWS = SafeNormalize(_WorldSpaceCameraPos - input.positionWS);
    real nDotL = saturate(dot(normalWS, light.direction));
    real3 halfDirectionWS = SafeNormalize(viewWS + light.direction);
    real nDotH = saturate(dot(normalWS, halfDirectionWS));
    real lDotH = saturate(dot(light.direction, halfDirectionWS));

    real reflectance = 0.02;
    real kd = 1 - reflectance;
    real diffuse = kd * GetWaterColor(saturate(dot(viewWS, normalWS)));
    real ks = lerp(reflectance, GetWaterColor(saturate(dot(viewWS, normalWS))), 0.6);

    real d = nDotH * nDotH * (HALF_MIN - 1) + 1.00001h;
    real lDotH2 = lDotH * lDotH;
    real specularTerm = HALF_MIN / ((d * d) * max(0.1h, lDotH2) * (HALF_MIN_SQRT * 4 + 2));
    real3 specular = ks * specularTerm;

    real3 gi = GlossyEnvironmentReflection(reflect(-viewWS, normalWS), 0, 1);
    
    color = light.color * nDotL * (specular + diffuse) + gi;
    return real4(color, 1);
}


#endif