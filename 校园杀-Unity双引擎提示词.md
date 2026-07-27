---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_c169d6c6891a11f1b66e525400e6dd8f
    ReservedCode1: 2dIteqlVYPksPlIHwW8Gb2aKCqDfMjjJsHVkPHn/6URGPmSDRuxZq9icHyJ6/hwaGUP9XOxZ1Ca5hGX3COWRQxaX25HMutFzkc+m9zHc74cvtQjzq20v5p0rFH/hYENBuWHbzCg4/Ij1MDu58QahQJsw33n2JTggajsXquQk35k1tqIG3Oo3R31T2dk=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_c169d6c6891a11f1b66e525400e6dd8f
    ReservedCode2: 2dIteqlVYPksPlIHwW8Gb2aKCqDfMjjJsHVkPHn/6URGPmSDRuxZq9icHyJ6/hwaGUP9XOxZ1Ca5hGX3COWRQxaX25HMutFzkc+m9zHc74cvtQjzq20v5p0rFH/hYENBuWHbzCg4/Ij1MDu58QahQJsw33n2JTggajsXquQk35k1tqIG3Oo3R31T2dk=
---

# 08-Unity-DualEngine 提示词

## 任务目标

实现 FairyGUI（UI 层）+ Unity 原生（3D 场景层）的双引擎协同架构。FairyGUI 负责所有 UI/交互，Unity 原生负责 3D 战场背景、英雄模型、粒子效果、相机控制。

## 输出要求

### 1. 三层渲染架构

```
Layer 0 (底层): Unity 3D Scene   — 战场背景、英雄模型、环境光
Layer 1 (中层): Unity Particles  — 粒子特效（火焰/治疗/护盾）
Layer 2 (顶层): FairyGUI GRoot   — 手牌、HUD、按钮、结算面板
```

- FairyGUI Stage Camera：CullingMask 仅渲染 UI Layer（Layer 5）
- Unity Main Camera：CullingMask 排除 UI Layer
- 两个相机 Depth：Main Camera = -1，Stage Camera = 0

### 2. 双引擎通信桥 DualEngineBridge.cs

```
public class DualEngineBridge : MonoBehaviour
{
    // FairyGUI → Unity：UI 事件触发 3D 响应
    public void OnCardPlayed(string cardId, Vector2 screenPos);
    public void OnHeroSelected(string heroId);
    
    // Unity → FairyGUI：3D 事件通知 UI 更新
    public void OnDamageDealt(string targetId, int amount);
    public void OnHeroDied(string heroId);
    public void OnTurnChanged(int round);
    
    // 坐标转换：屏幕坐标 ↔ 世界坐标
    public Vector3 ScreenToWorld(Vector2 screenPos, float depth);
    public Vector2 WorldToScreen(Vector3 worldPos);
}
```

### 3. 3D 战场场景

创建 `Assets\_Project\Scenes\Battle3D.unity`：
- 桌面战场：一个平面（Plane）+ 木质纹理（Canvas 2D 生成）
- 两方英雄站位：左侧（玩家1）和右侧（玩家2）各 3 个站位点
- 摄像机：俯视视角（45° 俯角），在出牌时拉近特写
- 环境光：暖色 Directional Light + 轻微 Ambient

### 4. 英雄 3D 模型

- 使用 Unity 原生 Cube/Capsule/Sphere 拼装简易英雄模型（程序化生成）
- 每个英雄预制体包含：身体、头部、武器、底座光环
- 不依赖外部 .fbx 模型文件
- 模型使用不同颜色区分：玩家1（蓝）、玩家2（红）

### 5. 摄像机控制 CameraController.cs

- 默认视角：俯视 45°，距离 10 单位
- 出牌时：平滑移向战场中央（1.5s）
- 攻击时：短暂震动（0.2s，幅度 0.1）
- 胜利时：环绕胜利英雄旋转一周
- 触控支持：单指旋转视角（水平旋转 ±45°）

### 6. 英雄动画

使用 Unity Animation 组件 + 程序化关键帧：
- Idle：轻微上下浮动（正弦波）
- 受击：向后弹开 + 闪红
- 攻击：向前冲刺 + 武器挥动
- 死亡：向后倾倒 + 下沉消失
- 胜利：双手举起 + 跳起

### 7. 场景与 UI 的协调

场景加载流程：
```
1. 加载 Battle3D 场景 → 实例化英雄模型
2. 加载 FairyGUI BattleHUD 包 → 显示 HUD
3. DualEngineBridge 连接两边
4. 开场动画（摄像机拉近 → 回合开始）
```

## 禁止行为

- 不要使用 Unity UI (UGUI) Canvas（全部走 FairyGUI）
- 不要在 FairyGUI 组件中嵌入 3D 模型（使用独立 Layer）
- 不要使用 SceneManager.LoadScene 同步加载（异步加载场景）

## 验收标准

- 战场中能看到 6 个英雄模型（双方各 3 个）
- 点击手牌 → 英雄做出攻击动画 → HUD 血量更新
- 摄像机在出牌时有平滑移动
- 两个引擎之间帧率均 ≥ 30 FPS
*（内容由AI生成，仅供参考）*
