---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_8ac23e5488d711f18766525400f8a581
    ReservedCode1: ENHuRb74SNNByJzWEPMAoFFbY217uCfw9ziwrJVcrRROVcIU26nF2BvmX+SImZcHSYY+Wu4eWWRFw9mmzGqLXcb8CtnCr5u/djPt280Dn7u7WAyJWaVTq+g/SqLL1KlEPLIeeGOAvuSUJVFMngAYFUMJlkMLn5MfZCor621/on6DD2v02NxI3O6MkPw=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_8ac23e5488d711f18766525400f8a581
    ReservedCode2: ENHuRb74SNNByJzWEPMAoFFbY217uCfw9ziwrJVcrRROVcIU26nF2BvmX+SImZcHSYY+Wu4eWWRFw9mmzGqLXcb8CtnCr5u/djPt280Dn7u7WAyJWaVTq+g/SqLL1KlEPLIeeGOAvuSUJVFMngAYFUMJlkMLn5MfZCor621/on6DD2v02NxI3O6MkPw=
---


# 多人在线卡牌对战游戏 - UI/视觉与动效开发提示词

> 本提示词用于 Claude Code，聚焦于卡牌对战游戏的前端UI设计、视觉表现、动画特效和开源资源整合。
> 技术栈：React + TypeScript + PixiJS + GSAP / Framer Motion + Tailwind CSS
> 设计语言：暗黑奇幻风格，参考《炉石传说》质感 + 《三国杀》东方元素融合

---

## 一、设计系统总纲

### 1.1 视觉基调

```
色彩体系：
┌─────────────────────────────────────────────────────────────┐
│ 主色调： 深琥珀金 #D4A843  (卡牌边框、UI镶边、按钮、稀有标识) │
│ 背景色： 暗曜石黑 #1A1A2E  (主背景、面板底色)                │
│ 辅助色： 魔焰橙 #E85D04     (攻击、伤害、警告)               │
│         翠玉绿 #2ECC71     (治疗、增益、生命恢复)            │
│         冰霜蓝 #5DADE2     (法力、法术、护盾)                │
│         暗影紫 #8E44AD     (身份技能、特殊效果)              │
│         熔岩红 #C0392B     (死亡、毁灭、负面)                │
│ 文本色： 羊皮纸 #F5E6CA    (主要文本)                        │
│         暗金 #B8956A       (次要文本)                        │
└─────────────────────────────────────────────────────────────┘

材质系统：
- 卡牌：羊皮纸纹理 + 鎏金边框 + 稀有度光效
- 战场：石质纹理地板 + 动态环境光
- UI面板：深色磨砂玻璃 + 金色描边
- 按钮：金属质感 + 按下凹陷效果
- 魔力水晶：宝石材质 + 脉冲发光
```

### 1.2 设计原则

| 原则 | 说明 |
|------|------|
| 层次分明 | 背景→战场→随从→手牌→UI面板，5层深度，清晰Z轴 |
| 即时反馈 | 每次操作必须有视觉反馈（悬浮放大、点击波纹、数值飘字） |
| 信息清晰 | 关键信息（法力、血量、攻击）大号醒目，次要信息弱化 |
| 氛围优先 | 粒子环境、动态光照、环境音效波形共同营造沉浸感 |
| 60fps | 所有动画基于 requestAnimationFrame，使用 GPU 加速属性 |

### 1.3 技术选型

| 层 | 技术 | 理由 |
|----|------|------|
| 框架 | React 18 + TypeScript | 组件化、类型安全 |
| 渲染引擎 | PixiJS 8 | WebGL 2D渲染，粒子系统，高性能 |
| 动画 | GSAP | 时间线编排、复杂补间、性能优于 CSS Animation |
| UI组件 | React + Tailwind CSS | 快速构建非游戏UI面板 |
| 状态管理 | Zustand | 轻量、无模板代码、支持中间件 |
| 音效 | Howler.js | 跨浏览器音频，空间音效 |
| 粒子 | PixiJS Particle Container | 高性能粒子（魔法光效、环境粒子） |

---

## 二、项目目录结构

