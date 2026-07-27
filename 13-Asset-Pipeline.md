---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_708c9e9c896311f1a68c525400826444
    ReservedCode1: v1Aa+OXpn93oieCPS/fOJwVPHr3LLNcz38+9Fi6Jj0815Hdst08zhDL7bgaBWgtL0WGPqO+T61LHY2PHQrHf2UYXswtwCo5pJnW3FfOP2rWpIUz0CLmSZwBWFnxmIdEesxvewPaQIxtTrG5NOlu/T8NYYr78pGVRtUNqEKNe1wD17Br4g70kK8X9HFI=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_708c9e9c896311f1a68c525400826444
    ReservedCode2: v1Aa+OXpn93oieCPS/fOJwVPHr3LLNcz38+9Fi6Jj0815Hdst08zhDL7bgaBWgtL0WGPqO+T61LHY2PHQrHf2UYXswtwCo5pJnW3FfOP2rWpIUz0CLmSZwBWFnxmIdEesxvewPaQIxtTrG5NOlu/T8NYYr78pGVRtUNqEKNe1wD17Br4g70kK8X9HFI=
---

# 校园杀 v0.2 - 核心玩法深化提示词

## 项目背景

你是 Claude，正在开发一款校园题材的回合制卡牌对战游戏「校园杀」。项目已通过 Unity 2022.3.62f3c1 完成双引擎（Canvas 2D + FairyGUI）搭建，WebGL (17MB) 和 Android APK (22MB) 均已构建成功。

项目根路径：`C:\CampusKillUnity`

## 任务目标

深化核心玩法系统，将当前占位脚本替换为可运行的完整游戏逻辑。

## 强制约束

1. **零外部依赖**：所有资源（图标、音效、字体）通过代码程序化生成或从互联网公开开源仓库获取（明确标注 URL），严禁引用需要付费/登录的资源。
2. **可独立验证**：每完成一个子系统，必须通过 Unity Editor Play Mode 自测确认无报错。
3. **文件清单**：每个子系统完成后，输出修改/新增的文件清单（路径 + 行数）。
4. **编码规范**：C# 代码使用 UTF-8，遵循 Unity 命名规范（PascalCase 类/方法，camelCase 变量）。

## 子系统一：回合制战斗引擎

### 文件路径
- `Assets/_Project/Scripts/Battle/TurnManager.cs`（替换现有占位）
- `Assets/_Project/Scripts/Battle/BattleStateMachine.cs`（替换现有占位）
- `Assets/_Project/Scripts/Battle/BattlePhases.cs`（新建枚举）

### 功能要求
1. **回合流转**：实现 `RoundStart → DrawPhase → MainPhase → BattlePhase → EndPhase → RoundEnd` 完整循环。
2. **先后手判定**：双方各掷一枚虚拟骰子（1-6），点数高者先手；平局重掷。
3. **能量系统**：每回合自动回复 1 点能量（上限 10 点），出牌消耗能量（普通牌 1-3 点，大招 5-7 点）。
4. **抽牌机制**：每回合从牌堆抽 2 张，手牌上限 10 张，超出时自选弃牌。
5. **胜负判定**：一方 HP ≤ 0 时触发 GameOver，展示结算面板。

### 验证标准
- 在 Unity Editor 中运行 Battle 场景，控制台输出完整回合日志，无 NullReferenceException。

---

## 子系统二：卡牌系统

### 文件路径
- `Assets/_Project/Scripts/Cards/CardData.cs`
- `Assets/_Project/Scripts/Cards/CardManager.cs`（替换现有占位）
- `Assets/_Project/Scripts/Cards/CardDeck.cs`
- `Assets/_Project/Scripts/Cards/SkillEffect.cs`

