---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_a7f55c0e88da11f18766525400f8a581
    ReservedCode1: VIXF1tpl1kKFg9P0YWcSvkRw3XLHWMEqW9a20XGDkkPFFE8tO7KTYWazw68yA8DQ1QWv5uKbsFJgFeYze38p2pDld1yUL+fSyvgEr6ZElbO2m/NagpCZ7HmM/Oi2xt4zTJSxBM67B1npsEZbiCXGy+oyWq/FW+I6fNxvvxPBuNfP/Bxnyk0y1kY9S3s=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_a7f55c0e88da11f18766525400f8a581
    ReservedCode2: VIXF1tpl1kKFg9P0YWcSvkRw3XLHWMEqW9a20XGDkkPFFE8tO7KTYWazw68yA8DQ1QWv5uKbsFJgFeYze38p2pDld1yUL+fSyvgEr6ZElbO2m/NagpCZ7HmM/Oi2xt4zTJSxBM67B1npsEZbiCXGy+oyWq/FW+I6fNxvvxPBuNfP/Bxnyk0y1kY9S3s=
---

# 多人在线卡牌对战游戏 - 手游客户端开发完整提示词

> 本提示词用于 Claude Code，请严格按照以下规范和架构生成完整移动端代码。
> 技术栈：React Native + TypeScript + react-native-game-engine + Socket.IO Client
> 目标平台：Android APK + iOS IPA

---

## 一、项目总览与架构原则

### 1.1 客户端定位
- 本客户端是之前后端开发的移动端对等实现，完整承载 1v1 标准对战与 4 人身份局
- 零美术依赖，所有视觉资源（卡面/战场背景/特效/粒子）在客户端本地程序化生成
- 与后端通过 Socket.IO 长连接实时通信，客户端仅做表现层渲染，所有游戏逻辑由服务端权威

### 1.2 架构原则

| 原则 | 说明 |
|------|------|
| 服务端权威 | 客户端不做游戏逻辑判定，只做表现和输入转发 |
| Canvas 渲染 | 游戏主界面使用 react-native-skia 或 WebView+Canvas 渲染，不依赖原生 UI 组件叠加 |
| 代码复用 | 游戏核心类型定义、状态模型、卡牌数据与 Web 端共享 |
| 离线可展示 | 卡牌收藏、牌组编辑、对战回放等非实时功能支持离线浏览 |
| 分包策略 | 卡牌/特效/音效资源按需下载，安装包基础体积 ≤ 80MB |

### 1.3 项目目录结构

```
card-game-mobile/
├── src/
│   ├── App.tsx                          # 根组件 + 导航容器
│   ├── navigation/
│   │   ├── RootNavigator.tsx            # 根导航（登录→大厅→对局）
│   │   └── GameNavigator.tsx            # 对局内导航
│   ├── screens/
│   │   ├── SplashScreen.tsx             # 启动画面
│   │   ├── LoginScreen.tsx              # 登录/注册
│   │   ├── LobbyScreen.tsx              # 大厅主页
│   │   ├── DeckEditorScreen.tsx         # 牌组编辑
│   │   ├── CardCollectionScreen.tsx     # 卡牌收藏
│   │   ├── MatchHistoryScreen.tsx       # 对战记录
│   │   ├── LeaderboardScreen.tsx        # 天梯排行
│   │   ├── RoomScreen.tsx               # 房间等待
│   │   ├── GameScreen.tsx               # 对局主界面
│   │   └── SettlementScreen.tsx         # 结算界面
│   ├── game/                            # 游戏核心（表现层）
│   │   ├── GameCanvas.tsx               # 游戏画布容器（Skia Canvas）
│   │   ├── BoardRenderer.ts             # 战场渲染器
│   │   ├── HandRenderer.ts              # 手牌渲染器
│   │   ├── CardRenderer.ts              # 单张卡牌渲染器
│   │   ├── HeroRenderer.ts              # 英雄/血量渲染
│   │   ├── ManaCrystal.ts               # 法力水晶 UI
│   │   ├── TurnIndicator.ts             # 回合指示器
│   │   ├── IdentityBadge.ts             # 身份标识（4人局）
│   │   ├── animations/
│   │   │   ├── AnimationManager.ts      # 动画编排器
│   │   │   ├── CardPlayAnimation.ts     # 出牌动画
│   │   │   ├── AttackAnimation.ts       # 攻击动画
│   │   │   ├── DeathAnimation.ts        # 死亡动画
│   │   │   ├── DamageNumber.ts          # 伤害数字飘字
│   │   │   ├── ManaAnimation.ts         # 法力水晶动画
│   │   │   └── ParticleSystem.ts        # 粒子系统（兼容移动端）
│   │   ├── gestures/
│   │   │   ├── DragCardHandler.ts       # 拖拽出牌手势
│   │   │   ├── TapTargetHandler.ts      # 点击选择目标
│   │   │   ├── SwipeHandler.ts          # 滑动手牌浏览
│   │   │   └── LongPressHandler.ts      # 长按查看卡牌详情
│   │   └── procedural/                  # 程序化生成
│   │       ├── CardFaceGenerator.ts     # 卡面生成
│   │       ├── BoardBgGenerator.ts      # 战场背景生成
│   │       └── EffectRenderer.ts        # 特效渲染
│   ├── network/                         # 网络层
│   │   ├── SocketClient.ts              # Socket.IO 客户端封装
│   │   ├── API.ts                       # HTTP API 封装
│   │   ├── ReconnectManager.ts          # 断线重连管理
│   │   └── StateSyncEngine.ts           # 状态同步引擎
│   ├── store/                           # 状态管理
│   │   ├── AuthStore.ts                 # 认证状态
│   │   ├── GameStore.ts                 # 对局状态（Zustand）
│   │   ├── LobbyStore.ts                # 大厅状态
│   │   └── DeckStore.ts                 # 牌组状态
│   ├── audio/                           # 音频
│   │   ├── AudioManager.ts             # 音频管理器
│   │   ├── SoundEffectPlayer.ts        # 音效播放
│   │   └── BGMManager.ts               # 背景音乐
│   ├── assets/                          # 静态资源
│   │   ├── fonts/                       # 字体
│   │   ├── icons/                       # 图标
│   │   └── sounds/                      # 音效文件
│   ├── utils/
│   │   ├── ScreenAdapter.ts             # 多分辨率适配
│   │   ├── MemoryManager.ts             # 移动端内存管理
│   │   ├── CacheManager.ts              # 本地缓存
│   │   └── DeviceInfo.ts                # 设备信息
│   └── types/
│       ├── game.ts                      # 游戏类型（与后端对齐）
│       ├── network.ts                   # 网络协议类型
│       └── ui.ts                        # UI 相关类型
├── android/                             # Android 原生配置
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── java/.../
│   │           └── MainApplication.java
│   └── settings.gradle
├── ios/                                 # iOS 原生配置
│   ├── CardGame/
│   │   ├── AppDelegate.mm
│   │   └── Info.plist
│   └── Podfile
├── __tests__/
├── package.json
├── tsconfig.json
├── metro.config.js
├── babel.config.js
├── react-native.config.js
└── eas.json                             # Expo Application Services 构建配置
```

