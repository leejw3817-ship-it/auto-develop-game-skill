---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_69bf0a9e88ea11f18108525400287e28
    ReservedCode1: 9LaVFw2V6g8dLXNBIOwi/UzZESVqmbeMlF2Q7cP3TTTpkeB6YEbelq36U+dfi/6gTp674zEdFtR/ydgHev5jgzE8ks/aLq+IGOzYukR/Nzbi6nz+ve/rV/pRWgDYjulA9jvjuwjvPhCR/tW5eDjCaMFzMMwQzb/mfjDLpwnnL/0xcGzLI7vbb9TWtQE=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_69bf0a9e88ea11f18108525400287e28
    ReservedCode2: 9LaVFw2V6g8dLXNBIOwi/UzZESVqmbeMlF2Q7cP3TTTpkeB6YEbelq36U+dfi/6gTp674zEdFtR/ydgHev5jgzE8ks/aLq+IGOzYukR/Nzbi6nz+ve/rV/pRWgDYjulA9jvjuwjvPhCR/tW5eDjCaMFzMMwQzb/mfjDLpwnnL/0xcGzLI7vbb9TWtQE=
---

# 校园杀 v0.1 → v0.2 三维度修复提示词

> **目标受众**：Claude Code（开发者 AI 代理）
> **执行范围**：前端 Phaser 3 TypeScript (game/) + 后端 Node.js/TypeScript (game/server/)
> **基准代码路径**：`C:\Users\31184\Desktop\校园杀v0.1\book-to-skill-1.2.0\game\`

---

## 维度一：对局完整度修复

### 一、现状诊断

#### 1.1 回合生命周期断裂点

**文件**：`src/engine/GameEngine.ts`

| 阶段 | 状态 | 代码证据 |
|------|------|----------|
| 回合开始 (PREPARE) | 部分实现 | L167: `this.state.phase = TurnPhase.PREPARE` + `triggerEvent(ON_TURN_START)`，但未重置 `hasUsedSha` / `shaUnlimited` 等标记位 |
| 判定阶段 (JUDGE) | **严重残缺** | L205: `resolveJudgeZone()` 仅处理 `处罚` 一种判定牌，其他延时锦囊（`闪电` 等）完全未实现 |
| 摸牌阶段 (DRAW) | 基本正常 | L208-215: 硬编码摸 2 牌，被动技能特殊处理已内联，但 `裁判员`/`兵王` 等后续角色无扩展点 |
| 出牌阶段 (PLAY) | **部分残缺** | L219-233: 人机分离正确，但 `executePlayCard` 无响应链（无懈可击不存在），人机交互后强制自动结束回合，玩家无法手动跳过 |
| 弃牌阶段 (DISCARD) | **严重残缺** | L536-565: `discardPhase()` 对玩家自动随机弃牌，完全没有选牌 UI 交互（AI 走 `AIController.chooseDiscard`，人类玩家走 `idx=0` 直接删除） |
| 回合结束 (END) | 基本正常 | L577-600: 触发 `ON_TURN_END` 事件 + `resetTurnFlags` + 臭水炸弹结算，但缺少 `夏侯惇` 类刚烈结算 |

**关键断裂点详情**：

**(a) 人类玩家自动闪/自动杀 — 响应系统完全缺失（L653-658）**
```typescript
// respondShan() @ L653-658 — 当前行为：
// 人类玩家: 自动找手牌中第一张闪打出，完全没有询问界面
const idx = player.character.hand.indexOf(shan);
player.character.hand.splice(idx, 1);
this.cardManager.discard(shan);
return true;
```
同理 `respondSha()` (L666-670) 也是自动出杀。

**(b) 弃牌阶段人类玩家无交互（L548-555）**
```typescript
// discardPhase() — 人类玩家不经过 AI，直接 idx=0 删牌
const idx = player.isAI ? AIController.chooseDiscard(player) : 0;
```

**(c) 无懈可击完全不存在**
整个 `GameEngine.ts`（783行）和 `CardManager.ts`（77行）中，`无懈可击` 仅在 `executeTacticCard` 的 `FAKE_NOTE` 分支打印"可在锦囊生效前使用抵消效果"（L434），但无任何实现代码。响应链机制缺失。

**(d) 延时锦囊判定仅处理处分**
`resolveJudgeZone()` (L527-535) 仅检查 `TacticType.PUNISH`，其他如 `闪电`、`兵粮寸断` 等锦囊不存在。

#### 1.2 3v3 模式完全缺失

**文件**：`src/core/types.ts`

仅有 2 种模式枚举：
```typescript
export enum GameMode {
  DUEL_1V1 = 'duel_1v1',
  IDENTITY_4P = 'identity_4p',
}
```
无 3v3 模式。服务端 `SocketServer.ts` 的 `match:start` 处理（L79）也仅有 `4p` 和默认 `1v1`。

#### 1.3 胜负结算流程不完整

**文件**：`src/engine/DamageSystem.ts` L216-235

`checkGameEnd()` 仅判断"只剩一个阵营存活"即结束，但：
- 4P 身份模式没有主公击杀/反贼全灭等差异化结算
- 平局（同归于尽）未处理
- 没有回合上限（防止无限对局）
- 死亡触发（坠机/亡魂等）后未二次检查游戏是否结束

#### 1.4 托管/断线处理缺失

- **前端单机模式**：完全没有 timeout 机制，玩家可无限等待
- **服务端**：`SocketServer.ts` L45-55 有 `ReconnectManager`，但 `disconnect` 事件（L211-222）仅广播 `room:playerLeft`，未将玩家设为托管状态由 AI 接管
- **前端 GameEngine**：无 `setPlayerAI(playerIndex, isAI)` 接口，无法运行时切换人机状态

#### 1.5 装备效果与技能触发不完整

| 装备/技能 | 问题 | 代码位置 |
|-----------|------|----------|
| 钰鞋路径伤害 | 路径上玩家无机会出闪 | `DamageSystem.ts` L113-118 |
| 命运之矛 bleed | 仅在 dealDamage 中打印日志，startTurn 中正确处理 | 正确，无问题 |
| 反伤/暴击/背刺等 | 核心逻辑在 `SkillResolver.ts` 中，但受限于 triggerEvent 触发链；部分技能对 DATA_HEAL/ON_HEAL 无响应 | `SkillResolver.ts` shouldTrigger() L113-124 |
| 手串自救 | 仅在 enterDying 中检测一次，没有"是否使用"的决策询问 | `DamageSystem.ts` L148-153 |

---

### 二、目标状态

1. 完整的回合六阶段，每阶段有明确的状态转换和 UI 反馈
2. 响应询问系统（闪/无懈可击/决斗出杀/濒死求桃）完整实现，人类玩家可通过 UI 选择
3. 弃牌阶段人类玩家可手动选牌
4. 3v3 模式完整可用（3v3 身份模式）
5. 托管/断线处理：闲置 60 秒自动切换 AI 托管
6. 延时锦囊判定区完整（闪电+兵粮寸断+乐不思蜀等效）

---

### 三、具体修改方案

#### 修改 1：实现响应询问系统

**涉及文件**：`src/engine/GameEngine.ts`、`src/engine/types.ts`、`src/scenes/BattleScene.ts`

**Step 1 — 扩展 GameAction 类型 (`src/engine/types.ts`)**

在现有 `ActionType` 枚举中新增：
```typescript
export enum ActionType {
  PLAY_CARD = 'PLAY_CARD',
  USE_SKILL = 'USE_SKILL',
  END_TURN = 'END_TURN',
  // 新增响应类型
  RESPOND_SHAN = 'RESPOND_SHAN',
  RESPOND_SHA = 'RESPOND_SHA',
  RESPOND_WUXIE = 'RESPOND_WUXIE',
  RESPOND_TAO = 'RESPOND_TAO',
  RESPOND_DISCARD = 'RESPOND_DISCARD',
  RESPOND_CANCEL = 'RESPOND_CANCEL',  // 不响应
}
```

**Step 2 — 修改 respondShan/respondSha/respondWuXie (`src/engine/GameEngine.ts`)**

将 `respondShan()` (L648-659) 改造为异步等待模式：

```typescript
private respondShan(player: PlayerRuntimeState): boolean {
  const shan = player.character.hand.find(c => c.basicType === BasicType.SHAN);
  if (!shan) return false;

  if (player.isAI) {
    const response = AIController.decideResponse(player, 'shan', this.state);
    if (response) {
      const idx = player.character.hand.indexOf(response);
      if (idx >= 0) {
        player.character.hand.splice(idx, 1);
        this.cardManager.discard(response);
      }
      return true;
    }
    return false;
  }

  // 人类玩家：发询问
  this.pendingResponse = {
    playerIndex: player.index,
    responseType: 'SHAN',
    callback: (accepted: boolean, card?: RuntimeCard) => {
      if (accepted && card) {
        const idx = player.character.hand.indexOf(card);
        if (idx >= 0) {
          player.character.hand.splice(idx, 1);
          this.cardManager.discard(card);
        }
        this.pendingResponse!.result = true;
      } else {
        this.pendingResponse!.result = false;
      }
    }
  };
  this.callbacks.onActionRequired(player.index, {
    type: ActionType.RESPOND_SHAN,
    playerIndex: player.index,
  });
  // 同步等待（实际架构需改造为 async/await 或事件驱动）
  return this.pendingResponse?.result ?? false;
}
```

> **注意**：上面的回调模式在同步函数中不可行。实际需将整个出牌阶段改为 async/await 或状态机+标志位模式。建议将 `executeBasicCard` / `executeTacticCard` 中所有涉及 humans response 的路径改为 `async`，并在 BattleScene 中实现对应的交互等待。

**Step 3 — 在 BattleScene 中添加响应询问 UI**

在 `src/scenes/BattleScene.ts` 中添加：

```typescript
// 响应询问覆盖层
private responseOverlay: Phaser.GameObjects.Container | null = null;