```
client/
├── src/
│   ├── main.tsx                          # 入口
│   ├── App.tsx                           # 根组件
│   │
│   ├── config/
│   │   ├── theme.ts                      # 色彩/字体/间距 Token
│   │   ├── animation.ts                  # 动画时长/缓动函数常量
│   │   └── assets.ts                     # 资源路径清单
│   │
│   ├── store/
│   │   ├── gameStore.ts                  # 游戏状态（Zustand）
│   │   ├── uiStore.ts                    # UI状态
│   │   └── settingsStore.ts              # 用户设置
│   │
│   ├── engine/                           # PixiJS 游戏引擎封装
│   │   ├── GameApp.ts                    # PixiJS Application 初始化
│   │   ├── SceneManager.ts              # 场景管理器
│   │   ├── AssetLoader.ts               # 资源加载器（含进度条）
│   │   ├── Camera.ts                     # 相机控制（震动/缩放）
│   │   └── TickManager.ts               # 帧循环管理
│   │
│   ├── scenes/                           # 游戏场景
│   │   ├── BattleScene.ts               # 对战主场景
│   │   ├── MainMenuScene.ts             # 主菜单场景
│   │   ├── DeckBuilderScene.ts          # 组牌场景
│   │   └── MatchResultScene.ts          # 结算场景
│   │
│   ├── game-objects/                     # 游戏实体
│   │   ├── Card.ts                       # 卡牌基类（PixiJS Container）
│   │   ├── MinionOnBoard.ts             # 场上随从
│   │   ├── Hero.ts                       # 英雄头像
│   │   ├── ManaCrystal.ts               # 法力水晶
│   │   ├── DeckPile.ts                   # 牌库堆
│   │   └── Graveyard.ts                 # 墓地
│   │
│   ├── effects/                          # 视觉特效
│   │   ├── ParticleSystem.ts            # 粒子系统管理器
│   │   ├── FloatingText.ts              # 飘字（伤害/治疗/状态文字）
│   │   ├── ScreenShake.ts               # 屏幕震动
│   │   ├── GlowFilter.ts                # 发光滤镜
│   │   ├── CardTrail.ts                 # 卡牌拖尾
│   │   ├── ImpactEffect.ts              # 冲击波效果
│   │   ├── SummonCircle.ts              # 召唤法阵
│   │   ├── DeathExplosion.ts            # 死亡破碎
│   │   ├── BuffAura.ts                   # Buff光环
│   │   └── LightningBolt.ts             # 闪电链特效
│   │
│   ├── animations/                       # 动作编排
│   │   ├── CardAnimations.ts            # 卡牌动画集
│   │   │   ├── drawCard()               # 抽牌动画
│   │   │   ├── playCard()               # 打出卡牌动画
│   │   │   ├── attackCard()             # 随从攻击动画
│   │   │   ├── deathCard()              # 随从死亡动画
│   │   │   ├── discardCard()            # 弃牌动画
│   │   │   └── shuffleCard()            # 洗牌动画
│   │   ├── UIAnimations.ts              # UI动画集
│   │   │   ├── turnTransition()         # 回合切换
│   │   │   ├── manaFill()               # 法力充能
│   │   │   ├── heroDamaged()            # 英雄受伤
│   │   │   ├── winBanner()              # 胜利横幅
│   │   │   └── defeatBanner()           # 失败横幅
│   │   └── IdentityAnimations.ts        # 身份动画集
│   │       ├── identityReveal()         # 身份揭示
│   │       └── skillActivate()          # 技能发动
│   │
│   ├── ui/                               # React UI 面板
│   │   ├── components/
│   │   │   ├── HandZone.tsx              # 手牌区
│   │   │   ├── CardInHand.tsx            # 手牌中的卡牌
│   │   │   ├── BoardZone.tsx             # 战场区（嵌入 PixiJS canvas）
│   │   │   ├── HeroPortrait.tsx          # 英雄头像面板
│   │   │   ├── ManaBar.tsx               # 法力水晶条
│   │   │   ├── EndTurnButton.tsx         # 结束回合按钮
│   │   │   ├── TurnIndicator.tsx         # 回合指示器
│   │   │   ├── OpponentInfo.tsx          # 对手信息
│   │   │   ├── EventLog.tsx              # 事件日志（右上角）
│   │   │   ├── EmoteWheel.tsx            # 表情轮盘
│   │   │   ├── MulliganPanel.tsx         # 换牌面板
│   │   │   ├── IdentityPanel.tsx         # 身份展示
│   │   │   └── TimerBar.tsx              # 回合倒计时条
│   │   ├── screens/
│   │   │   ├── LoginScreen.tsx
│   │   │   ├── LobbyScreen.tsx
│   │   │   ├── MatchScreen.tsx
│   │   │   ├── DeckScreen.tsx
│   │   │   └── LeaderboardScreen.tsx
│   │   └── shared/
│   │       ├── Button.tsx                # 通用按钮（金属质感）
│   │       ├── Modal.tsx                 # 弹窗
│   │       ├── Tooltip.tsx               # 提示框
│   │       └── LoadingSpinner.tsx
│   │
│   ├── audio/                            # 音效系统
│   │   ├── AudioManager.ts              # 音效管理器
│   │   ├── SoundEffects.ts              # 音效定义
│   │   └── BackgroundMusic.ts           # 背景音乐
│   │
│   ├── network/                          # 网络通信
│   │   ├── SocketClient.ts              # Socket.IO 客户端
│   │   ├── StateSync.ts                 # 状态同步适配器
│   │   └── NetworkMonitor.ts            # 网络质量监控
│   │
│   ├── hooks/                            # React Hooks
│   │   ├── useGameEngine.ts             # 游戏引擎 Hook
│   │   ├── useAnimation.ts              # 动画 Hook
│   │   ├── useSound.ts                  # 音效 Hook
│   │   └── useResponsive.ts             # 响应式适配 Hook
│   │
│   └── utils/
│       ├── easing.ts                     # 缓动函数库
│       ├── color.ts                      # 色彩工具
│       ├── randomRange.ts               # 随机工具
│       └── assetGenerator.ts            # 程序化资源生成（兜底方案）
│
├── public/
│   └── assets/                           # 静态资源
│       ├── textures/                     # 纹理
│       │   ├── cards/                    # 卡牌纹理
│       │   ├── board/                    # 战场纹理
│       │   ├── ui/                       # UI纹理
│       │   └── particles/               # 粒子纹理
│       ├── spritesheets/                 # 精灵表
│       └── audio/                        # 音频
│
├── package.json
├── tsconfig.json
├── tailwind.config.js
├── vite.config.ts
└── .env.example
```

