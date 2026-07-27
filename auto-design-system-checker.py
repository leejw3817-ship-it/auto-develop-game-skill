---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_8623c902890211f1a68c525400826444
    ReservedCode1: EkBp2BKuG1/Whjq6mGD1HU7MhRrhFhFV2zRCMwe0c9DTZ8M8yJePHIShxvjcG52hIJBpv+fnrSUe+QDMoZTxIacsWk4PK/hLuPMDt02l2ECp2A9XjFD46QxVapFd5Egn7VHB0nxPKXYQMsU+xrYfyWgB0rJeycOHUytOQfir9GpJ0Uqq/WDPMirms/8=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_8623c902890211f1a68c525400826444
    ReservedCode2: EkBp2BKuG1/Whjq6mGD1HU7MhRrhFhFV2zRCMwe0c9DTZ8M8yJePHIShxvjcG52hIJBpv+fnrSUe+QDMoZTxIacsWk4PK/hLuPMDt02l2ECp2A9XjFD46QxVapFd5Egn7VHB0nxPKXYQMsU+xrYfyWgB0rJeycOHUytOQfir9GpJ0Uqq/WDPMirms/8=
---

# 校园杀 v0.2 — Unity + FairyGUI 手动操作清单

> 本清单覆盖 Unity Editor（场景/预制体/Build）和 FairyGUI Editor（UI 包设计/导出）的完整操作步骤。
> 按顺序执行，每完成一项打勾即可。

---

## 前置条件检查

- [ ] Unity Hub 已安装，且安装了 Unity 2021.3+ 版本（带 WebGL 模块）
- [ ] FairyGUI Editor 已安装：`D:\Program Files\FairyGUI-Editor\FairyGUI-Editor\FairyGUI-Editor.exe`
- [ ] 项目路径确认：`C:\Users\31184\Desktop\校园杀v0.1\CampusKillUnity`

---

# Part A: Unity Editor — 场景搭建

### A1. 打开项目

- [ ] 打开 Unity Hub → 点击 **Open** → 选择 `C:\Users\31184\Desktop\校园杀v0.1\CampusKillUnity`
- [ ] 等待项目加载完成（首次打开可能需要较长时间）

### A2. 创建目录结构

- [ ] 在 Project 窗口右键 → Create → Folder，依次创建：
  - `Assets/_Project`
  - `Assets/_Project/Scenes`
  - `Assets/_Project/Prefabs`
  - `Assets/_Project/Materials`
  - `Assets/_Project/Scripts`

---

### A3. 场景 1：ClassroomScene（教室）

- [ ] File → New Scene → 选择 Basic (Built-in) → Create
- [ ] Ctrl+S 保存，路径 `Assets/_Project/Scenes/`，文件名 `ClassroomScene`

**光照**
- [ ] 选中 Directional Light → Inspector：
  - Color: `#FFDCAE`（暖黄）
  - Intensity: `1.2`
  - Rotation: X=50, Y=-30（模拟窗户射入光）

**地板**
- [ ] 右键 Hierarchy → 3D Object → Plane
  - Position: (0, 0, 0)
  - Scale: (10, 1, 10)
  - 创建 Material（Assets/_Project/Materials → 右键 Create → Material，命名 Floor_Wood）
  - Albedo 颜色设为 `#C49A6C`（浅木色），拖给 Plane

**课桌阵列**（每张桌子用 3 个 Cube：桌面+2条腿）
- [ ] 创建 Empty GameObject 命名 "DeskRow1"
- [ ] 在其下创建 Cube "DeskTop"：Scale (1.2, 0.05, 0.8)，位置 Y=0.75
- [ ] 创建 Cube "Leg_L"：Scale (0.08, 0.7, 0.08)，位置 (-0.5, 0.35, -0.3)
- [ ] 创建 Cube "Leg_R"：Scale (0.08, 0.7, 0.08)，位置 (-0.5, 0.35, 0.3)
- [ ] 复制 DeskRow1 生成 DeskRow2/3/4，Z 轴偏移 1.5
- [ ] 复制行生成列，X 轴偏移 2.0，最终 4×4=16 张桌子

