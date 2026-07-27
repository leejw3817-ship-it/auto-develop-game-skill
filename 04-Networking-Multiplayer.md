---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_2217873888ff11f1a68c525400826444
    ReservedCode1: uFjvVWrpDJ6v4PFfcmj5RGuLzEDXXbJ6Iqpm1yVSp8rT0MmBsnFmXfGwBbkawhSeN3qHZFLybmlClygZkud2pNutYHIPXgdWeDX5FBOA7Zf78a+23jEbuSE0SiroXJr9S1OH/+Dw8WZb4NKK87NgjzT+lFPDFHPrKg+wKdIODVwSov7U/P6JlGWiGqk=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_2217873888ff11f1a68c525400826444
    ReservedCode2: uFjvVWrpDJ6v4PFfcmj5RGuLzEDXXbJ6Iqpm1yVSp8rT0MmBsnFmXfGwBbkawhSeN3qHZFLybmlClygZkud2pNutYHIPXgdWeDX5FBOA7Zf78a+23jEbuSE0SiroXJr9S1OH/+Dw8WZb4NKK87NgjzT+lFPDFHPrKg+wKdIODVwSov7U/P6JlGWiGqk=
---

# 校园杀 FairyGUI UI 引擎集成 + 交付弹窗验证提示词

> 让 Claude 引入 FairyGUI 作为第三引擎专攻 UI 渲染，并在每次交付前自动弹窗做验证门禁。
> 三层引擎分工明确：Unity 管 3D 画面，Phaser 管游戏逻辑，FairyGUI 管 UI 表现。

---

## 一、为什么推荐 FairyGUI

### 1.1 三条理由

| 维度 | FairyGUI | Unity uGUI | Phaser Canvas Text |
|------|---------|------------|-------------------|
| 富文本 | 支持 HTML 标签 / 图文混排 / 超链接 | 仅 TextMeshPro 部分支持 | 弱（基础 fillText） |
| UI 动画 | 内置时间轴编辑器，无需写代码做动效 | 需 Animator + 脚本 | 需手写 Tween |
| 列表性能 | 虚拟列表，1000+ 项不卡 | 需手写对象池 | 无虚拟化 |
| 多分辨率适配 | 关联系统，一次设计多端自适应 | 需手动 Canvas Scaler | 需手写缩放 |
| 热更新 | UI 包作为资源独立更新，不重发包体 | 不独立 | 不独立 |
| 与 Unity 集成 | 官方 SDK，直接挂 FairyGUI 组件到 GameObject | 原生 | 无关 |
| 价格 | 免费（MIT 协议） | 免费 | 免费 |
| 中文本土化 | 国内团队维护，中文文档完善 | 英文为主 | 无关 |

**结论**：用 Phaser Canvas 文字渲染游戏 UI（手牌名/属性/技能描述/战斗日志/按钮）是当前画面粗糙的根源。FairyGUI 可以完全接管这一层，让 Phaser 只保留 Socket.io 连接和状态机逻辑。

### 1.2 三层引擎重新分工

```
┌───────────────────────────────────────────────┐
│                  Browser                       │
│                                                │
│  Unity WebGL     FairyGUI          Phaser 3   │
│  (底层 3D)       (中层 UI)         (逻辑层)    │
│  ┌──────────┐  ┌─────────────┐  ┌──────────┐ │
│  │3D场景     │  │主菜单界面    │  │游戏状态机  │ │
│  │角色模型    │  │选将界面     │  │Socket.io  │ │
│  │卡牌3D模型  │  │对局HUD      │  │命令路由    │ │
│  │粒子特效    │  │结算数据面板  │  │事件总线    │ │
│  │后处理      │  │按钮/输入框   │  │手牌布局计算│ │
│  │Shader特效  │  │战斗日志     │  │回合/阶段   │ │
│  └──────────┘  └─────────────┘  └──────────┘ │
│       ↑              ↑               ↑        │
│       └──────────────┼───────────────┘        │
│                  postMessage                  │
└───────────────────────────────────────────────┘
```

---

## 二、FairyGUI 集成步骤

### 2.1 获取 FairyGUI

