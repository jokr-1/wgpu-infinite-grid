fn inverse_m4(m: mat4x4<f32>) -> mat4x4<f32> {
        // Note: wgsl does not have an inverse() (matrix inverse) function built in.
        // Source adapted from https://github.com/glslify/glsl-inverse/blob/master/index.glsl
    let a00 = m[0][0];
    let a01 = m[0][1];
    let a02 = m[0][2];
    let a03 = m[0][3];
    let a10 = m[1][0];
    let a11 = m[1][1];
    let a12 = m[1][2];
    let a13 = m[1][3];
    let a20 = m[2][0];
    let a21 = m[2][1];
    let a22 = m[2][2];
    let a23 = m[2][3];
    let a30 = m[3][0];
    let a31 = m[3][1];
    let a32 = m[3][2];
    let a33 = m[3][3];
    let b00 = a00 * a11 - a01 * a10;
    let b01 = a00 * a12 - a02 * a10;
    let b02 = a00 * a13 - a03 * a10;
    let b03 = a01 * a12 - a02 * a11;
    let b04 = a01 * a13 - a03 * a11;
    let b05 = a02 * a13 - a03 * a12;
    let b06 = a20 * a31 - a21 * a30;
    let b07 = a20 * a32 - a22 * a30;
    let b08 = a20 * a33 - a23 * a30;
    let b09 = a21 * a32 - a22 * a31;
    let b10 = a21 * a33 - a23 * a31;
    let b11 = a22 * a33 - a23 * a32;
    let det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
    return mat4x4(
        vec4<f32>(
            a11 * b11 - a12 * b10 + a13 * b09,
            a02 * b10 - a01 * b11 - a03 * b09,
            a31 * b05 - a32 * b04 + a33 * b03,
            a22 * b04 - a21 * b05 - a23 * b03
        ),
        vec4<f32>(
            a12 * b08 - a10 * b11 - a13 * b07,
            a00 * b11 - a02 * b08 + a03 * b07,
            a32 * b02 - a30 * b05 - a33 * b01,
            a20 * b05 - a22 * b02 + a23 * b01
        ),
        vec4<f32>(
            a10 * b10 - a11 * b08 + a13 * b06,
            a01 * b08 - a00 * b10 - a03 * b06,
            a30 * b04 - a31 * b02 + a33 * b00,
            a21 * b02 - a20 * b04 - a23 * b00
        ),
        vec4<f32>(
            a11 * b07 - a10 * b09 - a12 * b06,
            a00 * b09 - a01 * b07 + a02 * b06,
            a31 * b01 - a30 * b03 - a32 * b00,
            a20 * b03 - a21 * b01 + a22 * b00
        )
    ) * (1.0 / det);
}

fn unproject_point(x: f32, y: f32, z: f32) -> vec3<f32> {
    let p = inverse_m4(camera.view_proj) * vec4(x, y, z, 1.0);
    return p.xyz / p.w;
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

@vertex
fn vs_main(
    @builtin(vertex_index) in_vertex_index: u32,
) -> VertexOutput {
    var out: VertexOutput;
    var plane = array(
        vec3<f32>(1.0, 1.0, 0.0),
        vec3<f32>(-1.0, 1.0, 0.0),
        vec3<f32>(-1.0, -1.0, 0.0),
        vec3<f32>(1.0, 1.0, 0.0),
        vec3<f32>(-1.0, -1.0, 0.0),
        vec3<f32>(1.0, -1.0, 0.0),
    );

    let p = plane[in_vertex_index];

    out.clip_position = vec4<f32>(p, 1.0);
    out.color = vec4<f32>(1.0, 0.0, 0.0, 1.0);
    out.near_point = unproject_point(p.x, p.y, 0.0).xyz;
    out.far_point = unproject_point(p.x, p.y, 1.0).xyz;
    return out;
}