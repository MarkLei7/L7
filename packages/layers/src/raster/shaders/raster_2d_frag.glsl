precision mediump float;
layout(std140) uniform commonUniforms {
 float u_min;
 float u_max;
 vec2 u_domain;
 float u_noDataValue;
 bool u_clampLow: true;
 bool u_clampHigh: true;
};
uniform sampler2D u_texture;
uniform sampler2D u_colorTexture;

in vec2 v_texCoord;
in float v_opacity;
out vec4 outputColor;

bool isnan_emu(float x) { return (x > 0.0 || x < 0.0) ? x != x : x != 0.0; }


void main() {

  float value = texture(SAMPLER_2D(u_texture),vec2(v_texCoord.x,v_texCoord.y)).r;
  if (value == u_noDataValue || isnan_emu(value))
      discard;
  else if ((!u_clampLow && value < u_domain[0]) || (!u_clampHigh && value > u_domain[1]))
     discard;
  else {
    float normalisedValue =(value - u_domain[0]) / (u_domain[1] -u_domain[0]);
    vec4 color = texture(SAMPLER_2D(u_colorTexture),vec2(normalisedValue, 0));
    
    outputColor = color;
    outputColor.a =  outputColor.a * v_opacity ;
    if(outputColor.a < 0.01)
      discard;
   
  }
}