```bash
# FairyGUI 官网: https://www.fairygui.com

# 下载两样东西:
# 1. FairyGUI Editor (Windows/Mac) — 可视化 UI 编辑器
#   下载地址: https://www.fairygui.com/product
#
# 2. FairyGUI Unity SDK — 运行时库
#   方式A: Unity Package Manager → Add package from git URL:
#     https://github.com/fairygui/FairyGUI-unity.git
#   方式B: Asset Store 搜索 "FairyGUI" 免费下载

# 兜底方案（网络不可用时）:
# FairyGUI Unity SDK 可以通过 GitHub 直接下载 zip 包
# https://github.com/fairygui/FairyGUI-unity/archive/refs/heads/master.zip
# 解压后把 Assets/Scripts/FairyGUI 整个文件夹拖入 Unity 项目
```

### 2.2 Unity 项目中的 FairyGUI 目录结构

```
Assets/
├── _Project/
│   ├── FairyGUI/                  # FairyGUI 相关
│   │   ├── Packages/              # 导出的 UI 包 (.bytes)
│   │   │   ├── MainMenu.bytes
│   │   │   ├── HeroSelect.bytes
│   │   │   ├── BattleHUD.bytes
│   │   │   └── ResultPanel.bytes
│   │   ├── FairyguiBridge.cs      # FairyGUI ↔ Phaser 桥接
│   │   └── UIPackageLoader.cs     # UI 包加载器
│   └── ...
```

### 2.3 FairyGUI ↔ Phaser 桥接

```csharp
// FairyguiBridge.cs
// 接收 Phaser 命令，驱动 FairyGUI 界面变化

using FairyGUI;

public class FairyguiBridge : MonoBehaviour
{
    // Phaser → FairyGUI 命令处理
    public void ReceiveUICommand(string json)
    {
        var cmd = JsonUtility.FromJson<UICommand>(json);
        switch (cmd.type)
        {
            case "OPEN_PANEL":
                UIPackageLoader.OpenPanel(cmd.panelId);
                break;
            case "CLOSE_PANEL":
                UIPackageLoader.ClosePanel(cmd.panelId);
                break;
            case "UPDATE_HP":
                UpdateHpDisplay(cmd.heroId, cmd.hp, cmd.maxHp);
                break;
            case "UPDATE_HAND_COUNT":
                UpdateHandCount(cmd.playerId, cmd.count);
                break;
            case "UPDATE_PHASE":
                UpdatePhaseDisplay(cmd.phase);
                break;
            case "UPDATE_TURN":
                UpdateTurnDisplay(cmd.turnNumber, cmd.activeHeroId);
                break;
            case "UPDATE_TIMER":
                UpdateTimer(cmd.seconds);
                break;
            case "APPEND_LOG":
                AppendBattleLog(cmd.message);
                break;
            case "SHOW_CARD_TOOLTIP":
                ShowCardTooltip(cmd.cardId, cmd.x, cmd.y);
                break;
            case "HIDE_CARD_TOOLTIP":
                HideCardTooltip();
                break;
            case "PLAY_UI_ANIM":
                PlayUIAnimation(cmd.animId);
                break;
            case "SET_RESULT":
                ShowResultPanel(cmd.win, cmd.stats);
                break;
        }
    }

    // FairyGUI → Phaser 事件上报
    // 当用户点击 FairyGUI 按钮时，通知 Phaser
    private void OnUIEvent(EventContext context)
    {
        var btn = context.sender as GButton;
        var evt = new UIEvent
        {
            type = "UI_CLICK",
            buttonId = btn.name,
            panelId = btn.root.name,
        };
        // 通过 postMessage 发给 Phaser
        var json = JsonUtility.ToJson(evt);
        Application.ExternalCall("receiveFairyGUIEvent", json);
    }
}
```

