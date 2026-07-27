---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_bf681167891a11f1b66e525400e6dd8f
    ReservedCode1: 7d51DyH0JjJSgcjdxat4NxiYP8S4fbLLYf1WRVoUnmhg06Y1jF5hTBtE8BQTxTHuRU+UWIFwFangJm8Ohyk6bYWnHPoh1IR/cjiObrtWCIO7spUaeSrDgUgoYZzDSsEqoC+nH4el1WXg+BPQeyjfL5rCv6QitgZoZ7Cah6vLCPCejk7P1M0EMbVkYGU=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_bf681167891a11f1b66e525400e6dd8f
    ReservedCode2: 7d51DyH0JjJSgcjdxat4NxiYP8S4fbLLYf1WRVoUnmhg06Y1jF5hTBtE8BQTxTHuRU+UWIFwFangJm8Ohyk6bYWnHPoh1IR/cjiObrtWCIO7spUaeSrDgUgoYZzDSsEqoC+nH4el1WXg+BPQeyjfL5rCv6QitgZoZ7Cah6vLCPCejk7P1M0EMbVkYGU=
---

# 06-Visual-Rendering 提示词

## 任务目标

为校园杀的卡牌对战场景创建视觉特效和动画系统。包括卡牌渲染、出牌动画、伤害数字、粒子特效、屏幕震动、UI 过渡动效。所有效果自行寻找开源资源，零外部付费依赖。

## 输出要求

### 1. 卡牌 3D 渲染 CardRenderer.cs

- 使用 Unity Canvas 2D 程序化生成卡牌纹理（底色、边框、文字、图标）
- 卡牌材质支持：金属光泽（学霸卡）、发光（稀有卡）、暗纹（普通卡）
- 卡牌拖拽效果：跟随鼠标 + 轻微旋转 + 投影
- 手牌扇形排列：卡牌以弧形展开，选中牌略微抬起

### 2. 出牌动画系统 CardAnimator.cs

| 动画 | 描述 | 时长 |
|------|------|------|
| 抽牌 | 从牌库飞入手牌区，带弧线 | 0.3s |
| 出牌 | 手牌飞向战场中央，放大 1.5x | 0.4s |
| 攻击 | 攻击卡牌飞向目标，碰撞后碎裂 | 0.5s |
| 受击 | 目标英雄闪红 + 震动 | 0.3s |
| 死亡 | 英雄卡牌破碎消失，粒子爆发 | 0.8s |
| 胜利 | 胜利英雄放大 + 金色光芒环绕 | 1.0s |

- 使用 DOTween（免费版，从 GitHub 获取）实现缓动
- 使用 Unity AnimationCurve 微调节奏

### 3. 粒子特效 ParticleEffects.cs

自行创建以下粒子系统预制体（使用 Unity Particle System，不需要外部素材）：
- 火焰粒子（红色/橙色，攻击特效）
- 治疗粒子（绿色十字上升）
- 护盾粒子（蓝色六边形环绕）
- 冰霜粒子（白色雪花，冰冻 debuff）
- 毒雾粒子（紫色烟雾，中毒 debuff）
- 金币粒子（金色圆形，奖励获取）

### 4. UI 动效

- 主菜单按钮 hover 放大 1.05x + 轻微发光（利用 FairyGUI 过渡）
- 选英雄确认时卡片翻转动画（3D 旋转 180°）
- 战斗 HUD 血量条平滑减少（0.5s lerp）
- 回合切换文字弹入 + 缩放（弹性缓出）

### 5. 画面后处理 PostProcessingProfile.asset

- 战斗场景使用 Bloom（发光）+ Vignette（暗角）
- 主菜单使用 Color Grading（暖色调）
- 结算胜负使用不同的 LUT（暖色/冷色）

### 6. 音效系统 AudioManager.cs

- 使用 Web Audio API 合成音效（程序化生成，不需要音频文件）
- 卡牌抽牌：短促纸牌摩擦声
- 攻击命中：低频冲击声
- 胜利：上升音阶旋律
- 背景音乐：程序化生成简单循环（可选）

## 资源策略

- **DOTween**：从 `https://github.com/Demigiant/dotween` 下载免费版
- **粒子素材**：使用 Unity 默认粒子纹理（Default-Particle）
- **字体**：使用系统自带中文字体（SimSun / Microsoft YaHei），子集化打包
- **音效**：使用 Unity 内置 AudioClip.Create 程序化合成
- 如果 DOTween 获取失败，使用 Unity AnimationCurve + Coroutine 手写缓动作为兜底

## 禁止行为

- 不要从 Asset Store 下载任何付费资源
- 不要使用 Shader Graph（使用内建 Shader）
- 不要引入超过 5MB 的外部资源
- 程序化生成的所有内容必须在 Awake 中完成，不要依赖预制体

## 验收标准

- 出牌有完整的抽牌 → 放置 → 攻击 → 受击 → 死亡动画链路
- 所有粒子特效可见且性能 > 30 FPS
- 音效在出牌/攻击/胜利时正确触发
- UI 按钮 hover 有视觉反馈
*（内容由AI生成，仅供参考）*
