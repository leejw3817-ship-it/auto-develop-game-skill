---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_b9ccf9a1891a11f1b66e525400e6dd8f
    ReservedCode1: oWhK8hzVNoGKY82E/wYN6ILf6cIGILWadehHQ0fdOZEW//E5+gSD3mycmNvK7L1pijyPxKdoLh/6uu32eXFeKGP4U1clt0MiMmFkP6538mG8NAvinrRn8iN7xQpU4X8Q312WktSGTr3LhnEi2MvFqnEP9bkWRlviuCc2B9oqyxiC3ImXGFU8t6NmBBg=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_b9ccf9a1891a11f1b66e525400e6dd8f
    ReservedCode2: oWhK8hzVNoGKY82E/wYN6ILf6cIGILWadehHQ0fdOZEW//E5+gSD3mycmNvK7L1pijyPxKdoLh/6uu32eXFeKGP4U1clt0MiMmFkP6538mG8NAvinrRn8iN7xQpU4X8Q312WktSGTr3LhnEi2MvFqnEP9bkWRlviuCc2B9oqyxiC3ImXGFU8t6NmBBg=
---

# 01-FairyGUI 集成绑定提示词

## 任务目标

将已发布的 6 个 FairyGUI 包（MainMenu / HeroSelect / BattleHUD / ResultPanel / CardTooltip / ResponsivePanel）集成到 Unity 项目中，实现组件加载、创建、显示、事件绑定、场景切换的全链路。

## 前提条件

- Unity 2022.3.62f3c1 已安装
- 项目路径：`C:\Users\31184\Desktop\校园杀v0.1\CampusKillUnity`
- 6 个 .bytes 文件位于：`Assets\_Project\FairyGUI\Packages\`
- FairyGUI Unity SDK 需要自行安装（通过 Unity Package Manager 或从 GitHub 下载）

## 输出要求

### 1. FairyGUI SDK 安装

- 从 GitHub `https://github.com/fairygui/FairyGUI-unity` 下载最新代码
- 将 `Assets/FairyGUI/` 目录放入项目中
- 使用 Unity Package Manager 安装依赖（如 TextMeshPro）

### 2. 包加载器 UIManager.cs

在 `Assets\_Project\Scripts\UI\UIManager.cs` 创建全局 UI 管理器：

```
public class UIManager : MonoBehaviour
{
    // 加载所有包
    void Awake() {
        UIPackage.AddPackage("FairyGUI/Packages/MainMenu");
        UIPackage.AddPackage("FairyGUI/Packages/HeroSelect");
        UIPackage.AddPackage("FairyGUI/Packages/BattleHUD");
        UIPackage.AddPackage("FairyGUI/Packages/ResultPanel");
        UIPackage.AddPackage("FairyGUI/Packages/CardTooltip");
        UIPackage.AddPackage("FairyGUI/Packages/ResponsivePanel");
    }
    
    // 创建 UI 实例并挂载到 GRoot
    public GComponent CreateUI(string pkgName, string componentName) { ... }
    
    // 销毁当前 UI 并切换
    public void SwitchUI(string pkgName, string componentName) { ... }
}
```

### 3. 每个包的 UI 控制器

为每个包创建独立的 UIController，负责：
- 组件生命周期管理
- 按钮/列表/滑动等交互事件绑定
- 数据模型的绑定与更新
- 与游戏逻辑层的通信接口

文件列表：
| 文件 | 职责 |
|------|------|
| `MainMenuController.cs` | 主菜单：开始游戏、设置、退出按钮 |
| `HeroSelectController.cs` | 英雄选择：列表渲染、选中确认、队伍编辑 |
| `BattleHUDController.cs` | 战斗界面：手牌区、出牌区、回合指示器、血量条 |
| `ResultPanelController.cs` | 结算面板：胜负展示、数据统计、返回按钮 |
| `CardTooltipController.cs` | 卡片提示：悬停显示卡片详情 |
| `ResponsivePanelController.cs` | 响应面板：对战中的选项按钮（出牌/跳过/技能） |

### 4. 事件系统

在 `Assets\_Project\Scripts\UI\UIEvents.cs` 定义全局 UI 事件枚举和事件总线，实现各 UI 控制器之间的解耦通信。

### 5. 场景配置

- 创建 `Assets\_Project\Scenes\Main.unity` 作为启动场景
- 场景中放置 UIManager（挂载到 Persistent GameObject）
- 配置 FairyGUI Stage Camera

## 禁止行为

- 不要修改 .bytes 文件
- 不要创建额外的 UIPackage（使用已发布的 6 个包）
- 组件名称必须完全匹配 package.xml 中定义的名字

## 验收标准

- Unity Play Mode 下能加载 MainMenu 包
- 点击"开始游戏"按钮能切换到 HeroSelect
- 所有按钮交互有响应日志
- 无 NullReferenceException
*（内容由AI生成，仅供参考）*
