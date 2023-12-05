precision highp float;
layout(location = 0) in vec3 a_Position;
layout(location = 14) in vec2 a_Uv;
layout(std140) uniform commonUniforms {
 mat4 u_ModelMatrix;
};
out vec2 v_texCoord;
out float v_opacity;
#pragma include "projection"
void main() {
   v_texCoord = a_Uv;
   v_opacity = opacity;
   vec4 project_pos = project_position(vec4(a_Position, 1.0));

    gl_Position = project_common_position_to_clipspace_v2(vec4(project_pos.xy,0., 1.0));
}