```typescript
// Phaser 侧: FairyguiBridgeClient.ts
// 封装对 FairyGUI 的命令发送

export class FairyguiBridgeClient {
  private unityBridge: UnityBridge;

  constructor(unityBridge: UnityBridge) {
    this.unityBridge = unityBridge;
    // 监听 FairyGUI 回来的事件
    (window as any).receiveFairyGUIEvent = (json: string) => {
      const evt: UIEvent = JSON.parse(json);
      this.handleUIEvent(evt);
    };
  }

  /** Phaser 调整 UI → FairyGUI 更新渲染 */
  openPanel(panelId: string): void {
    this.unityBridge.sendJson({ target: 'fairygui', type: 'OPEN_PANEL', panelId });
  }

  updateHp(heroId: string, hp: number, maxHp: number): void {
    this.unityBridge.sendJson({ target: 'fairygui', type: 'UPDATE_HP', heroId, hp, maxHp });
  }

  updatePhase(phase: string): void {
    this.unityBridge.sendJson({ target: 'fairygui', type: 'UPDATE_PHASE', phase });
  }

  updateTimer(seconds: number): void {
    this.unityBridge.sendJson({ target: 'fairygui', type: 'UPDATE_TIMER', seconds });
  }

  appendLog(message: string): void {
    this.unityBridge.sendJson({ target: 'fairygui', type: 'APPEND_LOG', message });
  }

  showCardTooltip(cardId: string, x: number, y: number): void {
    this.unityBridge.sendJson({ target: 'fairygui', type: 'SHOW_CARD_TOOLTIP', cardId, x, y });
  }

  showResult(win: boolean, stats: GameStats): void {
    this.unityBridge.sendJson({ target: 'fairygui', type: 'SET_RESULT', win, stats });
  }

  /** FairyGUI 按钮点击 → Phaser 处理 */
  private handleUIEvent(evt: UIEvent): void {
    switch (evt.buttonId) {
      case 'btn_end_turn':     EventBus.emit('player:endTurn'); break;
      case 'btn_confirm':      EventBus.emit('player:confirm', evt.panelId); break;
      case 'btn_cancel':       EventBus.emit('player:cancel', evt.panelId); break;
      case 'btn_play_again':   EventBus.emit('player:playAgain'); break;
      case 'btn_back_lobby':   EventBus.emit('player:backLobby'); break;
      default:                 EventBus.emit('ui:click', evt.buttonId);
    }
  }
}
```

### 2.4 FairyGUI UI 包设计清单

**Claude 需要在 FairyGUI Editor 中创建以下 UI 包：**

| UI 包 | 包含组件 | 关键要素 |
|-------|---------|---------|
| MainMenu | Logo、开始按钮、模式选择按钮、设置按钮、版本号 | Logo 渐入动画、按钮 hover 发光、粒子背景 |
| HeroSelect | 英雄列表(虚拟列表)、确认按钮、倒计时环 | 选中卡牌旋转展示、技能描述弹出、倒计时环动画 |
| BattleHUD | 手牌区容器、装备区容器、阶段指示器、回合指示器、体力条、倒计时条、结束回合按钮、战斗日志 | 实时更新 HP 数字（带飘字动画）、阶段指示器颜色切换、日志自动滚动 |
| ResultPanel | 胜负文字、MVP 展示区、数据统计表格、再来一局/返回大厅按钮 | 胜利金色文字带光晕、数据条目逐行滑入 |
| CardTooltip | 卡牌大图、卡名、费用、属性、技能描述、稀有度边框 | 跟随鼠标/手指、带弹性动画弹出、稀有度色彩 |
| ResponsivePanel | 响应询问弹窗（出闪/无懈/濒死求桃/弃牌选牌） | 可配置选项列表、倒计时环、自动默认选择 |

### 2.5 FairyGUI 动画时间轴关键效果

```
主菜单 Logo: 
  0.0s-0.8s: 从 Y+100 滑入 + Alpha 0→1 + Scale 1.5→1.0
  0.3s-1.2s: 光芒从左扫到右 (遮罩动画)

按钮 hover:
  0.0s-0.2s: Scale 1.0→1.05
  0.0s-0.3s: 边框发光 Alpha 0→1 + 颜色渐变为金色

回合切换:
  0.0s-0.5s: 旧阶段文字 Alpha 1→0 + 上滑退出
  0.3s-0.8s: 新阶段文字从下滑入 + Alpha 0→1
  0.5s-0.8s: 阶段色条颜色过渡

HP 变化:
  0.0s-0.3s: 血条刻度从旧值平滑过渡到新值（缓动）
  0.0s-0.5s: 伤害/治疗数字飘字 (FairyGUI Transition)
  0.3s-0.6s: 血条闪烁（红色伤害 / 绿色治疗）

卡牌悬停:
  0.0s-0.15s: Scale 1.0→1.3
  0.0s-0.25s: Y 上移 40px
  0.0s-0.2s: 阴影从 2px→10px 扩散

弹窗出现:
  0.0s-0.3s: Scale 0.8→1.0 (Back.EaseOut)
  0.0s-0.4s: 背景遮罩 Alpha 0→0.6
```