**黑板**
- [ ] 创建 Cube "Blackboard"：Position (0, 2, -4.5)，Scale (4, 1.5, 0.1)
- [ ] 创建 Material "Blackboard_Mat"，颜色深绿 `#2D5016`，拖给黑板

**窗户**
- [ ] 在墙位置创建 3 个 Cube "WindowPane"，Scale (0.05, 2, 1.5)
- [ ] 创建透明 Material：Rendering Mode → Transparent，Albedo 浅蓝 Alpha 60

**相机**
- [ ] 选中 Main Camera：
  - Position: (0, 8, -10)
  - Rotation: (30, 0, 0)
  - Field of View: 60

- [ ] Ctrl+S 保存

---

### A4. 场景 2：PlaygroundScene（操场）

- [ ] File → New Scene → Ctrl+S 保存为 `PlaygroundScene`

**光照**
- [ ] Directional Light：
  - Color: `#FF9632`（夕阳橙红）
  - Intensity: 1.0
  - Rotation: X=15, Y=180（低角度逆光）

**地面**
- [ ] Plane "Ground_Green"：Scale (15, 1, 15)，Material 绿色 `#4A8C3F`
- [ ] 跑道：创建 4 个长条 Cube 排成环形跑道，红色 Material `#B22222`

**足球门**
- [ ] 创建 Empty "Goal_Left"
- [ ] 3 个白色 Cube 组成门框（横梁+两根立柱），白色 Material
- [ ] 复制到右侧 "Goal_Right"

**教学楼剪影**
- [ ] 远处放 5-6 个灰色 Cube "Building_01~06"，位置 Z=-12
- [ ] 高度随机 3-8，Scale (2, 随机, 1)，灰色 Material `#555555`

**相机**
- [ ] Position: (0, 2, -5)
- [ ] Rotation: (10, 0, 0)

- [ ] Ctrl+S 保存

---

### A5. 场景 3：RooftopScene（天台）

- [ ] File → New Scene → Ctrl+S 保存为 `RooftopScene`

**光照**
- [ ] Directional Light：
  - Intensity: 1.5
  - Shadow Type: Hard Shadows

**天空盒**
- [ ] Window → Rendering → Lighting
- [ ] Environment → Skybox Material → 选择默认 Skybox（或搜索 "Sky"）

**地面**
- [ ] Plane "Roof"：Scale (10, 1, 10)，灰色 Material `#808080`

**围栏**
- [ ] 沿屋顶边缘（X=±4.5, Z=±4.5）放置 Cylinder "FencePost"：Scale (0.1, 1.2, 0.1)
- [ ] 柱间放 Cube "FenceRail" 作为横杆
- [ ] 每边约 10 根柱子，间距 1 单位

**城市天际线**
- [ ] 远景放高低错落灰色 Cube，Z=-15，X 范围 -8~8

**相机**
- [ ] Position: (0, 5, -6)
- [ ] Field of View: 72（广角）

- [ ] Ctrl+S 保存

---

### A6. 场景 4：LibraryScene（图书馆）

- [ ] File → New Scene → Ctrl+S 保存为 `LibraryScene`

**光照**
- [ ] Directional Light：Intensity `0.2`（极暗环境光）
- [ ] 创建多个 Point Light 模拟台灯：
  - 每个书架上方放一个，Range 3，Color `#FFE4A0`，Intensity 1.5

**书架**
- [ ] 创建 Empty "Bookshelf_01"
- [ ] Cube "Frame_L" / "Frame_R"：竖板 Scale (0.1, 3, 0.8)
- [ ] Cube "Shelf_1~5"：横板 Scale (1.5, 0.05, 0.8)，Y 间隔 0.5
- [ ] 复制 Bookshelf 生成 3 排，每排 4 个，形成通道

**尘埃粒子**
- [ ] 右键 Hierarchy → Effects → Particle System
- [ ] 参数：
  - Duration: 999, Start Lifetime: 8
  - Start Speed: 0.1~0.3, Start Size: 0.02~0.05
  - Start Color: 白色半透明 Alpha 80
  - Shape: Box, Scale (8, 4, 10)
  - Emission: Rate over Time 5
  - 取消重力（Gravity Modifier: 0）