private showResponsePrompt(responseType: string, hand: RuntimeCard[]): void {
  this.responseOverlay = this.add.container(0, 0).setDepth(THEME.depth.banner - 1);
  
  // 半透明遮罩
  const mask = this.add.rectangle(W/2, H/2, W, H, 0x000000, 0.4)
    .setInteractive(); // 阻止穿透点击
  
  // 提示文本
  const label = this.add.text(W/2, H*0.25, 
    responseType === 'SHAN' ? '是否使用【闪】？' : 
    responseType === 'TAO' ? '是否使用【桃】救援？' :
    responseType === 'WUXIE' ? '是否使用【无懈可击】？' : '请选择',
    { fontSize: '32px', color: '#ffd700', stroke: '#000', strokeThickness: 4 }
  ).setOrigin(0.5);
  
  // 可用的响应牌
  const usableCards = hand.filter(c => {
    if (responseType === 'SHAN') return c.basicType === BasicType.SHAN;
    if (responseType === 'TAO') return c.basicType === BasicType.TAO;
    return false;
  });
  
  // 渲染可用手牌供选择 + "取消"按钮
  // ... (省略具体渲染代码，参考现有 showTargetOverlay 模式)
  
  this.responseOverlay.add([mask, label, /* cards */, /* cancelBtn */]);
}
```

---

#### 修改 2：弃牌阶段人类玩家交互

**文件**：`src/engine/GameEngine.ts` (L536-565)

**当前代码**：
```typescript
private discardPhase(player: PlayerRuntimeState): void {
  // ... handLimit 计算 ...
  const over = player.character.hand.length - handLimit;
  if (over > 0) {
    for (let i = 0; i < over; i++) {
      if (player.isAI) {
        const idx = AIController.chooseDiscard(player);
        // ...
      }
    }
  }
}
```

**修改为**：
```typescript
private async discardPhase(player: PlayerRuntimeState): Promise<void> {
  // ... handLimit 计算逻辑不变 ...
  const over = player.character.hand.length - handLimit;
  if (over <= 0) return;

  this.state.phase = TurnPhase.DISCARD;

  if (player.isAI) {
    for (let i = 0; i < over; i++) {
      const idx = AIController.chooseDiscard(player);
      if (idx >= 0) {
        const [c] = player.character.hand.splice(idx, 1);
        this.cardManager.discard(c);
      }
    }
    return;
  }

  // 人类玩家：发弃牌询问
  this.log(`${player.character.name} 需弃置 ${over} 张牌`);
  return new Promise((resolve) => {
    this.callbacks.onActionRequired(player.index, {
      type: ActionType.RESPOND_DISCARD,
      playerIndex: player.index,
      data: { discardCount: over },
    });
    this.pendingDiscardResolve = resolve;
  });
}