---

## 三、卡牌视觉设计

### 3.1 卡牌模板规格

```
卡牌尺寸：220 × 310 px（手牌中缩放 0.85，场上缩放 0.75，悬浮展示 1.0）
卡牌圆角：12px
卡牌边框：2px 鎏金渐变 linear-gradient(135deg, #D4A843, #F5E6CA, #B8956A)

层级结构（从下到上）：
┌─────────────────────────┐
│  ① 卡牌背景纹理          │  ← 羊皮纸 + 职业色滤镜叠加
│  ② 插画区域 (上60%)      │  ← 随从/法术/装备插画
│  ③ 稀有度宝石            │  ← 中央顶部镶嵌
│  ④ 费用水晶 (左上角)     │  ← 法力消耗数值 + 蓝色宝石背景
│  ⑤ 卡名横幅             │  ← 半透明深色条 + 金色文字
│  ⑥ 类型图标 (右上角)     │  ← 随从(剑)/法术(星)/装备(盾)
│  ⑦ 描述文本区 (下30%)    │  ← 效果文字
│  ⑧ 攻击/生命 (底部)      │  ← 仅随从，剑图标+数值 / 心图标+数值
│  ⑨ 种族标记 (底部)       │  ← 如适用（龙/野兽/机械等）
│  ⑩ 边框光效层            │  ← 稀有度发光（白/蓝/紫/橙渐变脉冲）
└─────────────────────────┘
```

### 3.2 稀有度视觉差异

| 稀有度 | 边框颜色 | 宝石 | 光效 | 插画边框 |
|--------|---------|------|------|---------|
| 普通 | 灰色 | 无 | 无 | 无 |
| 稀有 | 蓝色辉光 | 蓝宝石 | 淡蓝呼吸光 | 细蓝线 |
| 史诗 | 紫色辉光 | 紫水晶 | 紫色脉冲光 | 紫金花纹 |
| 传说 | 橙色辉光 | 龙眼石 | 橙金旋转光 + 粒子飘散 | 金龙缠绕 |

### 3.3 卡牌状态视觉

```
正常： 标准渲染，无特殊效果
悬浮（手牌中）： 放大 1.15x，上移 20px，投影加深，边框发光
可打出： 费用足够时 → 卡牌边缘绿色脉冲光 + 微微上浮
不可打出： 费用不足时 → 卡牌整体降低饱和度 50% + 灰色蒙版
选中： 卡牌微旋转 -3° + 金色粗边框 + 粒子环绕
攻击中： 卡牌前冲 + 红色残影拖尾
受伤： 闪红 0.1s + 震动
死亡： 碎裂粒子 + 渐隐消失
冻结： 覆盖冰霜纹理 + 蓝白雪花粒子
buff： 底部光环颜色（绿=增益/红=减益/紫=身份）
```

### 3.4 卡牌程序化生成（无美术资源时的兜底）

```typescript
// assetGenerator.ts - 当没有美术素材时，用 Canvas 2D 程序化生成卡牌
class CardTextureGenerator {
  /**
   * 程序化生成完整卡牌纹理：
   * 1. 填充羊皮纸底色（带噪点纹理）
   * 2. 绘制金属边框（Canvas 线性渐变 + 斜角效果）
   * 3. 占位插画：职业主题几何图形 + 渐变（战士=红橙色盾形 / 法师=蓝紫六芒星 / 中立=灰金菱形）
   * 4. 圆角遮罩裁剪
   * 5. 文字渲染（卡名 / 描述 / 数值）
   * 6. 稀有度光效叠加（外发光 + 粒子点）
   * 7. 输出为 PixiJS Texture
   */
  
  generate(cardDef: CardDefinition): PIXI.Texture;
  generateRarityOverlay(rarity: Rarity): PIXI.Texture;
  generateCardBack(): PIXI.Texture;  // 统一卡背
}
```

---

## 四、对战场景布局

### 4.1 战场布局（1920×1080 基准，响应式缩放）

