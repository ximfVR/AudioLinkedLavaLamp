// If you're reading this, you're cute :3
#ifndef LAVA_LAMP_AL
#define LAVA_LAMP_AL

#include "UnityCG.cginc"
#include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"

#define AUDIOLINK_WIDTH                 128
#define ALPASS_CCSTRIP                  uint2(0,24) 
#define CHRONO_OFFSET                   float(1.4);

float _LavaLampEnableAudioLink_Toggle;
float _LavaLampEnableAudioLinkResize_Toggle;
float _LavaLampEnableAudioLinkColor_Toggle;
float _LavaLampEnableAudioLinkScroll_Toggle;

float _LavaReactiveColorOffsetRed;
float _LavaReactiveColorOffsetGreen;
float _LavaReactiveColorOffsetBlue;


float _LavaLampScrollTargetChannel;
float _LavaLampResizeTargetChannel;
float _LavaLampColorTargetChannel;

float _LavaLampReactiveResizeModifier;
float _LavaLampScrollAdjustment;

float LavaLampAudioLinkSpeedMultiplier(float scrollSpeed); // Unity is screaming for a prototype of this func in particular

// Leaving this here for people to experiment with. Chronotensity does cause a nice scaling effect,
// however it wraps around after going through the texture UV and you need to do some precise
// calcs to get it right. On certain songs this can make the particles of the lava move A LOT
// faster than needed. The calc I've done seems to be the most 'stable'?
// See https://github.com/llealloo/audiolink/tree/master/Docs#alpass_chronotensity
// float LavaLampAudioLinkScrollingChrono(float scrollSpeed)
// {
//     float chrono = (AudioLinkDecodeDataAsUInt( ALPASS_CHRONOTENSITY  + uint2( 1, 0 ) ) % 10000000) / 10000000.0;
//     return scrollSpeed += (chrono / 35); 
// }



float LavaLampAudioLinkSpeedMultiplier(float scrollSpeed)
{
    if(_LavaLampEnableAudioLink_Toggle == 1.0 && _LavaLampEnableAudioLinkScroll_Toggle == 1.0) {
        // Sampling to the `x` channel instead of `z` can lead to less jitter but it's not as nice looking.
        return (AudioLinkData( ALPASS_FILTEREDAUDIOLINK + uint2(_LavaLampScrollTargetChannel, 0) ).z / _LavaLampScrollAdjustment) + scrollSpeed;
    } else {
        return scrollSpeed;
    }
}

float LavaLampAudioLinkBlobResizeMultiplier(float scale)
{
    if(_LavaLampEnableAudioLink_Toggle == 1.0 && _LavaLampEnableAudioLinkResize_Toggle == 1.0) {
        return (AudioLinkData( ALPASS_FILTEREDAUDIOLINK + int2(_LavaLampResizeTargetChannel, 0) ).rrrr * _LavaLampReactiveResizeModifier);
    } else {
        return scale;
    }
    
}

float3 LavaLampAudioLinkSetColorBasedOnAudioLinkData(float3 lampColor, float pos, float2 xy)
{
    if(_LavaLampEnableAudioLink_Toggle == 1.0 && _LavaLampEnableAudioLinkColor_Toggle == 1.0) {
        float audioLink = (AudioLinkData( ALPASS_FILTEREDAUDIOLINK + uint2(_LavaLampColorTargetChannel, 0) ).z / 0.5);
        lampColor.r += clamp((audioLink / (_LavaReactiveColorOffsetRed / 0.1)), 0.0, 0.8);
        lampColor.g += clamp((audioLink / (_LavaReactiveColorOffsetGreen / 0.1)), 0.0, 0.8);
        lampColor.b += clamp((audioLink / (_LavaReactiveColorOffsetBlue / 0.1)), 0.0, 0.8);
        return lampColor;
    } else {
        return lampColor;
    }
    
}

#endif