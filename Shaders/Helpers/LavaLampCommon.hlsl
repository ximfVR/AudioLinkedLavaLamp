#ifndef LAVA_LAMP_COMMON_INCLUDED
#define LAVA_LAMP_COMMON_INCLUDED

#include "LavaLampLightingHelper.hlsl"
#include "LavaLampCoreHelper.hlsl"

static const float cSDFRaymarchMaxSteps = 100;

//Parameters --------------------------------------------------------------------------------------

#include "LavaLampSubregionParametersHelper.hlsl"
#include "LavaLampAudioLinkHelper.hlsl"

#include "UnityCG.cginc"

float _Reflectiveness;

Texture2D _RoughnessMap;
SamplerState sampler_RoughnessMap;
float4 _RoughnessMap_ST;
float _MinPerceptualRoughness;
float _MaxPerceptualRoughness;

Texture2D _NormalMap;
SamplerState sampler_NormalMap;
float4 _NormalMap_ST;
float _NormalStrength;

Texture2D _MatCapMap;
SamplerState sampler_MatCapMap;
float4 _MatCapMap_ST;
float  _MatCapAlpha;
float  _MatCapColorize;
float  _MatCapHueShift;

Texture2D _TintMap;
SamplerState sampler_TintMap;
float4 _TintMap_ST;
float3 _Tint;
float  _TintHueShift;
float  _TintBrightness;

bool _UseCustomReflectionProbe;
TextureCube _CustomReflectionProbe;
SamplerState sampler_CustomReflectionProbe;

float _RefractiveIndex;
float4 _BackgroundColor;

float3 _RimColor;
float  _RimHue;
float  _RimIntensity;
float  _RimPower;
float  _BlurFactor;

bool _UseBackgroundCubemap;
TextureCube _BackgroundCubemap;
SamplerState sampler_BackgroundCubemap;

Texture3D<float> _SDFTexture;
SamplerState sampler_SDFTexture;
float4 _SDFTexture_TexelSize;
float3 _SDFLowerCorner;
float3 _SDFSize;
float _SDFPixelSize;

float _WorldRecale;
float _MinThickness;

#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
    Texture2D _LavaLampGrabTexture; 
#else
    Texture2D _LavaLampGrabTexture;
#endif
SamplerState sampler_LavaLampGrabTexture;
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

//Helpers Functions -------------------------------------------------------------------------------

float GetRoughness(float2 uv)
{
    float perceptualRoughness = _RoughnessMap.Sample(sampler_RoughnessMap, TRANSFORM_TEX(uv, _RoughnessMap));
    perceptualRoughness = saturate(lerp(_MinPerceptualRoughness, _MaxPerceptualRoughness, perceptualRoughness));

    //unity parameterizes roughness as sqrt of the actual BRDF roughness, for a more linear change in appearence
    return perceptualRoughness * perceptualRoughness;// PerceptualRoughnessToRoughness(perceptualRoughness);
}

/*vec4 blur13(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.411764705882353) * direction;
  vec2 off2 = vec2(3.2941176470588234) * direction;
  vec2 off3 = vec2(5.176470588235294) * direction;
  color += texture2D(image, uv) * 0.1964825501511404;
  color += texture2D(image, uv + (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv - (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv + (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv - (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv + (off3 / resolution)) * 0.010381362401148057;
  color += texture2D(image, uv - (off3 / resolution)) * 0.010381362401148057;
  return color;
}
*/




#ifndef samplerscreen
    
