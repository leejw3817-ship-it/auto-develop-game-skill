---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_7248a914896311f1b66e525400e6dd8f
    ReservedCode1: CAMGI8ZHYZqm4NakZvIM9TCxCbJhvo8WDlmAbNgvUWe0Hli4XFwPCKMYllesM+tQH1Sig40n3/e1U7aLB3Wg/bpbzFGZ/X91ii+cUL0Uqnkrm/pEIo5e/rirRFzMBN5btXNLPdYEpajG3qytq1ezu0BXzW3Zms1GUegDlJ6V2uwBszqO2JwR3U7yWVo=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_7248a914896311f1b66e525400e6dd8f
    ReservedCode2: CAMGI8ZHYZqm4NakZvIM9TCxCbJhvo8WDlmAbNgvUWe0Hli4XFwPCKMYllesM+tQH1Sig40n3/e1U7aLB3Wg/bpbzFGZ/X91ii+cUL0Uqnkrm/pEIo5e/rirRFzMBN5btXNLPdYEpajG3qytq1ezu0BXzW3Zms1GUegDlJ6V2uwBszqO2JwR3U7yWVo=
---

# 校园杀 v0.2 - 资源管线与 1GB 体积达成提示词

## 项目背景

校园杀项目已构建 WebGL (17MB) + Android APK (22MB)。硬性可上线标准：**APK 占存 ≥ 1GB**。本提示词负责设计并执行资源填充管线，将 APK 体积从 22MB 膨胀到 1GB+。

项目根路径：`C:\CampusKillUnity`

## 核心约束

1. **零外部付费资源**：所有资源必须通过程序化生成或从公开开源仓库获取，标注来源 URL。
2. **不降画质**：填充资源必须为高质量（贴图 ≥ 1024x1024，音频 ≥ 44.1kHz 16bit），严禁用空白/低质量文件凑数。
3. **可编译**：每批次资源导入后必须通过 `BuildScript.BuildAndroid` 验证构建成功。

## 体积构成目标

| 类别 | 目标体积 | 策略 |
|------|---------|------|
| 高清角色立绘 | 200MB | 程序化生成 + Kenney/OpenGameArt 获取 |
| 卡牌插画 | 300MB | 程序化 Canvas 2D 生成 200 张唯一卡面 |
| 场景背景 | 150MB | 多层视差背景 + 动态光照贴图 |
| 音频资源 | 200MB | BGM × 5 + SFX × 30，Web Audio API 合成 |
| UI 贴图集 | 100MB | 完整 FairyGUI 组件纹理集 |
| 视频/开场动画 | 50MB | MP4 片头 + 转场动画 |
| 字体资源 | 20MB | 开源中文字体 Noto Sans SC 全套 |
| 预留膨胀 | 30MB | Runtime 数据缓存、存档、日志 |

## 执行步骤

### 步骤 1：Canvas 2D 程序化卡牌生成器

**文件路径：**
- `Assets/_Project/Scripts/Tools/CardTextureGenerator.cs`
- `Assets/_Project/Scripts/Tools/ProceduralArtGenerator.cs`

**功能要求：**
1. 使用 `Texture2D.SetPixels` 程序化生成 **200 张唯一卡面**纹理，每张 1024×1024 RGBA。
2. 每张卡面包含：随机几何背景图案（Perlin 噪声/渐变/条纹）+ 卡牌边框 + 类型图标 + 稀有度光效。
3. 纹理质量设置为 `TextureImporterFormat.RGBA32`，不压缩以保证体积。
4. 生成后保存为 `Assets/_Project/Textures/Cards/card_000.png` ~ `card_199.png`。
5. 每张纹理体积约 4MB（1024×1024×4 字节），200 张 ≈ **800MB**（按需调整为纹理集以节省内存但保留磁盘占用）。

**调整方案：** 使用 2048×2048 RGBA 纹理，每张 16MB，生成 20 张 = 320MB + 卡牌背面/边框 etc。

### 步骤 2：音频资源合成

**文件路径：**
- `Assets/_Project/Scripts/Tools/AudioGenerator.cs`（使用 Unity `AudioClip.Create` 程序化合成）