---

## 二、技术栈与关键依赖

### 2.1 依赖清单

```json
{
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.74.0",
    "@shopify/react-native-skia": "^1.2.0",
    "react-native-gesture-handler": "^2.16.0",
    "react-native-reanimated": "^3.10.0",
    "socket.io-client": "^4.7.0",
    "zustand": "^4.5.0",
    "@react-navigation/native": "^6.1.0",
    "@react-navigation/stack": "^6.3.0",
    "@react-navigation/bottom-tabs": "^6.5.0",
    "react-native-safe-area-context": "^4.10.0",
    "react-native-screens": "^3.31.0",
    "react-native-sound": "^0.11.0",
    "@react-native-async-storage/async-storage": "^1.23.0",
    "react-native-fs": "^2.20.0",
    "axios": "^1.7.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-native": "^0.73.0",
    "typescript": "^5.4.0",
    "jest": "^29.7.0",
    "@testing-library/react-native": "^12.4.0",
    "metro-react-native-babel-preset": "^0.77.0",
    "expo": "~51.0.0",
    "eas-cli": "^10.0.0"
  }
}
```

### 2.2 为什么选 React Native 而非 Unity / Flutter

| 考量 | React Native | Flutter | Unity |
|------|-------------|---------|-------|
| 与现有 Web 端代码复用 | 高（共享 TypeScript 类型、状态逻辑） | 低（Dart 独立实现） | 极低（C#） |
| 安装包体积 | 15-30MB（基础） | 20-40MB | 50-80MB+ |
| Canvas 2D 渲染 | react-native-skia（GPU 加速） | CustomPainter（优质） | 内置（最强大） |
| 热更新 | CodePush / expo-updates | 需第三方方案 | Addressables |
| 学习成本 | 低（JS/TS 生态） | 中 | 高 |
| 卡牌游戏适用性 | 完全胜任 | 完全胜任 | 过重 |

> 最终选择 React Native + Skia Canvas——最大化复用已有的 TypeScript 类型定义和状态管理逻辑，安装包轻量，热更新方便。

---

## 三、多分辨率适配系统（重中之重）

移动端碎片化的屏幕尺寸是最大痛点。本系统采用「设计基准 + 等比缩放 + 安全区」三层适配。

### 3.1 设计基准

```
基准分辨率：390 × 844（iPhone 14 逻辑像素）
适配范围：320×568（iPhone SE） ~ 428×926（iPhone 14 Pro Max）
         360×640（小屏 Android） ~ 412×915（大屏 Android）
平板：768×1024 ~ 1024×1366（iPad，采用两栏布局）
```

### 3.2 适配引擎

```typescript
// ScreenAdapter.ts
class ScreenAdapter {
  static readonly BASE_WIDTH = 390;
  static readonly BASE_HEIGHT = 844;

  private _screenWidth: number;
  private _screenHeight: number;
  private _scaleX: number;   // 宽度缩放比
  private _scaleY: number;   // 高度缩放比
  private _scale: number;    // 统一缩放比（取 min，保证不裁剪）
  private _safeAreaTop: number;
  private _safeAreaBottom: number;

  constructor() {
    const { width, height } = Dimensions.get('window');
    this._screenWidth = width;
    this._screenHeight = height;
    this._scaleX = width / ScreenAdapter.BASE_WIDTH;
    this._scaleY = height / ScreenAdapter.BASE_HEIGHT;
    this._scale = Math.min(this._scaleX, this._scaleY);
    this._safeAreaTop = 0; // 由 SafeAreaView 动态注入
    this._safeAreaBottom = 0;
  }

  /** 将设计稿尺寸转换为当前设备实际像素 */
  px(designPx: number): number {
    return Math.round(designPx * this._scale);
  }

  /** 字体大小适配（字体不跟随 scale，使用阶梯缩放防止太小/太大） */
  fontSize(designSize: number): number {
    const base = designSize * this._scale;
    // 限制在 10~32 之间
    return Math.max(10, Math.min(32, base));
  }

  /** 游戏内卡牌尺寸（固定高度比，宽度自适应） */
  cardSize(): { width: number; height: number } {
    // 手牌区最多 10 张，每张宽 = 屏幕宽 / 6.5（保证不重叠且有间距）
    const cardWidth = this._screenWidth / 6.5;
    const cardHeight = cardWidth * 1.41; // 卡牌宽高比 1:1.41
    return { width: Math.round(cardWidth), height: Math.round(cardHeight) };
  }

  /** 棋盘格尺寸 */
  boardSlotSize(): number {
    // 4人局 5 槽位，1v1 7 槽位，每格宽 = 屏幕宽 / (maxSlots + 2)
    const maxSlots = 7;
    return Math.round(this._screenWidth / (maxSlots + 2));
  }

  /** 平板检测 */
  isTablet(): boolean {
    return Math.min(this._screenWidth, this._screenHeight) >= 600;
  }

  /** 异形屏安全区 */
  get safeArea(): { top: number; bottom: number; left: number; right: number } {
    return {
      top: this._safeAreaTop,
      bottom: this._safeAreaBottom,
      left: 0,
      right: 0,
    };
  }
}

// 全局单例
export const adapter = new ScreenAdapter();
```

### 3.3 平板双栏布局

```typescript
// 平板模式下：左侧战场 + 右侧手牌/信息面板
// 手机模式下：战场在上 + 手牌在下
const isTablet = adapter.isTablet();

// 对局界面布局
const layout = isTablet
  ? {
      boardArea: { flex: 3, borderRight: 1 },    // 左侧 75%
      handArea: { flex: 1, flexDirection: 'column' }, // 右侧 25%
      infoPanel: { height: 120 },                  // 信息面板
      hand: { flex: 1 },                           // 手牌区
    }
  : {
      boardArea: { flex: 3 },                      // 上方 60%
      handArea: null,                              // 手机手牌在底部浮动
      hand: { position: 'absolute', bottom: 0, height: adapter.px(140) },
    };
```

---