// 在类中添加
private pendingDiscardResolve: (() => void) | null = null;

// 供 UI 调用的完成方法是
public confirmDiscard(cards: RuntimeCard[]): void {
  const player = this.state.players[this.state.currentPlayerIndex];
  for (const c of cards) {
    const idx = player.character.hand.findIndex(hc => hc.instanceId === c.instanceId);
    if (idx >= 0) {
      player.character.hand.splice(idx, 1);
      this.cardManager.discard(c);
    }
  }
  this.pendingDiscardResolve?.();
  this.pendingDiscardResolve = null;
  this.emitState();
}
```

**对应 BattleScene.ts UI**：弃牌阶段显示手牌，允许玩家点击选中（高亮），选中 `discardCount` 张后出现"确认弃置"按钮。

---

#### 修改 3：无懈可击响应链

**文件**：`src/engine/GameEngine.ts` (L380-435 executeTacticCard)

在 `executeTacticCard` 开头插入响应链逻辑：
```typescript
private executeTacticCard(player: PlayerRuntimeState, card: RuntimeCard, targets: PlayerIndex[]): void {
  this.log(`${player.character.name} 使用了【${card.name}】！`);

  // ─── 无懈可击响应窗口 ───
  for (const p of this.state.players) {
    if (!p.alive || p.index === player.index) continue;
    const wuxie = p.character.hand.find(
      c => c.tacticType === TacticType.FAKE_NOTE
    );
    if (wuxie) {
      if (p.isAI) {
        if (AIController.decideResponse(p, 'wuxie', this.state)) {
          const idx = p.character.hand.indexOf(wuxie);
          p.character.hand.splice(idx, 1);
          this.cardManager.discard(wuxie);
          this.log(`${p.character.name} 使用【无懈可击】抵消！`);
          this.cardManager.discard(card);
          return; // 锦囊被抵消
        }
      } else {
        // 询问人类玩家 — 需要异步处理
        // 此处先简化：预留接口位置
        this.log('【无懈可击】询问系统待实现');
      }
    }
  }

  // 原有锦囊效果执行...
  // (switch case 代码不变)
}
```

---

#### 修改 4：添加 3v3 模式

**文件**：`src/core/types.ts` + `src/engine/GameEngine.ts` + `src/scenes/HeroSelectScene.ts`

**(a) 类型定义 — `src/core/types.ts`**：
```typescript
export enum GameMode {
  DUEL_1V1 = 'duel_1v1',
  IDENTITY_4P = 'identity_4p',
  TEAM_3V3 = 'team_3v3',  // 新增
}
```

**(b) 对局初始化 — `src/engine/GameEngine.ts` `initGame()`**：
3v3 模式下 `playerCount=6`，分两支队伍（暖色/冷色），座次交替排列。胜负条件为一方三名角色全部阵亡。

**(c) 选将界面 — `src/scenes/HeroSelectScene.ts`**：
添加 3v3 模式入口，支持队伍选将（通常为暖色方先选 1 名→冷色方选 2 名→暖色方选 2 名→冷色方选 2 名→暖色方选 2 名→冷色方选 1 名）。

---

#### 修改 5：托管/断线处理

**文件**：`src/engine/GameEngine.ts` + `src/scenes/BattleScene.ts`

```typescript
// GameEngine 新增
private turnTimer: number | null = null;
private static TURN_TIMEOUT = 60_000; // 60 秒

public setPlayerAI(index: PlayerIndex, isAI: boolean): void {
  this.state.players[index].isAI = isAI;
  const name = this.state.players[index].character.name;
  this.log(`${name} ${isAI ? '进入托管' : '取消托管'}`);
}