#endif
// LinearEyeDepth(input.dpos.z / input.dpos.w);
float3 Blur(Texture2D<float4> screen, float2 uv, float factor)
{
    #if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)

        float3 res = _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv, (float)unity_StereoEyeIndex)).rgb * 0.1964825501511404;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + factor * 1.411764705882353 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - factor * 1.411764705882353 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + factor * 3.294117647058823 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - factor * 3.294117647058823 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + factor * 5.176470588235294 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - factor * 5.176470588235294 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;

        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(factor, -factor) * 1.411764705882353 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(factor, -factor) * 1.411764705882353 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(factor, -factor) * 3.294117647058823 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(factor, -factor) * 3.294117647058823 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(factor, -factor) * 5.176470588235294 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(factor, -factor) * 5.176470588235294 * 0.707, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;

        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(factor, 0) * 1.411764705882353, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(factor, 0) * 1.411764705882353, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(0, factor) * 1.411764705882353, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(0, factor) * 1.411764705882353, (float)unity_StereoEyeIndex)).rgb * 0.0742267411682086;

        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(factor, 0) * 3.294117647058823, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(factor, 0) * 3.294117647058823, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(0, factor) * 3.294117647058823, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(0, factor) * 3.294117647058823, (float)unity_StereoEyeIndex)).rgb * 0.0236175994626119;
        
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(factor, 0) * 5.176470588235294, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(factor, 0) * 5.176470588235294, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv + float2(0, factor) * 5.176470588235294, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(uv - float2(0, factor) * 5.176470588235294, (float)unity_StereoEyeIndex)).rgb * 0.0051906812005740;
    #else
        float3 res = _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv).rgb * 0.1964825501511404;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + factor * 1.411764705882353 * 0.707).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - factor * 1.411764705882353 * 0.707).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + factor * 3.294117647058823 * 0.707).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - factor * 3.294117647058823 * 0.707).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + factor * 5.176470588235294 * 0.707).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - factor * 5.176470588235294 * 0.707).rgb * 0.0051906812005740;

        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(factor, -factor) * 1.411764705882353 * 0.707).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(factor, -factor) * 1.411764705882353 * 0.707).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(factor, -factor) * 3.294117647058823 * 0.707).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(factor, -factor) * 3.294117647058823 * 0.707).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(factor, -factor) * 5.176470588235294 * 0.707).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(factor, -factor) * 5.176470588235294 * 0.707).rgb * 0.0051906812005740;

        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(factor, 0) * 1.411764705882353).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(factor, 0) * 1.411764705882353).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(0, factor) * 1.411764705882353).rgb * 0.0742267411682086;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(0, factor) * 1.411764705882353).rgb * 0.0742267411682086;

        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(factor, 0) * 3.294117647058823).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(factor, 0) * 3.294117647058823).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(0, factor) * 3.294117647058823).rgb * 0.0236175994626119;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(0, factor) * 3.294117647058823).rgb * 0.0236175994626119;
        
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(factor, 0) * 5.176470588235294).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(factor, 0) * 5.176470588235294).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv + float2(0, factor) * 5.176470588235294).rgb * 0.0051906812005740;
        res += _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, uv - float2(0, factor) * 5.176470588235294).rgb * 0.0051906812005740;
    #endif
    return res;
}


float rimLight(float3 normal, float3 viewDirection)
{
    float NdotV = 1 - dot(normal, viewDirection);
    NdotV = pow(NdotV, _RimPower) * _RimIntensity;
    return NdotV;
}


float3 hueShift(float3 color, float hue, float brightness) {
    float3 c = cos(hue * 6.2831 + float3(0, -1.57079632, 3.14159265));
    float3 res = color * c.x + cross(0.57735, color) * c.y + dot(0.57735, color) * (c.z + 1) * 0.57735;
    return res * brightness;
}

float3 GetMappedNormal(float2 uv, float3 worldNormal, float3 worldTangent, float3 worldBitangent, bool isFrontFace)
{
    float3 normalMap = UnpackNormal(_NormalMap.Sample(sampler_NormalMap, TRANSFORM_TEX(uv, _NormalMap)));
    normalMap.xy *= _NormalStrength;
    normalMap = normalize(normalMap);

    //Mikktspace normal mapping, don't normalize any of the interpolated TBN vectors
    float3 mappedNormal = (worldNormal * normalMap.z)
                        + (worldTangent * normalMap.x)
                        + (worldBitangent * normalMap.y);

    //need to flip the normal when rendering a back face
    return normalize(mappedNormal) * (isFrontFace ? 1.0 : -1.0);
}