## 四、游戏画布渲染（Skia Canvas）

### 4.1 渲染架构

游戏主界面不使用原生 RN 组件堆叠，而是使用单个 Skia Canvas 完成所有游戏元素的绘制。这样做的好处：
- 避免大量 View 嵌套导致的布局性能问题
- 动画帧率稳定 60fps
- 粒子/特效渲染与游戏画面在同一上下文，无合成开销

```typescript
// GameCanvas.tsx
import { Canvas, useCanvasRef } from '@shopify/react-native-skia';

const GameCanvas: React.FC = () => {
  const canvasRef = useCanvasRef();
  const gameStore = useGameStore();

  // 每帧绘制（由 react-native-reanimated 驱动）
  useFrameCallback((frameInfo) => {
    if (!canvasRef.current) return;
    // 根据游戏状态逐层绘制
    renderFrame(canvasRef.current, gameStore.state, frameInfo);
  });

  return (
    <Canvas ref={canvasRef} style={StyleSheet.absoluteFill} />
  );
};
```

### 4.2 渲染层级（从底到顶）

```
Layer 0: 战场背景（程序化生成的暗黑奇幻风格）
Layer 1: 己方战场随从（底部 5-7 个槽位）
Layer 2: 敌方战场随从（顶部 5-7 个槽位）
Layer 3: 双方英雄 + 血量条 + 护甲
Layer 4: 己方手牌（底部弧形排列，可拖拽）
Layer 5: 法力水晶条
Layer 6: 回合指示器 + 身份标识
Layer 7: 飘字伤害数字
Layer 8: 粒子特效（攻击/死亡/法术）
Layer 9: 选中高亮 + 目标箭头
Layer 10: 对战日志（可选显示/隐藏）
```

### 4.3 卡牌程序化生成（移动端优化版）

```typescript
// CardFaceGenerator.ts - 移动端性能优化
class CardFaceGenerator {
  // 缓存已生成的卡面 SkImage，避免每帧重绘
  private cardCache: Map<string, SkImage> = new Map();
  private maxCacheSize = 60; // 移动端缓存上限

  /**
   * 生成一张卡牌的 SkImage。
   * 移动端不使用复杂的 10 层结构，简化为 5 层：
   *   Layer 1: 底色 + 圆角矩形
   *   Layer 2: 稀有度边框（发光/金属色）
   *   Layer 3: 费用水晶（左上角圆形）
   *   Layer 4: 卡名 + 描述文字
   *   Layer 5: 攻击/血量（随从卡，右下角）
   */
  generate(card: CardData, size: { width: number; height: number }): SkImage {
    const cacheKey = `${card.id}_${size.width}x${size.height}`;
    if (this.cardCache.has(cacheKey)) {
      return this.cardCache.get(cacheKey)!;
    }

    const surface = Skia.Surface.MakeOffscreen(size.width, size.height)!;
    const canvas = surface.getCanvas();

    // Layer 1: 底色 + 圆角
    const bgPaint = Skia.Paint();
    bgPaint.setColor(Skia.Color(card.rarityColor));
    canvas.drawRoundRect(
      Skia.RRectXY(Skia.XYWHRect(0, 0, size.width, size.height), 8, 8),
      bgPaint
    );

    // Layer 2: 稀有度边框
    // ...

    // Layer 3: 费用
    // ...

    // Layer 4: 文字
    // ...

    // Layer 5: 属性
    // ...

    const image = surface.makeImageSnapshot();
    // LRU 缓存管理
    this.addToCache(cacheKey, image);
    return image;
  }

  private addToCache(key: string, image: SkImage): void {
    if (this.cardCache.size >= this.maxCacheSize) {
      const firstKey = this.cardCache.keys().next().value;
      this.cardCache.delete(firstKey);
    }
    this.cardCache.set(key, image);
  }

  /** 预生成牌组中所有卡牌（进入对局时调用，避免对局中卡顿） */
  preGenerate(deck: CardData[]): void {
    const size = adapter.cardSize();
    for (const card of deck) {
      this.generate(card, size);
    }
  }
}
```

---

## 五、触控手势系统

### 5.1 手势映射

| 操作 | 手势 | 实现 |
|------|------|------|
| 出牌 | 长按手牌 → 拖拽到战场 | PanResponder + Reanimated |
| 选择攻击目标 | 点击己方随从 → 点击敌方目标 | Tap Gesture |
| 使用英雄技能 | 点击英雄头像 | Tap |
| 查看卡牌详情 | 长按卡牌 0.5s | LongPress |
| 浏览手牌 | 手牌区左右滑动 | Pan（水平方向） |
| 结束回合 | 点击回合结束按钮 | Tap |
| 表情 | 点击表情按钮 → 选择 | Tap + Sheet |
| 投降 | 设置 → 投降（二次确认） | Tap + Alert |

### 5.2 拖拽出牌核心实现

```typescript
// DragCardHandler.ts
import { Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  runOnJS,
} from 'react-native-reanimated';

interface DragCardConfig {
  cardIndex: number;           // 手牌中的索引
  cardWidth: number;
  cardHeight: number;
  boardSlotsY: number;         // 战场 Y 坐标（拖到此处即为出牌）
  onCardPlayed: (index: number) => void;
  onDragCancel: () => void;
}

export function useDragCardGesture(config: DragCardConfig) {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const scale = useSharedValue(1);
  const isDragging = useSharedValue(false);

  const dragGesture = Gesture.Pan()
    .onStart(() => {
      isDragging.value = true;
      scale.value = withSpring(1.1); // 拿起卡牌时放大
    })
    .onUpdate((event) => {
      translateX.value = event.translationX;
      translateY.value = event.translationY;
    })
    .onEnd((event) => {
      isDragging.value = false;
      scale.value = withSpring(1);

      // 判断是否拖到战场区域（Y 方向上移超过阈值）
      if (event.translationY < -config.boardSlotsY * 0.6) {
        runOnJS(config.onCardPlayed)(config.cardIndex);
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
      } else {
        // 回弹
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
        runOnJS(config.onDragCancel)();
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
      { scale: scale.value },
    ],
    zIndex: isDragging.value ? 999 : 1,
    opacity: isDragging.value ? 0.9 : 1,
  }));

  return { dragGesture, animatedStyle };
}
```

### 5.3 弧形手牌布局

