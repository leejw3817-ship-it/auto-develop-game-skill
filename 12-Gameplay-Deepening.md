---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_e46cca1788ee11f1b66e525400e6dd8f
    ReservedCode1: xi32Zfed8l5IzqBmOEaHWu4ecljKzqacYkcFY0ZalIkXJaW9mYElSRNE3OvUAIHGCeQbd86yXJuZjX2qbzODJEzsELcReOCJgxmFpVT9RYHTNWFoGgHf3WB43+UVOD6cbsVsSOTJNzeHlxpKTeXSrikzqpbAPhkpktsFQEBq1bLqb5JAAwFMp1Fg8zE=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_e46cca1788ee11f1b66e525400e6dd8f
    ReservedCode2: xi32Zfed8l5IzqBmOEaHWu4ecljKzqacYkcFY0ZalIkXJaW9mYElSRNE3OvUAIHGCeQbd86yXJuZjX2qbzODJEzsELcReOCJgxmFpVT9RYHTNWFoGgHf3WB43+UVOD6cbsVsSOTJNzeHlxpKTeXSrikzqpbAPhkpktsFQEBq1bLqb5JAAwFMp1Fg8zE=
---

# 校园杀 UI 资源获取与设计落地提示词

> 让 Claude 自行找资源、自行设计、自行集成进 Phaser 3 游戏项目。
> 零美术依赖，开源资源 + 程序化生成兜底。

---

## 一、资源获取路线

### 1.1 图标（UI 图标 + 技能图标 + 装备图标）

**优先级从高到低**，Claude 按顺序尝试，找到一个足够完整的就直接用：

| 次序 | 来源 | 地址 | 数量 | 许可 | 说明 |
|------|------|------|------|------|------|
| 1 | Game-icons.net | https://game-icons.net | 4000+ | CC-BY 3.0 | 游戏风格最匹配，含暗黑/奇幻/武术分类，SVG 格式，可调色 |
| 2 | Lucide Icons | https://lucide.dev/icons | 1400+ | ISC | 现代简洁风，SVG，适合 UI 按钮/菜单 |
| 3 | Phosphor Icons | https://phosphoricons.com | 9000+ | MIT | 6 种风格切换(Regular/Bold/Fill/Duotone)，适合多场景 |
| 4 | Font Awesome Free | https://fontawesome.com | 2000+ | CC-BY 4.0 / MIT | 通用图标，Web Font 方式引入 |
| 5 | Tabler Icons | https://tabler.io/icons | 5000+ | MIT | 线性风格，与 Lucide 互补 |

**使用方式**：下载 SVG → 通过 Phaser 的 `this.textures.addBase64` 或直接用 `this.load.svg` 加载 → 作为 Sprite 或 Image 使用。也可以用 Phaser 的 `rexui` 插件直接渲染 SVG。

**兜底方案**：如果以上任意一个源不可访问（网络问题），用 Canvas 2D 程序化绘制所有图标。每个图标定义为 `(ctx, size, color) => void` 的函数，绘制简单几何图形。

```typescript
// 图标兜底生成器示例
const iconDrawers: Record<string, (ctx: CanvasRenderingContext2D, s: number) => void> = {
  attack: (ctx, s) => {
    ctx.beginPath();
    ctx.moveTo(s * 0.5, 0); ctx.lineTo(s, s * 0.3); ctx.lineTo(s * 0.7, s * 0.3);
    ctx.lineTo(s * 0.7, s); ctx.lineTo(s * 0.3, s); ctx.lineTo(s * 0.3, s * 0.3);
    ctx.lineTo(0, s * 0.3); ctx.closePath(); ctx.fill();
  },
  shield: (ctx, s) => { /* ... */ },
  heal: (ctx, s) => { /* ... */ },
};
```

### 1.2 UI 纹理 / 面板背景