bool IsBindDataSet(float4 bindPosition, float4 bindNormal, float4 bindTangent)
{
#if defined(LAVA_LAMP_BIND_DATA_AUTO)
    //when the UV channels bind data can be stored in are unbound they are all set to the same value by default
    //this also detects misconfigurations where different sets of data are set to the save UV channel
    return any(bindPosition != bindNormal) && any(bindPosition != bindTangent) && any(bindNormal != bindTangent);
#elif defined(LAVA_LAMP_BIND_DATA_ENABLED)
    return true;
#else
    return false;
#endif
}

float GetModelThickness(float3 startPosition, float3 marchDirection)
{
    [branch]
    if (all(_SDFTexture_TexelSize == 1.0)) //if all these are 1 then the texture is only one pixel wide, meaning it is the default texture
    {
        return _MinThickness;
    }
    else
    {
        //transform to SDF texture coordinate space
        startPosition -= _SDFLowerCorner;
        startPosition /= _SDFSize;
        marchDirection /= _SDFSize;

        float totalDistance = _SDFPixelSize; //start with a one pixel offset

        //raymarch to find the distance to exit the model
        //[loop]
        //for (int step = 0; step < cSDFRaymarchMaxSteps; ++step)
        {
            float3 uvw = startPosition + (marchDirection * totalDistance);
            float distaceToSurface = -_SDFTexture.SampleLevel(sampler_SDFTexture, uvw, 0.0).r; //invert the SDF

            [branch]
            if (distaceToSurface < -_SDFPixelSize) //don't stop until we are a pixel beyond the surface to better handle shallow angles
            {
                return max(_MinThickness, totalDistance + distaceToSurface); //add the final (negative) distance to back up to the surface
            }

            totalDistance = max(distaceToSurface, (_SDFPixelSize * 0.3333333)); //always step at least a third of a pixel
        }

        return max(_MinThickness, totalDistance); //if we run out of steps just return the distance we stopped at
    }
}

float GetBackgroundDepth(float4 clipPos)
{
    float4 screenPos = ComputeScreenPos(clipPos);
    float2 screenUV = screenPos.xy / screenPos.w;
    float2 normalizedDeviceCoordinates = clipPos.xy / clipPos.w;

    //mirror on edges of screen
    screenUV = screenUV > 1.0 ? 2.0 - screenUV : abs(screenUV);
    normalizedDeviceCoordinates = abs(normalizedDeviceCoordinates) > 1.0
                                ? sign(normalizedDeviceCoordinates) * (2.0 - abs(normalizedDeviceCoordinates))
                                : normalizedDeviceCoordinates;

    //sample depth texture
    float projectedDepth = SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, float4(screenUV, 0.0, 0.0));

    //check for a missing depth buffer by testing if the value is equal to the value of the default Unity placeholder texture
    //won't work if the depth buffer only exists due to a directional light that doesn't render in mirrors or only renders in mirrors
    //then the depth buffer will stay bound but will only be correct for the pass where the directional light renders
    //(the "Water" and "PlayerLocal" layers don't render in mirrors, the "MirrorReflection" and "reserved2" layers only render in mirrors)
    //also test for if the depth is the far plane (== 0) because it causes artifacts in mirrors for some reason
    bool isDepthValid = (projectedDepth != asfloat(0x3E5D0000)) && (projectedDepth > 0.0);

    //handle skewed depth planes (such as in mirrors), works for both orthographic and perspective projections
    //(in VR the eye projection matrix can also skew the clip pos based on depth which is why the _m02 and _m12 terms
    //are here. that part isn't correct for orthographic projections but those terms should always be 0 then anyway)
    projectedDepth -= ((normalizedDeviceCoordinates.x + UNITY_MATRIX_P._m02) / UNITY_MATRIX_P._m00) * UNITY_MATRIX_P._m20;
    projectedDepth -= ((normalizedDeviceCoordinates.y + UNITY_MATRIX_P._m12) / UNITY_MATRIX_P._m11) * UNITY_MATRIX_P._m21;

    //un-project depth
    float depth = (UNITY_MATRIX_P._m33 == 0.0) //check if this is a perspective matrix
                ? (UNITY_MATRIX_P._m23 / (projectedDepth + UNITY_MATRIX_P._m22)) //perspective
                : ((UNITY_MATRIX_P._m23 - projectedDepth) / UNITY_MATRIX_P._m22); //orthographic
    
    //if depth is invalid treat the background as arbitrarily far away
    return isDepthValid ? depth : 10000000.0;
}