```typescript
// 手牌按弧形排列，中心卡牌最大，两侧逐渐缩小并旋转
function calculateHandLayout(
  cardCount: number,
  screenWidth: number,
  cardWidth: number
): CardLayout[] {
  const layouts: CardLayout[] = [];
  const centerX = screenWidth / 2;
  const arcRadius = screenWidth * 1.2;  // 弧半径
  const maxRotate = 15;                  // 最大旋转角度（度）

  for (let i = 0; i < cardCount; i++) {
    // 从 -0.5 到 +0.5 均匀分布
    const t = cardCount === 1 ? 0 : (i / (cardCount - 1) - 0.5) * 2;
    const angle = t * (Math.PI / 6); // 最大 ±30°
    const x = centerX + Math.sin(angle) * arcRadius - cardWidth / 2;
    const y = -Math.cos(angle) * arcRadius * 0.3; // 轻微上下
    const rotation = t * maxRotate;
    const zIndex = Math.round(10 - Math.abs(t) * 10); // 中间的 Z 轴最高

    layouts.push({ x, y, rotation, zIndex, scale: 1 - Math.abs(t) * 0.15 });
  }
  return layouts;
}
```

---

## 六、网络通信层

### 6.1 Socket.IO 客户端封装

```typescript
// SocketClient.ts
import { io, Socket } from 'socket.io-client';
import { Platform } from 'react-native';

class SocketClient {
  private socket: Socket | null = null;
  private reconnectManager: ReconnectManager;

  constructor() {
    this.reconnectManager = new ReconnectManager(this);
  }

  /**
   * 连接服务器。
   * Android 模拟器中 10.0.2.2 指向宿主机 localhost，
   * iOS 模拟器直接用 localhost。
   */
  connect(token: string, serverUrl: string): void {
    const url = Platform.select({
      android: serverUrl.replace('localhost', '10.0.2.2'),
      ios: serverUrl,
      default: serverUrl,
    });

    this.socket = io(url, {
      auth: { token },
      transports: ['websocket'],  // 移动端只走 WebSocket
      reconnection: true,
      reconnectionAttempts: 10,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 10000,
      timeout: 20000,
    });

    this.registerBaseListeners();
  }

  private registerBaseListeners(): void {
    this.socket!.on('connect', () => {
      console.log('[Socket] Connected:', this.socket!.id);
      this.reconnectManager.onConnected();
    });

    this.socket!.on('disconnect', (reason) => {
      console.log('[Socket] Disconnected:', reason);
      this.reconnectManager.onDisconnected(reason);
    });

    this.socket!.on('error', (error) => {
      console.error('[Socket] Error:', error);
    });
  }

  /** 注册游戏事件监听 */
  onGameEvent(event: string, handler: (data: any) => void): void {
    this.socket!.on(event, handler);
  }

  /** 发送游戏操作 */
  emit(event: string, data?: any): void {
    if (!this.socket?.connected) {
      throw new Error('Socket not connected');
    }
    this.socket.emit(event, data);
  }

  disconnect(): void {
    this.socket?.disconnect();
    this.socket = null;
  }
}

export const socketClient = new SocketClient();
```

### 6.2 断线重连管理器

```typescript
// ReconnectManager.ts
class ReconnectManager {
  private wasInGame = false;
  private gameStateBeforeDisconnect: any = null;
  private disconnectTimer: ReturnType<typeof setTimeout> | null = null;

  onDisconnected(reason: string): void {
    // 保存当前游戏状态（如果正在对局中）
    if (GameStore.getState().isInGame) {
      this.wasInGame = true;
      this.gameStateBeforeDisconnect = GameStore.getState();
    }

    // 显示重连提示
    GameStore.getState().showReconnectOverlay();

    // 60s 超时
    this.disconnectTimer = setTimeout(() => {
      GameStore.getState().onReconnectTimeout();
    }, 60000);
  }

  onConnected(): void {
    if (this.disconnectTimer) {
      clearTimeout(this.disconnectTimer);
      this.disconnectTimer = null;
    }

    if (this.wasInGame) {
      // 重连后请求完整状态回放
      socketClient.emit('game:requestReconnectState');
      this.wasInGame = false;
    }

    GameStore.getState().hideReconnectOverlay();
  }
}
```

### 6.3 HTTP API 封装

```typescript
// API.ts
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const api = axios.create({
  baseURL: __DEV__ ? 'http://10.0.2.2:3000/api' : 'https://api.cardgame.com/api',
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
});

// 请求拦截器：自动附加 Token
api.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 响应拦截器：统一错误处理 + Token 过期
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await AsyncStorage.removeItem('auth_token');
      // 跳转到登录页
      navigationRef.navigate('Login');
    }
    return Promise.reject(error);
  }
);

export const apiClient = {
  // 卡牌
  getCards: () => api.get('/cards'),
  getCard: (id: string) => api.get(`/cards/${id}`),

  // 牌组
  getDecks: () => api.get('/decks'),
  createDeck: (data: CreateDeckDTO) => api.post('/decks', data),
  updateDeck: (id: string, data: UpdateDeckDTO) => api.put(`/decks/${id}`, data),
  deleteDeck: (id: string) => api.delete(`/decks/${id}`),

  // 对战记录
  getMatchHistory: (page: number) => api.get('/matches/history', { params: { page } }),
  getMatchDetail: (id: string) => api.get(`/matches/${id}`),

  // 天梯
  getLeaderboard: () => api.get('/leaderboard'),

  // 用户
  getUserStats: (userId: string) => api.get(`/users/${userId}/stats`),
};

export default apiClient;
```

---

## 七、打包与构建

### 7.1 Android APK 构建配置

```groovy
// android/app/build.gradle 关键配置

android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.cardgame.mobile"
        minSdkVersion 24        // Android 7.0+
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            ndk {
                abiFilters "armeabi-v7a", "arm64-v8a" // 仅 ARM，减小包体积
            }
        }
        debug {
            debuggable true
            // 开发阶段使用 Hermes 调试
            hermesCommand "${rootProject.projectDir}/node_modules/hermes-engine/%OS-BIN%/hermes"
        }
    }

    // 启用 Hermes 引擎（更小的内存占用和更快的启动速度）
    project.ext.react = [
        enableHermes: true,
        hermesFlagsRelease: ["-O", "-output-source-map"],
    ]
}
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.cardgame.mobile">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <application
        android:name=".MainApplication"
        android:label="卡牌对战"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:allowBackup="false"
        android:theme="@style/AppTheme"
        android:networkSecurityConfig="@xml/network_security_config">
        <!-- 开发阶段允许 HTTP 明文 -->
    </application>
</manifest>
```

### 7.2 iOS 构建配置

```ruby
# ios/Podfile
platform :ios, '15.0'

target 'CardGame' do
  config = use_native_modules!

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => true,
    :fabric_enabled => false,
  )

  # Skia 需要的额外配置
  pod 'React-RCTAnimation', :path => '../node_modules/react-native/Libraries/NativeAnimation'
end
```