```
┌─────────────────────────────────────────────────────────────┐
│  [菜单] [对手头像 + 血条]         [回合倒计时条]   [设置⚙] │  ← 顶部栏 (60px)
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              对手手牌区 (仅显示卡背)                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─┬─┬─┬─┬─┬─┬─┐    ┌──┐  ┌──┐  ┌──┐  ┌──┐             │
│  │ │ │ │ ││ │ │ │    │对│  │对│  │对│  │对│             │   │
│  │随│随│随│随│ │ │    │手│  │手│  │手│  │手│             │   │
│  │从│从│从│从│ │ │    │牌│  │英│  │装│  │技│             │   │
│  │1 │2 │3 │4 │ │ │    │库│  │雄│  │备│  │能│             │   │
│  └─┴─┴─┴─┴─┴─┴─┘    └──┘  └──┘  └──┘  └──┘             │
│                                                             │
│================ 战场分割线 (动态能量流) ===================│
│                                                             │
│  ┌─┬─┬─┬─┬─┬─┬─┐    ┌──┐  ┌──┐  ┌──┐  ┌──┐             │
│  │ │ │ │ ││ │ │ │    │我│  │我│  │我│  │我│             │   │
│  │随│随│随│随│ │ │    │方│  │方│  │方│  │方│             │   │
│  │从│从│从│从│ │ │    │牌│  │英│  │装│  │技│             │   │
│  │1 │2 │3 │4 │ │ │    │库│  │雄│  │备│  │能│             │   │
│  └─┴─┴─┴─┴─┴─┴─┘    └──┘  └──┘  └──┘  └──┘             │
│                                                             │
│  我方手牌区 ┌──────────────────────────────────────┐       │
│  (扇形展开) │[卡1] [卡2] [卡3] [卡4] [卡5] [卡6] │       │
│             └──────────────────────────────────────┘       │
│                                                             │
│  [英雄头像+血条]  [法力水晶 🟎🟎🟎◌◌◌]  [🔚结束回合]   │  ← 底部栏 (80px)
└─────────────────────────────────────────────────────────────┘
```

### 4.2 战场背景

```typescript
// 战场背景由三层组成：

// ① 静态背景层：根据身份/职业变化
const Backgrounds = {
  NEUTRAL:   '竞技场石质地面 + 火炬 + 观众席剪影',
  WARRIOR:   '熔岩锻造场 + 铁砧火花 + 武器架',
  MAGE:      '奥术图书馆 + 悬浮书籍 + 魔法符文',
  ROGUE:     '暗影小巷 + 月光 + 晾衣绳剪影',
  PRIEST:    '圣光殿堂 + 彩绘玻璃 + 烛光',
  HUNTER:    '森林营地 + 篝火 + 动物足迹',
  // 4人身份局额外背景
  IDENTITY:  '古战场 + 破碎旗帜 + 乌鸦盘旋 + 暗红天空',
};

// ② 动态环境层：粒子系统持续运行
const AmbientParticles = {
  DUST_MOTES:    { texture: 'soft_circle', count: 30, alpha: 0.3, speed: 0.2 },
  EMBER:         { texture: 'ember', count: 20, alpha: 0.6, speed: 1.5, fade: true },
  MAGIC_SPARKS:  { texture: 'spark', count: 15, alpha: 0.4, speed: 0.8 },
};

// ③ 交互反馈层：随操作触发
// - 随从攻击时 → 地面冲击波扩散
// - 法术施放时 → 魔法阵短暂显现
// - 随从死亡时 → 地面碎裂粒子
// - 身份揭示时 → 全屏暗影脉冲
```

### 4.3 战场的动态环境光

```typescript
// 使用 PixiJS ColorMatrixFilter 或 CSS 遮罩实现全局光照变化：
// - 我方回合：战场亮度 +5%，暖色调（琥珀光）
// - 敌方回合：战场亮度 -3%，冷色调（淡蓝光）
// - 战斗阶段：红色微闪（0.05s 脉动）
// - 身份局主公回合：金色环境光
// - 低血量（<30%）：画面边缘红色暗角加深
```

---

## 五、动画系统

### 5.1 卡牌动画清单

```typescript
// CardAnimations.ts - 每个动画用 GSAP Timeline 编排
interface CardAnimationSet {
  
  // ===== 手牌区动画 =====
  drawCard(card: Card): gsap.core.Timeline;
  // 牌库弹出 → 弧线飞入手牌 → 0.4s → 缓出弹性
  // 轨迹：从牌库位置贝塞尔曲线到手牌槽位
  
  discardCard(card: Card): gsap.core.Timeline;
  // 手牌缩小 → 旋转飞向弃牌堆 → 0.3s
  
  // ===== 出牌动画 =====
  playMinion(card: Card, targetSlot: Point): gsap.core.Timeline;
  // ① 手牌放大上浮 → 翻转展示 → 0.3s
  // ② 飞向战场目标槽位 → 0.25s
  // ③ 落地冲击波 + 召唤法阵闪现 → 0.15s
  // ④ 战吼效果播放（如有）
  // 总时长约 1.2s
  
  playSpell(card: Card, target: Point): gsap.core.Timeline;
  // ① 卡牌飞向目标 → 0.3s
  // ② 卡牌闪光自旋 + 放大 → 消失 → 0.3s
  // ③ 目标处魔法爆炸 → 效果粒子 → 0.4s
  
  // ===== 战斗动画 =====
  attackForward(attacker: MinionOnBoard, target: MinionOnBoard): gsap.core.Timeline;
  // ① 攻击者蓄力后拉 20px → 0.2s
  // ② 前冲至目标位置 → 0.15s
  // ③ 碰撞闪光 + 伤害数字弹出 + 目标受击后仰 → 0.2s
  // ④ 攻击者弹回原位（弹性缓出）→ 0.3s
  
  // ===== 死亡动画 =====
  deathMinion(minion: MinionOnBoard): gsap.core.Timeline;
  // ① 暗红色滤镜渐入 → 0.2s
  // ② 碎裂成 12 片粒子 → 向四周散开 → 0.4s
  // ③ 原地留下暗影残迹 → 渐隐 → 0.3s
  
  deathHero(hero: Hero): gsap.core.Timeline;
  // ① 英雄头像震动加剧 → 0.5s
  // ② 头像碎裂粒子爆炸 → 0.6s
  // ③ 全屏红色渐变遮罩 → 0.3s
  
  // ===== 魔力水晶动画 =====
  manaFill(crystal: ManaCrystal): gsap.core.Timeline;
  // 空水晶旋转180° → 填充蓝色辉光 → 脉冲发光 → 0.5s
  
  manaSpend(crystal: ManaCrystal): gsap.core.Timeline;
  // 水晶辉光流向卡牌 → 水晶变灰 → 0.3s
  
  // ===== 洗牌动画 =====
  shuffleDeck(deck: DeckPile): gsap.core.Timeline;
  // 牌库上下弹跳 → 卡牌虚影飞溅 → 0.6s
}
```

