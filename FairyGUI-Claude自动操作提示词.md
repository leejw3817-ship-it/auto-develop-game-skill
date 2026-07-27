---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_efc303fc88f111f1a68c525400826444
    ReservedCode1: MW6DPzPWmf9+MIr+ZP/xEg6ALIUpqBwr+3Zen5iwutd1CEggmV9GDhDKfcOQ5XMMF7/m2KoFLjb13Q71CN4rlVfeVOnTq0RyTZIAcdIWy+A5R8tDThqUDlwooprNY6byPz5rJ2j/6rS7CiZz+yaSJ5psyTwawG38Tyn714A/GIQOBqfJ2yIC3mI1Zb4=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_efc303fc88f111f1a68c525400826444
    ReservedCode2: MW6DPzPWmf9+MIr+ZP/xEg6ALIUpqBwr+3Zen5iwutd1CEggmV9GDhDKfcOQ5XMMF7/m2KoFLjb13Q71CN4rlVfeVOnTq0RyTZIAcdIWy+A5R8tDThqUDlwooprNY6byPz5rJ2j/6rS7CiZz+yaSJ5psyTwawG38Tyn714A/GIQOBqfJ2yIC3mI1Zb4=
---

# 校园杀 Unity + Phaser 3 双引擎架构提示词

> 让 Claude 在保留现有 Phaser 3 游戏逻辑层的前提下，引入 Unity WebGL 作为渲染引擎，双引擎驱动，追求原生级视觉品质。

---

## 一、架构原则：双引擎分工与边界

### 1.1 一句话架构

```
Phaser 3 = 游戏大脑（逻辑/网络/状态/UI交互）
Unity    = 游戏皮囊（渲染/特效/动画/3D场景/音频空间）
```

### 1.2 职责边界表

| 模块 | Phaser 3 负责 | Unity 负责 | 说明 |
|------|-------------|-----------|------|
| 游戏状态机 | ✅ 全局 | ❌ | 回合/阶段/角色状态由 Phaser 管理 |
| 网络通信 | ✅ Socket.io | ❌ | Unity 不直接连服务器 |
| UI 交互 | ✅ 手牌拖拽/按钮/菜单 | ❌ | 操作层归 Phaser，渲染层归 Unity |
| 卡牌渲染 | ❌ | ✅ | 3D 卡牌模型 + PBR 材质 + 稀有度光效 |
| 对战场景 | ❌ | ✅ | 3D 校园场景 + 动态光照 + 后处理 |
| 特效系统 | ❌ | ✅ | 粒子/Shader 特效（伤害/治疗/技能） |
| 角色模型 | ❌ | ✅ | 3D 角色 + 待机/攻击/受伤/胜利动画 |
| 音频空间 | ❌ | ✅ | 3D 空间化音频（距离衰减/方向感） |
| 伤害飘字 | ✅ | ❌ | 飘字复用现有 Canvas 方案 |
| 手牌布局 | ✅ 位置计算 | ✅ 渲染 | Phaser 算坐标，Unity 渲染卡牌 |
| 字幕/日志 | ✅ | ❌ | 文本层归 Phaser |
| 结算动画 | ❌ | ✅ | MVP 展示/Victory/Defeat 全 3D 动画 |

### 1.3 通信架构图

```
┌──────────────────────────────────────────────────┐
│                   Browser (单页)                   │
│                                                    │
│  ┌──────────────┐      postMessage       ┌──────┐ │
│  │  Phaser 3    │ ◄──────────────────► │Unity │ │
│  │  (Canvas 2D) │   Command / Event     │WebGL │ │
│  │              │                       │      │ │
│  │  • 游戏逻辑   │                       │• 渲染 │ │
│  │  • 网络层    │                       │• 特效 │ │
│  │  • UI 文本   │                       │• 动画 │ │
│  │  • 手牌布局   │                       │• 音频 │ │
│  └──────┬───────┘                       └──────┘ │
│         │ Socket.io                                │
│         ▼                                          │
│    Game Server (Python)                            │
└──────────────────────────────────────────────────┘
```

---

## 二、Unity 项目搭建

### 2.1 项目配置

