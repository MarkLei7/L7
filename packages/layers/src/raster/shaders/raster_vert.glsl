precision highp float;
layout(location = 0) in vec3 a_Position;
layout(std140) uniform commonUniforms {
 mat4 u_ModelMatrix;
 vec4 u_extent;
 float u_min;
 float u_max;
 float u_width;
 float u_height;
 float u_heightRatio;
};

sampler2D u_texture;
sampler2D u_colorTexture;
out vec2 v_texCoord;
out vec4 v_color;

#pragma include "projection"
void main() {
  vec2 uv = a_Position.xy / vec2(u_width, u_height);
  vec2 minxy =  project_position(vec4(u_extent.xy, 0, 1.0)).xy;
  vec2 maxxy =  project_position(vec4(u_extent.zw, 0, 1.0)).xy;
  float value = texture(SAMPLER_2D(u_texture) vec2(uv.x,1.0 - uv.y)).x;
  vec2 step = (maxxy - minxy) / vec2(u_width, u_height);
  vec2 pos = minxy + vec2(a_Position.x, a_Position.y ) * step;
  //  v_texCoord = a_Uv;
  value = clamp(value,u_min,u_max);
  float value1 =  (value - u_min) / (u_max -u_min);
  vec4 color = texture(SAMPLER_2D(u_colorTexture),vec2(intensity, 0));



  gl_Position = project_common_position_to_clipspace_v2(vec4(pos.xy, project_scale(value) * u_heightRatio, 1.0));

}