**功能要求：**
1. **BGM × 5**：通过程序化波形（正弦 + 三角 + 噪声组合）合成不同场景背景音乐，每段 60-120 秒，导出为 WAV 44.1kHz 16bit，存到 `Assets/_Project/Audio/BGM/`。
2. **SFX × 30**：打击音效、抽牌、弃牌、回合切换、胜利/失败等音效，每段 1-3 秒，存到 `Assets/_Project/Audio/SFX/`。
3. 导入设置使用 `AudioImporter` API 设为 `Streaming` + `DecompressOnLoad = false` 以增加磁盘占用。
4. 也可从 Freesound.org（CC0）下载高质量音效作为补充，标注 URL。

### 步骤 3：场景背景与视差

**文件路径：**
- `Assets/_Project/Scripts/Tools/BackgroundGenerator.cs`

**功能要求：**
1. 为战斗场景生成 3 层视差背景（远景天空/中景建筑/近景地面），每层 2048×1024 程序化纹理。
2. 为主菜单生成 1 张全屏背景 2048×2048。
3. 所有背景纹理不压缩（RGBA32），确保体积贡献 ≥ 150MB。
4. 使用 `RenderTexture` + `Camera.Render` 烘焙静态背景到磁盘。

### 步骤 4：立绘与角色图集

**策略：**
- 从 OpenGameArt.org 获取 CC0 角色立绘素材（搜索 "anime character sprite CC0"），下载至少 10 套完整立绘（每个角色含 3-5 表情变体）。
- 若获取不到，使用 Unity `SkinnedMeshRenderer` + 程序化网格生成 3D 角色 → 渲染为 2D 精灵图集。
- 所有立绘导入为 2048×2048 RGBA，不压缩。

### 步骤 5：视频与动画

**文件路径：**
- `Assets/_Project/Scripts/Tools/VideoGenerator.cs`

**功能要求：**
1. 使用 Unity Recorder API 录制 3 秒游戏内场景（开场 Logo 动画）→ 导出为 H.264 MP4，10Mbps 码率 → 约 3.75MB。
2. 补充：使用 FFmpeg 命令行（从 https://ffmpeg.org 下载）生成 20 段粒子/转场视频，每段 2MB → 共 40MB。
3. 全部放入 `Assets/_Project/Videos/` 并标记为 `StreamingAssets`。

### 步骤 6：字体嵌入

1. 从 Google Fonts 下载 Noto Sans SC（简体中文）全套字体文件：https://fonts.google.com/noto/specimen/Noto+Sans+SC
2. 包含 Regular、Bold、Light、Medium 四个字重，全部导入 Unity 为 `Font Asset`（动态模式 character set: Extended ASCII + 常用中文 3500 字）。
3. 字体文件贡献约 20MB。

## 体积验证方法

每完成一个步骤后，在 Unity Editor 中运行以下验证代码（可通过 `BuildScript.BuildAndroid` 构建后检查 APK 大小）：

```csharp
// 在 BuildScript 中添加体积预算检查
static void CheckSizeBudget()
{
    string apkPath = "Builds/Android/CampusKill.apk";
    var fi = new FileInfo(apkPath);
    float gb = fi.Length / 1024f / 1024f / 1024f;
    Debug.Log($"[Budget] APK: {gb:F2} GB / 1.00 GB target");
    if (gb < 1.0f) Debug.LogWarning($"[Budget] 还差 {1.0f - gb:F2} GB");
}
```

## 交付验证

完成后生成 `C:\CampusKillUnity\Builds\size-report.json`：
```json
{
  "apk_total_gb": 0,
  "breakdown": {
    "textures_gb": 0,
    "audio_gb": 0,
    "meshes_gb": 0,
    "animations_gb": 0,
    "fonts_gb": 0,
    "video_gb": 0,
    "code_gb": 0,
    "other_gb": 0
  },
  "passes_1gb": false
}
```

生成 `C:\CampusKillUnity\Builds\size-verification-modal.html` 弹窗验证，逐项勾选各资源类别体积达标情况。
*（内容由AI生成，仅供参考）*
