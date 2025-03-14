// * COD4-SHADERGEN - xoxor4d.github.io
// * Template used : [vs_3_0_shadergen_viewmodel_full_projection.hlsl]
// * Mat. Template : [shadergen_viewmodel_phong.template]

#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <shader_vars.h>

struct VertexInput
{
	float4 position : POSITION;
    float4 normal   : NORMAL;
    float4 texcoord : TEXCOORD0;
};

struct PixelInput
{
    float4 position     : POSITION;
    float3 texcoord     : TEXCOORD0;
};

PixelInput vs_main( const VertexInput vertex ) 
{
	PixelInput pixel;
  
    float  shadowmapConst = 0.0009765625; // 1.0/1024
    float  oneQuarter     = 0.25;
    float  chunks         = 0.0078125; // 8.0/1024
    float  maxFLT         = 3.05175781e-005; // 1.0/32768;
    float  noise          = 0.03125; // 1.0/32
    float4 c99            = float4( 0.00787401572 /*1.0/127*/, 0.00392156886 /*1.0/255*/, -1 /**/, 0.752941191 /*1.0/1.328*/ );

    float4 setup;
    setup = float4( vertex.texcoord.zx * (1.0f / 1024.0f), vertex.texcoord.zx * (1.0f / 32768.0f));
    setup = float4( vertex.texcoord.wy * 0.25f,            vertex.texcoord.wy * (8.0f / 1024.0f)) + setup;

    float4 fraction;
    fraction = frac(setup);

    float4 idk;
    idk = float4( fraction.xy * -(1.0f / 32.0f) + fraction.zw, setup.zw + -fraction.zw );

    float2 uv1;
    float2 uv2;
    float2 uv3;
    float2 uv4;

    uv1 = float2( idk.xy * 32.0 + -15.0 );
    uv2 = float2( idk.zw * -2.0 + 1.0 );

    uv3 = float2( uv2 * fraction.xy + uv2 );
    uv4 = pow(2, uv1);

    pixel.texcoord.xy = float2( uv3 * uv4 ); 
    pixel.texcoord.z = 1.0;
    

    // ############################ TEXCOORDS END ####################################
    // ############################ POSITION BEGIN ###################################

    pixel.position = mul( float4( vertex.position.xyz, 1.0f ), worldMatrix );
    pixel.position = mul( pixel.position, viewProjectionMatrix ); 

    // unpack normals
    float4 normal1;
    normal1 = float4( vertex.normal.xyz * (1.0f /127.0f), vertex.normal.w * (1.0f / 255.0f)) + float4(-1.0f, -1.0f, -1.0f, (1.0f / 1.328f));
    normal1.xyz = normal1.xyz * normal1.w;

	return pixel;
}