```
Unity 版本: 2022.3 LTS（稳定长期支持版）
渲染管线: URP (Universal Render Pipeline)
目标平台: WebGL 2.0
压缩格式: Brotli（比 Gzip 小 20%）
初始包体目标: < 15MB（代码 + 基础 Shader + 空场景）
资源按需下载: 场景/模型/纹理通过 Addressables 远程加载
```

### 2.2 场景清单（Unity 需要构建的场景）

| 场景名 | 用途 | 核心元素 | 触发时机 |
|--------|------|---------|---------|
| MainMenuScene | 主菜单背景 | 3D 校园全景 + 镜头缓慢环绕 + 粒子樱花/落叶 | 进入主菜单 |
| BattleScene1 | 教室战场 | 课桌排列 + 黑板 + 窗户光线 + 粉笔灰粒子 | 对局开始 |
| BattleScene2 | 操场战场 | 跑道 + 足球门 + 夕阳 Bloom + 远处看台 | 对局开始（随机） |
| BattleScene3 | 天台战场 | 天台围栏 + 城市远景 + 风吹衣服动画 + 晚霞 HDR | 对局开始（随机） |
| BattleScene4 | 图书馆战场 | 书架环绕 + 台灯光照 + 浮尘粒子 + 静谧氛围 | 对局开始（随机） |
| ResultScene | 结算场景 | 聚光灯舞台 + 彩带粒子 + 胜利/失败动画 | 对局结束 |

### 2.3 资产清单（Addressables 远程加载）

| 资产类型 | 数量 | 预估体积 | 备注 |
|---------|------|---------|------|
| 角色模型（低模） | 22 个 | ~66MB | 每人 3K 三角 + 512px 贴图 |
| 角色动画 | 22×5 套 | ~44MB | 待机/攻击/受伤/胜利/死亡，每套 2MB |
| 卡牌模型 | 60 张 | ~30MB | 卡牌 = 带凹凸贴图的薄片，每张 0.5MB |
| 场景模型 | 5 个 | ~80MB | 教室/操场/天台/图书馆/结算舞台 |
| 特效预制体 | 30 个 | ~15MB | 粒子系统/Shader Graph 效果 |
| 音频 | 20 个 | ~20MB | 3D 空间化音效 |
| 天空盒 | 5 个 | ~10MB | 每个场景专用 |
| **合计** | | **~265MB** | 全部分布式加载，初始下载仅 ~15MB |

### 2.4 项目目录结构（Unity 侧）

```
Assets/
├── _Project/
│   ├── Scenes/                    # 场景文件
│   │   ├── MainMenuScene.unity
│   │   ├── BattleScene_Classroom.unity
│   │   ├── BattleScene_Playground.unity
│   │   ├── BattleScene_Rooftop.unity
│   │   ├── BattleScene_Library.unity
│   │   └── ResultScene.unity
│   ├── Prefabs/                   # 预制体
│   │   ├── Characters/            # 22 个角色预制体
│   │   ├── Cards/                 # 卡牌预制体（含卡面/卡背）
│   │   ├── Effects/               # 特效预制体
│   │   └── UI/                    # Unity UI（加载界面/过场）
│   ├── Scripts/                   # C# 脚本
│   │   ├── Bridge/                # Phaser 通信桥接
│   │   │   ├── MessageRouter.cs       # 消息路由中枢
│   │   │   ├── CommandHandler.cs      # 命令解析器
│   │   │   └── EventDispatcher.cs     # 事件上报器
│   │   ├── Core/                  # 核心系统
│   │   │   ├── SceneDirector.cs       # 场景导演（加载/卸载/切换）
│   │   │   ├── CardRenderer3D.cs      # 3D 卡牌渲染器
│   │   │   ├── CharacterAnimator.cs   # 角色动画控制器
│   │   │   └── CameraController.cs    # 相机控制（对局视角）
│   │   ├── Effects/               # 特效系统
│   │   │   ├── EffectManager.cs       # 特效池管理
│   │   │   ├── DamageEffect.cs        # 伤害特效
│   │   │   ├── HealEffect.cs          # 治疗特效
│   │   │   ├── SkillEffect.cs         # 技能释放特效
│   │   │   └── CardPlayEffect.cs      # 出牌特效
│   │   ├── Audio/                 # 音频系统
│   │   │   ├── SpatialAudioManager.cs # 3D 空间音频管理
│   │   │   └── AudioEventEmitter.cs   # 音频事件发射器
│   │   └── Addressables/          # 资源加载
│   │       └── AssetLoader.cs         # Addressables 封装
│   ├── Shaders/                   # 自定义 Shader
│   │   ├── CardPBR.shader             # 卡牌 PBR（金属/粗糙度/法线）
│   │   ├── CardRarityGlow.shader      # 稀有度边缘光（传说金/史诗紫）
│   │   ├── DissolveEffect.shader      # 溶解死亡效果
│   │   └── OutlineHighlight.shader    # 选中高亮描边
│   └── Materials/                 # 材质
└── AddressableAssetsData/         # Addressables 配置
```