---

## 三、UI 层职责完全移交

### 3.1 从 Phaser 移交给 FairyGUI 的模块

| 原有模块（Phaser） | 移交给 FairyGUI 后的效果 |
|-------------------|----------------------|
| Phaser Text (卡牌名称/属性) | FairyGUI 富文本 + 字体阴影 + 渐变 |
| Phaser Graphics (HP 血条) | FairyGUI 进度条 + 平滑过渡动画 + 颜色渐变 |
| Phaser Text (阶段指示器) | FairyGUI 组件 + 图标 + 动画切换 |
| Phaser Text (战斗日志) | FairyGUI 虚拟列表 + 自动滚动 + 颜色标签 |
| Phaser Container (手牌区) | FairyGUI 列表布局 + 弧形排列 + 悬停动画 |
| Phaser Graphics (按钮) | FairyGUI 按钮 + 多状态（普通/悬停/按下/禁用）|
| Phaser Container (弹窗) | FairyGUI 弹窗 + 遮罩 + 动画 + 点击外部关闭 |

### 3.2 Phaser 保留的职责（不可移交）

```
Phaser 保留:
  ✅ Socket.io 连接管理（这是 Phaser 唯一不可替代的理由）
  ✅ 游戏状态机（GameEngine.ts 全部逻辑）
  ✅ 命令路由（接收服务器消息 → 分发给 Unity / FairyGUI）
  ✅ 手牌坐标计算（弧形数学 → 把坐标传给 Unity 渲染卡牌位置）
  ✅ 事件总线（所有模块间的解耦通信）
```

---

## 四、交付弹窗验证系统

### 4.1 设计目标

Claude 完成开发任务后，不能只说"完成了"就结束。必须生成一份结构化的验证清单，以弹窗形式呈现给开发者逐项确认，全部勾选通过才算交付。

### 4.2 验证弹窗数据结构

```typescript
// verify.ts — 交付验证弹窗系统

interface VerificationItem {
  id: string;             // 唯一标识
  category: '功能' | '视觉' | '性能' | '交互' | '资源' | '集成';
  title: string;          // 验证项名称
  description: string;    // 如何验证的具体描述
  expected: string;       // 预期结果
  method: 'manual' | 'auto';  // 手动验证 / 自动检测
  autoCheck?: () => Promise<boolean>;  // 自动检测函数
  status: 'pending' | 'pass' | 'fail';
  evidence?: string;      // 失败时的截图路径或错误日志
}

interface VerificationReport {
  taskName: string;
  completedAt: string;
  items: VerificationItem[];
  passCount: number;
  failCount: number;
  blockedCount: number;
  overallStatus: 'pass' | 'fail' | 'blocked';
}
```

### 4.3 Claire 交付时必须输出的验证清单

