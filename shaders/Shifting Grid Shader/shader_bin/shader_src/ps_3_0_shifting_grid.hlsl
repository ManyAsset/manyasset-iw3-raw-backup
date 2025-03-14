#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>

#define LINE_SPACING 80.0
#define LINE_THICKNESS 0.98
#define SPEED 0.08

struct PixelInput
{
    float4 position     : POSITION;
    float3 texcoord     : TEXCOORD0;
};

struct PixelOutput
{
	float4 color        : COLOR;
};

float2 GetGradient(float2 intPos, float t) {
    float rand = frac(sin(dot(intPos, float2(12.9898, 78.233))) * 43758.5453);;

    float angle = 6.283185 * rand + 4.0 * t * rand;
    return float2(cos(angle), sin(angle));
}


float Pseudo3dNoise(float3 pos) {
    float2 i = floor(pos.xy);
    float2 f = pos.xy - i;
    float2 blend = f * f * (3.0 - 2.0 * f);
    float noiseVal = 
        lerp(
            lerp(
                dot(GetGradient(i + float2(0, 0), pos.z), f - float2(0, 0)),
                dot(GetGradient(i + float2(1, 0), pos.z), f - float2(1, 0)),
                blend.x),
            lerp(
                dot(GetGradient(i + float2(0, 1), pos.z), f - float2(0, 1)),
                dot(GetGradient(i + float2(1, 1), pos.z), f - float2(1, 1)),
                blend.x),
        blend.y
    );
    return noiseVal / 0.7;
}

float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float lines(float line_thickness, float line_spacing, float2 uv)
{
    float vert_lines = smoothstep(line_thickness, 1.0, cos((uv.x - gameTime.w * SPEED) * line_spacing));
    float horz_lines = smoothstep(line_thickness, 1.0, cos((uv.y - gameTime.w * SPEED) * line_spacing));
    
    return vert_lines + horz_lines;
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;
    float2 uv = pixel.texcoord.xy;

    uv.x -= smoothstep(0.01, 1.0, Pseudo3dNoise(float3(uv * 20.0, gameTime.w * 0.2))) * 0.008;
    uv.y += smoothstep(0.01, 1.0, Pseudo3dNoise(float3(uv * 20.0, gameTime.w * 0.1))) * 0.008;
    
    float main_lines = lines(LINE_THICKNESS, LINE_SPACING, uv);
    float bloom = lines(LINE_THICKNESS * 0.01, LINE_SPACING, uv) / 10.0;
    
    float3 col = float3(main_lines + bloom, main_lines + bloom, main_lines + bloom);
    col *= hsv2rgb(float3(gameTime.w * 0.15, 1.0, 1.0));

    fragment.color = float4(col, 1.0);
    return fragment;
}