| 来源 | 地址 | 说明 |
|------|------|------|
| AmbientCG | https://ambientcg.com | 免费 PBR 材质，可用于面板背景纹理（纸张/布料/木板等），CC0 |
| TextureKing | https://textureking.com | 300+ 免费纹理，适合 UI 面板底纹 |
| Subtle Patterns | https://www.toptal.com/designers/subtlepatterns/ | CSS 背景图案，CC-BY-SA |

**使用方式**：下载 512×512 或 1024×1024 的纹理图 → 在 Phaser 中设为 TileSprite，用于面板/卡牌背面/桌面背景。

**兜底方案**：Canvas 2D 生成噪点纹理 + 渐变，代码量约 50 行。

### 1.3 字体

**中文字体是最大难点——中文完整字体动辄 10MB+，必须子集化。**

| 来源 | 地址 | 许可 | 推荐用途 |
|------|------|------|---------|
| 站酷系列 | https://www.zcool.com.cn/special/zcoolfonts/ | 免费商用 | 标题/标语（站酷快乐体、站酷文艺体等） |
| 阿里巴巴普惠体 | https://fonts.alibabagroup.com | 免费商用 | 正文（完整 GB2312 + 繁体） |
| 霞鹜文楷 | https://github.com/lxgw/LxgwWenKai | SIL OFL | UI 正文，手写风格适合校园主题 |
| 思源黑体 | https://github.com/adobe-fonts/source-han-sans | SIL OFL | 通用正文，覆盖最全 |
| 得意黑 | https://github.com/atelier-anchor/smiley-sans | SIL OFL | 标题/标语，活泼风格 |
| Google Fonts (Noto Sans SC) | https://fonts.google.com | SIL OFL | 通用正文 |

**字体子集化脚本**（Claude 必须执行，不能直接下载完整字体）：

```bash
# 1. 安装 fonttools
pip install fonttools brotli

# 2. 收集游戏中所有中文字符
# 从角色名/技能描述/卡牌名/UI 文案中提取去重字符集
node scripts/extract-chars.js > chars.txt

# 3. 子集化字体
pyftsubset 霞鹜文楷.ttf \
  --text-file=chars.txt \
  --output-file=public/fonts/LXGWWenKai-subset.woff2 \
  --flavor=woff2 \
  --layout-features='*' \
  --no-hinting

# 预期结果：完整字体 15MB → 子集后 800KB ~ 1.5MB
```

**Phaser 加载**：

```typescript
// 在 preload 中
this.load.font('gameFont', 'fonts/LXGWWenKai-subset.woff2');
this.load.font('titleFont', 'fonts/SmileySans-subset.woff2');
```

**兜底方案**：如果字体下载失败，使用系统默认字体栈 `"Microsoft YaHei", "PingFang SC", "Noto Sans SC", sans-serif`，Canvas 渲染时会自动使用系统已安装的字体。

### 1.4 音效

| 来源 | 地址 | 许可 |
|------|------|------|
| Freesound | https://freesound.org | CC0 / CC-BY |
| Mixkit | https://mixkit.co/free-sound-effects/ | 免费商用 |
| Zapsplat | https://www.zapsplat.com | 需注册，免费 |
| Pixabay Sound Effects | https://pixabay.com/sound-effects/ | 免费商用 |

**需要的音效清单**（按优先级）：
- 卡牌出牌：whoosh / 啪
- 攻击音效：sword / punch
- 闪避音效：swoosh / dodge
- 伤害音效：hit / damage
- 回合开始：bell / chime
- 回合结束：tick
- 胜利/失败：fanfare
- 按钮点击：click

**兜底方案**：Web Audio API 程序化合成的音效函数表，约 200 行代码覆盖全部基础音效。

```typescript
// 音效合成兜底
class SfxSynthesizer {
  private ctx: AudioContext;
  play(type: 'card_play' | 'attack' | 'dodge' | 'hurt' | 'turn_start' | 'turn_end' | 'win' | 'lose' | 'click') {
    switch(type) {
      case 'card_play': return this.playNoise(0.05, 800, 'triangle'); // 短促清脆
      case 'attack': return this.playNoise(0.12, 200, 'sawtooth', 800, 200); // 降调嗡声
      // ...
    }
  }
}
```