### 5.2 UI动画清单

```typescript
// UIAnimations.ts
interface UIAnimationSet {
  
  turnTransition(isMyTurn: boolean): gsap.core.Timeline;
  // 回合指示器滑入 → 显示「你的回合」金色大字 → 渐出 → 1.5s
  // 环境光切换（见4.3）
  // 结束回合按钮从灰变金 + 脉冲提示
  
  heroDamaged(hero: Hero, damage: number): gsap.core.Timeline;
  // ① 头像闪红 + 震动 → 0.15s
  // ② 血条扣血动画（缓出，0.5s）
  // ③ 红色伤害数字飘出（向上飘 + 渐隐 → 1.2s）
  
  heroHealed(hero: Hero, amount: number): gsap.core.Timeline;
  // 绿色光环扩散 + 绿色数字飘出
  
  winBanner(): gsap.core.Timeline;
  // ① 全屏暗金色遮罩骤降 → 0.3s
  // ② 胜利文字从中央放大弹出 → 0.5s（带弹性）
  // ③ 金色粒子爆发 → 持续2s
  
  defeatBanner(): gsap.core.Timeline;
  // ① 全屏暗红遮罩 → 0.3s
  // ② 失败文字缓缓下降 → 0.8s
  // ③ 灰烬粒子飘落
  
  identityReveal(identity: Identity): gsap.core.Timeline;
  // ① 身份卡背旋转 → 揭示真身 → 0.6s
  // ② 身份文字 + 对应颜色光效（主公金/忠臣蓝/反贼红/内奸紫）
  // ③ 全屏短暂暗影脉冲
  
  skillActivate(identity: Identity): gsap.core.Timeline;
  // 身份徽记放大旋转 → 对应颜色光柱 → 1.0s
  
  mulliganSelect(cardIndex: number): gsap.core.Timeline;
  // 选中卡牌高亮上浮 → 红色边框标记 → 0.2s
  
  timeWarning(remaining: number): gsap.core.Timeline;
  // 回合计时条变红 → 脉冲闪烁 → 越临近越急促
  
  emotePlay(emoteType: string): gsap.core.Timeline;
  // 表情气泡从英雄头像弹出 → 放大 → 渐隐 → 2s
}
```

### 5.3 粒子特效清单

```typescript
// 预定义粒子模板（ParticleSystem.ts）
enum ParticlePreset {
  // 环境粒子
  DUST = 'dust',                    // 浮动尘埃
  EMBER_RISING = 'ember_rising',    // 上升火星
  MAGIC_ORBITS = 'magic_orbits',    // 环绕魔法粒子
  
  // 战斗粒子
  IMPACT_SPARK = 'impact_spark',    // 碰撞火花
  SLASH_ARC = 'slash_arc',          // 斩击弧线
  BLOOD_SPLATTER = 'blood_splatter',// 血溅
  SHIELD_BLOCK = 'shield_block',    // 格挡光盾
  
  // 法术粒子
  FIREBALL = 'fireball',            // 火球拖尾
  ICE_SHARDS = 'ice_shards',        // 冰晶碎片
  LIGHTNING_CHAIN = 'lightning',    // 闪电链
  HEALING_LIGHT = 'healing_light',  // 治愈光束（上升金色粒子）
  SHADOW_BURST = 'shadow_burst',    // 暗影爆发
  
  // 特殊粒子
  CARD_SUMMON = 'card_summon',      // 召唤法阵
  DEATH_SHATTER = 'death_shatter',  // 死亡碎裂
  BUFF_UP = 'buff_up',              // 增益上升（绿色箭头粒子）
  DEBUFF_DOWN = 'debuff_down',      // 减益下降（红色箭头粒子）
  RARITY_LEGENDARY = 'legendary',   // 传说卡牌龙息粒子
  GOLDEN_SPARKLE = 'golden_spark',  // 金色闪耀（胜利/传说道具）
}

// 每个 Preset 配置：
interface ParticleConfig {
  texture: string;           // 粒子纹理
  count: number;             // 一次发射数量
  lifetime: [number, number];// 寿命范围 (ms)
  speed: [number, number];   // 速度范围
  angle: [number, number];   // 发射角度范围
  alpha: { start: number; end: number }; // 透明度渐变
  scale: { start: number; end: number };  // 大小渐变
  blendMode: PIXI.BLEND_MODES;           // 混合模式
  gravity?: { x: number; y: number };    // 重力
}
```

