layout(std140) uniform commonUniforms {
  vec4 u_stroke_color : [0.0, 0.0, 0.0, 0.0];
  float u_stroke_width;
  float u_stroke_opacity : 1;
  vec2 u_offsets;
  float u_additive;
};

in vec4 v_color;
in float v_blur;
in float v_innerRadius;
out vec4 outputColor;

#pragma include "picking"
void main() {
  vec2 center = vec2(0.5);

  // Tip: 片元到中心点的距离 0 - 1
  float fragmengTocenter = distance(center, gl_PointCoord) * 2.0;
  // Tip: 片元的剪切成圆形
  float circleClipOpacity = 1.0 - smoothstep(v_blur, 1.0, fragmengTocenter);


  if(v_innerRadius < 0.99) {
    // 当存在 stroke 且 stroke > 0.01
    float blurWidth = (1.0 - v_blur)/2.0;
    vec4 stroke = vec4(u_stroke_color.rgb, u_stroke_opacity);
    if(fragmengTocenter > v_innerRadius + blurWidth) {
      outputColor = stroke;
    } else if(fragmengTocenter > v_innerRadius - blurWidth){
      float mixR = (fragmengTocenter - (v_innerRadius - blurWidth)) / (blurWidth * 2.0);
      outputColor = mix(v_color, stroke, mixR);
    } else {
      outputColor = v_color;
    }
  } else {
    // 当不存在 stroke 或 stroke <= 0.01
    outputColor = v_color;
  }

  outputColor = filterColor(outputColor);
  
  if(u_additive > 0.0) {
    outputColor *= circleClipOpacity;
  } else {
    outputColor.a *= circleClipOpacity;
  }

}