### 1.5 背景音乐（BGM）

| 来源 | 地址 | 许可 | 说明 |
|------|------|------|------|
| OpenGameArt | https://opengameart.org | 多种(CC0/CC-BY) | 游戏专用，分类清晰 |
| Incompetech | https://incompetech.com/music/royalty-free/ | CC-BY | Kevin MacLeod 作品，质量极高 |
| Pixabay Music | https://pixabay.com/music/ | 免费商用 | 数量多，质量参差 |

**需要的 BGM**：
- 主菜单：轻松/期待感
- 对局中（正常）：紧张但不压迫
- 对局中（残局/濒死）：加速/紧迫
- 胜利结算
- 失败结算

**兜底方案**：不兜底。BGM 不是必需的，没找到就静音。禁止用 TTS 合成音乐。

---

## 二、视觉设计系统

### 2.1 主题定位

**校园主题 ≠ 学校 App**。关键词：青春/热血/对抗/日系校园动漫风格。

参考作品：《弹丸论破》《女神异闻录5》《排球少年》——大胆的配色、动态 UI 元素、手写/涂鸦感的装饰。

### 2.2 调色板

```
主题色系：日系校园热血
  主色 #E53935  —— 斗志红（按钮/选中态/伤害/红方阵营）
  辅色 #1E88E5  —— 理性蓝（蓝方阵营/链接/防御）
  强调 #FFB300  —— 警示琥珀（警告/濒死/倒计时）
  成功 #43A047  —— 和平绿（治疗/增益/胜利）
  中性 #546E7A  —— 蓝灰（正文/次级信息）

场景用色（暗色主题基底）：
  最深背景 #1A1A2E  —— 午夜蓝黑（主背景）
  面板背景 #16213E  —— 深蓝（卡片/弹窗基底）
  面板分割 #0F3460  —— 深海蓝（分割线/边框）
  文字主色 #EAEAEA  —— 暖灰白
  文字辅色 #A0A0B0  —— 冷灰
```

### 2.3 字体层级

```
标题大字：站酷快乐体 / 得意黑 —— 用于主菜单标题、结算画面文字
UI 正文：霞鹜文楷 / 阿里巴巴普惠体 —— 用于卡牌名称、技能描述、按钮
数字/属性：Noto Sans SC Bold —— 用于 HP、ATK、费用等数字
等宽备用：系统默认等宽 —— 用于伤害飘字中的数字
```

### 2.4 间距体系（基数 8px）

```
xs: 4px   —— 紧凑间距（图标内边距）
sm: 8px   —— 小间距（标签之间、小元素内部）
md: 16px  —— 标准间距（卡片内边距、列表项之间）
lg: 24px  —— 宽松间距（区块之间）
xl: 32px  —— 区块间隔
xxl: 48px —— 大面积留白（主菜单 logo 下方）
```

### 2.5 圆角体系

```
按钮：6px
卡片（手牌）：10px
面板/弹窗：12px
头像/头像框：50%（圆形）
装备栏方块：4px
```

### 2.6 阴影体系

```
卡片悬浮（手牌 hover）：0 4px 20px rgba(0,0,0,0.5) + 金光边框
面板弹窗：0 8px 32px rgba(0,0,0,0.6)
按钮按下：inset 0 2px 4px rgba(0,0,0,0.3)
```

---

## 三、Phaser 3 集成方案

### 3.1 加载管线