```xml
<!-- ios/CardGame/Info.plist 关键配置 -->
<key>CFBundleDisplayName</key>
<string>卡牌对战</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>  <!-- 开发阶段允许 HTTP -->
</dict>
```

### 7.3 构建命令

```bash
# 开发运行
npx react-native run-android    # Android 开发模式
npx react-native run-ios        # iOS 开发模式

# 构建 Release APK
cd android && ./gradlew assembleRelease
# 产物：android/app/build/outputs/apk/release/app-release.apk

# 构建 AAB（Google Play）
cd android && ./gradlew bundleRelease
# 产物：android/app/build/outputs/bundle/release/app-release.aab

# iOS Archive（需 Xcode）
cd ios && xcodebuild -workspace CardGame.xcworkspace \
  -scheme CardGame \
  -configuration Release \
  archive -archivePath ./build/CardGame.xcarchive

# 导出 IPA
xcodebuild -exportArchive \
  -archivePath ./build/CardGame.xcarchive \
  -exportPath ./build/ \
  -exportOptionsPlist exportOptions.plist
```

### 7.4 安装包瘦身策略

| 策略 | 效果 |
|------|------|
| Hermes 引擎 | JS 字节码体积减少 60%，内存减少 30% |
| Android App Bundle (.aab) | 按设备架构分发，用户下载体积减少 40% |
| ProGuard + R8 | 代码混淆 + 死代码剔除，减少 20-30% |
| 仅 ARM 架构 | 剔除 x86 模拟器库，减少 ~15MB |
| 资源按需下载 | 卡牌图片/音效在对局时从 CDN 拉取，不在安装包内 |
| 字体子集化 | 仅打包游戏使用的字符集，中文字体从 15MB → 3MB |
| PNG 压缩 + WebP | 图标资源压缩率 50-80% |

> 基础安装包（APK/IPA）：Android ≤ 45MB，iOS ≤ 55MB（仅含代码 + 基础引擎 + 启动必需资源）

### 7.5 总占存目标与资源包策略

**核心原则：安装包 ≠ 占存。APK 只负责把用户拉进门，完整游戏体验通过「首次启动资源包」撑到 1GB+。**

#### 占存分解（目标 1.2GB ~ 1.5GB）

| 资源类型 | 预估体积 | 分发方式 | 说明 |
|---------|---------|---------|------|
| 基础安装包 | 45MB | APK/IPA 内置 | React Native 运行时 + 核心代码 + 启动页 |
| 卡牌高清卡面 | 350MB | 首次启动下载 | 400 张卡牌 × 2 种分辨率 (1080p + 720p) × 程序化预渲染 PNG |
| 卡牌闪卡特效 | 120MB | 首次启动下载 | 传说/史诗级卡牌序列帧动画 (30fps×3s×15张传说卡) |
| 对战场景背景 | 150MB | 首次启动下载 | 12 个主题场景 × 2 种分辨率静态背景 + 动态粒子层 |
| 音效包 | 200MB | 首次启动下载 | 卡牌出场/攻击/死亡/法术音效 + UI 交互音 |
| 语音包 (中文) | 280MB | 首次启动下载 | 400 张卡牌 × 出场语音 + 英雄台词 + 系统播报 |
| BGM 包 | 80MB | 首次启动下载 | 8 首背景音乐 (大厅/对战×3/结算/开包/教程)，OGG 128kbps |
| 多语言资源 | 60MB | 按需下载 | 日/英/韩 文本 + 对应语音包基础版 |
| 英雄皮肤 | 90MB | 按需下载 | 10 款可选英雄皮肤 (每人 9MB) |
| 新手教程动画 | 35MB | 首次启动下载 | 8 段引导动画序列帧 |
| 本地缓存 | 50MB | 运行时生成 | 对战回放、卡牌数据缓存、日志 |
| **合计** | **~1.46GB** | | |

#### 首次启动资源下载流程

```typescript
// ResourceDownloadManager.ts
class ResourceDownloadManager {
  private requiredPackages: ResourcePackage[] = [
    { id: 'cards_hd',        name: '卡牌高清卡面包',      size: 350, priority: 1, required: true },
    { id: 'cards_sparkle',   name: '闪卡特效包',          size: 120, priority: 3, required: false },
    { id: 'scenes',          name: '对战场景包',          size: 150, priority: 1, required: true },
    { id: 'sfx',             name: '音效包',              size: 200, priority: 1, required: true },
    { id: 'voice_cn',        name: '中文语音包',          size: 280, priority: 2, required: true },
    { id: 'bgm',             name: '背景音乐包',          size: 80,  priority: 2, required: true },
    { id: 'tutorial',        name: '新手教程动画',        size: 35,  priority: 3, required: false },
  ];

  private optionalPackages: ResourcePackage[] = [
    { id: 'voice_jp',        name: '日语语音包',          size: 45,  priority: 4, required: false },
    { id: 'voice_en',        name: '英语语音包',          size: 40,  priority: 4, required: false },
    { id: 'voice_kr',        name: '韩语语音包',          size: 40,  priority: 4, required: false },
    { id: 'skins',           name: '英雄皮肤包',          size: 90,  priority: 5, required: false },
    // 可选的额外高清背景 (4K)
    { id: 'scenes_4k',       name: '4K场景高清包',        size: 80,  priority: 5, required: false },
  ];

  private totalRequiredSize: number; // 必须下载的总大小
  private downloadedSize: number = 0;

  constructor() {
    this.totalRequiredSize = this.requiredPackages
      .filter(p => p.required)
      .reduce((sum, p) => sum + p.size, 0);
  }

  /**
   * 首次启动流程：
   * 1. 显示华丽启动画面 + 进度条
   * 2. 按 priority 顺序下载必须包
   * 3. 至少下载完 priority=1 的包后才允许进入大厅
   * 4. 后台继续下载 priority≥2 的包
   */
  async startFirstLaunchDownload(
    onProgress: (progress: DownloadProgress) => void
  ): Promise<void> {
    // 按优先级分组
    const groups = this.groupByPriority(this.requiredPackages);

    for (const group of groups) {
      const results = await Promise.all(
        group.map(pkg => this.downloadPackage(pkg, onProgress))
      );

      // Priority 1 全部完成后允许进入游戏
      if (group[0].priority === 1) {
        EventBus.emit('resource:minimum_ready');
        // 后续包转入后台下载，同时启动大厅
        this.downloadRemainingInBackground(groups.slice(1));
      }
    }
  }

  private async downloadPackage(
    pkg: ResourcePackage,
    onProgress: (progress: DownloadProgress) => void
  ): Promise<void> {
    const destPath = `${RNFS.DocumentDirectoryPath}/resources/${pkg.id}`;
    const url = `${RESOURCE_CDN_BASE}/${pkg.id}_v${RESOURCE_VERSION}.zip`;

    const result = await RNFS.downloadFile({
      fromUrl: url,
      toFile: `${destPath}.zip`,
      progress: (res) => {
        const pct = res.bytesWritten / res.contentLength;
        onProgress({
          packageId: pkg.id,
          name: pkg.name,
          progress: pct,
          downloadedMB: Math.round(res.bytesWritten / 1024 / 1024),
          totalMB: pkg.size,
        });
      },
    }).promise;

    if (result.statusCode === 200) {
      // 解压 ZIP
      await RNFS.unzip(`${destPath}.zip`, destPath);
      await RNFS.unlink(`${destPath}.zip`);
      this.downloadedSize += pkg.size;
    }
  }

  /** 按需下载可选资源包 */
  async downloadOptional(id: string): Promise<void> {
    const pkg = this.optionalPackages.find(p => p.id === id);
    if (!pkg) throw new Error(`Unknown package: ${id}`);
    await this.downloadPackage(pkg, () => {});
  }
}
```