---

## 三、Phaser ↔ Unity 通信协议

### 3.1 通信通道

```typescript
// Phaser 侧: 通过 HTML5 postMessage 与 Unity WebGL 实例通信
class UnityBridge {
  private unityInstance: any;  // Unity WebGL 实例引用

  constructor(unityInstance: any) {
    this.unityInstance = unityInstance;
    // 监听 Unity 发来的事件
    window.addEventListener('message', this.handleUnityMessage);
  }

  /** Phaser → Unity: 发送命令 */
  sendCommand(command: UnityCommand): void {
    this.unityInstance.SendMessage('Bridge', 'ReceiveCommand', JSON.stringify(command));
  }

  /** Unity → Phaser: 接收事件 */
  private handleUnityMessage = (event: MessageEvent) => {
    if (event.data?.source !== 'unity') return;
    const evt: UnityEvent = JSON.parse(event.data.payload);
    this.handleEvent(evt);
  };
}
```

```csharp
// Unity 侧: 接收 Phaser 命令
public class CommandHandler : MonoBehaviour
{
    public void ReceiveCommand(string json)
    {
        var cmd = JsonUtility.FromJson<BaseCommand>(json);
        switch (cmd.type)
        {
            case "LOAD_SCENE":       SceneDirector.Load(cmd.sceneId); break;
            case "PLAY_ANIM":        CharacterAnimator.Play(cmd.heroId, cmd.animName); break;
            case "PLAY_EFFECT":      EffectManager.Play(cmd.effectId, cmd.position, cmd.targetHeroId); break;
            case "RENDER_CARDS":     CardRenderer3D.RenderHand(cmd.cardIds, cmd.positions); break;
            case "UPDATE_HP":        CharacterAnimator.UpdateHP(cmd.heroId, cmd.hp, cmd.maxHp); break;
            case "SHOW_RESULT":      SceneDirector.Load("Result", cmd.result); break;
            case "SET_CAMERA":       CameraController.Switch(cmd.viewMode, cmd.heroId); break;
        }
    }
}
```

### 3.2 命令协议（Phaser → Unity）

```typescript
// 所有从 Phaser 发往 Unity 的命令
type UnityCommand =
  | { type: 'LOAD_SCENE'; sceneId: string }                    // 切换场景
  | { type: 'PLAY_ANIM'; heroId: string; animName: string }    // 播放角色动画
  | { type: 'PLAY_EFFECT'; effectId: string; position: Vec3; targetHeroId?: string } // 播放特效
  | { type: 'RENDER_CARDS'; cardIds: string[]; positions: Vec3[] }  // 渲染手牌
  | { type: 'REMOVE_CARD'; cardId: string }                        // 移除卡牌
  | { type: 'PLAY_CARD_TO_FIELD'; cardId: string; fromPos: Vec3; toPos: Vec3 } // 出牌飞行
  | { type: 'UPDATE_HP'; heroId: string; hp: number; maxHp: number } // 更新体力
  | { type: 'UPDATE_EQUIPMENT'; heroId: string; slot: string; cardId: string | null }
  | { type: 'SHOW_RESULT'; result: 'win' | 'lose'; mvpHeroId: string }
  | { type: 'SET_CAMERA'; viewMode: 'overview' | 'self'; heroId: string }
  | { type: 'HIGHLIGHT_HERO'; heroId: string; active: boolean }   // 高亮当前行动角色
  | { type: 'TURN_INDICATOR'; heroId: string }                    // 回合指示器移到目标
  | { type: 'PLAY_BGM'; trackId: string }                         // 切换背景音乐
  | { type: 'PLAY_SFX'; sfxId: string; position: Vec3 }           // 播放空间音效
  | { type: 'DAMAGE_SHAKE'; heroId: string; intensity: number }   // 受击震动
  | { type: 'HERO_DEFEATED'; heroId: string }                     // 角色阵亡动画
  | { type: 'CARD_GLOW'; cardId: string; active: boolean }        // 卡牌高亮（可用提示）
```