private startTurnTimer(): void {
  this.clearTurnTimer();
  const player = this.state.players[this.state.currentPlayerIndex];
  if (player.isAI) return;
  this.turnTimer = window.setTimeout(() => {
    this.log(`${player.character.name} 超时，自动托管`);
    this.setPlayerAI(player.index, true);
    this.runAITurn(player);
  }, GameEngine.TURN_TIMEOUT) as unknown as number;
}
```

服务端 `SocketServer.ts` 在 disconnect 时：
```typescript
// L211-222 之间插入
client.isDisconnected = true;
this.broadcastRoom(room.id, 'game:playerAFK', { userId: client.userId });
// RoomManager 内部切换为 AI 托管
room.setPlayerAFK(client.userId, true);
```

---

## 维度二：游戏界面完整度修复

### 一、现状诊断

**文件**：`src/scenes/BattleScene.ts`、`src/scenes/MenuScene.ts`、`src/scenes/HeroSelectScene.ts`

#### 2.1 已有界面清单

| 界面/元素 | 文件:行号 | 状态 |
|-----------|-----------|------|
| 主菜单 | `MenuScene.ts:1-180` | 完整 |
| 模式选择 | `MenuScene.ts:76-128` | 单人难度选择有，联网按钮空壳 |
| 选将界面 | `HeroSelectScene.ts` | 存在 |
| 对局主界面 | `BattleScene.ts` | 基础框架存在 |
| 手牌区 | `BattleScene.drawHand()` | 存在 |
| 装备区 | `BattleScene.drawSeats()` 仅装备徽章 | **仅图标不展示详情** |
| 判定区 | 无 | **完全缺失** |
| 其他玩家信息 | `BattleScene.drawSeats()` | 头像/HP/手牌数/装备徽章 |
| 体力/体力上限 | HP 条在 drawSeats | 存在 |
| 回合指示器 | `drawHUD()` 中 turnLabel | 仅文本 |
| 阶段指示器 | `drawHUD()` 中 phaseLabel | 仅文本 |
| 操作提示 | 无 | **完全缺失** |
| 回合时间 | 无 | **完全缺失** |

#### 2.2 完全缺失的交互界面

| 缺失界面 | 影响 |
|----------|------|
| **选目标界面** | `showTargetOverlay` 仅对杀和部分锦囊生效，提示不清晰 |
| **响应询问（出闪）** | 当前自动处理，无 UI |
| **响应询问（无懈）** | 完全不支持 |
| **濒死求桃界面** | 自动搜索桃自救/他救，无玩家选择权 |
| **弃牌阶段选牌** | 人类玩家自动删牌 |
| **判定区展示** | 玩家不知道自己的判定区有什么 |
| **装备区详细展示** | 不知道装备了什么具体装备 |
| **回合计时器** | 无 |
| **操作提示区** | 玩家不知道当前可以做什么 |

#### 2.3 BattleScene 渲染结构

**文件**：`src/scenes/BattleScene.ts`
容器层级（自底向上）：
```
bgLayer (depth: 基于 THEME.depth.background)
seatLayer (depth: 5)
handLayer (depth: 10)
hudLayer  (depth: ~6-7)
fxLayer   (depth: 50)
```

**问题**：hudLayer 和 fxLayer 之间缺少一个专门的 `interactionLayer`（深度 30），用于响应询问/选目标/弃牌选牌等交互覆盖层。

---

### 二、目标状态

1. 完整的对局 HUD：回合指示器 + 阶段指示器 + 计时器 + 操作提示区
2. 装备区/判定区可视化展示
3. 所有交互询问有独立 UI 覆盖层
4. 响应式布局，支持不同分辨率

---

### 三、具体修改方案

#### 修改 1：装备区详细展示

**文件**：`src/scenes/BattleScene.ts` `drawSeats()` 函数

在每个玩家座位区域添加装备区渲染（当前仅在第 4 层 depth 的 seatLayer 中绘制头像/HP）：

```typescript
// 在 drawSeats() 中，每个玩家座位后追加
private drawEquipmentZone(
  player: PlayerRuntimeState, 
  cx: number, cy: number
): void {
  const zoneX = cx + 180; // 座位右侧偏移
  const zoneY = cy - 30;
  const slots: { key: string; label: string }[] = [
    { key: 'weapon', label: '武' },
    { key: 'armor', label: '甲' },
    { key: 'plusHorse', label: '+1' },
    { key: 'minusHorse', label: '-1' },
    { key: 'accessory', label: '饰' },
  ];

  slots.forEach((slot, i) => {
    const sx = zoneX + i * 55;
    const eq = player.character.equipment[slot.key];
    
    if (eq) {
      // 绘制装备卡牌缩略图
      this.drawMiniCard(eq, sx, zoneY);
    } else {
      // 绘制空槽位
      const g = this.add.graphics();
      g.lineStyle(1, 0x555555, 0.5);
      g.strokeRoundedRect(sx - 20, zoneY - 28, 40, 56, 4);
      const label = this.add.text(sx, zoneY, slot.label, {
        fontSize: '10px', color: '#555555'
      }).setOrigin(0.5);
      this.seatElements.push(g, label);
    }
  });
}
```

#### 修改 2：判定区展示

**文件**：`src/scenes/BattleScene.ts`

```typescript
private drawJudgeZone(player: PlayerRuntimeState, cx: number, cy: number): void {
  if (player.character.judgeZone.length === 0) return;

  const zoneX = cx - 180;
  const zoneY = cy - 30;

  // 判定区标题
  const label = this.add.text(zoneX, zoneY - 35, '判定区', {
    fontSize: '11px', color: '#ff6600'
  }).setOrigin(0.5);
  this.seatElements.push(label);

  player.character.judgeZone.forEach((card, i) => {
    const sx = zoneX + i * 50;
    this.drawMiniCard(card, sx, zoneY, 0xff6600); // 橙色边框
  });
}
```

#### 修改 3：完整 HUD 增强

**文件**：`src/scenes/BattleScene.ts` `drawHUD()` 函数

```typescript
private drawHUD(): void {
  // ... 现有回合数和阶段文本保持 ...

  // ─── 新增：阶段指示器动画 ───
  this.drawPhaseIndicator();

  // ─── 新增：回合倒计时 ───
  this.drawTurnTimer();

  // ─── 新增：操作提示区 ───
  this.drawActionHint();

  // ─── 新增：手牌数量指示 ───
  this.drawHandCount();
}

