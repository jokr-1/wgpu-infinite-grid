fn grid(frag_pos: vec3<f32>, scale: f32) -> vec4<f32> {
    let coord = frag_pos.xz * scale; // use the scale variable to set the distance between the lines
    let derivative = fwidth(coord) * 0.8;
    let grid = abs(fract(coord - 0.5) - 0.5) / derivative;
    let line = min(grid.x, grid.y);
    let minimumz = min(derivative.y, 1.0);
    let minimumx = min(derivative.x, 1.0);
    var color = vec4(0.15, 0.15, 0.15, 1.0 - min(line, 0.75));

    // color.w *= 0.1;
    // z axis
    if frag_pos.x > -0.5 * minimumx && frag_pos.x < 0.5 * minimumx {
        color.x = 0.3;
        color.y = 0.3;
        color.z = 0.3;
        color.w = 0.7;
    }
        
    // x axis
    if frag_pos.z > -0.5 * minimumz && frag_pos.z < 0.5 * minimumz {
        color.x = 0.3;
        color.y = 0.3;
        color.z = 0.3;
        color.w = 0.7;
    }

    return color;
}

fn computeLinearDepth(p: vec3<f32>) -> f32 {
    let near = 0.01;
    let far = 10.0;
    let clip_space_pos = camera.view_proj * vec4<f32>(p.xyz, 1.0);
    let clip_space_depth = (clip_space_pos.z / clip_space_pos.w) * 2.0 - 1.0; // put back between -1 and 1
    let linear_depth = (2.0 * near * far) / (far + near - clip_space_depth * (far - near)); // get linear value between 0.01 and 100
    return linear_depth / far; // normalize
}

struct CameraUniform {
    view_position: vec3<f32>,
    view_proj: mat4x4<f32>,
};

@group(0) @binding(0)
var<uniform> camera: CameraUniform;

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(1) color: vec4<f32>,
    @location(2) near_point: vec3<f32>,
    @location(3) far_point: vec3<f32>,
};

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let t = -in.near_point.y / (in.far_point.y - in.near_point.y);
    let frag_pos = in.near_point + t * (in.far_point - in.near_point);
    let alpha = 1.0 * f32(t > 0.0);
    let linear_depth = computeLinearDepth(frag_pos);
    let fading = max(0.0, (0.5 - linear_depth));
    return grid(frag_pos, 2.0) * alpha * fading; //vec4<f32>(1.0, 0.0, 0.0, alpha);
}