**相机**
- [ ] Position: (0, 1.6, -4)
- [ ] 可选：添加 Post-processing Volume → Bloom 实现柔焦

- [ ] Ctrl+S 保存

---

### A7. 场景 5：ResultStage（结算舞台）

- [ ] File → New Scene → Ctrl+S 保存为 `ResultStage`

**光照**
- [ ] Directional Light：Intensity 0.1
- [ ] 创建 3 个 Spot Light：
  - Position 上方环形排列，指向舞台中心 (0, 0, 0)
  - Spot Angle: 30, Intensity: 3
  - Color: 分别金色/暖白/浅粉

**帷幕**
- [ ] 左侧：Cube 拉伸 Scale (0.2, 5, 3)，Position (-4, 2.5, -1)，红色 Material
- [ ] 右侧：镜像 Position (4, 2.5, -1)
- [ ] 顶部幕布：Cube Scale (10, 0.2, 2)，Position (0, 4.5, -1)

**地板**
- [ ] Plane "StageFloor"：Scale (6, 1, 4)，Material 深木色带光滑反射

**金色粒子**
- [ ] 创建 Particle System：
  - Start Color: 金色 `#FFD700`
  - Start Lifetime: 4, Start Speed: 1~3
  - Shape: Box, Position 上方，Emission Rate 20
  - Gravity: -0.5（缓慢下落）

**相机**
- [ ] Position: (0, 2, -8)
- [ ] 附加脚本做环绕（窗口下方 Add Component → 新建 C# 脚本 "CameraOrbit"）
- [ ] CameraOrbit 内容：
```csharp
using UnityEngine;
public class CameraOrbit : MonoBehaviour {
    public float speed = 10f;
    void Update() {
        transform.RotateAround(Vector3.zero, Vector3.up, speed * Time.deltaTime);
    }
}
```

- [ ] Ctrl+S 保存

---

# Part B: Unity Editor — 预制体

### B1. Card3D.prefab

- [ ] Hierarchy 右键 → 3D Object → Cube，命名 "Card3D"
- [ ] Scale: (0.7, 1.0, 0.02)
- [ ] 创建 Material "Card_White"：白色 Albedo，拖给 Card3D
- [ ] 选中 Card3D → Add Component → 搜索 CardDisplay → New Script → Create and Add
- [ ] 拖 Card3D 到 `Assets/_Project/Prefabs/` 生成预制体

- [ ] CardDisplay.cs 内容：
```csharp
using UnityEngine;
public class CardDisplay : MonoBehaviour
{
    public string cardName;
    public int cost;
    public int attack;
    public int defense;
    public string description;
    public enum Rarity { Common, Uncommon, Rare, Epic, Legendary }
    public Rarity rarity;
}
```

---

### B2. HeroCharacter.prefab

- [ ] 创建 Empty "HeroCharacter"
- [ ] 添加 Capsule "Body"：Position (0, 1.0, 0)，Scale (0.4, 0.5, 0.4)，Material 蓝色
- [ ] 添加 Sphere "Head"：Position (0, 1.55, 0)，Scale (0.25, 0.25, 0.25)，Material 肤色
- [ ] 添加 Cylinder "Arm_L"：Position (-0.35, 1.3, 0)，Rotation Z=-30，Scale (0.08, 0.3, 0.08)
- [ ] 添加 Cylinder "Arm_R"：Position (0.35, 1.3, 0)，Rotation Z=30，Scale (0.08, 0.3, 0.08)
- [ ] 整体拖入 Prefabs 文件夹

---

### B3. DamageEffect.prefab

- [ ] 右键 → Effects → Particle System，命名 "DamageEffect"
- [ ] 参数：
  - Duration: 0.5
  - Start Lifetime: 0.4~0.6
  - Start Speed: 3~6
  - Start Size: 0.3~0.6
  - Start Color: 红色 `#FF2020`
  - Max Particles: 15
  - Shape: Sphere, Radius 0.5
  - Emission → Rate over Time: 0, Bursts: Time 0, Count 15
  - Gravity Modifier: 1.5
  - Renderer → Material: Default-Particle
