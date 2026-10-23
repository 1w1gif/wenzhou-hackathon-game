// Dora.d.ts — Dora SSR 运行时 API 类型桩（仅覆盖本项目用到的 API 面）
// 运行时由 Dora SSR 提供 require("Dora")；tsconfig 用 noResolvePaths 跳过其 Lua 解析。
// 构造器均为「值 + 命名空间」合并写法：既可当函数调用，也提供 X.Type 类型。

declare module "Dora" {
  // ---------- 基础值类型 ----------
  export interface Vec2Type {
    x: number;
    y: number;
    add(v: Vec2Type): Vec2Type;
    sub(v: Vec2Type): Vec2Type;
    normalize(): Vec2Type;
  }

  export interface ColorType {
    r: number;
    g: number;
    b: number;
    a: number;
  }

  export interface RectType {
    x: number;
    y: number;
    width: number;
    height: number;
  }

  export interface SizeType {
    width: number;
    height: number;
  }

  // ---------- 构造器（值 + 命名空间） ----------
  export const Vec2: {
    (x?: number, y?: number): Vec2Type;
    new (x?: number, y?: number): Vec2Type;
    Type: Vec2Type;
  };
  export namespace Vec2 {
    export type Type = Vec2Type;
  }

  export const Color: {
    (r: number, g: number, b: number, a?: number): ColorType;
    new (r: number, g: number, b: number, a?: number): ColorType;
    Type: ColorType;
  };
  export namespace Color {
    export type Type = ColorType;
  }

  export const Rect: {
    (x?: number, y?: number, width?: number, height?: number): RectType;
    new (x?: number, y?: number, width?: number, height?: number): RectType;
    Type: RectType;
  };
  export namespace Rect {
    export type Type = RectType;
  }

  // ---------- 输入 ----------
  export type KeyName =
    | "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M"
    | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z"
    | "Space" | "Escape" | "Return" | "Tab" | "LShift" | "LeftShift" | "RShift"
    | "Left" | "Right" | "Up" | "Down" | "Enter" | "Esc"
    | "Num0" | "Num1" | "Num2" | "Num3" | "Num4" | "Num5" | "Num6" | "Num7" | "Num8" | "Num9"
    | "NumAdd" | "NumSub" | "NumMult" | "NumDiv" | "NumEnter" | "NumDecimal";
  export const KeyName: Record<KeyName, KeyName>;

  export const Keyboard: {
    isKeyPressed(key: KeyName): boolean;
    isKeyDown(key: KeyName): boolean;
  };

  // ---------- 节点 ----------
  export interface NodeType {
    x: number;
    y: number;
    z: number;
    angle: number;
    scaleX: number;
    scaleY: number;
    scale: number;
    visible: boolean;
    opacity: number;
    order: number;
    position: Vec2Type;
    anchor: Vec2Type;
    color: ColorType;
    addTo(parent: NodeType): void;
    removeFromParent(): void;
    schedule(callback: (dt: number) => boolean | void): void;
    onKeyDown(callback: (key: KeyName) => void): void;
    perform(action: unknown): void;
  }
  export const Node: {
    (): NodeType;
    new (): NodeType;
    Type: NodeType;
  };
  export namespace Node {
    export type Type = NodeType;
  }

  export interface DrawNodeType extends NodeType {
    clear(): void;
    drawDot(position: Vec2Type, radius: number, color: ColorType): void;
    drawSegment(from: Vec2Type, to: Vec2Type, radius: number, color: ColorType): void;
    drawPolygon(points: Vec2Type[], fill: ColorType): void;
    drawPolygon(points: Vec2Type[], fill: ColorType, borderWidth: number, borderColor: ColorType): void;
  }
  export const DrawNode: {
    (): DrawNodeType;
    new (): DrawNodeType;
    Type: DrawNodeType;
  };
  export namespace DrawNode {
    export type Type = DrawNodeType;
  }

  // ---------- 纹理 / 精灵 / 标签 ----------
  export const TextureFilter: { Point: number; Linear: number };

  export interface Texture2DType {
    width: number;
    height: number;
  }
  export const Texture2D: {
    (filePath: string): Texture2DType | undefined;
    new (filePath: string): Texture2DType;
    Type: Texture2DType;
  };
  export namespace Texture2D {
    export type Type = Texture2DType;
  }

  export interface SpriteType extends NodeType {
    filter: number;
    textureRect: RectType;
    texture: Texture2DType | undefined;
    flipX: boolean;
    flipY: boolean;
  }
  export const Sprite: {
    (texture: Texture2DType | string, rect?: RectType): SpriteType;
    new (texture: Texture2DType | string, rect?: RectType): SpriteType;
    Type: SpriteType;
  };
  export namespace Sprite {
    export type Type = SpriteType;
  }

  export interface LabelType extends NodeType {
    text: string;
    textWidth: number;
    alignment: number;
  }
  export const Label: {
    (fontName: string, fontSize: number): LabelType | undefined;
    new (fontName: string, fontSize: number): LabelType;
    Type: LabelType;
  };
  export namespace Label {
    export type Type = LabelType;
  }

  // ---------- 全局服务 ----------
  export const View: {
    size: SizeType;
    scaleFactor: number;
  };

  export const Director: {
    entry: NodeType;
    ui: NodeType;
    appTime: number;
  };

  export const Audio: {
    playStream(file: string, loop?: boolean, crossFadeTime?: number): boolean;
    stopStream(time?: number): void;
    load(file: string): boolean;
    play(file: string, loop?: boolean): boolean;
    stop(file: string): boolean;
    stopAll(): void;
    getVolume(): number;
    globalVolume: number;
  };

  export interface AudioSourceType extends NodeType {
    volume: number;
    playing: boolean;
    play(): boolean;
    pause(): void;
    stop(): void;
  }
  export const AudioSource: {
    (file: string, autoRemove?: boolean): AudioSourceType | undefined;
    new (file: string, autoRemove?: boolean): AudioSourceType;
    Type: AudioSourceType;
  };
  export namespace AudioSource {
    export type Type = AudioSourceType;
  }
}