private drawPhaseIndicator(): void {
  const phases = ['PREPARE', 'JUDGE', 'DRAW', 'PLAY', 'DISCARD', 'END'];
  const phaseNames = ['准备', '判定', '摸牌', '出牌', '弃牌', '结束'];
  const currentIdx = phases.indexOf(this.currentPhase);
  
  const startX = 100;
  const y = 55;

  phases.forEach((p, i) => {
    const x = startX + i * 100;
    const isCurrent = i === currentIdx;
    const isPast = i < currentIdx;

    const dot = this.add.circle(x, y, isCurrent ? 8 : 5,
      isCurrent ? 0xffd700 : isPast ? 0x448844 : 0x444466
    );
    
    const label = this.add.text(x, y + 18, phaseNames[i], {
      fontSize: '10px',
      color: isCurrent ? '#ffd700' : '#888888'
    }).setOrigin(0.5);

    this.hudElements.push(dot, label);
  });
}

private drawActionHint(): void {
  // 右下角操作提示区
  const hintX = W - 200;
  const hintY = H - 170;

  const hintText = this.getActionHintText();
  const hint = this.add.text(hintX, hintY, hintText, {
    fontSize: '14px', color: '#cccccc',
    backgroundColor: '#00000044',
    padding: { x: 12, y: 8 },
    align: 'left',
  }).setOrigin(0.5);
  this.hudElements.push(hint);
}

private getActionHintText(): string {
  if (this.currentPhase !== 'PLAY') return '';
  if (this.currentPlayerIndex !== 0) return '等待对手行动...';
  return '点击手牌出牌 | 点击技能使用 | 点击"结束回合"';
}
```

#### 修改 4：交互覆盖层框架

**文件**：`src/scenes/BattleScene.ts`

新增统一的交互覆盖层管理：

```typescript
// 类属性
private interactionOverlay: Phaser.GameObjects.Container | null = null;

enum OverlayType {
  RESPONSE_SHAN = 'RESPONSE_SHAN',
  RESPONSE_TAO = 'RESPONSE_TAO',
  DISCARD_SELECT = 'DISCARD_SELECT',
  TARGET_SELECT = 'TARGET_SELECT',
  DEATH_RESCUE = 'DEATH_RESCUE',
}

private showInteractionOverlay(type: OverlayType, data?: any): void {
  this.clearInteractionOverlay();

  this.interactionOverlay = this.add.container(0, 0)
    .setDepth(THEME.depth.uiOverlay + 5);

  // 半透明遮罩
  const mask = this.add.rectangle(W/2, H/2, W, H, 0x000000, 0.35)
    .setInteractive();

  this.interactionOverlay.add(mask);

  switch (type) {
    case OverlayType.RESPONSE_SHAN:
      this.buildShanPrompt(data);
      break;
    case OverlayType.RESPONSE_TAO:
      this.buildTaoPrompt(data);
      break;
    case OverlayType.DISCARD_SELECT:
      this.buildDiscardSelect(data);
      break;
    case OverlayType.TARGET_SELECT:
      this.buildTargetSelect(data);
      break;
    case OverlayType.DEATH_RESCUE:
      this.buildDeathRescue(data);
      break;
  }
}