```typescript
// 对局完整度验证
const GAMEPLAY_CHECKS: VerificationItem[] = [
  {
    id: 'gp-01',
    category: '功能',
    title: '标准回合流程完整',
    description: '开启 1v1 对局，走完判定→摸牌→出牌→弃牌→回合结束',
    expected: '六个阶段依次触发，阶段指示器文字和颜色切换正确',
    method: 'manual',
  },
  {
    id: 'gp-02',
    category: '功能',
    title: '出【杀】→闪避响应',
    description: '对人类玩家使用【杀】，观察是否弹出出闪询问弹窗',
    expected: '弹窗出现，倒计时可见，出闪后不受伤害，不出闪则扣血',
    method: 'manual',
  },
  {
    id: 'gp-03',
    category: '功能',
    title: '【决斗】交互链',
    description: '使用【决斗】指定人类玩家，观察双方轮流出杀',
    expected: '双方弹窗依次出现，直到一方不出杀，扣血方正确',
    method: 'manual',
  },
  {
    id: 'gp-04',
    category: '功能',
    title: '濒死求桃',
    description: '将人类玩家体力打至 0，观察是否弹出求桃弹窗',
    expected: '弹窗出现，可选手牌中的桃，使用后体力恢复至 1',
    method: 'manual',
  },
  {
    id: 'gp-05',
    category: '功能',
    title: '弃牌阶段选牌',
    description: '手牌数大于体力值时进入弃牌阶段',
    expected: '弃牌选牌弹窗出现，可多选卡牌，选够数量后确认按钮变亮',
    method: 'manual',
  },
  {
    id: 'gp-06',
    category: '功能',
    title: '无懈可击响应',
    description: '对 AI 使用锦囊牌时 AI 出无懈，观察是否弹出无懈询问窗',
    expected: '弹窗询问是否出无懈响应，不出则锦囊生效',
    method: 'manual',
  },
  {
    id: 'gp-07',
    category: '功能',
    title: '3v3 模式对局',
    description: '开启 3v3 对局，打到一方全部阵亡',
    expected: '回合顺序正确，队友信息显示正确，阵亡后跳过回合',
    method: 'manual',
  },
  {
    id: 'gp-08',
    category: '功能',
    title: '对局结束结算',
    description: '任意一方达成胜利条件',
    expected: '对局停止，弹出结算界面，显示胜负和统计',
    method: 'manual',
  },
];

// UI 界面验证
const UI_CHECKS: VerificationItem[] = [
  {
    id: 'ui-01',
    category: '视觉',
    title: '主菜单界面',
    description: '启动游戏，观察主菜单',
    expected: 'Logo + 按钮清晰可见，动画流畅，点击有反馈',
    method: 'manual',
  },
  {
    id: 'ui-02',
    category: '视觉',
    title: '选将界面',
    description: '进入选将界面',
    expected: '英雄列表展示，选中高亮，技能描述可读，倒计时正常',
    method: 'manual',
  },
  {
    id: 'ui-03',
    category: '视觉',
    title: '对局 HUD 完整',
    description: '进入对局，观察所有界面元素',
    expected: '手牌/装备/体力/阶段/回合/倒计时/结束按钮全部可见',
    method: 'manual',
  },
  {
    id: 'ui-04',
    category: '视觉',
    title: '装备区展示',
    description: '装备武器/防具/马后观察装备区',
    expected: '装备卡牌在装备区正确显示，可查看详情',
    method: 'manual',
  },
  {
    id: 'ui-05',
    category: '视觉',
    title: '判定区展示',
    description: '被贴乐/兵/闪电后观察判定区',
    expected: '判定牌在判定区可见，判定后消失',
    method: 'manual',
  },
  {
    id: 'ui-06',
    category: '视觉',
    title: '结算界面',
    description: '对局结束后',
    expected: '胜负动画 + 数据统计 + 返回按钮',
    method: 'manual',
  },
];

// 字幕系统验证
const SUBTITLE_CHECKS: VerificationItem[] = [
  {
    id: 'sub-01',
    category: '交互',
    title: '战斗日志滚动',
    description: '连续触发 5 个以上事件，观察日志区域',
    expected: '日志自动滚动到最新，旧日志不遮挡新日志',
    method: 'manual',
  },
  {
    id: 'sub-02',
    category: '交互',
    title: '伤害飘字无重叠',
    description: '同一目标连续受到 3 次伤害',
    expected: '每次伤害数字出现位置不重叠，依次向上偏移',
    method: 'manual',
  },
  {
    id: 'sub-03',
    category: '交互',
    title: '多源字幕不冲突',
    description: '同时触发伤害+技能名显示+阶段切换',
    expected: '三种文字各自出现在不同区域，不互相覆盖',
    method: 'manual',
  },
  {
    id: 'sub-04',
    category: '交互',
    title: '字幕自动清除',
    description: '等待所有动画和字幕播放完毕',
    expected: '2 秒后飘字自动消失，不残留',
    method: 'manual',
  },
];

// 双引擎验证
const DUAL_ENGINE_CHECKS: VerificationItem[] = [
  {
    id: 'de-01',
    category: '集成',
    title: 'Unity 加载成功',
    description: '刷新页面，观察控制台',
    expected: '无 Unity 加载错误，场景背景为 3D 而非纯色',
    method: 'manual',
  },
  {
    id: 'de-02',
    category: '集成',
    title: 'FairyGUI 加载成功',
    description: '进入对局，观察 UI 元素',
    expected: '体力条/阶段指示器/日志等使用 FairyGUI 渲染，非 Phaser Canvas 文字',
    method: 'manual',
  },
  {
    id: 'de-03',
    category: '集成',
    title: '三引擎通信正常',
    description: '进行一回合操作（出牌→攻击→扣血）',
    expected: 'Phaser 逻辑→Unity 特效触发→FairyGUI HP更新 全部同步',
    method: 'manual',
  },
  {
    id: 'de-04',
    category: '集成',
    title: '降级模式可用',
    description: '在低端设备或用 Chrome DevTools 模拟 2G CPU',
    expected: '自动切换到 Low 画质档，游戏仍可运行',
    method: 'manual',
  },
];

// 性能验证
const PERF_CHECKS: VerificationItem[] = [
  {
    id: 'pf-01',
    category: '性能',
    title: 'FPS ≥ 55（桌面端）',
    description: 'Chrome DevTools Performance 面板录制 10 秒对局',
    expected: '平均 FPS ≥ 55，无低于 30 的帧',
    method: 'manual',
  },
  {
    id: 'pf-02',
    category: '性能',
    title: '内存 < 500MB',
    description: 'Chrome DevTools Memory 面板，打完一整局后截图',
    expected: 'JS Heap + Unity Memory 合计 < 500MB',
    method: 'manual',
  },
];

// 全部验证项汇总
const ALL_CHECKS = [
  ...GAMEPLAY_CHECKS,
  ...UI_CHECKS,
  ...SUBTITLE_CHECKS,
  ...DUAL_ENGINE_CHECKS,
  ...PERF_CHECKS,
];
```

