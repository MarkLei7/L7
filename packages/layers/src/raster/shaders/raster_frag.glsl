in vec4 v_color;
layout(std140) uniform commonUniforms {
 vec4 u_extent;
 float u_opacity;
 float u_min;
 float u_max;
 float u_width;
 float u_height;
 float u_heightRatio;
};
#define PI 3.141592653589793;

out vec4 outputColor
void main() {
   outputColor = v_color;
   outputColor.a *= u_opacity;
   if(outputColor.a < 0.01)
   discard;

}