private clearInteractionOverlay(): void {
  if (this.interactionOverlay) {
    this.interactionOverlay.destroy(true);
    this.interactionOverlay = null;
  }
}
```

#### 修改 5：濒死求桃界面

```typescript
private buildDeathRescue(data: { dyingIndex: PlayerIndex }): void {
  const dyingPlayer = this.players[data.dyingIndex];
  // 提示：xxx 濒死，是否使用桃救援？
  // 渲染可用桃的玩家手牌 + 跳过按钮
  // 如果所有玩家都跳过 → 角色死亡
}
```

---

## 维度三：字幕叠加冲突修复

### 一、现状诊断

#### 3.1 字幕/日志系统现状

**核心代码路径**：

| 组件 | 文件:行号 | 功能 |
|------|-----------|------|
| 操作日志 | `BattleScene.drawLog()` | 显示最近 4 条 actionLog，Y=H/2+32 |
| 回合横幅 | `ParticleSystem.turnBanner()` | 回合切换横幅，y 从 -40 滑入到 60，1500ms 后消失 |
| 出牌特效 | `ParticleSystem.cardPlayEffect()` | 卡牌召唤粒子 + 扩散光环 |
| 伤害飘字 | `ParticleSystem.damageNumber()` | -N 飘字，depth=depth.damageNumbers(100) |
| 治疗飘字 | `ParticleSystem.healNumber()` | +N 飘字，depth=depth.damageNumbers(100) |
| 状态文本 | `ParticleSystem.statusText()` | 技能触发/状态文字 |
| 技能光效 | `ParticleSystem.skillGlow()` | 魔法圈粒子 + 屏幕震动 |
| 死亡爆炸 | `ParticleSystem.deathExplosion()` | 死亡碎片 + 屏幕震动 + 红色闪烁 |

#### 3.2 字幕冲突具体问题

**问题 (a)：drawLog 与 turnBanner 位置重叠（ParticleSystem.ts:170-176 + BattleScene.ts）**

- `drawLog()` 渲染在 Y = H/2 + 32（屏幕中央偏下）
- `turnBanner()` 动画终点在 Y = 60（屏幕顶部附近）
- 两者 Y 方向不重叠，**但 drawLog 的 depth 在座位层 (5-7) 附近，而 turnBanner 的 depth 是 banner(200)**，实际不会产生 Z 冲突
- **真正问题**：回合切换时 turnBanner 滑入 + drawLog 更新同时发生，视觉上信息密度过大，且旧 log 内容不自动消失形成残留

**问题 (b)：多条日志同时刷新导致视觉跳动（BattleScene.ts drawLog 相关）**

`drawLog()` 每次 `onLog` 回调触发后重绘全部 4 条，若在一帧内有多个日志（如伤害 + 技能触发 + 反伤），`drawLog` 被连续调用 3 次，每次 destroy 旧文本再 create 新文本，造成剧烈闪烁。

**问题 (c)：damageNumber/healNumber/statusText 之间无位置防重叠**

`ParticleSystem.damageNumber()` (L88-101)、`healNumber()` (L103-114)、`statusText()` (L116-126) 各自独立发射，x 只加了 `±10px` 随机偏移。当同一角色同时受到伤害 + 触发技能 + 回复体力时，三个飘字几乎完全重叠在同一个 (x, y)。

**问题 (d)：无字幕队列管理**

所有日志/飘字/横幅都是"即调即显"，没有任何队列管理：
- 无优先级（例如：死亡 > 伤害 > 技能 > 普通出牌）
- 无显示时长管理（所有 tween 各自独立，无统一生命周期）
- 无并发数量限制（理论上可以同时出现 N 个飘字 + N 个 statusText + turnBanner + 4 条 log）
- 无分类过滤（所有消息混合在同一 actionLog 数组和同一 drawLog 渲染中）

**问题 (e)：actionLog 内存无限增长**

`GameEngine.log()` (L752-757) 仅在 >200 条时 shift，但 drawLog 只显示最后 4 条。战斗日志无分区管理（伤害日志 vs 出牌日志 vs 技能日志 vs 系统通知）。

#### 3.3 当前 Z-Depth 分配对照（theme.ts:78-88）

```
background: 0
ambientParticles: 1
boardObjects: 5
handCards: 10
hoverCard: 15
uiOverlay: 20
fxLayer: 50
damageNumbers: 100
screenFlash: 150
banner: 200
debugOverlay: 999
```

**缺失**：无 `logLayer`（用于 drawLog）、无 `floatTextLayer`（用于 statusText）、无明确的 `overlayInteraction` 层。

---

### 二、目标状态

1. 字幕/飘字/横幅有统一队列管理器
2. 同屏多条信息自动错开位置（防重叠）
3. 不同类别信息有优先级和显示时长策略
4. drawLog 改为增量更新（不整块销毁重建）
5. Z-Depth 分层清晰，无跨层冲突

---

### 三、具体修改方案

#### 修改 1：新增 SubtitleManager 模块

**新文件**：`src/ui/SubtitleManager.ts`

```typescript
/**
 * 校园杀 v2.0 - Subtitle Manager
 * 统一管理所有飘字、横幅、日志输出，解决叠加冲突。
 */
import Phaser from 'phaser';
import { THEME } from './theme';

interface SubtitleItem {
  type: 'damage' | 'heal' | 'status' | 'banner' | 'log';
  text: string;
  priority: number;   // 1=high(死亡), 2=medium(伤害), 3=low(技能), 4=info(出牌)
  duration: number;   // ms
  x?: number;
  y?: number;
  color?: number;
  timestamp: number;
}

export class SubtitleManager {
  private scene: Phaser.Scene;
  private queue: SubtitleItem[] = [];
  private activeFloatTexts: Phaser.GameObjects.Text[] = [];
  private recentPositions: Map<number, number[]> = new Map(); // playerIndex -> last y offsets
  private logContainer: Phaser.GameObjects.Container;
  private logTexts: Phaser.GameObjects.Text[] = [];
  private bannerActive = false;
  private processing = false;