```typescript
// 在 LoadingScene 或主 Scene 的 preload 中
preload() {
  // 1. 字体（优先加载，后续文本渲染依赖）
  this.load.font('bodyFont', 'fonts/LXGWWenKai-subset.woff2');
  this.load.font('titleFont', 'fonts/SmileySans-subset.woff2');

  // 2. 图标（SVG → Texture）
  this.load.svg('icon_attack', 'assets/icons/attack.svg');
  this.load.svg('icon_shield', 'assets/icons/shield.svg');
  // ... 批量加载

  // 3. 纹理
  this.load.image('tex_paper', 'assets/textures/paper_diffuse.jpg');
  this.load.image('tex_cloth', 'assets/textures/cloth_diffuse.jpg');
  this.load.image('tex_wood', 'assets/textures/wood_diffuse.jpg');

  // 4. 音效
  this.load.audio('sfx_card_play', 'assets/sfx/card_play.ogg');
  this.load.audio('sfx_attack', 'assets/sfx/attack.ogg');
  // ...

  // 5. BGM（非阻塞，流式加载）
  this.load.audio('bgm_menu', 'assets/bgm/menu.ogg');
  this.load.audio('bgm_battle', 'assets/bgm/battle.ogg');
}
```

### 3.2 面板组件模式

每个 UI 面板实现为**独立的 Phaser Container + 工厂函数**，而非散落在 Scene 中：

```typescript
// ui/panels/CardDetailPanel.ts
export function createCardDetailPanel(
  scene: Phaser.Scene,
  x: number,
  y: number,
  cardData: CardData
): Phaser.GameObjects.Container {
  const container = scene.add.container(x, y);

  // 背景（带纹理的 NinePatch / RoundedRect）
  const bg = scene.add.graphics();
  bg.fillStyle(0x16213E, 0.95);
  bg.fillRoundedRect(-150, -200, 300, 400, 12);
  // 面板纹理叠加
  const tex = scene.add.tileSprite(-150, -200, 300, 400, 'tex_paper');
  tex.setAlpha(0.08);

  // 卡面美术
  const cardArt = createCardArt(scene, 0, -120, cardData);

  // 名称
  const nameText = scene.add.text(0, 50, cardData.name, {
    fontFamily: 'bodyFont',
    fontSize: '22px',
    color: '#EAEAEA',
  }).setOrigin(0.5);

  // 属性
  const statsText = scene.add.text(0, 80, `体力 ${cardData.hp}  攻击 ${cardData.atk}`, {
    fontFamily: 'bodyFont',
    fontSize: '16px',
    color: '#A0A0B0',
  }).setOrigin(0.5);

  // 技能描述
  const descText = scene.add.text(0, 120, cardData.skillDesc, {
    fontFamily: 'bodyFont',
    fontSize: '14px',
    color: '#FFB300',
    wordWrap: { width: 260 },
    lineSpacing: 6,
  }).setOrigin(0.5, 0);

  container.add([bg, tex, cardArt, nameText, statsText, descText]);
  return container;
}
```

### 3.3 动画系统

```typescript
// 入场动画预设（用于面板弹出）
const ANIM_PRESETS = {
  scaleIn: (target: Phaser.GameObjects.Container, duration = 300) => {
    target.setScale(0.8).setAlpha(0);
    scene.tweens.add({
      targets: target,
      scale: 1,
      alpha: 1,
      duration,
      ease: 'Back.easeOut',
    });
  },
  slideUp: (target: Phaser.GameObjects.Container, duration = 300) => {
    const finalY = target.y;
    target.y += 40; target.setAlpha(0);
    scene.tweens.add({
      targets: target,
      y: finalY,
      alpha: 1,
      duration,
      ease: 'Cubic.easeOut',
    });
  },
  fadeIn: (target: Phaser.GameObjects.Container, duration = 200) => {
    target.setAlpha(0);
    scene.tweens.add({
      targets: target,
      alpha: 1,
      duration,
      ease: 'Linear',
    });
  },
};
```

### 3.4 响应式布局