- [ ] 拖入 Prefabs 文件夹

---

### B4. HealEffect.prefab

- [ ] 复制 DamageEffect，重命名 "HealEffect"
- [ ] 修改参数：
  - Start Color: 绿色 `#40FF40` → `#FFD700`（渐变）
  - Start Speed: 2~4
  - Gravity Modifier: -0.5（向上）
  - Shape: Cone, Angle 15
- [ ] 拖入 Prefabs 文件夹

---

### B5. CardGlow.prefab

- [ ] 创建 Plane "CardGlow"
- [ ] Scale: (0.8, 1.1, 1)
- [ ] 创建 Material "Glow_Common"：
  - Emission: 勾选，颜色白色，强度 0.5
- [ ] 复制 Material 制作 5 个版本：
  - Glow_Common：白色 Emission
  - Glow_Uncommon：蓝色 `#4488FF`
  - Glow_Rare：紫色 `#9944FF`
  - Glow_Epic：橙色 `#FF8844`
  - Glow_Legendary：红色 `#FF4444`
- [ ] 拖入 Prefabs 文件夹
- [ ] 注：使用时根据稀有度动态替换材质或设置 Emission 颜色

---

# Part C: Unity Editor — Build WebGL

### C1. 添加场景到构建列表

- [ ] File → Build Settings...
- [ ] 点击 **Add Open Scenes**（确保当前打开了一个场景）
- [ ] 或者把所有 5 个 .unity 文件从 Project 窗口拖入 Scenes In Build 列表
- [ ] 确认列表包含：ClassroomScene, PlaygroundScene, RooftopScene, LibraryScene, ResultStage

### C2. 切换平台

- [ ] Platform 列表选择 **WebGL**
- [ ] 点击 **Switch Platform** 按钮
- [ ] 等待切换完成（右下角进度条）

### C3. Player Settings

- [ ] 点击 **Player Settings...**
- [ ] Resolution and Presentation：
  - Default Width: `1280`, Height: `720`
  - 勾选 **Run In Background**
- [ ] Publishing Settings：
  - Compression Format: Gzip（默认即可）
  - 勾选 Decompression Fallback

### C4. 执行 Build

- [ ] 回到 Build Settings 窗口
- [ ] 点击 **Build**（或 Build And Run）
- [ ] 输出目录选择：`C:\Users\31184\Desktop\校园杀v0.1\CampusKillUnity\Build`
- [ ] 创建新文件夹名 `Build`，点 Select Folder
- [ ] 等待构建完成（首次 WebGL Build 可能需要 5-15 分钟）

### C5. 验证

- [ ] 确认 Build 文件夹包含：
  - `index.html`
  - `Build/` 子文件夹（含 .framework.js, .data, .wasm 等）
  - `TemplateData/` 文件夹

---

# Part D: FairyGUI Editor — UI 包设计

### D1. 创建项目

- [ ] 打开 `D:\Program Files\FairyGUI-Editor\FairyGUI-Editor\FairyGUI-Editor.exe`
- [ ] 菜单：文件 → 新建项目
- [ ] 项目名称：`CampusKill`
- [ ] 项目路径：`C:\Users\31184\Desktop\校园杀v0.1\FairyGUI-Project`
- [ ] 分辨率：1280×720

---

### D2. UI 包 1：MainMenu

- [ ] 在项目面板右键 → 新建包 → 命名 `MainMenu`
- [ ] 在 MainMenu 包下新建组件：

| 组件名 | 类型 | 关键属性 |
|--------|------|---------|
| bg_overlay | 图形 | 矩形 1280×720，填充 `#000000` Alpha 60% |
| logo_text | 文本 | 内容 "校园杀"，字体 48px 粗体，颜色 `#E53935`，居中偏上 Y=200 |
| btn_1v1 | 按钮 | 文字 "1v1 对战"，宽 240 高 60，圆角 12，背景 `#E53935`，文字白色 24px |
| btn_3v3 | 按钮 | 文字 "3v3 身份局"，样式同上，Y 偏移 +80 |
| btn_settings | 按钮 | 文字 "设置"，样式同上但背景灰色 `#666666`，Y 偏移 +160 |
| txt_version | 文本 | "v0.2"，14px，灰色，右下角 |