### 3.3 事件协议（Unity → Phaser）

```typescript
// 所有从 Unity 上报给 Phaser 的事件（关键时机通知）
type UnityEvent =
  | { type: 'SCENE_LOADED'; sceneId: string }                // 场景加载完毕
  | { type: 'ANIM_COMPLETE'; heroId: string; animName: string } // 动画播放完毕
  | { type: 'EFFECT_COMPLETE'; effectId: string }            // 特效播放完毕
  | { type: 'CARD_ARRIVED'; cardId: string }                 // 卡牌飞行到位
  | { type: 'CARD_CLICKED'; cardId: string }                 // 点击了 Unity 中的卡牌（传递给 Phaser）
  | { type: 'ASSET_LOAD_PROGRESS'; pct: number; assetName: string } // 资源加载进度
  | { type: 'UNITY_READY' }                                  // Unity 完全就绪
```

---

## 四、关键场景交互设计

### 4.1 对战场景运行时布局

```
┌───────────────────────────────────────────────────────┐
│              Unity WebGL Canvas (全屏底层)              │
│                                                        │
│   3D教室场景 · 对手角色模型(待机动画) · 粒子光照         │
│   · 手牌（Unity 3D 卡牌模型，弧线排列）                  │
│   · 装备区（Unity 3D 小卡牌模型）                        │
│   · 角色阴影 + Bloom 后处理                              │
│                                                        │
│ ┌─────────────────────────────────────────────────┐   │
│ │       Phaser Canvas (透明叠加层)                  │   │
│ │                                                  │   │
│ │   顶部HUD: [回合3] [出牌阶段] [倒计时15s]          │   │
│ │   左侧: 己方手牌区(Phaser 计算位置→Unity渲染)      │   │
│ │   伤害飘字: "-2"  (Phaser Text 对象)              │   │
│ │   战斗日志: "张三对李四使用了决斗" (Phaser Text)    │   │
│ │   底栏: [结束回合]按钮                             │   │
│ │                                                  │   │
│ └─────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────┘
```

### 4.2 出牌完整交互链

```
1. 玩家点击 Phaser 层的卡牌
2. Phaser 发送 CARD_GLOW 到 Unity → Unity Shader 高亮该卡牌 + 合法目标
3. 玩家点击目标角色（Unity 3D 模型的 Raycast）
4. Unity 发送 CARD_CLICKED 事件 → Phaser 收到后走游戏逻辑校验
5. 校验通过 → Phaser 发送 PLAY_CARD_TO_FIELD 到 Unity
6. Unity 播放卡牌飞行弧线动画（贝塞尔曲线 + 粒子拖尾）
7. 动画完成 → Unity 上报 CARD_ARRIVED
8. Phaser 发送 PLAY_EFFECT(攻击特效) + DAMAGE_SHAKE(目标震动) + UPDATE_HP
9. 所有特效完成 → Phaser 推进游戏状态机
```

### 4.3 选将界面

```
Unity: 22 个 3D 角色模型环形排列，缓慢自转，聚光灯从上打光
       选中角色 → 前踏一步 + 拔武器动画
       倒计时 → 场景边缘泛红 + 心跳音效渐强

Phaser: 顶部 "选择你的英雄" 标题 + 倒计时数字 + 确认按钮
        底部角色名称 + 技能描述文字
```

### 4.4 结算界面

```
Unity: 胜利方角色站在聚光灯下 + 彩带粒子 + 镜头从低角度仰拍
       失败方角色跪地/低头动画 + 场景暗角压暗
       MVP 角色特写 + 旋转展示

Phaser: 数据面板 "击杀2 辅助1 承伤450"
        [再来一局] [返回大厅] 按钮
```

---

## 五、技术整合关键代码

