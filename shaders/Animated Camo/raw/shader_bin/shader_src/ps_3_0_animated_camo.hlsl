#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>

#define SCROLL_VERT_SPEED 0.04
#define SCROLL_HORIZ_SPEED 0.08

struct PixelInput
{
    float4 position     : POSITION;
    float3 texcoord     : TEXCOORD0;
};

struct PixelOutput
{
	float4 color        : COLOR;
};

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;
    float2 uv = pixel.texcoord.xy;

    uv.x += gameTime.w * SCROLL_HORIZ_SPEED;
    uv.y += gameTime.w * SCROLL_VERT_SPEED;

    float4 color_map = tex2D( colorMapSampler, uv );

    fragment.color = color_map;
    return fragment;
}
