#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>

#define PROJMAP_INTENSITY 2.0
#define WORLDPOS_TO_PROJECTION_SCALE 64.

struct PixelInput
{
    float4 position     : POSITION;
    float3 worldPos     : TEXCOORD1;
};

struct PixelOutput
{
	float4 color        : COLOR;
};

float N21(float2 p) {
	p = frac(p * float2(2.15, 8.3));
    p += dot(p, p + 2.5);
    return frac(p.x * p.y);
}

float2 N22(float2 p) {
	float n = N21(p);
    return float2(n, N21(p + n));
}

float2 getPos(float2 id, float2 offset) {
	float2 n = N22(id + offset);
    float x = cos(gameTime.w * n.x);
    float y = sin(gameTime.w * n.y);
    return float2(x, y) * 0.4 + offset;
}

float distanceToLine(float2 p, float2 a, float2 b) {
	float2 pa = p - a;
    float2 ba = b - a;
    float t = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - t * ba);
}

float getLine(float2 p, float2 a, float2 b) {
	float distance = distanceToLine(p, a, b);
    float dx = 15.0/600.;
    float lengtha = length(a - (b+float2(0.0000000001, 0.0000000001)));
    return smoothstep(dx, 0.0, distance) * smoothstep(1.2, 0.3, lengtha);
}

float layer(float2 st) {
    float m = 0.0;
    float2 gv = frac(st) - 0.5;
    float2 id = floor(st);
    float2 pointPos = getPos(id, float2(0.0, 0.0));
    m += smoothstep(0.05, 0.03, length(gv - pointPos));
    
    float2 p[9];
    p[0] = getPos(id, float2(-1.0, -1.0));
    p[1] = getPos(id, float2(-1.0, 0.0));
    p[2] = getPos(id, float2(-1.0, 1.0));
    p[3] = getPos(id, float2( 0.0, -1.0));
    p[4] = getPos(id, float2( 0.0, 0.0));
    p[5] = getPos(id, float2( 0.0, 1.0));
    p[6] = getPos(id, float2( 1.0, -1.0));
    p[7] = getPos(id, float2( 1.0, 0.0));
    p[8] = getPos(id, float2( 1.0, 1.0));
    
    for (int j = 0; j <=8 ; j++) {
    	m += getLine(gv, p[4], p[j]);
        float2 temp = (gv - p[j]) * 100.0;
        m += 1.0/dot(temp, temp) * (sin(10.0 * gameTime.w + frac(p[j].x) * 20.0) * 0.5 + 0.5);
        
    }
    
    m += getLine(gv, p[1], p[3]);
    m += getLine(gv, p[1], p[5]);
    m += getLine(gv, p[3], p[7]);
    m += getLine(gv, p[5], p[7]);
    
    return m;
}

float3 mainImage( float2 fragCoord )
{
    float2 uv = (fragCoord - 0.5 * 1000.) / 1000.;
    
    float m = 0.0;
    
    float theta = gameTime.w * 0.1;
    float2x2 rot = float2x2(cos(theta), -sin(theta), sin(theta), cos(theta));
    
    uv = mul(rot, uv);
    
    for (float i = 0.0; i < 1.0 ; i += 0.25) {
    	float depth = frac(i + gameTime.w * 0.1); //
        m += layer(uv * lerp(10.0, 0.5, depth) + i * 20.0) * smoothstep(0.0, 0.2, depth) * smoothstep(1.0, 0.8, depth);
    }
    
    float3 baseColor = sin(float3(3.45, 6.56, 8.78) * gameTime.w * 0.2) * 0.5 + 0.5;
    
    float3 col = m * baseColor;
    // Output to screen
    return col;
}

PixelOutput ps_main( const PixelInput pixel )
{
    PixelOutput fragment;

    float   SIDE_SCALE      = 0.5;                  // 0.5 means half the size
    float2  SIDE_ASPECT     = float2( 1.0, 1.0 );   // 0.5 means more strech; 2.0 will compress
    float2  SIDE_OFFSET     = float2( 0.0, 0.0 );   // -x -> front; +y -> right

    float2 UV_SIDE = (pixel.worldPos.xz * (1.0 / SIDE_SCALE) * WORLDPOS_TO_PROJECTION_SCALE) * SIDE_ASPECT + SIDE_OFFSET;

    float3 COLOR_SIDE;

    COLOR_SIDE = mainImage(UV_SIDE);

    float4 tpSample;

    tpSample.xyz = COLOR_SIDE;
    //tpSample.xyz *= tpSample.xyz * PROJMAP_INTENSITY;
    tpSample.w = 1.0f;

    fragment.color = tpSample;

    return fragment;
}