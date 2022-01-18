//
//  BaseWarp.metal
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 3/1/2022.
//

#include <metal_stdlib>
using namespace metal;



float colormap_red(float x) {
    if (x < 0.0) {
        return 54.0 / 255.0;
    } else if (x < 20049.0 / 82979.0) {
        return (829.79 * x + 54.51) / 255.0;
    } else {
        return 1.0;
    }
}


float colormap_green(float x) {
    if (x < 20049.0 / 82979.0) {
        return 0.0;
    } else if (x < 327013.0 / 810990.0) {
        return (8546482679670.0 / 10875673217.0 * x - 2064961390770.0 / 10875673217.0) / 255.0;
    } else if (x <= 1.0) {
        return (103806720.0 / 483977.0 * x + 19607415.0 / 483977.0) / 255.0;
    } else {
        return 1.0;
    }
}

float colormap_blue(float x) {
    if (x < 0.0) {
        return 54.0 / 255.0;
    } else if (x < 7249.0 / 82979.0) {
        return (829.79 * x + 54.51) / 255.0;
    } else if (x < 20049.0 / 82979.0) {
        return 127.0 / 255.0;
    } else if (x < 327013.0 / 810990.0) {
        return (792.02249341361393720147485376583 * x - 64.364790735602331034989206222672) / 255.0;
    } else {
        return 1.0;
    }
}

float4 colormap(float x) {
    return float4(colormap_red(x), colormap_green(x), colormap_blue(x), 1.0);
}

float rand(float2 n) {
    return fract(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
}

float noise(float2 p){
    float2 ip = floor(p);
    float2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
        mix(rand(ip),rand(ip+float2(1.0,0.0)),u.x),
        mix(rand(ip+float2(0.0,1.0)),rand(ip+float2(1.0,1.0)),u.x),u.y);
    return res*res;
}

float fbm( float2 p, float time )
{
    const matrix<float, 2> mtx = matrix<float, 2>( 0.80,  0.60, -0.60,  0.80 );
    float f = 0.0;

    f += 0.500000*noise( p + time  ); p = mtx*p*2.02;
    f += 0.031250*noise( p ); p = mtx*p*2.01;
    f += 0.250000*noise( p ); p = mtx*p*2.03;
    f += 0.125000*noise( p ); p = mtx*p*2.01;
    f += 0.062500*noise( p ); p = mtx*p*2.04;
    f += 0.015625*noise( p + sin(time) );

    return f/0.96875;
}

float pattern( float2 p, float time )
{
    return fbm( p + fbm( p + fbm( p, time ), time ), time );
}

kernel void warp(texture2d<float, access::write> output [[texture(0)]],
                    constant float &time [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
    
    // Initialise pixel coordinates
    float2 fragCoord = float2(gid.x, output.get_height() - gid.y);
    
    // Get resolution of metal view using width and height of screen texture
    float2 iResolution = float2(output.get_width(), output.get_height());
    
    // Normalise the coordinates so x and y is in range 0 to 1
    float2 uv = fragCoord / iResolution.x;
    
    float t = time * 0.8;
    
    float shade = pattern(uv, t);
    
    output.write(float4(colormap((shade)).rgb, 1), gid);
    
}
