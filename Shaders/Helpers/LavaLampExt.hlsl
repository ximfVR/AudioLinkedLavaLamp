#ifndef LAVA_LAMP_EXT
#define LAVA_LAMP_EXT

#include "UnityCG.cginc"

Texture2D _MatCapMap;
SamplerState sampler_MatCapMap;
float4 _MatCapMap_ST;
float  _MatCapAlpha;

float4 _RimColor;
float  _RimIntensity;
float  _RimPower;

float  _BlurFactor;

sampler2D _BackgroundTexture;
sampler2D _GrabTexture;

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv     : TEXCOORD0;
};

struct v2f
{
    float4 grabPos : TEXCOORD0;
    float4 pos : SV_POSITION;

    float3 worldNormal : TEXCOORD1;
    float3 viewDirection : TEXCOORD2;
    float2 uv : TEXCOORD3;

    float2 cap	: TEXCOORD4;
};

v2f LavaLampCustomExtVert(appdata v) {
    v2f o;
    o.uv = v.uv;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.grabPos = ComputeGrabScreenPos(o.pos);

    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.viewDirection = WorldSpaceViewDir(v.vertex);

    float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
    worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
    o.cap.xy = worldNorm.xy * 0.5 + 0.5;

    return o;
}







float4 texBlur(sampler2D tex, float4 p, float factor)
{
    float4 res = tex2Dproj(tex, p);
    float l = sqrt( LinearEyeDepth(p.z / p.w)) * 0.05;   
    

    //res += tex2Dproj(tex, ( p + float4(p.x + factor * l, p.y, p.z, p.w) ) );
    //res += tex2Dproj(tex, ( p + float4(p.x - factor * l, p.y, p.z, p.w) ) );
    
    return res;
}



float4 rimLight(float4 color, float3 normal, float3 viewDirection)
{
    float NdotV = 1 - dot(normal, viewDirection);
    NdotV = pow(NdotV, _RimPower) * _RimIntensity;
    return lerp(color, _RimColor, NdotV);
}


float4 LavaLampCustomExtFrag(v2f i) : SV_Target
{
    float4 res = texBlur(_GrabTexture, i.grabPos, _BlurFactor);

    float4 mc = _MatCapMap.Sample(sampler_MatCapMap, TRANSFORM_TEX(i.cap, _MatCapMap));

    //res = lerp(res, mc, _MatCapAlpha);
    //res = res + mc * _MatCapAlpha;

    i.worldNormal = normalize(i.worldNormal);
    i.viewDirection = normalize(i.viewDirection);
    
    //res = rimLight(res, i.worldNormal, i.viewDirection);

    return res;
}




#endif