float3 GetBackground(float3 worldPos, float3 traceDirection, inout float distanceToExit)
{
    float4 backgroundColor = _BackgroundColor;

    [branch]
    if (_UseBackgroundCubemap)
    {
        backgroundColor *= _BackgroundCubemap.Sample(sampler_BackgroundCubemap, traceDirection);
    }

#ifdef LAVA_LAMP_USE_TRANSPARENCY
    //determine the point where we exit the model, that's where we should sample the background
    float3 exitPos = worldPos + (traceDirection * distanceToExit * _WorldRecale);
    float4 exitClipPos = UnityWorldToClipPos(exitPos);

    bool isBackgroundInsideLamp = false;

#ifdef LAVA_LAMP_DEPTH_INTERSECTION
    float startDepth = -dot(UNITY_MATRIX_V[2], float4(worldPos, 1.0));
    float backgroundDepth = GetBackgroundDepth(exitClipPos);

    //if we refracted into something in front of the entry position, resample without refraction
    [branch]
    if (backgroundDepth < startDepth)
    {
        exitClipPos = UnityWorldToClipPos(worldPos);
        backgroundDepth = GetBackgroundDepth(exitClipPos);
    }

    //determine how far along the trace ray we need to travel to reach the sampled depth
    float distanceDepthScale = max(0.0, -dot(UNITY_MATRIX_V[2].xyz, traceDirection) * _WorldRecale);
    float distanceToHitBackground = max(0.0, (backgroundDepth - startDepth) / distanceDepthScale);

    //check if the background is actually inside the lava lamp and clamp the exit distance to the background distance
    isBackgroundInsideLamp = distanceToHitBackground <= distanceToExit;
    distanceToExit = max(0.0, min(distanceToExit, distanceToHitBackground));
#endif

    //get background uv
    float4 screenPos = ComputeGrabScreenPos(exitClipPos);
    float2 screenUV = screenPos.xy / screenPos.w;
    screenUV = screenUV > 1.0 ? 2.0 - screenUV : abs(screenUV); //mirror on edges of screen

    //float d = SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, float4(screenUV, 0.0, 0.0));

    #if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)

        //alpha blend _BackgroundColor over the actual background when the background isn't inside the lava lamp
        return lerp(_BlurFactor > 0 ? Blur(_LavaLampGrabTexture, screenUV, _BlurFactor * 0.002 ) :
                    _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, float3(screenUV, (float)unity_StereoEyeIndex)).rgb,
                    backgroundColor.rgb,
                    isBackgroundInsideLamp ? 0.0 : backgroundColor.a);
    #else
            //alpha blend _BackgroundColor over the actual background when the background isn't inside the lava lamp
        return lerp(_BlurFactor > 0 ? Blur(_LavaLampGrabTexture, screenUV, _BlurFactor * 0.002 ) :
                    _LavaLampGrabTexture.Sample(sampler_LavaLampGrabTexture, screenUV).rgb,
                    backgroundColor.rgb,
                    isBackgroundInsideLamp ? 0.0 : backgroundColor.a);
    #endif
#else
    //if the lamp isn't transparent just return a solid color
    return backgroundColor.rgb;
#endif
}

//Shader Structs ----------------------------------------------------------------------------------