```typescript
// ui/layout/LayoutManager.ts
export class LayoutManager {
  static readonly BASE_WIDTH = 1920;
  static readonly BASE_HEIGHT = 1080;

  private scaleX: number;
  private scaleY: number;

  constructor(scene: Phaser.Scene) {
    this.scaleX = scene.scale.width / LayoutManager.BASE_WIDTH;
    this.scaleY = scene.scale.height / LayoutManager.BASE_HEIGHT;
  }

  // 任意坐标按基准分辨率等比缩放
  scalePos(x: number, y: number): [number, number] {
    return [x * this.scaleX, y * this.scaleY];
  }

  // 安全区（刘海屏/底部导航栏适配）
  get safeArea() {
    return {
      top: 44 * this.scaleY,
      bottom: (LayoutManager.BASE_HEIGHT - 34) * this.scaleY,
      left: 0,
      right: LayoutManager.BASE_WIDTH * this.scaleX,
    };
  }
}
```

---

## 四、资源获取命令行清单

Claude 在开始 UI 开发前，先执行以下命令获取所有资源：

```bash
# ===== 图标 =====
# Game-icons.net 批量下载（选一组约 80 个游戏相关图标）
# 手动挑选或使用 API：https://game-icons.net/tags.json
# 保存到 assets/icons/

# ===== 纹理 =====
# ambientCG 下载纸张/布料纹理
curl -L "https://ambientcg.com/get?file=Paper001_1K-JPG.zip" -o /tmp/paper.zip
unzip /tmp/paper.zip -d public/assets/textures/

curl -L "https://ambientcg.com/get?file=Fabric050_1K-JPG.zip" -o /tmp/fabric.zip
unzip /tmp/fabric.zip -d public/assets/textures/

# ===== 字体 =====
# 霞鹜文楷
curl -L "https://github.com/lxgw/LxgwWenKai/releases/latest/download/LXGWWenKai-Regular.ttf" \
  -o /tmp/LXGWWenKai.ttf

# 得意黑
curl -L "https://github.com/atelier-anchor/smiley-sans/releases/latest/download/SmileySans-Oblique.ttf" \
  -o /tmp/SmileySans.ttf

# 字体子集化
pip install fonttools brotli
node scripts/extract-chars.js > /tmp/chars.txt
pyftsubset /tmp/LXGWWenKai.ttf --text-file=/tmp/chars.txt \
  --output-file=public/assets/fonts/LXGWWenKai-subset.woff2 --flavor=woff2
pyftsubset /tmp/SmileySans.ttf --text-file=/tmp/chars.txt \
  --output-file=public/assets/fonts/SmileySans-subset.woff2 --flavor=woff2

# ===== 音效 =====
# 从 Freesound/Mixkit 逐一下载，保存到 assets/sfx/
# 文件名：card_play.ogg / attack.ogg / dodge.ogg / hurt.ogg / turn_start.ogg / turn_end.ogg / win.ogg / lose.ogg / click.ogg

# ===== BGM =====
# 从 OpenGameArt 搜索下载，保存到 assets/bgm/
```

---

## 五、UI 页面清单与布局规范

### 5.1 必须实现的页面

| 页面 | 关键元素 | 交互要求 |
|------|---------|---------|
| 主菜单 | Logo、开始游戏、模式选择、设置、退出 | Logo 入场动画；按钮 hover 缩放 + 高亮边框 |
| 模式选择 | 1v1/3v3 切换、房间号输入、加入/创建按钮 | 模式切换动画 |
| 选将界面 | 英雄卡牌网格、确认按钮、倒计时 | 卡牌 hover 放大展示详情；选中高亮边框；倒计时环 |
| 对局主界面 | 手牌区、装备区、判定区、体力/体力上限、阶段指示器、回合指示器、结束回合按钮、聊天/日志 | 见下方对局布局详述 |
| 结算界面 | 胜负动画、MVP 展示、数据统计、返回大厅按钮 | 胜利/失败不同动画；数据面板滑入 |

### 5.2 对局主界面布局