### 4.4 验证弹窗 UI（Claire 交付时自动生成）

```html
<!-- verification-modal.html -->
<!-- Claire 交付时生成此 HTML 文件，开发者双击打开即可验证 -->

<div id="verify-app">
  <header>
    <h1>校园杀 v0.2 交付验证</h1>
    <p>任务: Unity双引擎 + FairyGUI UI + 对局修复</p>
    <p>完成时间: 2026-07-27</p>
    <div class="progress-bar">
      <div class="fill" style="width:0%"></div>
    </div>
    <span class="counter">0 / 25 项通过</span>
    <span class="status pending">待验证</span>
  </header>

  <section class="category">
    <h2>对局完整度 (8项)</h2>
    <div class="check-item" data-id="gp-01">
      <input type="checkbox">
      <div class="info">
        <strong>标准回合流程完整</strong>
        <p>验证方法: 开启 1v1 对局，走完判定→摸牌→出牌→弃牌→回合结束</p>
        <p>预期结果: 六个阶段依次触发，阶段指示器文字和颜色切换正确</p>
        <textarea placeholder="未通过时填写具体表现..." hidden></textarea>
      </div>
      <span class="tag">手动验证</span>
    </div>
    <!-- ... 更多验证项 ... -->
  </section>

  <!-- 每个类别一个 section，共 5 个 section -->

  <!-- 未通过原因汇总区 -->
  <section class="failures" hidden>
    <h2>未通过项 (0)</h2>
    <ul id="failure-list"></ul>
  </section>

  <!-- 底部操作 -->
  <footer>
    <button id="btn-save">保存记录</button>
    <button id="btn-skip" class="secondary">跳过验证（风险自负）</button>
    <button id="btn-done" disabled>全部通过 — 确认交付</button>
  </footer>
</div>
```

### 4.5 弹窗交互行为

```typescript
// 验证弹窗交互逻辑

// 1. 勾选 = 该验证项通过
// 2. 取消勾选 = 该验证项未通过，弹出文本框填写具体问题
// 3. 进度条 = 已通过数 / 总数
// 4. 全部通过时:
//    - 进度条 100% + 绿色
//    - "确认交付"按钮亮起
//    - 点击后生成 VerificationReport JSON，触发交付完成回调
// 5. 有未通过项时:
//    - "未通过项"区域展开，列出所有失败项 + 问题描述
//    - "确认交付"按钮灰色禁用
//    - 开发者可以选择"跳过验证"（记录到日志，黄色警告）
// 6. "保存记录": 导出当前验证进度为 JSON 文件到 output/verification-report.json
```

### 4.6 Claire 交付流程强制规则