struct LavaLampVertex
{
    float3 position : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;

#if defined(LAVA_LAMP_BIND_DATA_ENABLED) || defined(LAVA_LAMP_BIND_DATA_AUTO)

#if defined(LAVA_LAMP_BIND_POSITIONS_SLOT_1)
    float4 bindPositionAndSubregion : TEXCOORD1;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_2)
    float4 bindPositionAndSubregion : TEXCOORD2;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_3)
    float4 bindPositionAndSubregion : TEXCOORD3;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_4)
    float4 bindPositionAndSubregion : TEXCOORD4;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_5)
    float4 bindPositionAndSubregion : TEXCOORD5;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_6)
    float4 bindPositionAndSubregion : TEXCOORD6;
#else
    float4 bindPositionAndSubregion : TEXCOORD7;
#endif

#if defined(LAVA_LAMP_BIND_NORMALS_SLOT_1)
    float4 bindNormal : TEXCOORD1;
#elif defined(LAVA_LAMP_BIND_NORMALS_SLOT_2)
    float4 bindNormal : TEXCOORD2;
#elif defined(LAVA_LAMP_BIND_NORMALS_SLOT_3)
    float4 bindNormal : TEXCOORD3;
#elif defined(LAVA_LAMP_BIND_NORMALS_SLOT_4)
    float4 bindNormal : TEXCOORD4;
#elif defined(LAVA_LAMP_BIND_NORMALS_SLOT_5)
    float4 bindNormal : TEXCOORD5;
#elif defined(LAVA_LAMP_BIND_NORMALS_SLOT_6)
    float4 bindNormal : TEXCOORD6;
#else
    float4 bindNormal : TEXCOORD7;
#endif

#if defined(LAVA_LAMP_BIND_TANGENTS_SLOT_1)
    float4 bindTangent : TEXCOORD1;
#elif defined(LAVA_LAMP_BIND_TANGENTS_SLOT_2)
    float4 bindTangent : TEXCOORD2;
#elif defined(LAVA_LAMP_BIND_TANGENTS_SLOT_3)
    float4 bindTangent : TEXCOORD3;
#elif defined(LAVA_LAMP_BIND_TANGENTS_SLOT_4)
    float4 bindTangent : TEXCOORD4;
#elif defined(LAVA_LAMP_BIND_TANGENTS_SLOT_5)
    float4 bindTangent : TEXCOORD5;
#elif defined(LAVA_LAMP_BIND_TANGENTS_SLOT_6)
    float4 bindTangent : TEXCOORD6;
#else
    float4 bindTangent : TEXCOORD7;
#endif

#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct LavaLampVertexShadow
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;

#if defined(LAVA_LAMP_BIND_DATA_ENABLED) || defined(LAVA_LAMP_BIND_DATA_AUTO)
    
#if defined(LAVA_LAMP_BIND_POSITIONS_SLOT_1)
    float4 bindPositionAndSubregion : TEXCOORD1;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_2)
    float4 bindPositionAndSubregion : TEXCOORD2;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_3)
    float4 bindPositionAndSubregion : TEXCOORD3;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_4)
    float4 bindPositionAndSubregion : TEXCOORD4;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_5)
    float4 bindPositionAndSubregion : TEXCOORD5;
#elif defined(LAVA_LAMP_BIND_POSITIONS_SLOT_6)
    float4 bindPositionAndSubregion : TEXCOORD6;
#else
    float4 bindPositionAndSubregion : TEXCOORD7;
#endif

#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct LavaLampBasePixelInput
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float3 worldNormal : TEXCOORD2;
    float4 worldTangent : TEXCOORD3;
    float3 bindPosition : TEXCOORD4;
    float3 bindNormal : TEXCOORD5;
    float4 bindTangent : TEXCOORD6;

    nointerpolation uint lavaIndex : TEXCOORD7;
    UNITY_FOG_COORDS(8)
#ifdef LAVA_LAMP_USE_LIGHTING
    UNITY_SHADOW_COORDS(9)
#endif

    UNITY_VERTEX_OUTPUT_STEREO
};