### 功能要求
1. **卡牌数据结构**：`CardData` ScriptableObject 包含字段：卡牌ID(int)、名称(string)、类型枚举(Attack/Defense/Skill/Curse)、费用(int)、描述(string)、效果ID列表(List<int>)。
2. **预置牌组**：开局自动创建 30 张基础牌组（10 攻击 + 8 防御 + 8 技能 + 4 诅咒），通过代码 ScriptableObject 生成。
3. **卡牌效果系统**：实现至少 6 种效果——直接伤害、护盾、抽牌、回血、对方弃牌、伤害翻倍。
4. **战斗内卡牌操作**：点击手牌 → 高亮可用目标 → 确认出牌 → 播放效果 → 卡牌进弃牌堆。
5. **牌堆管理**：抽牌堆（DrawPile）、手牌（Hand）、弃牌堆（DiscardPile）、移除区（ExileZone）四区流转。

### 验证标准
- 创建 30 张牌的测试场景，在 Editor 中模拟抽牌→出牌→效果结算→弃牌完整流程。

---

## 子系统三：AI 对手

### 文件路径
- `Assets/_Project/Scripts/AI/AIPlayer.cs`
- `Assets/_Project/Scripts/AI/AIDecisionTree.cs`
- `Assets/_Project/Scripts/AI/AIStrategyProfiles.cs`

### 功能要求
1. **决策树 AI**：基于手牌费用 × 效果收益的贪心评估，选择当前回合最优出牌组合。
2. **策略画像**：内置 3 种 AI 风格——激进型（优先攻击）、保守型（优先防御/回血）、均衡型（动态权重）。
3. **难度分级**：简单（随机出牌）、普通（贪心单牌）、困难（贪心组合最优解 3 步前瞻）。
4. **思考延迟**：AI 出牌添加 0.5-1.5 秒随机延迟，模拟真人思考。

### 验证标准
- AI vs AI 自动对战 100 局，输出胜率统计，三种难度胜率有显著差异。

---

## 子系统四：UI 战斗 HUD

### 文件路径
- 通过 FairyGUI Editor 创建 `BattleHUD` 包（已有 .bytes）
- `Assets/_Project/Scripts/UI/BattleHUDController.cs`
- `Assets/_Project/Scripts/UI/CardHandRenderer.cs`

### 功能要求
1. **HUD 布局**：顶部对手信息栏（头像、HP 条、能量）、底部己方信息栏、中央战场区域、右侧手牌区。
2. **手牌渲染**：卡牌在 FairyGUI 中渲染为可拖拽/点击的组件，包含卡名、费用、类型图标、描述文本。
3. **动画反馈**：出牌时卡牌从手牌区飞向目标 → 命中特效闪烁 → 伤害数字飘字。
4. **状态提示**：回合切换时全屏文字提示"你的回合"/"对手回合"，持续 1.5 秒淡出。
5. **程序化纹理**：所有图标/数字/特效使用 Canvas 2D Texture2D.SetPixels 程序化生成，P0 无需外部图片。

### 验证标准
- 在 FairyGUI Editor 预览 BattleHUD 包，所有组件正确渲染，无缺图/错位。

---

## 交付验证

完成所有子系统后：

1. 在 `C:\CampusKillUnity\Builds\` 目录生成验证清单 `verification-v0.2.json`，格式如下：
```json
{
  "version": "0.2",
  "subsystems": [
    {"name": "回合制战斗引擎", "status": "pass/fail", "test_count": 0},
    {"name": "卡牌系统", "status": "pass/fail", "test_count": 0},
    {"name": "AI对手", "status": "pass/fail", "winrate_stats": {}},
    {"name": "UI战斗HUD", "status": "pass/fail", "missing_assets": []}
  ],
  "build_webgl_mb": 0,
  "build_apk_mb": 0,
  "total_errors": 0,
  "total_warnings": 0
}
```

2. 运行 `BuildScript.BuildAll` 确保 WebGL + Android 双端构建通过。

3. 生成 `C:\CampusKillUnity\Builds\verification-modal.html`，包含逐项勾选验证弹窗，所有项勾选通过后显示"校园杀 v0.2 交付确认"按钮。
*（内容由AI生成，仅供参考）*
