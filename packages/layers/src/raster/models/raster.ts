import {
  AttributeType,
  gl,
  IEncodeFeature,
  IModel,
  ITexture2D,
} from '@antv/l7-core';
import { getDefaultDomain } from '@antv/l7-utils';
import BaseModel from '../../core/BaseModel';
import { IRasterLayerStyleOptions } from '../../core/interface';
import { RasterImageTriangulation } from '../../core/triangulation';
import rasterFrag from '../shaders/raster_2d_frag.glsl';
import rasterVert from '../shaders/raster_2d_vert.glsl';
import { ShaderLocation } from '../../core/CommonStyleAttribute';
export default class RasterModel extends BaseModel {
  protected texture: ITexture2D;
  protected colorTexture: ITexture2D;
  public getUninforms() {
    const commoninfo = this.getCommonUniformsInfo();
    const attributeInfo = this.getUniformsBufferInfo(this.getStyleAttribute());
    this.updateStyleUnifoms();
    return {
      ...commoninfo.uniformsOption,
      ...attributeInfo.uniformsOption,
    }

  }
  protected getCommonUniformsInfo(): { uniformsArray: number[]; uniformsLength: number; uniformsOption: { [key: string]: any } } {
    const {
      clampLow = true,
      clampHigh = true,
      noDataValue = -9999999,
      domain,
      rampColors,
    } = this.layer.getLayerConfig() as IRasterLayerStyleOptions;
    const newdomain = domain || getDefaultDomain(rampColors);
    this.colorTexture = this.layer.textureService.getColorTexture(
      rampColors,
      newdomain,
    );

    const commonOptions = {
      // u_opacity: opacity || 1,
      u_texture: this.texture,
      u_domain: newdomain,
      u_clampLow: clampLow,
      u_clampHigh: typeof clampHigh !== 'undefined' ? clampHigh : clampLow,
      u_noDataValue: noDataValue,
      u_colorTexture: this.colorTexture,
    };
    const commonBufferInfo = this.getUniformsBufferInfo(commonOptions);

    return commonBufferInfo;
  }

  private async getRasterData(parserDataItem: any) {
    if (Array.isArray(parserDataItem.data)) {
      // 直接传入波段数据
      return {
        data: parserDataItem.data,
        width: parserDataItem.width,
        height: parserDataItem.height,
      };
    } else {
      // 多波段形式、需要进行处理
      const { rasterData, width, height } = await parserDataItem.data;
      return {
        data: Array.from(rasterData),
        width,
        height,
      };
    }
  }

  public async initModels(): Promise<IModel[]> {
    const source = this.layer.getSource();
    const { createTexture2D } = this.rendererService;
    const parserDataItem = source.data.dataArray[0];

    const { data, width, height } = await this.getRasterData(parserDataItem);

    this.texture = createTexture2D({
      data,
      width,
      height,
      format: gl.LUMINANCE,
      type: gl.FLOAT,
      // aniso: 4,
    });

    const model = await this.layer.buildLayerModel({
      moduleName: 'rasterImageData',
      vertexShader: rasterVert,
      fragmentShader: rasterFrag,
      triangulation: RasterImageTriangulation,
      inject: this.getInject(),
      primitive: gl.TRIANGLES,
      depth: { enable: false },
    });
    return [model];
  }

  public async buildModels(): Promise<IModel[]> {
    this.initUniformsBuffer();//不确定要不要这个
    return this.initModels();
  }

  public clearModels(): void {
    this.texture?.destroy();
    this.colorTexture?.destroy();
  }

  protected registerBuiltinAttributes() {
    // point layer size;
    this.styleAttributeService.registerStyleAttribute({
      name: 'uv',
      type: AttributeType.Attribute,
      descriptor: {
        name: 'a_Uv',
        shaderLocation: ShaderLocation.UV,
        buffer: {
          // give the WebGL driver a hint that this buffer may change
          usage: gl.DYNAMIC_DRAW,
          data: [],
          type: gl.FLOAT,
        },
        size: 2,
        update: (
          feature: IEncodeFeature,
          featureIdx: number,
          vertex: number[],
        ) => {
          return [vertex[3], vertex[4]];
        },
      },
    });
  }
}