### 5.1 HTML 入口：双 Canvas 叠加

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    * { margin: 0; padding: 0; overflow: hidden; }
    /* Unity Canvas 占据全屏底层 */
    #unity-container { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 1; }
    #unity-canvas { width: 100%; height: 100%; }
    /* Phaser Canvas 透明叠加在上层 */
    #phaser-container { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 2; pointer-events: none; }
    #phaser-container canvas { pointer-events: auto; /* 仅 Phaser 的交互元素可点击 */ }
    /* 加载遮罩 */
    #loading-overlay {
      position: absolute; top: 0; left: 0; width: 100%; height: 100%;
      background: #1A1A2E; z-index: 100;
      display: flex; flex-direction: column; align-items: center; justify-content: center;
      color: #EAEAEA; font-family: 'bodyFont', sans-serif;
    }
    #loading-progress { width: 60%; max-width: 400px; height: 4px; background: #16213E; margin-top: 16px; border-radius: 2px; }
    #loading-bar { height: 100%; background: #E53935; border-radius: 2px; transition: width 0.3s; }
  </style>
</head>
<body>
  <div id="unity-container">
    <canvas id="unity-canvas"></canvas>
  </div>
  <div id="phaser-container"></div>
  <div id="loading-overlay">
    <h2>校园杀</h2>
    <div id="loading-progress"><div id="loading-bar" style="width:0%"></div></div>
    <p id="loading-text">正在准备对决...</p>
  </div>

  <script src="Build/unity.loader.js"></script>
  <script>
    // Unity 加载
    createUnityInstance(document.querySelector("#unity-canvas"), {
      dataUrl: "Build/unity.data.br",
      frameworkUrl: "Build/unity.framework.js.br",
      codeUrl: "Build/unity.wasm.br",
      streamingAssetsUrl: "StreamingAssets",
      companyName: "CampusKill",
      productName: "CampusKill",
      productVersion: "0.2",
    }).then((unityInstance) => {
      // 暴露给 Phaser
      window.__unityInstance = unityInstance;
      document.getElementById('loading-overlay').style.display = 'none';
      // 启动 Phaser
      window.dispatchEvent(new Event('unity-ready'));
    }).catch((error) => {
      console.error('Unity 加载失败，回退到纯 Phaser 模式', error);
      window.__unityFailed = true;
      document.getElementById('loading-overlay').style.display = 'none';
      window.dispatchEvent(new Event('unity-ready')); // 带标识的回退
    });
  </script>
</body>
</html>
```

### 5.2 Phaser 侧：双引擎 Game 配置

```typescript
// main.ts
import Phaser from 'phaser';
import { UnityBridge } from './engine/UnityBridge';
import { BattleScene } from './scenes/BattleScene';

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.CANVAS,           // 必须 CANVAS，WebGL 会与 Unity 抢上下文
  parent: 'phaser-container',
  width: 1920,
  height: 1080,
  transparent: true,             // 透明背景，让 Unity 画面透出
  backgroundColor: 'transparent',
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
  scene: [BootScene, MenuScene, BattleScene, ResultScene],
};

const game = new Phaser.Game(config);

// 全局 Unity 桥接实例
export const unityBridge = new UnityBridge();
```

### 5.3 Unity 侧：WebGL 模板定制

```csharp
// Assets/WebGLTemplates/CampusKill/index.html (Unity 构建模板)
// 自定义 Unity WebGL 模板，使 Canvas 透明背景 + 去默认 UI

// 关键修改：
// 1. unityInstance 创建时传入 backgroundColor: [0,0,0,0] (透明)
// 2. 移除 Unity 默认的加载进度条（由外层 HTML 统一管理）
// 3. 移除 Unity 默认的 fullscreen 按钮
// 4. 注入 MessageRouter.js 初始化脚本
```

### 5.4 双引擎同步的帧率协调

```typescript
// Phaser 侧: RateLimiter —— 避免过度向 Unity 发命令
class UnityRateLimiter {
  private lastSendTime = 0;
  private readonly minInterval = 16; // ms，约 60fps

  send(command: UnityCommand): void {
    const now = performance.now();
    if (now - this.lastSendTime < this.minInterval) {
      // 合并到下一帧发送
      this.pendingCommands.push(command);
      if (!this.scheduled) {
        this.scheduled = true;
        requestAnimationFrame(() => {
          this.flush();
          this.scheduled = false;
        });
      }
      return;
    }
    this.lastSendTime = now;
    unityBridge.sendCommand(command);
  }