---

## 六、开源资源整合方案

### 6.1 推荐获取的资源类型与来源

> Claude Code 应从以下来源自行搜索、下载并整合资源。若某资源不可用，自动寻找同类替代品。

```typescript
// assets.ts - 资源获取与fallback策略
interface AssetSource {
  // 优先级：① npm包直接引用 ② CDN下载 ③ 程序化生成兜底
  
  // ===== 图标 (SVG/PNG) =====
  icons: {
    primary: [
      { name: 'game-icons.net', url: 'https://game-icons.net/', type: 'SVG/PNG' },
      { name: 'lucide-react', npm: 'lucide-react', type: 'npm' },
      { name: 'phosphor-icons', npm: '@phosphor-icons/react', type: 'npm' },
    ],
    fallback: 'Canvas 2D 绘制简单几何图标',
    // 需要的图标清单：剑(攻击)、心(生命)、星(法术)、盾(装备)、水晶(法力)、
    //   骷髅(死亡)、火焰、冰、闪电、圣光、暗影、齿轮(设置)、箭头等
  },
  
  // ===== 卡牌插画 (占位图 → 可替换) =====
  cardArt: {
    primary: [
      // 使用公共领域/CC0 奇幻艺术资源
      { name: 'OpenGameArt', url: 'https://opengameart.org/', search: 'fantasy card portrait' },
      { name: 'Unsplash', url: 'https://unsplash.com/', search: 'fantasy warrior monster' },
    ],
    fallback: '程序化生成：职业主题几何形状 + Perlin Noise 纹理 + 渐变配色',
    // 生成参数：职业 → 主色调 + 形状模板
    // 战士=红橙盾形 / 法师=蓝紫六芒星 / 猎人=绿棕弓形 / 盗贼=暗紫匕首
    // 牧师=金白十字 / 中立=灰金菱形
  },
  
  // ===== 音效 (CC0/CC-BY) =====
  audio: {
    primary: [
      { name: 'freesound.org', baseUrl: 'https://freesound.org/', license: 'CC0' },
      { name: 'mixkit.co', url: 'https://mixkit.co/free-sound-effects/game/', license: 'free' },
      { name: 'sfxr.me', type: 'generator', note: '8-bit 音效生成器，JS 实现' },
    ],
    fallback: 'js-sfxr 库程序化生成（npm: js-sfxr）',
    // 所需音效：
    // draw_card, play_minion, play_spell, attack_hit, minion_death,
    // hero_damage, turn_start, mana_fill, win_fanfare, defeat_horn,
    // button_click, card_hover, identity_reveal, skill_activate
  },
  
  // ===== 背景音乐 (CC0) =====
  music: {
    primary: [
      { name: 'OpenGameArt Music', url: 'https://opengameart.org/art-search-advanced?field_art_type_tid%5B%5D=12&sort_by=count&license=cc0' },
      { name: 'pixabay music', url: 'https://pixabay.com/music/search/genre/video%20game/' },
    ],
    fallback: 'Web Audio API 生成环境氛围音（低频无人机 + 风铃声）',
  },
  
  // ===== 字体 =====
  fonts: {
    primary: [
      { name: 'Cinzel', google: 'Cinzel:wght@400;700;900', style: '标题/卡名' },
      { name: 'MedievalSharp', google: 'MedievalSharp', style: '奇幻正文' },
      { name: 'Crimson Text', google: 'Crimson+Text:wght@400;600', style: '描述文本' },
      { name: 'Uncial Antiqua', google: 'Uncial+Antiqua', style: '特殊标题' },
    ],
    fallback: '系统衬线字体 Georgia / Times New Roman',
  },
  
  // ===== 纹理材质 (程序化生成) =====
  textures: {
    parchment: 'Canvas 2D: 米色底 + 多层 Perlin Noise + 边缘烧焦效果',
    metalBorder: 'Canvas 2D: 线性渐变 #D4A843 → #B8956A → #8B6914 + 斜角高光',
    stoneFloor: 'Canvas 2D: 深灰底 + Voronoi Noise 裂缝 + 随机碎石',
    magicCircle: 'Canvas 2D: 同心圆 + 符文文字 + 旋转光效',
    gemCrystal: 'Canvas 2D: 多边形切面 + 径向渐变 + 高光反射点',
  },
}
```

### 6.2 npm 依赖清单

```json
{
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "pixi.js": "^8.1.0",
    "gsap": "^3.12.0",
    "zustand": "^4.5.0",
    "socket.io-client": "^4.7.0",
    "howler": "^2.2.0",
    "lucide-react": "^0.400.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.3.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "vite": "^5.3.0",
    "@vitejs/plugin-react": "^4.3.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "@types/howler": "^2.2.0"
  }
}
```

### 6.3 资源加载策略

