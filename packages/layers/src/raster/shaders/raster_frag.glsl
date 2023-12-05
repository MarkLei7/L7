in vec4 v_color;
in float v_opacity;
#define PI 3.141592653589793;

out vec4 outputColor
void main() {
   outputColor = v_color;
   outputColor.a *= v_opacity;
   if(outputColor.a < 0.01)
   discard;

}
