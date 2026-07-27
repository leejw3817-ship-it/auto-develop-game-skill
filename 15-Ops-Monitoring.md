---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_c088f870891a11f1a68c525400826444
    ReservedCode1: 1ykPeZas7aExpm0XtC47zke+hbuaNqhhb6JkMxEZNFNqrjd3rpPrsFl5N/nOejNoqg/KUccQyZjwdDs5tGksmRFM/aGqEVbmdYoI1WkuRzgP3MQ/Au1XRAd6r6dKRoHxqYbxcNauIRuqAFR9olzqUP63fuOW+NXcy78tw/80xr3H10wAexQ061Af9tk=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_c088f870891a11f1a68c525400826444
    ReservedCode2: 1ykPeZas7aExpm0XtC47zke+hbuaNqhhb6JkMxEZNFNqrjd3rpPrsFl5N/nOejNoqg/KUccQyZjwdDs5tGksmRFM/aGqEVbmdYoI1WkuRzgP3MQ/Au1XRAd6r6dKRoHxqYbxcNauIRuqAFR9olzqUP63fuOW+NXcy78tw/80xr3H10wAexQ061Af9tk=
---

# 07-Mobile-Build 提示词

## 任务目标

将校园杀打包为 Android APK，适配移动端触控操作、屏幕适配、性能优化、权限管理。目标：APK 大小 ≥1GB（完整资源包），可上线标准。

## 输出要求

### 1. 触控输入适配

创建 `Assets\_Project\Scripts\Input\TouchInputAdapter.cs`：
- 将所有鼠标操作映射为触控
- 卡牌拖拽使用 Touch Phase（Began → Moved → Ended）
- 双击 = 快速点击两次（间隔 < 300ms）
- 长按 = 按住 ≥ 500ms（显示卡牌详情 CardTooltip）
- 双指缩放用于查看战场全局（可选）
- 屏蔽 Unity 默认的触控模拟（Standalone Input Module）

### 2. 屏幕适配 ScreenAdapter.cs

- 基准分辨率 1920×1080（FairyGUI 设计分辨率）
- 支持 16:9 / 18:9 / 19.5:9 / 20:9 屏幕比例
- 使用 FairyGUI GRoot.contentScaleFactor 自动缩放
- 刘海屏安全区域适配（SafeArea.cs）
- 横屏/竖屏自动旋转支持（默认横屏 Landscape Left）

### 3. 性能优化

#### 渲染优化
- FairyGUI FairyBatching 自动合并 DrawCall
- UI 图集纹理最大 2048×2048，RGBA32
- 粒子系统最大粒子数限制 200/个
- LOD：手牌区卡牌在远距离降低纹理精度

#### 内存优化
- 使用 Addressables 异步加载包（按需加载，不用时卸载）
- 卡牌纹理使用 AssetBundle 压缩
- 战斗日志使用环形缓冲区（最多保留 50 条）
- GC 优化：对象池复用卡牌 GameObject

#### 包体优化
- Texture 压缩：ASTC 6×6（Android）
- Mesh 压缩：开启
- Audio 压缩：Vorbis（Quality 70%）
- Scripting Backend：IL2CPP
- Stripping Level：Medium
- 目标 APK 大小 ≥ 1GB（含完整卡牌美术资源）

### 4. Android 权限配置

在 `AndroidManifest.xml` 中仅声明必要权限：
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<!-- 如需语音聊天 -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### 5. 移动端 UI 适配

- 所有按钮最小触控区域 48×48dp
- Tooltip 在移动端改为长按弹出
- 聊天输入框弹出时界面自动上移
- 通知栏弹出时不遮挡游戏 UI

### 6. 构建配置

Player Settings 关键配置：
```
Company Name: CampusKill
Product Name: 校园杀
Default Orientation: Landscape Left
Minimum API Level: 26 (Android 8.0)
Target API Level: 33 (Android 13)
Scripting Backend: IL2CPP
ARM64: Checked
ARMv7: Unchecked
```

### 7. 打包脚本 BuildScript.cs

```csharp
public class BuildScript
{
    [MenuItem("Build/Android APK")]
    public static void BuildAndroid()
    {
        // 自动设置 Bundle Version
        // 执行构建
        // 输出 apk 到 Build/ 目录
    }
}
```

## 禁止行为

- 不要使用 .NET Standard 2.0（必须 .NET 4.x 或 .NET Standard 2.1）
- 不要开启 Development Build（Release 模式构建）
- 不要在 IL2CPP 下使用反射（提前声明 link.xml）
- 不要在移动端使用 OnMouseDown/OnMouseOver（必须走 TouchInputAdapter）

## 验收标准

- ADB install 到 Android 设备能正常启动
- 横屏显示正确，无黑边/拉伸
- 触控操作流畅（拖拽卡牌无延迟）
- APK 大小 ≥ 1GB
- 中低端设备（骁龙 660 / 4GB RAM）能跑 30 FPS
*（内容由AI生成，仅供参考）*