  /** 最大同时显示的飘字数量 */
  private static MAX_FLOAT_TEXTS = 6;
  /** 同一角色飘字的垂直偏移步长 */
  private static FLOAT_OFFSET_STEP = 30;
  /** log 最大保留条数 */
  private static MAX_LOG_LINES = 6;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.logContainer = scene.add.container(0, 0)
      .setDepth(THEME.depth.fxLayer - 5); // 45, 在 fxLayer 之下
    this.initLogDisplay();
  }

  // ─── 队列 API ───
  enqueue(item: Omit<SubtitleItem, 'timestamp'>): void {
    this.queue.push({ ...item, timestamp: Date.now() });
    if (!this.processing) this.processQueue();
  }

  private async processQueue(): Promise<void> {
    this.processing = true;
    while (this.queue.length > 0) {
      // 按优先级排序（高优先级先显示）
      this.queue.sort((a, b) => a.priority - b.priority);
      const item = this.queue.shift()!;
      await this.displayItem(item);
    }
    this.processing = false;
  }

  private async displayItem(item: SubtitleItem): Promise<void> {
    switch (item.type) {
      case 'damage':
      case 'heal':
      case 'status':
        this.showFloatText(item);
        break;
      case 'banner':
        await this.showBanner(item);
        break;
      case 'log':
        this.appendLog(item.text);
        break;
    }
    // 最小间隔防止视觉轰炸
    await this.delay(Math.min(item.duration || 100, 80));
  }

  // ─── 飘字防重叠 ───
  private showFloatText(item: SubtitleItem): void {
    if (this.activeFloatTexts.length >= SubtitleManager.MAX_FLOAT_TEXTS) {
      // 淘汰最旧的飘字
      const oldest = this.activeFloatTexts.shift();
      oldest?.destroy();
    }

    const baseX = item.x ?? this.scene.cameras.main.width / 2;
    const baseY = item.y ?? this.scene.cameras.main.height / 2;
    const playerKey = item.y ?? 0; // 用 Y 坐标近似分组

    // 计算偏移防止重叠
    const recent = this.recentPositions.get(Math.round(baseY / 50)) || [];
    const offsetIdx = recent.length;
    recent.push(Date.now());
    if (recent.length > 3) recent.shift();
    this.recentPositions.set(Math.round(baseY / 50), recent);

    const offsetX = (offsetIdx % 2 === 0 ? -1 : 1) * 40 * Math.ceil((offsetIdx + 1) / 2);
    const offsetY = -offsetIdx * SubtitleManager.FLOAT_OFFSET_STEP;

    const color = item.color
      ?? (item.type === 'damage' ? 0xff4444
        : item.type === 'heal' ? 0x44ff44
        : 0xffdd44);

    const txt = this.scene.add.text(
      baseX + offsetX, baseY + offsetY, item.text, {
        fontFamily: '"Noto Sans SC",sans-serif',
        fontSize: item.type === 'damage' || item.type === 'heal' ? '42px' : '22px',
        color: `#${color.toString(16).padStart(6, '0')}`,
        fontStyle: 'bold',
        stroke: '#000000',
        strokeThickness: 4,
      }
    ).setOrigin(0.5)
     .setDepth(THEME.depth.damageNumbers + offsetIdx)
     .setAlpha(1);

    this.activeFloatTexts.push(txt);

    this.scene.tweens.add({
      targets: txt,
      y: txt.y - 80,
      alpha: 0,
      duration: item.duration || 1000,
      ease: 'Sine.easeOut',
      onComplete: () => {
        txt.destroy();
        const idx = this.activeFloatTexts.indexOf(txt);
        if (idx >= 0) this.activeFloatTexts.splice(idx, 1);
      }
    });
  }

  // ─── 横幅（带互斥锁） ───
  private async showBanner(item: SubtitleItem): Promise<void> {
    // 如果上一个横幅还在显示中，等待它结束
    while (this.bannerActive) {
      await this.delay(200);
    }
    this.bannerActive = true;

    const w = this.scene.cameras.main.width;
    const txt = this.scene.add.text(w / 2, -40, item.text, {
      fontFamily: '"Noto Sans SC",sans-serif',
      fontSize: '36px',
      color: '#ffd700',
      fontStyle: 'bold',
      stroke: '#000',
      strokeThickness: 5,
    }).setOrigin(0.5)
     .setDepth(THEME.depth.banner)
     .setAlpha(0);

    return new Promise((resolve) => {
      // 滑入
      this.scene.tweens.add({
        targets: txt, y: 60, alpha: 1,
        duration: 600, ease: 'Back.easeOut',
      });
      // 停留后滑出
      this.scene.tweens.add({
        targets: txt, y: -40, alpha: 0,
        delay: item.duration || 1800,
        duration: 400,
        onComplete: () => {
          txt.destroy();
          this.bannerActive = false;
          resolve();
        }
      });
    });
  }

  // ─── 日志增量更新（不销毁重建） ───
  private initLogDisplay(): void {
    for (let i = 0; i < SubtitleManager.MAX_LOG_LINES; i++) {
      const txt = this.scene.add.text(10, 0, '', {
        fontFamily: '"Noto Sans SC",sans-serif',
        fontSize: '13px',
        color: '#aaaaaa',
        wordWrap: { width: 380 },
      }).setOrigin(0, 0.5);
      this.logTexts.push(txt);
      this.logContainer.add(txt);
    }
    this.updateLogPositions();
  }

  private appendLog(text: string): void {
    // 移位：将最旧的 text 设为新内容
    this.logTexts.push(this.logTexts.shift()!);
    this.logTexts[this.logTexts.length - 1].setText(text);

    // 淡入效果
    this.scene.tweens.add({
      targets: this.logTexts[this.logTexts.length - 1],
      alpha: { from: 0, to: 1 },
      duration: 200,
    });

    // 旧条目逐渐变暗
    this.logTexts.forEach((t, i) => {
      t.setAlpha(1 - (this.logTexts.length - 1 - i) * 0.15);
    });

    this.updateLogPositions();
  }

  private updateLogPositions(): void {
    const baseY = this.scene.cameras.main.height / 2 + 32;
    this.logTexts.forEach((t, i) => {
      t.setY(baseY + i * 18);
    });
  }

  // ─── 工具方法 ───
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => this.scene.time.delayedCall(ms, resolve));
  }

  /** 清理所有活跃飘字（场景切换时调用） */
  destroy(): void {
    this.activeFloatTexts.forEach(t => t.destroy());
    this.activeFloatTexts = [];
    this.logContainer.destroy();
    this.queue = [];
  }
}
```

#### 修改 2：BattleScene 接入 SubtitleManager

**文件**：`src/scenes/BattleScene.ts`

**(a) 初始化**
```typescript
// 在 create() 中添加
this.subtitleManager = new SubtitleManager(this);
```

**(b) 替换 drawLog 调用**

删除原有的 `drawLog()` 方法和 `logElements` 管理。所有通过 `onLog` 回调的日志改为：
```typescript
// GameEngine.callbacks.onLog
onLog: (message: string) => {
  // 判断消息类型并分配优先级
  const priority = message.includes('阵亡') ? 1
    : message.includes('伤害') ? 2
    : message.includes('发动') || message.includes('技能') ? 3
    : 4;

  this.subtitleManager.enqueue({
    type: 'log',
    text: message,
    priority,
    duration: 3000,
  });
}
```

**(c) 替换 turnBanner 调用**

```typescript
// 替换 particles.turnBanner(...)
this.subtitleManager.enqueue({
  type: 'banner',
  text: `第${turnNumber}回合 · ${playerName}`,
  priority: 2,
  duration: 2000,
});
```

**(d) 替换 damageNumber/healNumber 调用**

```typescript
// 获取玩家座位坐标后
this.subtitleManager.enqueue({
  type: 'damage',
  text: `-${amount}`,
  priority: 2,
  duration: 1200,
  x: targetSeatX,
  y: targetSeatY - 40,
  color: 0xff4444,
});
```

#### 修改 3：actionLog 分类管理

**文件**：`src/engine/GameEngine.ts`

```typescript
// 新增分类日志方法
logEvent(category: 'combat' | 'skill' | 'system' | 'card', msg: string): void {
  const prefix = {
    combat: '⚔️ ',
    skill: '✨ ',
    system: '📋 ',
    card: '🃏 ',
  }[category];
  
  this.state.actionLog.push(`[${category}] ${msg}`);
  if (this.state.actionLog.length > 200) this.state.actionLog.shift();

  // 分类日志也触发回调，前端可根据 category 设置字体颜色
  this.callbacks.onLog(`[${category}] ${msg}`);
}
```

#### 修改 4：BattleScene drawLog 增量改造

**文件**：`src/scenes/BattleScene.ts`

```typescript
// 新增分类颜色
private logColors: Record<string, string> = {
  combat: '#ff6666',
  skill: '#ffcc44',
  system: '#aaccff',
  card: '#88cc88',
};