- [ ] 为按钮添加过渡：选中按钮 → 过渡 → 缩放 → 鼠标悬停 Scale 1.05

---

### D3. UI 包 2：HeroSelect

- [ ] 新建包 → `HeroSelect`

| 组件名 | 类型 | 关键属性 |
|--------|------|---------|
| title_bar | 组件 | 宽 1280 高 60，背景 `#E53935` |
| title_text | 文本 | "选择你的英雄"，白色 28px 粗体，居中 |
| hero_list | 列表 | 宽 600 高 500，左侧，虚拟列表模式，折叠式隐藏 |
| hero_item | 组件 | 宽 580 高 100，含圆形头像(100×100)、名字、描述 |
| skill_panel | 组件 | 宽 500 高 400，右侧，显示选中英雄技能 |
| skill_name | 文本 | 技能名，20px 粗体 `#1E88E5` |
| skill_desc | 文本 | 技能描述，16px `#333333`，多行 |
| btn_confirm | 按钮 | "确认选择"，宽 200 高 55，底部居中 |
| timer_ring | 进度条 | 环形，直径 80，30 秒倒计时，颜色渐变绿→黄→红 |

---

### D4. UI 包 3：BattleHUD（核心包）

- [ ] 新建包 → `BattleHUD`

| 组件名 | 类型 | 关键属性 |
|--------|------|---------|
| **顶部栏** | | |
| top_bar | 组件 | 宽 1280 高 50，背景深灰半透明 |
| txt_turn | 文本 | "第 1 回合"，16px 白色，左侧 |
| phase_indicator | 组件 | 5 个标签横向排列：判定/摸牌/出牌/弃牌/回合结束，当前高亮 `#E53935` |
| timer_bar | 进度条 | 宽 200 高 20，20 秒倒计时，前景 `#E53935`，右侧 |
| **玩家区域** | | |
| player_panel | 组件 | 左下角，宽 400 |
| avatar_player | 图形 | 圆形 80×80，头像占位（灰色圆形） |
| hp_bar_player | 进度条 | 宽 200 高 16，5 格血条，红色 |
| txt_hand_count | 文本 | "手牌: 4"，14px 白色 |
| equip_area | 组件 | 4 个 60×90 格子横向排列（武器/防具/+1马/-1马），灰色边框 |
| **对手区域** | | |
| enemy_panel | 组件 | 右上角（镜像），宽 400 |
| avatar_enemy | 图形 | 圆形 80×80，头像占位 |
| hp_bar_enemy | 进度条 | 同上 |
| **底部操作区** | | |
| bottom_bar | 组件 | 宽 1280 高 80，底部 |
| btn_end_turn | 按钮 | "结束回合"，宽 160 高 50，仅出牌阶段显示 |
| btn_confirm | 按钮 | "确定"，宽 120 高 45，需要确认时显示 |
| btn_cancel | 按钮 | "取消"，宽 120 高 45，灰色 |
| **战斗日志** | | |
| log_panel | 组件 | 右侧，宽 300 高 400 |
| log_list | 列表 | 虚拟列表，最多 50 条，自动滚动到底部 |
| log_item | 文本 | 14px，颜色按事件类型：伤害红/治疗绿/系统白 |

---

### D5. UI 包 4：ResultPanel

- [ ] 新建包 → `ResultPanel`

| 组件名 | 类型 | 关键属性 |
|--------|------|---------|
| bg_overlay | 图形 | 全屏黑色 Alpha 70% |
| result_text | 文本 | "胜利！" 或 "失败"，48px 粗体，金色 `#FFD700`，居中 Y=200 |
| mvp_panel | 组件 | 宽 400 高 300，MVP 卡片展示 |
| stats_table | 组件 | 表格：伤害量/治疗量/出牌数/回合数 |
| stat_row | 组件 | 一行：标签(左)+数值(右)，字体 18px |
| btn_rematch | 按钮 | "再来一局"，宽 200 高 55，主色红色 |
| btn_lobby | 按钮 | "返回大厅"，宽 180 高 50，灰色 |

---

### D6. UI 包 5：CardTooltip