  private pendingCommands: UnityCommand[] = [];
  private scheduled = false;

  private flush(): void {
    // 合并同类命令（如多次 UPDATE_HP 只发最后一次）
    const merged = this.mergeCommands(this.pendingCommands);
    merged.forEach(cmd => unityBridge.sendCommand(cmd));
    this.pendingCommands = [];
    this.lastSendTime = performance.now();
  }
}
```

---

## 六、降级与回退策略

### 6.1 三级渲染模式

```
Mode A: Unity + Phaser（完整双引擎）
  条件: WebGL 2.0 可用 + 设备性能足够（桌面端 / 高端移动端）
  体验: 完整 3D 场景 + 全特效

Mode B: Phaser + WebGL 特效（轻量双引擎）
  条件: WebGL 2.0 不可用但 WebGL 1.0 可用
  体验: Phaser 2D 场景 + Phaser WebGL 粒子特效
  实现: Unity 加载失败时自动切换

Mode C: 纯 Phaser（单引擎回退）
  条件: WebGL 均不可用 / 设备性能不足
  体验: 现有 v0.1 体验（纯 Canvas 2D）
  实现: 完全绕过 Unity 加载
```

### 6.2 自动检测与切换

```typescript
// engine/RenderModeDetector.ts
export function detectRenderMode(): 'dual' | 'lite' | 'fallback' {
  // 检测 WebGL 2.0
  const canvas = document.createElement('canvas');
  const gl2 = canvas.getContext('webgl2');
  if (!gl2) {
    return 'fallback'; // 完全不支持 WebGL 2.0
  }

  // 检测性能（简单 GPU 基准）
  const debugInfo = gl2.getExtension('WEBGL_debug_renderer_info');
  const gpu = debugInfo
    ? gl2.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL).toLowerCase()
    : '';

  // 集成显卡 / 低端移动 GPU → 轻量模式
  if (gpu.includes('intel hd') || gpu.includes('mali-4') || gpu.includes('adreno 3')) {
    return 'lite';
  }

  // 可以跑 Unity
  return 'dual';
}
```

---

## 七、构建与部署流水线

### 7.1 构建产物结构

```
dist/
├── index.html                          # 双 Canvas 入口
├── assets/                             # Phaser 静态资源（图标/字体/音效）
├── Build/                              # Unity WebGL 构建产物
│   ├── unity.loader.js
│   ├── unity.framework.js.br           # Brotli 压缩
│   ├── unity.data.br
│   └── unity.wasm.br
├── Addressables/                       # Unity Addressables 远程资源（CDN 部署）
│   ├── scenes/
│   ├── characters/
│   ├── effects/
│   └── catalog_xxx.json
└── js/                                 # Phaser 业务代码（Vite 打包）
    └── bundle.xxx.js
```

### 7.2 构建命令

```bash
# 1. 构建 Unity WebGL
# Unity CLI:
/Applications/Unity/Hub/Editor/2022.3.x/Unity.app/Contents/MacOS/Unity \
  -quit -batchmode -projectPath ./CampusKillUnity \
  -buildTarget WebGL \
  -executeMethod CampusKillBuilder.Build \
  -logFile build.log

# CampusKillBuilder.Build 方法：
# - 切换到 CampusKill WebGL Template
# - 启用 Brotli 压缩
# - 设置 Code Optimization: Size
# - 输出到 ../public/Build/

# 2. 构建 Phaser (Vite)
npm run build

# 3. 部署 Addressables 到 CDN
# Unity Addressables 构建后产物 → 上传到 CDN
```

### 7.3 体积控制

| 优化项 | 方法 | 效果 |
|--------|------|------|
| Unity Wasm 体积 | IL2CPP + Code Stripping: High + Managed Stripping Level: High | 减小 40% |
| Shader 变体 | 仅保留 URP Lit + 自定义 Shader，关闭 Built-in 变体 | 减小 60% |
| 纹理压缩 | Crunch 压缩(WebGL 用 DXT)，最大 1024px | 减小 50% |
| 场景按需加载 | Addressables 远程加载，不打包进初始构建 | 初始包 < 15MB |
| 音频流式 | BGM 使用 Streaming 模式，不全部加载到内存 | 内存节省 80MB |

---

## 八、迁移策略（不推倒重来）

### 8.1 渐进式三步迁移

```
Phase 1: Unity 作为"背景渲染器"（1-2 天）
  ├── 新增 BootScene → 加载 Unity WebGL
  ├── 替换 BattleScene 背景：从 Phaser 纯色 → Unity 3D 教室场景
  ├── 手牌/装备/角色仍用 Phaser 渲染
  └── 目标：看到 3D 场景背景，游戏逻辑零改动