// 修改 onLog 回调
onLog: (msg: string) => {
  const match = msg.match(/^\[(\w+)\]\s(.+)/);
  const category = match?.[1] ?? 'system';
  const text = match?.[2] ?? msg;
  const color = this.logColors[category] || '#aaaaaa';

  const priority = category === 'combat' ? 2
    : category === 'skill' ? 3
    : 4;

  this.subtitleManager.enqueue({
    type: 'log',
    text: text,
    priority,
    duration: 4000,
  });
}
```

---

## 修复优先级与实施顺序

### 第一阶段（对局可玩性 — P0）
1. **维度一-修改1**：响应询问系统（闪/决斗）
2. **维度一-修改2**：弃牌阶段人类玩家交互
3. **维度三-修改1**：SubtitleManager 模块创建
4. **维度三-修改2**：BattleScene 接入 SubtitleManager
5. **维度二-修改3**：HUD 增强（阶段指示器 + 回合计时器 + 操作提示）

### 第二阶段（界面完整 — P1）
6. **维度二-修改1**：装备区详细展示
7. **维度二-修改2**：判定区展示
8. **维度二-修改4**：交互覆盖层框架
9. **维度二-修改5**：濒死求桃界面
10. **维度三-修改3**：actionLog 分类管理

### 第三阶段（深度完善 — P2）
11. **维度一-修改3**：无懈可击响应链
12. **维度一-修改4**：3v3 模式
13. **维度一-修改5**：托管/断线处理
14. **维度三-修改4**：drawLog 分类着色

---

## 跨维度耦合注意事项

1. **维度一的响应系统 (修改1) 与维度二的交互覆盖层 (修改4) 强耦合**：实现响应询问时必须同步完成前端覆盖层 UI。两者必须在一个 PR 中同时交付。

2. **维度一的弃牌交互 (修改2) 复用维度二的交互覆盖层框架 (修改4)**：确保 `DISCARD_SELECT` OverlayType 复用同一套遮罩+交互容器架构。

3. **维度三的 SubtitleManager (修改1) 需要维度一的 log 回调数据 (修改3)**：分类 log 需要 GameEngine 端同步改造，否则 SubtitleManager 收到的仍是未分类文本。

4. **Z-Depth 统一分配**：维度二 (修改1-2：装备区/判定区) 放在 depth 5-6 (boardObjects)；交互覆盖层 (修改4) 放在 depth 25；SubtitleManager 日志 (维度三) 放在 depth 45；飘字保持 depth 100+；横幅保持 depth 200。

---

## 验收标准

### 维度一
- [ ] 人类玩家被【杀】时可以手动选择是否出【闪】
- [ ] 人类玩家被【决斗】时可以手动选择是否出【杀】
- [ ] 弃牌阶段展示手牌供人类玩家勾选弃置
- [ ] 3v3 模式可从选将到结算完整运行一局
- [ ] 闲置 60 秒自动托管并显示"托管中"标识

### 维度二
- [ ] 对局界面展示 6 阶段指示器，当前阶段高亮
- [ ] 每个玩家的装备区显示 5 个槽位（含空槽/已装备）
- [ ] 判定区有延时锦囊牌时在头像旁显示
- [ ] 出牌阶段右下角显示操作提示
- [ ] 回合倒计时可见（默认 60 秒）

### 维度三
- [ ] 同一角色同时受到伤害+治疗时，飘字自动错开不重叠
- [ ] 回合切换横幅与日志不出现视觉冲突
- [ ] 两条日志连续出现时平滑动效而非闪烁重建
- [ ] 同一帧内 >3 条日志时自动排队分帧显示，间隔 ≥80ms
*（内容由AI生成，仅供参考）*
