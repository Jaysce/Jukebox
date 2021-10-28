//
//  Gradient.metal
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 28/10/21.
//

#include <metal_stdlib>
using namespace metal;

float3 pallete(float2 uv, float time, float3 a, float3 b, float3 c, float3 d) {
    return a + b * cos(6.28318 * (c * time + d));
}

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    constant float &time [[buffer(0)]],
                    constant float3 &color [[buffer(1)]],
                    uint2 gid [[thread_position_in_grid]]) {
    
    // Initialise pixel coordinates
    float2 fragCoord = float2(gid.x, output.get_height() - gid.y);
    
    // Get resolution of metal view using width and height of screen texture
    float2 iResolution = float2(output.get_width(), output.get_height());
    
    // Normalise the coordinates so x and y is in range 0 to 1
    float2 uv = fragCoord / iResolution;
    
    // Shift the range of coordinates to -0.5 to 0.5 to center the origin
//    uv -= 0.5;
    
    // Normalise ratio so image isn't stretched
//    uv.x *= iResolution.x / iResolution.y;
    
    // Scales the texture
//    uv *= 0.5;
    
    float t = time * 0.05;
    
    // Calculate two points on screen.
    float2 c1 = float2(sin(t) * 0.35, cos(time) * 0.55);
    float2 c2 = float2(sin(t * 0.55) * 0.75, cos(time * 0.50) * 0.45);
    
    float3 a = float3(167, 139, 250) / 255.0;
    float3 b = float3(255, 119, 119) / 255.0;
    float3 c = float3(162, 65, 107) / 255.0;
    float3 d = float3(133, 39, 71) / 255.0;
    
    // Determine length to point 1 & calculate color
    float d1 = length(uv - c1);
    float3 col1 = pallete(uv, d1 + t, a, b, c, d);
    
    // Determine length to point 2 & calculate color.
    float d2 = length(uv -c2);
    float3 col2 = pallete(uv, d2 + t, float3(0.2, 0.3, 0.7), float3(0.2, 0.5, 0.9), float3(0.1, 0.5, 0.4), float3(0, 0.1, 0.2));
    
    output.write(float4((col1 + col2) / 2, 1), gid);
    
}