Phase 2: Unity 接管卡牌/角色渲染（2-3 天）
  ├── 卡牌从 Phaser Sprite → Unity 3D 卡牌模型
  ├── 角色从头像 → Unity 3D 角色模型 + 动画
  ├── 装备区/判定区 → Unity 小卡牌模型
  ├── 手牌位置仍由 Phaser 计算，渲染交给 Unity
  └── 目标：对局画面全部 3D 化，交互层仍是 Phaser

Phase 3: Unity 接管特效/动画（1-2 天）
  ├── 伤害/治疗/技能特效 → Unity Shader + 粒子
  ├── 出牌/弃牌/判定 → Unity 动画
  ├── 角色死亡/胜利 → Unity 骨骼动画
  ├── 结算画面 → Unity ResultScene
  └── 目标：完整双引擎体验
```

### 8.2 代码修改最小化原则

```
现有 BattleScene.ts 的游戏逻辑代码（状态机/网络/事件处理）→ 零改动
仅替换渲染相关方法：
  drawSeats()        → 删除，改为 unityBridge.sendCommand({type:'...'})
  drawHand()         → 位置计算保留，渲染行替换
  drawEquipments()   → 删除
  playCardAnimation()→ 删除
  showDamageEffect() → 删除

新增 Unity 命令调用点（在现有事件回调中插入）：
  on('game:turnStart',  heroId => unity.send({type:'TURN_INDICATOR', heroId}))
  on('game:phaseChange', phase => /* 无 Unity 命令，仅 Phaser HUD 更新 */)
  on('game:damage',     data  => { unity.send({type:'PLAY_EFFECT',...}); unity.send({type:'UPDATE_HP',...}); })
  on('game:heal',       data  => { unity.send({type:'PLAY_EFFECT',...}); unity.send({type:'UPDATE_HP',...}); })
  on('game:cardPlayed',  card  => unity.send({type:'PLAY_CARD_TO_FIELD',...}))
  on('game:heroDefeated',heroId => unity.send({type:'HERO_DEFEATED', heroId}))
  on('game:gameOver',   result => unity.send({type:'SHOW_RESULT', result}))
```

---

## 九、性能基准与验收标准

| 指标 | 目标值 | 测量方法 |
|------|--------|----------|
| Unity 帧率 | ≥ 55 FPS（桌面）/ ≥ 30 FPS（移动） | Unity Stats 面板 |
| Phaser 帧率 | ≥ 58 FPS | Phaser game.loop.actualFps |
| Unity Wasm 初始加载 | < 5 秒（4G 网络） | Performance API |
| 场景切换延迟 | < 1 秒 | 从 LOAD_SCENE 发送到 SCENE_LOADED 回调 |
| 命令延迟（Phaser→Unity） | < 2ms（同帧） | Performance.now() 差值 |
| 内存占用 | < 500MB（含 Unity + Phaser + 资源） | Chrome DevTools Memory |
| GPU 占用 | < 80%（集成显卡） | 任务管理器 |

---

## 十、输出要求

1. **Unity 项目**：完整的 `CampusKillUnity` 项目，包含上述目录结构、所有 C# 脚本、场景和预制体
2. **Phaser 集成代码**：`UnityBridge.ts` / `RateLimiter.ts` / `RenderModeDetector.ts` / `main.ts` 及所有修改后的 Scene 文件
3. **HTML 入口**：`index.html` 双 Canvas 叠加 + Unity 加载器
4. **构建脚本**：`CampusKillBuilder.cs`（Unity 侧）+ Vite 配置更新
5. **Addressables 配置**：所有资源的 Group 和 Label 设置
6. 所有代码使用 TypeScript / C#，类型完备，零 any / 零 dynamic
7. 游戏必须可以从主菜单 → 选将 → 对局 → 结算完整走通，视觉上看到 3D 场景
*（内容由AI生成，仅供参考）*