```
┌─────────────────────────────────────────────────────┐
│                    对手信息栏                          │
│  [头像] 名字  体力:■■■■□  手牌数:5  [装备][判定]       │
│                                                       │
│                      中央战场                           │
│               (卡牌使用/技能特效区域)                     │
│                                                       │
│                    队友信息栏(3v3)                       │
│  [头像] 名字  体力:■■■□□  手牌数:3  [装备]              │
│                                                       │
├─────────────────────────────────────────────────────┤
│  [回合指示器] 阶段:出牌阶段  [结束回合按钮]    [日志]     │
│                                                       │
│  手牌区:  [卡1] [卡2] [卡3] [卡4] [卡5]               │
│  装备区:  [武器] [防具] [+1马] [-1马]                  │
│  判定区:  [乐]  [兵]  [闪电]                           │
│  体力: ■■■□  ♥4/4                                     │
└─────────────────────────────────────────────────────┘
```

---

## 六、设计防"AI 感"约束

> 以下特征绝对禁止出现在最终 UI 中，它们会让游戏一眼就被认出来是 AI 生成的。

### 禁止的配色
- `linear-gradient(135deg, #667eea 0%, #764ba2 100%)` 蓝紫渐变
- `#6366f1` / `#8b5cf6` / `#ec4899` Tailwind 默认色系
- 纯白 `#FFFFFF` + 浅灰 `#F3F4F6` 的背景组合

### 禁止的布局
- 居中单列卡片 + `box-shadow: 0 4px 6px rgba(0,0,0,0.1)` 的列表
- `rounded-xl` + `shadow-lg` + `bg-white` 三件套
- 全页面 `gap-4` / `p-6` / `space-y-4` 的机械间距

### 禁止的字体
- 默认使用 Inter 字体
- 中文页面使用 Arial / Helvetica 作为 fallback 的唯一选择

### 禁止的交互
- 仅 `hover:scale-105` 的单调缩放
- 无过渡动画的状态切换（按钮/面板凭空出现和消失）
- 进度条使用纯色填充无纹理

---

## 七、落地执行顺序（Claude 必须按此顺序）

```
Step 1: 下载资源
  ├── 图标：Game-icons.net 选 80 个 → assets/icons/
  ├── 纹理：ambientCG 下 3 张 → assets/textures/
  ├── 字体：霞鹜文楷 + 得意黑 → 子集化 → assets/fonts/
  ├── 音效：Freesound 下 9 个 → assets/sfx/
  └── BGM：OpenGameArt 搜 2 首 → assets/bgm/

Step 2: 建立 UI 基础架构
  ├── LayoutManager.ts —— 响应式缩放
  ├── PanelFactory.ts —— 面板创建工厂
  ├── ButtonFactory.ts —— 按钮组件（含 hover/active 动效）
  ├── SubtitleManager.ts —— 字幕/飘字/日志管理（复用上一轮修复提示词的设计）
  └── theme.ts —— 调色板/字体/间距/圆角常量

Step 3: 实现页面（按游戏流程顺序）
  ├── MenuScene —— 主菜单
  ├── ModeSelectScene —— 模式选择
  ├── HeroSelectScene —— 选将界面
  ├── BattleScene —— 对局主界面（复用但美化现有布局）
  └── ResultScene —— 结算界面

Step 4: 集成到现有游戏
  └── 替换 BattleScene 中的 drawSeats/drawHand/drawEquipments 为新的面板组件
```

---

## 八、输出要求

1. 所有资源文件必须实际从互联网下载到本地 `public/assets/` 目录
2. 无法下载的资源使用程序化生成兜底，不得留空占位
3. 每个 UI 组件必须拆分为独立 `.ts` 文件，放在 `src/ui/` 目录下
4. 最终产物：可直接运行的 Phaser 3 游戏，主菜单→选将→对局→结算完整可走通
5. 所有文本使用子集化字体渲染，不得回退到系统默认中文字体
*（内容由AI生成，仅供参考）*