```typescript
// AssetLoader.ts
class AssetLoader {
  /**
   * 分层加载策略：
   * 
   * Phase 1（关键路径，0-3s）：
   *   - 程序化生成所有卡牌纹理（无需网络请求）
   *   - 加载字体（font-display: swap）
   *   - 生成粒子纹理（2x2像素点 + Canvas缩放 = 各种粒子形状）
   *   → 此时游戏已可渲染，使用程序化纹理
   * 
   * Phase 2（后台异步，3-15s）：
   *   - 下载真实插画资源替换占位图
   *   - 下载音效资源
   *   - 下载背景音乐
   *   → 替换后无感知过渡
   * 
   * Phase 3（空闲时）：
   *   - 预加载后续可能用到的资源
   */
  
  // 自定义加载画面（游戏标题 + 进度条 + 环境粒子 + 加载提示文字轮换）
  showLoadingScreen(): void;
}
```

---

## 七、交互设计

### 7.1 操作流程

```
玩家回合内操作流程：

① 鼠标悬浮手牌中的卡牌：
   → 卡牌放大 1.15x + 上浮 + 显示详细 Tooltip（效果说明）
   → 费用足够：绿色脉冲边框
   → 费用不足：灰色蒙版 + 不可点击

② 拖拽卡牌出战：
   → 卡牌跟随鼠标 + 半透明拖影
   → 进入战场区域：目标槽位高亮（可用=绿 / 非法=红）
   → 松开：执行出牌动画
   → 需要选择目标：卡牌悬浮等待，目标高亮可选

③ 点击场上随从发起攻击：
   → 随从周围出现攻击范围指示器（红色箭头指向可选目标）
   → 可选目标：高亮绿色边框
   → 不可选目标（潜行/己方）：灰色
   → 点击目标：执行攻击动画

④ 使用身份技能：
   → 点击技能按钮 → 技能图标旋转 + 对应颜色光效
   → 需要选择目标 → 同②的目标选择逻辑

⑤ 结束回合：
   → 按钮从金色变为灰色 + 锁定
   → "敌方回合"大字滑入 → 敌方随从可行动指示亮起
```

### 7.2 右键菜单

```typescript
// 右键点击场上随从弹出菜单
interface ContextMenu {
  options: [
    { label: '查看详情',  action: 'inspect',  icon: 'eye' },       // 悬浮大卡展示
    { label: '攻击目标',  action: 'attack',   icon: 'sword' },     // 进入攻击选择
    { label: '使用技能',  action: 'skill',    icon: 'star' },      // 如有主动技能
  ];
  // 菜单从点击位置弹出，暗色磨砂玻璃 + 金色边框
}
```

### 7.3 键盘快捷键

```
Space     → 结束回合（需在己方回合）
Esc       → 取消当前操作 / 关闭弹窗
1-6       → 选择手牌中第N张卡
Tab       → 切换可选目标
Enter     → 确认选择
Ctrl+Z    → 取消最后选中的卡（回到手牌）
```

---

## 八、动效细节规范

### 8.1 缓动函数选用指南

| 场景 | 缓动函数 | 感觉 |
|------|---------|------|
| 卡牌从牌库飞入手中 | `elastic.out(1, 0.5)` | 弹性，有活力 |
| 卡牌打出 | `back.out(1.2)` | 轻微过冲，有力道 |
| 攻击前冲 | `power2.in` + `power2.out` | 蓄力→爆发 |
| 伤害数字飘出 | `power1.out` | 自然衰减 |
| UI面板弹出 | `back.out(1.4)` | 干脆利落 |
| 回合切换横幅 | `expo.inOut` | 大气平滑 |
| 环境粒子 | 线性 | 持续柔和 |
| 法力充能 | `bounce.out` | 欢快弹跳 |

### 8.2 动画时长阶梯

```
瞬时 (0-100ms):   悬浮高亮、选中标记、鼠标跟随
快速 (100-250ms): 卡牌飞入、碰撞反馈、数字弹出
中速 (250-500ms): 出牌动画、攻击完整流程、死亡消失
慢速 (500-1000ms): 回合切换、身份揭示、技能发动
叙事 (1-3s):      胜利/失败横幅、过场动画
```

### 8.3 GPU 加速清单

```typescript
// 始终使用以下 CSS 属性进行动画（GPU 合成），避免 layout/paint：
// ✅ transform (translate, scale, rotate)
// ✅ opacity
// ✅ filter (在 PixiJS 中使用内置滤镜)

// ❌ 禁止动画的属性（触发重排）：
// width, height, top, left, margin, padding, border-width
```

---

## 九、响应式适配

### 9.1 断点策略

```typescript
// useResponsive.ts
const breakpoints = {
  desktop: 1920,     // 标准1080p → 原生布局
  laptop: 1366,      // 笔记本 → 缩放至 0.85
  tablet: 1024,      // 平板 → 缩放至 0.7 + UI紧凑模式
  mobile: 768,       // 手机 → 竖屏布局（手牌在底部横排）
};

// 缩放策略：等比缩放整个游戏画布，保持 16:9 比例
// 使用 CSS transform: scale() 包裹游戏容器
// 黑边填充（letterbox）
```

### 9.2 移动端特殊适配

```
竖屏布局 (768px以下)：
┌──────────┐
│ 对手信息  │  ← 压缩顶部栏
│ 对手手牌  │  ← 仅显示数量
│          │
│ 对手战场  │  ← 单行滚动
│          │
│──────────│
│          │
│ 我方战场  │  ← 单行滚动
│          │
│ 我方手牌  │  ← 横向滑动选择
│ [法力][回合]│ ← 底部固定
└──────────┘

触摸操作：
- 点击 = 悬浮（0.3s长按 = 右键菜单）
- 滑动 = 手牌区横向滚动
- 双指缩放 = 查看卡牌详情
```