```
Claude 完成任意开发任务后，必须按以下流程交付：

Step 1: 生成验证清单
  ├── 根据本次修改的文件范围，从全部验证项中筛出相关的
  ├── 新增本次修改特有的验证项（如新功能、新页面）
  └── 生成 verification-modal.html

Step 2: 输出验证弹窗
  ├── 在最终回复中附上 verification-modal.html 的路径
  ├── 告知开发者：双击打开此文件，逐项勾选验证
  └── 明确说明：全部勾选通过 = 正式交付

Step 3: 等待验证结果
  ├── 如果开发者回复"全部通过"：记录 ✅ 交付完成
  ├── 如果开发者回复未通过项列表：立即修复对应问题，修复后重新生成验证弹窗
  └── 如果开发者回复"跳过验证"：记录 ⚠️ 跳过的项，标记风险

禁止的行为:
  ❌ 完成任务后说"做好了，试试看"就直接结束
  ❌ 用自己的判断代替开发者验证（"我应该没问题的"）
  ❌ 验证清单不写具体验证方法（"功能正常"这种不可验证的描述）
```

---

## 五、完整项目文件清单（Claire 交付时必须全部存在）

```
校园杀v0.2/
├── index.html                         # 三层 Canvas 入口（Unity + FairyGUI + Phaser）
├── verification-modal.html            # 交付验证弹窗 ← 每次交付必生成

├── public/
│   ├── Build/                         # Unity WebGL 构建产物
│   │   ├── unity.loader.js
│   │   ├── unity.framework.js.br
│   │   ├── unity.data.br
│   │   └── unity.wasm.br
│   └── FairyGUI/                      # FairyGUI UI 包
│       ├── MainMenu.bytes
│       ├── HeroSelect.bytes
│       ├── BattleHUD.bytes
│       ├── ResultPanel.bytes
│       ├── CardTooltip.bytes
│       └── ResponsivePanel.bytes

├── src/                               # Phaser 3 业务代码
│   ├── main.ts                        # 三引擎启动入口
│   ├── engine/
│   │   ├── UnityBridge.ts             # Unity 通信桥
│   │   ├── FairyguiBridgeClient.ts    # FairyGUI 通信桥
│   │   └── RenderModeDetector.ts      # 渲染模式检测
│   ├── game/
│   │   ├── GameEngine.ts              # 游戏状态机
│   │   └── types.ts                   # 类型定义
│   ├── scenes/
│   │   ├── BootScene.ts               # 启动加载场景
│   │   ├── MenuScene.ts
│   │   ├── HeroSelectScene.ts
│   │   ├── BattleScene.ts             # 对局场景（逻辑层）
│   │   └── ResultScene.ts
│   └── ui/
│       └── SubtitleManager.ts         # 飘字/字幕/日志管理

├── CampusKillUnity/                   # Unity 项目（源码不构建）
│   └── Assets/_Project/
│       ├── Scenes/                    # 5 个 3D 场景
│       ├── Prefabs/                   # 角色/卡牌/特效预制体
│       ├── Scripts/                   # C# 桥接/动画/特效/场景脚本
│       ├── Shaders/                   # 4 个自定义 Shader Graph
│       └── FairyGUI/                  # FairyGUI Unity SDk 集成

└── design/                            # 设计文档
    └── FairyGUI-Project.fairy         # FairyGUI Editor 项目文件
```

---

## 六、输出要求

1. **FairyGUI 集成**：6 个 UI 包必须在 FairyGUI Editor 中设计并导出为 .bytes 文件，Unity 侧可加载渲染
2. **三引擎通信**：Phaser ↔ Unity ↔ FairyGUI 三向 postMessage 链路完整，各一条确认通路
3. **验证弹窗**：`verification-modal.html` 必须包含本次任务相关的全部验证项（约 25 项），每项有具体的验证方法和预期结果
4. **交付准则**：Claude 在完成开发后禁止直接结束，必须先输出验证弹窗路径，等待开发者勾选确认
5. **代码质量**：TypeScript + C# 类型完备，零 any / 零 dynamic
6. **可运行性**：从 `index.html` 启动，主菜单 → 选将 → 对局 → 结算完整走通，UI 由 FairyGUI 渲染
*（内容由AI生成，仅供参考）*