struct LavaLampLightingPixelInput
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float3 worldNormal : TEXCOORD2;
    float4 worldTangent : TEXCOORD3;
    UNITY_FOG_COORDS(4)
    UNITY_SHADOW_COORDS(5)
    
    UNITY_VERTEX_OUTPUT_STEREO
};

struct LavaLampShadowPixelInput
{
    V2F_SHADOW_CASTER;

    UNITY_VERTEX_OUTPUT_STEREO
};

//Vertex Shaders ----------------------------------------------------------------------------------

LavaLampBasePixelInput LavaLampBaseVertexShader(LavaLampVertex vertex)
{
    LavaLampBasePixelInput output;

    UNITY_SETUP_INSTANCE_ID(vertex);
    UNITY_INITIALIZE_OUTPUT(LavaLampBasePixelInput, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = vertex.uv;

    output.worldPos = mul(unity_ObjectToWorld, float4(vertex.position, 1.0)).xyz;
    output.pos = UnityWorldToClipPos(output.worldPos);

    output.worldNormal = normalize(mul(float4(vertex.normal, 0.0), unity_WorldToObject).xyz);
    output.worldTangent = float4(normalize(mul(unity_ObjectToWorld, float4(vertex.tangent.xyz, 0.0)).xyz), vertex.tangent.w);
    
#if defined(LAVA_LAMP_BIND_DATA_ENABLED) || defined(LAVA_LAMP_BIND_DATA_AUTO)
    [branch]
    if(IsBindDataSet(vertex.bindPositionAndSubregion, vertex.bindNormal, vertex.bindTangent))
    {
        output.bindPosition = vertex.bindPositionAndSubregion.xyz;
        output.bindNormal = vertex.bindNormal.xyz;
        output.bindTangent = vertex.bindTangent;
        output.lavaIndex = vertex.bindPositionAndSubregion.w;
        
        //if the index is invalid just throw out this vertex
        if (output.lavaIndex >= NUM_LAVA_LAMP_SUBREGIONS)
        {
            output.pos = asfloat(~0); //NaN
        }
    }
    else
#endif
    {
        //if there is no bind data, use object space instead
        output.bindPosition = vertex.position;
        output.bindNormal = normalize(vertex.normal);
        output.bindTangent = float4(normalize(vertex.tangent.xyz), vertex.tangent.w);
        output.lavaIndex = 0;
    }
    
    UNITY_TRANSFER_FOG(output, output.pos);

#ifdef LAVA_LAMP_USE_LIGHTING
    UNITY_TRANSFER_SHADOW(output, vertex.lightmapUV); // pass shadow coordinates to pixel shader
#endif

    return output;
}

LavaLampLightingPixelInput LavaLampLightingVertexShader(LavaLampVertex vertex)
{
    LavaLampLightingPixelInput output;

    UNITY_SETUP_INSTANCE_ID(vertex);
    UNITY_INITIALIZE_OUTPUT(LavaLampLightingPixelInput, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = vertex.uv;

    output.worldPos = mul(unity_ObjectToWorld, float4(vertex.position, 1.0)).xyz;
    output.pos = UnityWorldToClipPos(output.worldPos);

    output.worldNormal = normalize(mul(float4(vertex.normal, 0.0), unity_WorldToObject).xyz);
    output.worldTangent = float4(normalize(mul(unity_ObjectToWorld, float4(vertex.tangent.xyz, 0.0)).xyz), vertex.tangent.w);

    //if the index is invalid just throw out this vertex (with models that don't have bind data set, the w component should default to 0)
#if defined(LAVA_LAMP_BIND_DATA_ENABLED) || defined(LAVA_LAMP_BIND_DATA_AUTO)
    if (vertex.bindPositionAndSubregion.w >= NUM_LAVA_LAMP_SUBREGIONS)
    {
        output.pos = asfloat(~0); //NaN
    }
#endif

    UNITY_TRANSFER_FOG(output, output.pos);
    UNITY_TRANSFER_SHADOW(output, vertex.lightmapUV); // pass shadow coordinates to pixel shader
    
    return output;
}

LavaLampShadowPixelInput LavaLampShadowVertexShader(LavaLampVertexShadow v)
{
    LavaLampShadowPixelInput output;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(output)

#if defined(LAVA_LAMP_BIND_DATA_ENABLED) || defined(LAVA_LAMP_BIND_DATA_AUTO)
    //if the index is invalid just throw out this vertex (with models that don't have bind data set, the w component should default to 0)
    if (v.bindPositionAndSubregion.w >= NUM_LAVA_LAMP_SUBREGIONS)
    {
        output.pos = asfloat(~0); //NaN
    }
#endif

    return output;
}



//Pixel Shaders -----------------------------------------------------------------------------------

float4 LavaLampBasePixelShader(LavaLampBasePixelInput input, bool isFrontFace : SV_IsFrontFace) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    //get the viewing direction
    bool isOrthographic = UNITY_MATRIX_P._m33 != 0.0;
    float3 cameraForward = normalize(float3(unity_CameraToWorld._m02, unity_CameraToWorld._m12, unity_CameraToWorld._m22));
    float3 viewDirection = isOrthographic ? cameraForward : normalize(input.worldPos - _WorldSpaceCameraPos);

    float3 worldBitangent = cross(input.worldNormal, input.worldTangent.xyz) * input.worldTangent.w * unity_WorldTransformParams.w;
    float3 mappedNormal = GetMappedNormal(input.uv, input.worldNormal, input.worldTangent.xyz, worldBitangent, isFrontFace);

    //refraction
    float3 incidence = viewDirection + (mappedNormal * saturate(-dot(viewDirection, mappedNormal)));
    float3 refraction = incidence * (1.0 / _RefractiveIndex);
    float3 refractedViewDirection = refraction - (mappedNormal * sqrt(saturate(1.0 - dot(refraction, refraction))));
    refractedViewDirection = normalize(refractedViewDirection);

    //transform view direction into tangent space, the TBN vectors may not be orthogonal so calculate the inverse TBN rather than the transpose
    float3 tangentTraceDirection =
    {
        dot(refractedViewDirection, cross(input.worldNormal, worldBitangent)),
        dot(refractedViewDirection, cross(worldBitangent, input.worldTangent.xyz)),
        dot(refractedViewDirection, cross(input.worldTangent.xyz, input.worldNormal))
    };

    //convert trace direction to bind pos space
    float3 bindBitangent = cross(input.bindNormal, input.bindTangent) * input.bindTangent.w;

    float3 traceDirection = (tangentTraceDirection.x * input.bindTangent)
                          + (tangentTraceDirection.y * input.bindNormal)
                          + (tangentTraceDirection.z * bindBitangent);
    traceDirection = normalize(traceDirection) * -input.worldTangent.w * unity_WorldTransformParams.w;

    //do a SDF trace to get the thickness of the mesh
    float thickness = GetModelThickness(input.bindPosition, traceDirection);

    //get the background color, (this can also modify the thickness if an object is inside of the lamp and depth intersection is enabled)
    float3 backgroundColor = GetBackground(input.worldPos, refractedViewDirection, thickness);

    //evaluate the lava lamp
    float3 lampColor = GetLavaLampColor(input.bindPosition, traceDirection, thickness, backgroundColor, input.lavaIndex);
    lampColor = LavaLampAudioLinkSetColorBasedOnAudioLinkData(lampColor, input.pos, input.uv.xy);
    //calculate the glass surface lighting

    float roughness = GetRoughness(input.uv);

    //get the cubemap reflection
    float3 ambientSpecular = 0.0;

    [branch]
    if (_UseCustomReflectionProbe)
    {
        ambientSpecular = SampleReflectionProbe(_CustomReflectionProbe, sampler_CustomReflectionProbe, mappedNormal, viewDirection, roughness);
    }
    else
    {
        ambientSpecular = SampleBuiltInReflectionProbes(input.worldPos, mappedNormal, viewDirection, roughness);
    }

    float3 glassLighting = ambientSpecular * ReflectionProbeFresnel(mappedNormal, viewDirection, _Reflectiveness, roughness);

#ifdef LAVA_LAMP_USE_LIGHTING
    UNITY_LIGHT_ATTENUATION(lightAttenuation, input, input.worldPos);
    float3 specularColor = GetDirectSpecularLighting(input.worldPos, mappedNormal, viewDirection, roughness, _Reflectiveness, lightAttenuation);
    glassLighting += ClampBrightness(specularColor, _MaxSpecularHighlightBrightness);
#endif

    //composite the final color
    float3 glassTint = _Tint * _TintMap.Sample(sampler_TintMap, TRANSFORM_TEX(input.uv, _TintMap)).rgb;
    glassTint = hueShift(glassTint, _TintHueShift, _TintBrightness);

    float3 worldNorm = mul(UNITY_MATRIX_V, input.worldNormal).rgb;

    worldNorm = mul(UNITY_MATRIX_V, mappedNormal).rgb;
    float3 NormalBlend_MatCapUV_Detail = worldNorm * float3(-1, -1, 1);
    float3 NormalBlend_MatCapUV_Base = (mul(UNITY_MATRIX_V, float4(-viewDirection, 0)).rgb * float3(-1, -1, 1)) + float3(0, 0, 1);
    float3 noSknewViewNormal = NormalBlend_MatCapUV_Base * dot(NormalBlend_MatCapUV_Base, NormalBlend_MatCapUV_Detail) / NormalBlend_MatCapUV_Base.b - NormalBlend_MatCapUV_Detail;

    float2 cap = noSknewViewNormal.xy * 0.5 + 0.5;

    float4 mc = _MatCapMap.Sample(sampler_MatCapMap, TRANSFORM_TEX(cap, _MatCapMap));
    mc.rgb = hueShift(lerp(mc.rgb, mc.rgb * float3(1,0,0), _MatCapColorize), _MatCapHueShift, 1.0);

    float3 finalColor = glassLighting + (lampColor * glassTint * (1.0 - _Reflectiveness)) + mc * _MatCapAlpha;
    float3 rim = hueShift(_RimColor, _RimHue, 1) * rimLight(input.worldNormal, -viewDirection);
    finalColor = finalColor + rim; //custom
    
    //apply fog (technically this will be applying fog to the background twice but it's not too noticeable in practice)
    UNITY_APPLY_FOG(input.fogCoord, finalColor);

    return float4(finalColor, 1.0);
}

float4 LavaLampLightingPixelShader(LavaLampLightingPixelInput input, bool isFrontFace : SV_IsFrontFace) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    //get the viewing direction
    bool isOrthographic = UNITY_MATRIX_P._m33 != 0.0;
    float3 cameraForward = normalize(float3(unity_CameraToWorld._m02, unity_CameraToWorld._m12, unity_CameraToWorld._m22));
    float3 viewDirection = isOrthographic ? cameraForward : normalize(input.worldPos - _WorldSpaceCameraPos);

    //get the surface lighting
    float3 worldBitangent = cross(input.worldNormal, input.worldTangent.xyz) * input.worldTangent.w * unity_WorldTransformParams.w;
    float3 mappedNormal = GetMappedNormal(input.uv, input.worldNormal, input.worldTangent.xyz, worldBitangent, isFrontFace);
    float roughness = GetRoughness(input.uv);

    UNITY_LIGHT_ATTENUATION(lightAttenuation, input, input.worldPos);
    float3 specularColor = GetDirectSpecularLighting(input.worldPos, mappedNormal, viewDirection, roughness, _Reflectiveness, lightAttenuation);
    float3 glassLighting = ClampBrightness(specularColor, _MaxSpecularHighlightBrightness);

    //apply fog
    UNITY_APPLY_FOG(input.fogCoord, glassLighting);

    return float4(glassLighting, 0.0);
}

float4 LavaLampShadowPixelShader(LavaLampShadowPixelInput input) : SV_Target
{
    SHADOW_CASTER_FRAGMENT(input)
}

#endif