#### 资源 CDN 部署要求

```
资源服务器 (CDN) 目录结构:
https://cdn.cardgame.com/resources/
├── cards_hd_v1.zip           (350MB)  卡牌高清卡面
├── cards_sparkle_v1.zip      (120MB)  闪卡特效
├── scenes_v1.zip             (150MB)  对战场景
├── sfx_v1.zip                (200MB)  音效
├── voice_cn_v1.zip           (280MB)  中文语音
├── voice_jp_v1.zip           (45MB)   日语语音
├── voice_en_v1.zip           (40MB)   英语语音
├── voice_kr_v1.zip           (40MB)   韩语语音
├── bgm_v1.zip                (80MB)   背景音乐
├── skins_v1.zip              (90MB)   英雄皮肤
├── tutorial_v1.zip           (35MB)   教程动画
├── scenes_4k_v1.zip          (80MB)   4K场景 (可选)
└── manifest.json                     资源版本清单
```

#### 资源版本管理

```typescript
// 每次发版更新 manifest.json，客户端对比本地版本决定是否重新下载
interface ResourceManifest {
  version: number;       // 全局资源版本号
  packages: {
    [id: string]: {
      version: number;
      size: number;
      checksum: string;  // SHA256，用于校验完整性
      url: string;
    };
  };
}

// 增量更新：只下载版本号变化的包
async function checkAndUpdateResources(): Promise<string[]> {
  const localManifest = await AsyncStorage.getItem('resource_manifest');
  const remoteManifest = await fetch(`${RESOURCE_CDN_BASE}/manifest.json`).then(r => r.json());

  const toUpdate: string[] = [];
  for (const [id, remote] of Object.entries(remoteManifest.packages)) {
    const local = localManifest?.[id];
    if (!local || local.version < remote.version) {
      toUpdate.push(id);
    }
  }
  return toUpdate;
}
```

---

## 八、大规模资源生产流水线

> 400 张卡牌 × 每张高清卡面 + 闪卡 + 音效 + 语音，人工制作不现实。必须建立程序化生产流水线。

### 8.1 卡牌数据定义（400 张完整卡池）

```typescript
// 卡池规模：400 张
// 随从卡：200 张（含 20 张传说）
// 法术卡：150 张（含 15 张传说）
// 装备卡：50 张（含 5 张传说）
//
// 每张卡牌定义包含：
// - 基础属性（费用/攻击/血量/耐久）
// - 卡面美术参数（程序化生成用）
// - 音效参数（出场/攻击/死亡音效 ID）
// - 语音参数（台词文本 + TTS 参数或录音文件路径）

interface FullCardDefinition {
  // 游戏数据
  id: string;
  name: string;
  nameEn: string;           // 英文名（多语言用）
  type: 'minion' | 'spell' | 'equipment';
  cost: number;             // 1-10
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  class: string;            // 职业或 'neutral'
  attack?: number;
  health?: number;
  durability?: number;
  effects: CardEffect[];
  keywords: string[];
  description: string;      // 中文描述

  // 卡面美术参数（驱动 CardFaceGenerator 的程序化渲染）
  artParams: {
    colorScheme: string[];          // 主色调/辅色/强调色 (3 色数组)
    pattern: 'geometric' | 'flame' | 'ice' | 'shadow' | 'light' | 'nature' | 'arcane' | 'blood';
    iconId: string;                  // 卡面中央图标 ID
    borderStyle: 'simple' | 'engraved' | 'flame' | 'energy' | 'void';
    backgroundSeed: number;          // 背景噪声种子（保证每张卡独一无二）
    particleType: 'none' | 'spark' | 'aura' | 'flame' | 'ice' | 'shadow' | 'lightning';
  };

  // 音效参数
  audioParams: {
    playSfx: string;         // 出场音效 ID
    attackSfx: string;       // 攻击音效 ID
    deathSfx: string;        // 死亡音效 ID
    spellSfx?: string;       // 法术释放音效 ID
  };

  // 语音参数
  voiceParams: {
    summonLines: string[];   // 出场台词 (2-3 句)
    attackLines: string[];   // 攻击台词 (1-2 句)
    deathLine: string;       // 死亡台词
    flavorLines?: string[];  // 彩蛋台词
  };

  // 闪卡参数（传说/史诗卡）
  sparkleParams?: {
    type: 'gold_shine' | 'energy_wave' | 'void_tear' | 'fire_ring' | 'ice_crystal';
    frameCount: number;      // 序列帧数量
    fps: number;
    duration: number;        // 秒
  };
}

// 400 张卡牌数据存储为 card_database.ts，约 800KB
// 通过脚本批量导入 PostgreSQL + 导出 JSON 供客户端使用
```

### 8.2 卡面批量渲染流水线

```bash
# scripts/generate_all_card_faces.sh
# 使用 Node.js + node-canvas 在后端批量渲染 400 张卡面

# 输出：
# resources/cards_hd/        # 1080p PNG (400 张，~300MB)
#   card_001.png ~ card_400.png
# resources/cards_md/        # 720p PNG (400 张，~50MB)
#   card_001.png ~ card_400.png
# resources/sparkle/         # 闪卡序列帧 (15 张传说 × 120 帧 ~120MB)
#   card_legend_001/frame_00001.png ~ frame_00120.png
#   ...

# 批量生成脚本
node scripts/batch_render_cards.js \
  --database ./src/data/card_database.ts \
  --output-hd ./resources/cards_hd/ \
  --output-md ./resources/cards_md/ \
  --output-sparkle ./resources/sparkle/ \
  --parallel 8 \            # 8 线程并行
  --resolution-hd 1080 \
  --resolution-md 720
```