---

## 十、性能优化

### 10.1 渲染优化

```typescript
// 性能预算：稳定 60fps（16.67ms/帧）
const PerfBudget = {
  gameLogic:   '3ms',    // 状态更新
  pixiRender:  '8ms',    // PixiJS 渲染
  reactRender: '3ms',    // React UI 更新
  headroom:    '2.67ms', // 余量
};

// 优化手段：
// 1. 对象池：卡牌对象、粒子、飘字全部池化复用
// 2. ParticleContainer：批量渲染粒子（比普通 Container 快 10x）
// 3. RenderTexture：将静态元素（战场背景、UI面板）烘焙为纹理
// 4. Culling：仅渲染视口内的游戏对象
// 5. Batch Rendering：相同纹理的对象合批渲染
// 6. React.memo：UI 组件避免无谓重渲染
// 7. useMemo / useCallback：稳定引用
// 8. Web Worker：复杂计算（如 AI 模拟、状态哈希校验）放到 Worker
```

### 10.2 内存管理

```typescript
// 内存预算：< 512MB (桌面) / < 200MB (移动)
// - 纹理资源：加载后缓存，场景切换时释放非共享纹理
// - 动画实例：动画完成后自动 kill() 并从 Timeline 移除
// - 事件监听：组件卸载时清理所有 PixiJS 事件和 GSAP Tween
// - 粒子系统：限制同时存在的粒子总数 < 2000
```

---

## 十一、开发顺序

| Phase | 内容 | 可演示效果 |
|-------|------|-----------|
| Phase 1 | 项目骨架 + 设计Token + AssetLoader + 程序化卡牌生成 | 静态卡牌展示 |
| Phase 2 | PixiJS 游戏引擎封装 + 战场场景 + 背景渲染 | 空战场 + 环境粒子 |
| Phase 3 | 手牌区UI + 手牌卡牌组件 + 扇形展开布局 | 手牌展示 + 悬浮交互 |
| Phase 4 | 出牌动画 + 随从入场 + 战场布局 | 可打出随从到场上 |
| Phase 5 | 攻击动画 + 战斗碰撞 + 伤害飘字 + 死亡动画 | 随从可互相攻击 |
| Phase 6 | 英雄UI + 血量/法力动画 + 回合切换 + 技能按钮 | 完整回合循环 |
| Phase 7 | 法术/装备卡动画 + 全部效果粒子系统 | 所有卡牌类型可演示 |
| Phase 8 | 身份UI + 身份揭示动画 + 4人局布局调整 | 身份局视觉效果 |
| Phase 9 | 音效整合 + 背景音乐 + 音频管理器 | 完整视听体验 |
| Phase 10 | 匹配/大厅/结算 UI 界面 | 完整游戏流程 |
| Phase 11 | 响应式适配 + 移动端布局 | 多端可玩 |
| Phase 12 | 性能优化 + 对象池 + 纹理烘焙 | 稳定60fps |

---

## 十二、输出要求

按以下顺序生成代码：

1. **配置与Token**：`theme.ts` → `animation.ts` → `assets.ts`
2. **PixiJS 引擎**：`GameApp.ts` → `SceneManager.ts` → `AssetLoader.ts` → `Camera.ts` → `TickManager.ts`
3. **程序化资源生成**：`assetGenerator.ts`（卡牌纹理、粒子纹理、材质纹理全部程序化生成）
4. **卡牌渲染**：`Card.ts`（PixiJS Container）→ `MinionOnBoard.ts` → `Hero.ts` → `ManaCrystal.ts`
5. **特效系统**：`ParticleSystem.ts`（含所有预设）→ `FloatingText.ts` → 各特效组件
6. **动画编排**：`CardAnimations.ts` → `UIAnimations.ts` → `IdentityAnimations.ts`
7. **战场场景**：`BattleScene.ts`（组装所有视觉元素）
8. **React UI组件**：`HandZone.tsx` → `CardInHand.tsx` → `BoardZone.tsx` → `HeroPortrait.tsx` → `ManaBar.tsx` → `EndTurnButton.tsx` → `TurnIndicator.tsx` → `TimerBar.tsx` → `MulliganPanel.tsx` → `IdentityPanel.tsx`
9. **页面与导航**：`LoginScreen.tsx` → `LobbyScreen.tsx` → `MatchScreen.tsx` → `MatchResultScene.ts`
10. **音效系统**：`AudioManager.ts` → `SoundEffects.ts` → `BackgroundMusic.ts`
11. **状态管理**：`gameStore.ts` → `uiStore.ts` → `settingsStore.ts`
12. **网络适配**：`SocketClient.ts` → `StateSync.ts` → `NetworkMonitor.ts`

所有视觉资源优先用 Canvas 2D 程序化生成（无外部依赖），确保 Claude Code 可独立完成全部开发，无需手动准备任何美术素材。后续用户可替换为专业美术资源，接口已在 `assets.ts` 中标注。
*（内容由AI生成，仅供参考）*