- [ ] 新建包 → `CardTooltip`

| 组件名 | 类型 | 关键属性 |
|--------|------|---------|
| tip_bg | 图形 | 矩形 220×320，圆角 8，阴影 |
| card_image | 装载器 | 200×280，卡牌图占位，灰色 |
| txt_name | 文本 | 卡牌名，18px 粗体 |
| txt_cost | 文本 | 费用图标+数字，20px |
| txt_desc | 文本 | 技能描述，14px，支持多行，最大行数 5 |
| rarity_border | 图形 | 边框 4px，颜色按稀有度切换 |

- [ ] 整体添加动效：出现时过渡 Scale 0.8→1.0，持续时间 0.3s，缓动 Back.EaseOut

---

### D7. UI 包 6：ResponsivePanel

- [ ] 新建包 → `ResponsivePanel`

| 组件名 | 类型 | 关键属性 |
|--------|------|---------|
| modal_bg | 图形 | 全屏黑色 Alpha 50% |
| dialog_card | 组件 | 宽 600 高 400，居中，白色背景，圆角 16，阴影 |
| title_text | 文本 | "请选择是否出【闪】"，22px 粗体 `#333333` |
| card_list | 列表 | 水平排列的可选手牌，每项 100×140 |
| option_list | 列表 | 文字选项按钮（如"出闪"/"不出"） |
| timer_ring | 进度条 | 环形 10 秒倒计时，右上角 |
| note_text | 文本 | 灰色提示文字 "10 秒后自动选择默认选项" |

---

# Part E: FairyGUI Editor — 导出

### E1. 发布设置

- [ ] 菜单：文件 → 项目设置
- [ ] 发布 → 发布路径：`C:\Users\31184\Desktop\校园杀v0.1\CampusKillUnity\Assets\_Project\FairyGUI\Packages`
- [ ] 勾选：导出二进制格式（.bytes）
- [ ] 确定

### E2. 逐个发布

- [ ] 在项目面板右键 MainMenu 包 → 发布
- [ ] 重复：HeroSelect / BattleHUD / ResultPanel / CardTooltip / ResponsivePanel

### E3. 验证

- [ ] 确认以下 6 个文件已生成：
  - `MainMenu.bytes`
  - `HeroSelect.bytes`
  - `BattleHUD.bytes`
  - `ResultPanel.bytes`
  - `CardTooltip.bytes`
  - `ResponsivePanel.bytes`

---

## 完成标志

全部完成后的目录结构：

```
校园杀v0.1/
├── CampusKillUnity/
│   ├── Assets/_Project/
│   │   ├── Scenes/
│   │   │   ├── ClassroomScene.unity    ✅
│   │   │   ├── PlaygroundScene.unity    ✅
│   │   │   ├── RooftopScene.unity      ✅
│   │   │   ├── LibraryScene.unity      ✅
│   │   │   └── ResultStage.unity       ✅
│   │   ├── Prefabs/
│   │   │   ├── Card3D.prefab           ✅
│   │   │   ├── HeroCharacter.prefab    ✅
│   │   │   ├── DamageEffect.prefab     ✅
│   │   │   ├── HealEffect.prefab       ✅
│   │   │   └── CardGlow.prefab         ✅
│   │   ├── Scripts/
│   │   │   └── CardDisplay.cs          ✅
│   │   └── FairyGUI/Packages/
│   │       ├── MainMenu.bytes          ✅
│   │       ├── HeroSelect.bytes        ✅
│   │       ├── BattleHUD.bytes         ✅
│   │       ├── ResultPanel.bytes       ✅
│   │       ├── CardTooltip.bytes       ✅
│   │       └── ResponsivePanel.bytes   ✅
│   └── Build/
│       ├── index.html                  ✅
│       └── Build/ (WebGL 产物)          ✅
└── FairyGUI-Project/                   ✅
```

---

**预计总耗时**：Unity 场景搭建 1.5-2 小时 + 预制体 30 分钟 + Build 10-20 分钟 + FairyGUI UI 设计 1-1.5 小时 + 导出 5 分钟 = **约 3.5-4.5 小时**
*（内容由AI生成，仅供参考）*