### 8.3 音效批量生成

```bash
# scripts/generate_all_sfx.py
# 使用程序化音频合成 (Web Audio API / Tone.js) 生成卡牌音效
# 不需要真人录音，用合成器参数化生成

# 音效分类（约 600 个独立音效文件）：
# - 通用卡牌出场  50 个 (不同费用/类型有不同的音高和音色)
# - 攻击音效      30 个 (物理/魔法/火焰/冰霜等类型)
# - 死亡音效      20 个
# - 法术释放      40 个 (按元素类型)
# - UI 交互       15 个 (点击/确认/取消/回合开始/胜利/失败)
# - 英雄技能      10 个 (按职业)
# - 身份揭示       4 个 (主公/忠臣/反贼/内奸)
#
# 格式：OGG Vorbis 128kbps / 44.1kHz / 单声道
# 每个文件 0.3-2 秒，平均 50KB，合计 ~200MB

python scripts/batch_synthesize_sfx.py \
  --config ./src/data/sfx_config.json \
  --output ./resources/sfx/ \
  --format ogg \
  --bitrate 128
```

### 8.4 语音台词生成

```bash
# 使用 TTS (Edge TTS / Azure Speech) 批量生成卡牌台词
# 400 张卡 × 平均 3 句台词 × 2 秒 × 128kbps MP3 ≈ 280MB

python scripts/batch_generate_voices.py \
  --database ./src/data/card_database.ts \
  --lang zh-CN \
  --voice zh-CN-XiaoxiaoNeural \
  --output ./resources/voice_cn/ \
  --format mp3 \
  --bitrate 128
```

### 8.5 对战场景背景批量生成

```typescript
// 12 个主题场景，每个场景由程序化生成：
// 1. 经典战场 - 中古城堡  2. 暗影森林  3. 熔岩地狱
// 4. 冰封王座  5. 沙漠遗迹  6. 天空之城
// 7. 深海神殿  8. 蒸汽工坊  9. 月下竹林
// 10. 龙巢废墟 11. 星辰虚空  12. 樱花庭院
//
// 每个场景：
// - 1080p 静态背景 PNG (~5MB)
// - 720p 静态背景 PNG (~2MB)
// - 动态粒子层配置 JSON (颜色/速度/密度)
// - 环境音效 OGG (~2MB)
//
// 12 个场景 × (5+2+2)MB ≈ 108MB，加上动态层开销 ~150MB

interface SceneDefinition {
  id: string;
  name: string;
  layers: SceneLayer[];        // 多层视差背景
  particles: ParticleConfig;   // 环境粒子
  ambientSfx: string;          // 环境音 ID
  lighting: LightingConfig;    // 光照参数 (影响卡牌色调)
}

// 场景在服务端用 node-canvas 批量渲染后打包进 scenes_v1.zip
```

---

## 九、移动端特有功能

### 8.1 推送通知

```typescript
// 使用 Firebase Cloud Messaging (FCM) 实现推送
import messaging from '@react-native-firebase/messaging';

class PushNotificationManager {
  async init(): Promise<void> {
    // 请求权限
    const authStatus = await messaging().requestPermission();
    const enabled =
      authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
      authStatus === messaging.AuthorizationStatus.PROVISIONAL;

    if (!enabled) return;

    // 获取 FCM Token
    const fcmToken = await messaging().getToken();
    // 发送到后端绑定
    await apiClient.registerPushToken(fcmToken);

    // 前台消息处理
    messaging().onMessage(async (remoteMessage) => {
      // 显示本地通知
      this.showLocalNotification(remoteMessage);
    });
  }

  private showLocalNotification(message: any): void {
    // 使用 react-native-push-notification 或 Notifee
    // 场景：匹配成功、回合开始、好友邀请
    PushNotification.localNotification({
      channelId: 'game',
      title: message.notification?.title,
      message: message.notification?.body,
    });
  }
}
```

### 8.2 本地数据持久化

```typescript
// 使用 AsyncStorage + react-native-fs 实现离线能力
import AsyncStorage from '@react-native-async-storage/async-storage';
import RNFS from 'react-native-fs';

class LocalDataManager {
  /**
   * 对局回放本地存储
   * 匹配成功后，eventLog 写入本地文件
   */
  async saveReplay(matchId: string, eventLog: GameEvent[]): Promise<void> {
    const path = `${RNFS.DocumentDirectoryPath}/replays/${matchId}.json`;
    await RNFS.mkdir(`${RNFS.DocumentDirectoryPath}/replays`);
    await RNFS.writeFile(path, JSON.stringify(eventLog), 'utf8');
  }

  async loadReplay(matchId: string): Promise<GameEvent[]> {
    const path = `${RNFS.DocumentDirectoryPath}/replays/${matchId}.json`;
    const content = await RNFS.readFile(path, 'utf8');
    return JSON.parse(content);
  }

  /**
   * 卡牌数据缓存（避免每次启动都从服务器拉取）
   */
  async cacheCards(cards: CardData[]): Promise<void> {
    await AsyncStorage.setItem('cached_cards', JSON.stringify(cards));
    await AsyncStorage.setItem('cached_cards_time', Date.now().toString());
  }

  async getCachedCards(): Promise<CardData[] | null> {
    const cacheTime = await AsyncStorage.getItem('cached_cards_time');
    if (!cacheTime) return null;
    // 缓存 24 小时
    if (Date.now() - parseInt(cacheTime) > 24 * 60 * 60 * 1000) return null;
    const data = await AsyncStorage.getItem('cached_cards');
    return data ? JSON.parse(data) : null;
  }
}
```

### 8.3 性能监控

```typescript
// 移动端性能监控（帧率/内存/网络延迟）
class PerformanceMonitor {
  private fpsHistory: number[] = [];
  private lastFrameTime = Date.now();

  /** 测量当前帧率 */
  measureFPS(): number {
    const now = Date.now();
    const delta = now - this.lastFrameTime;
    this.lastFrameTime = now;
    const fps = 1000 / delta;
    this.fpsHistory.push(fps);
    if (this.fpsHistory.length > 60) this.fpsHistory.shift();

    // 平均帧率低于 30 → 触发降级
    const avgFPS = this.fpsHistory.reduce((a, b) => a + b) / this.fpsHistory.length;
    if (avgFPS < 30) {
      this.triggerDegradation();
    }
    return fps;
  }

  private triggerDegradation(): void {
    // 降级策略：
    // 1. 降低粒子数量上限（20 → 5）
    // 2. 关闭非必要动画（法力水晶飘动、背景粒子）
    // 3. 降低卡牌重绘频率
    GameStore.getState().setQualityLevel('low');
  }

  /** 内存使用监控 */
  async checkMemory(): Promise<void> {
    // Hermes 引擎下获取 JS 堆内存
    const jsHeapSize = (global as any).HermesInternal
      ?.getInstrumentedStats?.()
      ?.js_allocatedBytes;

    if (jsHeapSize && jsHeapSize > 150 * 1024 * 1024) {
      // JS 堆超过 150MB → 清理缓存
      CardFaceGenerator.clearCache();
      // 触发 GC hint
      (global as any).HermesInternal?.triggerGC?.();
    }
  }
}
```

---

## 十、安全与反作弊（客户端）

### 10.1 客户端安全措施

| 措施 | 说明 |
|------|------|
| 代码混淆 | ProGuard (Android) + JS Obfuscator |
| 防截屏 | 对局界面禁止截屏/录屏（FLAG_SECURE） |
| 请求签名 | 关键 API 请求附带 HMAC 签名 |
| 证书绑定 | SSL Pinning 防止中间人攻击 |
| Root/越狱检测 | 检测到 Root 或越狱 → 禁止进入排位模式 |
| 模拟器检测 | 检测到模拟器 → 仅允许匹配 AI 对战 |

```typescript
// 防截屏（Android）
import { NativeModules, Platform } from 'react-native';

// GameScreen.tsx - 进入对局时开启
function enableSecureFlag(): void {
  if (Platform.OS === 'android') {
    NativeModules.SecureFlagModule?.enable();
  }
}

function disableSecureFlag(): void {
  if (Platform.OS === 'android') {
    NativeModules.SecureFlagModule?.disable();
  }
}
```

### 10.2 操作合法性客户端预检

```typescript
// 客户端先做一层快速校验，减少无效请求
class ClientActionValidator {
  /** 出牌前预检 */
  canPlayCard(card: Card, state: GameState): { valid: boolean; reason?: string } {
    if (state.currentPlayerId !== state.myPlayerId) {
      return { valid: false, reason: '不是你的回合' };
    }
    if (card.cost > state.mana.current) {
      return { valid: false, reason: '法力值不足' };
    }
    if (state.phase !== 'MAIN_PHASE') {
      return { valid: false, reason: '当前阶段不能出牌' };
    }
    if (card.type === 'minion' && state.board.myMinions.length >= state.maxBoardSlots) {
      return { valid: false, reason: '战场已满' };
    }
    return { valid: true };
  }
}
```

---

## 十一、测试策略

### 11.1 移动端专属测试

| 测试类型 | 工具 | 覆盖内容 |
|---------|------|---------|
| 组件测试 | @testing-library/react-native | UI 组件渲染正确性 |
| 手势测试 | Detox + 自定义 gesture simulator | 拖拽/点击/长按手势流程 |
| 适配测试 | 多设备快照对比 | 5 种分辨率下的 UI 一致性 |
| 网络测试 | Mock Socket.IO server | 重连/超时/丢包场景 |
| 性能测试 | Flipper + Perfetto | 帧率/内存/启动时间 |
| E2E | Detox | 登录→匹配→对局→结算完整流程 |

### 11.2 测试设备矩阵

```
最低端：iPhone SE (1st gen) / Android 7.0 2GB RAM
中端：  iPhone 11 / Android 10 4GB RAM
高端：  iPhone 15 Pro / Android 14 8GB RAM
平板：  iPad 10th gen / Android 平板 10"
```

---

## 十二、发布流程

### 12.1 发布清单

```
□ 代码混淆 + 资源压缩
□ Android: Signed APK / App Bundle
□ iOS: 配置 Provisioning Profile + 签名证书
□ 服务器地址从开发环境切换到生产环境
□ 关闭开发调试工具（Flipper / Remote Debugger）
□ 推送证书配置（APNs + FCM）
□ 隐私政策页面上线
□ 应用内更新检测 (CodePush / expo-updates)
□ Google Play / App Store 截图 + 描述
□ 灰度发布 5% → 20% → 100%
```

### 12.2 热更新配置

```json
// eas.json - Expo Application Services
{
  "build": {
    "production": {
      "channel": "production"
    },
    "preview": {
      "channel": "preview",
      "distribution": "internal"
    }
  },
  "submit": {
    "production": {
      "android": { "track": "internal" },
      "ios": { "appleId": "xxx@xxx.com" }
    }
  }
}
```

```bash
# 发布热更新（无需重新提交审核）
eas update --branch production --message "修复卡牌显示bug"
```

---

## 十三、输出要求

请按照以下顺序生成代码：

1. **项目初始化**：package.json / tsconfig.json / metro.config.js / babel.config.js / 原生配置
2. **类型定义**：所有 shared types（与后端对齐的 game.ts / network.ts / ui.ts）
3. **适配引擎**：ScreenAdapter.ts（先写，其他模块依赖它）
4. **网络层**：SocketClient.ts → API.ts → ReconnectManager.ts → StateSyncEngine.ts
5. **状态管理**：AuthStore → GameStore → LobbyStore → DeckStore（Zustand）
6. **导航**：RootNavigator → GameNavigator
7. **游戏画布**：GameCanvas → BoardRenderer → HandRenderer → CardRenderer → HeroRenderer
8. **卡牌生成**：CardFaceGenerator（程序化绘制）
9. **手势系统**：DragCardHandler → TapTargetHandler → SwipeHandler → LongPressHandler
10. **动画系统**：AnimationManager → 所有动画模块 → ParticleSystem
11. **音频系统**：AudioManager → SoundEffectPlayer → BGMManager
12. **屏幕页面**：按流程顺序（Splash → Login → Lobby → DeckEditor → Room → Game → Settlement）
13. **移动端特有**：PushNotificationManager / LocalDataManager / PerformanceMonitor
14. **安全模块**：ClientActionValidator / SecureFlagModule
15. **测试**：组件测试 / 手势测试 / E2E

每个模块生成后附带一行注释说明该模块的职责。所有代码使用 TypeScript 严格模式。

> 注意：本提示词假设后端已按 `card-game-backend-prompt.md` 实现完成，所有 Socket.IO 事件和 HTTP API 接口已可用。
*（内容由AI生成，仅供参考）*
