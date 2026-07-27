---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_0ba7ecd988fe11f1a68c525400826444
    ReservedCode1: mRWemDMESubMhdXxsDiGdkaRPpjw7fd8jM7YCkJ8i7FjiIdKiRGXHEuQrlIeyUx5wT5MJ7a2cK2lQNMhJUIDxCX7bRBV8SiEXU4JEYUyNlv2uJc39qqUrAYgLeueJXtNDg1v+eN0qtMyfjUA1ueTl7cqudIgabN4rj50cogmqj1V+9MkZrkSX5Hayy4=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_0ba7ecd988fe11f1a68c525400826444
    ReservedCode2: mRWemDMESubMhdXxsDiGdkaRPpjw7fd8jM7YCkJ8i7FjiIdKiRGXHEuQrlIeyUx5wT5MJ7a2cK2lQNMhJUIDxCX7bRBV8SiEXU4JEYUyNlv2uJc39qqUrAYgLeueJXtNDg1v+eN0qtMyfjUA1ueTl7cqudIgabN4rj50cogmqj1V+9MkZrkSX5Hayy4=
---

# 校园杀 Unity 免费资源获取与画面优化提示词

> 让 Claude 自行搜寻 Unity 免费资源，下载、适配、优化，最终产出可运行的 3D 校园杀对局画面。

---

## 一、资源获取路线

### 1.1 角色模型与动画

**优先级从高到低**，找到一个足够完整的系列就用，不混搭不同风格。

| 次序 | 来源 | 地址 | 许可 | 说明 |
|------|------|------|------|------|
| 1 | Adobe Mixamo | https://www.mixamo.com | 免费（需 Adobe 账号） | 70+ 角色模型 + 2500+ 动画，直接导出 FBX for Unity。有校园题材角色（学生/运动服/校服风格），动画含 idle/attack/hit/death/victory |
| 2 | Unity Asset Store - RPG Characters | 搜索 "Free RPG Characters" | 免费 / 需遵守各自许可 | 大量免费低模角色包，适合批量选角 |
| 3 | Sketchfab (CC0 filter) | https://sketchfab.com/search?q=anime+character&type=models&license=cc0 | CC0 | 动漫风格角色，需手动筛选 |
| 4 | VRM 模型（BOOTH/CraftPix） | https://booth.pm / https://craftpix.net | 免费 | 日系动漫角色，需 UniVRM 插件导入 |

**Claude 必须执行的 Mixamo 批量下载流程**：

```bash
# Mixamo 没有公开 API，Claude 需要手动操作：
# 1. 浏览器访问 https://www.mixamo.com
# 2. 注册/登录 Adobe 账号（免费）
# 3. 下载以下角色（选"校园/现代"风格的）：
#    - 男性学生 × 11（对应男角色）
#    - 女性学生 × 11（对应女角色）
# 4. 每个角色下载动画：
#    - Idle (原地待机)
#    - Sword Slash / Punch (攻击)
#    - Hit Reaction (受击)
#    - Dying / Death (死亡)
#    - Cheering / Victory (胜利)
# 5. 导出设置：Format: FBX for Unity, Skin: With Skin, FPS: 30, Keyframe Reduction: off
# 6. 放入: Assets/_Project/Models/Characters/
```

**Mixamo 无法访问时的兜底**：

```
使用 Unity 内置的 Character Creator（程序化人体 + 骨骼）：
- UMA 2 (Unity Multipurpose Avatar): 免费程序化角色系统
- 自己拼：Capsule + 四肢 + 头部 → 最简单的卡通风格
- 动画使用 Animation Rigging + 简单的 IK 程序化生成
```

### 1.2 场景模型

| 来源 | 地址 | 许可 | 推荐资产 |
|------|------|------|---------|
| Unity Asset Store | 搜索 "Free Classroom" "Free School" | 免费 | Classroom Pack / School Environment |
| Sketchfab (CC0) | https://sketchfab.com/search?q=classroom&type=models&license=cc0 | CC0 | 教室/操场/天台/图书馆模型 |
| OpenGameArt | https://opengameart.org | CC0/CC-BY | 像素风格可忽略，重点找 3D |
| Kenney Assets | https://kenney.nl/assets/category:3D | CC0 | 家具/建筑/道具 Kit，可搭场景 |
| Quixel Megascans | https://quixel.com/megascans (Unreal 用，但可导出) | 免费 | 高质量 PBR 纹理用于场景材质 |

**五个场景的资源清单**：

| 场景 | 核心模型需求 | 参考搜索关键词 |
|------|-------------|--------------|
| 教室 | 课桌×12、椅子×12、讲台、黑板、窗户、日光灯 | "classroom desk chair blackboard" |
| 操场 | 跑道地面纹理、足球门框、篮球架、看台、旗杆 | "school playground track field" |
| 天台 | 围栏、空调外机、水管、长椅、天空盒 | "rooftop fence city skyline" |
| 图书馆 | 书架×6、阅读桌×2、台灯、书籍堆、地毯 | "library bookshelf reading table" |
| 结算舞台 | 舞台、聚光灯、帷幕、彩带 | "stage spotlight curtain" |

**兜底方案（场景模型找不到时）**：

```
使用 Unity ProBuilder（免费内置工具）手搭场景：
- 教室: Cube 拉成墙壁/地板 + 拉成课桌 + Cylinder 做灯管
- 操场: Plane 铺地面 + Cube 做看台 + 简单几何体拼球门
- 天台: Cube 做围栏 + Cube 做空调外机
- 图书馆: Cube 做书架（中间挖空放书籍色块）
- 用量：每个场景约 30-80 个简单几何体，纯色材质 + 少量纹理贴花

ProBuilder 快捷键：
  Ctrl+K: 切换面/边/顶点模式
  Shift+拖拽面: 挤出
  Ctrl+Shift+拖拽边: 倒角
```

### 1.3 特效资源

| 来源 | 地址 | 许可 | 说明 |
|------|------|------|------|
| Unity Asset Store - "Free VFX" | 搜索 "Free VFX Pack" / "Free Particle Pack" | 免费 | Cartoon FX Free / Unity Particle Pack |
| Unity Asset Store - "Free Shader" | 搜索 "Free Shader" | 免费 | 溶解/发光/描边 Shader |
| Real-Time VFX | https://realtimevfx.com | 社区 | 大量免费粒子系统预设 |
| ShaderToy 转 Unity | https://www.shadertoy.com | CC-BY-NC-SA | 酷炫 Shader 效果，需手动移植到 Shader Graph |

**需要的特效清单（30 种）**：

```
攻击类: 剑气斩 / 拳风 / 能量弹 / 血溅 / 火花
治疗类: 绿色光柱 / 十字光 / 花瓣飘落 / 生命回流
技能类: 火焰爆发 / 冰霜冻结 / 暗影吞噬 / 雷霆一击 / 圣光审判
状态类: 中毒(绿雾) / 眩晕(星旋) / 沉默(锁链) / 灼烧(火焰光环)
卡牌类: 出牌拖尾 / 卡牌飞行弧线 / 稀有度光晕(金/紫/蓝/白)
场景类: 樱花飘落 / 落叶 / 粉笔灰 / 浮尘 / 雨水(天台)
结算类: 彩带 / 烟花 / 聚光灯 / 金色光环
```

**兜底方案（特效全都找不到时）**：

```
用 Unity VFX Graph + Shader Graph 自制所有特效（约 200 行代码）：
- 伤害: 红色粒子爆发 + 屏幕震动
- 治疗: 绿色上升粒子 + 十字光晕
- 出牌: 拖尾 Trail Renderer + 金色粒子
- 卡牌稀有度: Shader Graph 边缘发光 (Fresnel Effect)
```

### 1.4 音频资源

| 来源 | 地址 | 许可 | 说明 |
|------|------|------|------|
| Freesound | https://freesound.org | CC0 | 按标签搜索，大量游戏音效 |
| Mixkit | https://mixkit.co/free-sound-effects/ | 免费商用 | UI/战斗音效 |
| OpenGameArt | https://opengameart.org/art-search-advanced?field_art_type_tid%5B%5D=13 | CC0 | 专为游戏设计的音效 |
| Pixabay Sound Effects | https://pixabay.com/sound-effects/ | 免费商用 | 通用音效 |

**需要下载的音效清单**：

```
战斗: sword_swing / punch_hit / whoosh / impact / blood_splat
魔法: fire_burst / ice_crack / thunder / heal_chime / dark_woosh  
UI:   card_draw / card_place / button_click / turn_start / timer_tick
环境: classroom_ambient / playground_wind / rooftop_wind / library_quiet
角色: male_hurt / female_hurt / male_death / female_death / cheer
```

**BGM 清单**：

```
主菜单: 轻快校园感（搜索 "school anime bgm" "light adventure"）
对局1: 紧张对决（搜索 "battle tension" "duel"）
对局2: 热血激昂（搜索 "epic battle" "fighting spirit"）
残局:  压迫感（搜索 "desperate" "last stand"）
胜利:  庆祝（搜索 "victory fanfare" "triumph"）
失败:  惋惜（搜索 "defeat" "sad ending"）
```

### 1.5 UI 贴图与材质

| 来源 | 地址 | 许可 | 说明 |
|------|------|------|------|
| ambientCG | https://ambientcg.com | CC0 | PBR 材质（纸张、布料、木材、金属） |
| Poly Haven | https://polyhaven.com/textures | CC0 | 高质量 HDR 环境贴图 + PBR 纹理 |
| Unity Asset Store | 搜索 "Free UI Pack" / "Free GUI" | 免费 | UI 套件 |

**用于卡牌/UI 面板的材质**：
- 卡牌基底：Old Paper / Parchment（泛黄纸张感，校园风格）
- 稀有度边框：Gold / Silver / Copper 金属材质
- 面板背景：Canvas Fabric / Dark Wood（教室桌面感）
- 按钮：Brushed Metal / Glossy Plastic

---

## 二、画面渲染优化

### 2.1 URP 配置

```csharp
// URP 设置文件 (.asset) 需配置的关键项

// 渲染质量:
Quality:
  Anti Aliasing (MSAA): 4x
  Render Scale: 1.0 (桌面) / 0.8 (移动)
  Shadow Resolution: 2048 (桌面) / 1024 (移动)
  Shadow Distance: 30
  Shadow Cascades: 2
  Soft Shadows: Enabled (桌面) / Disabled (移动)
  LOD Bias: 1.0

// 后处理（桌面端）:
Post-processing:
  Bloom: Intensity 0.3, Threshold 0.9, Scatter 0.7
  Color Grading: ACES Tonemapping, Saturation +10
  Vignette: Intensity 0.2, Smoothness 0.3
  Depth of Field: 仅结算画面使用, Aperture f/2.8

// 移动端后处理（精简）:
Post-processing:
  Bloom: Intensity 0.15
  Color Grading: Neutral Tonemapping
```

### 2.2 光照系统

```
场景主光 (Directional Light):
  教室: 色温 5500K (自然日光), Intensity 2.0, 从窗户方向射入
  操场: 色温 4500K (傍晚), Intensity 1.5, 低角度长阴影
  天台: 色温 6000K (午后), Intensity 2.5, 顶部照射
  图书馆: 色温 3200K (暖色台灯), Intensity 0.8, 点光源多盏

环境光:
  使用 HDRI Skybox (Poly Haven 免费下载)
  环境光强度: 0.5 (让暗部不完全黑)

角色打光:
  每个角色前方 45° 补面光 (Spot Light, Intensity 0.5, 仅照亮角色 Layer)
  避免脸部阴影过重

稀有度卡牌发光:
  传说: Emissive 材质, 金色自发光 + Bloom 溢出
  史诗: Emissive 材质, 紫色自发光
  稀有: Emissive 材质, 蓝色自发光
  普通: 无自发光
```

### 2.3 材质优化

所有从 Mixamo/Sketchfab 下载的模型，材质需要统一改造：

```
1. 转换所有材质为 URP/Lit
2. 贴图导入设置:
   - Max Size: 1024（角色）/ 2048（场景主纹理）
   - Compression: High Quality (桌面) / Normal Quality (移动)
   - Generate Mip Maps: ✓
   - sRGB: ✓ (Base Map) / ✗ (Normal Map / Metallic / AO)
3. 移除不需要的贴图通道（如果角色不需要 Emission / Height Map，删掉节省内存）
4. 合并贴图：Metallic + Smoothness + AO 合并为一张 Mask Map（URP 标准做法）
```

### 2.4 自定义 Shader（Shader Graph）

**必须实现的 4 个 Shader**：

#### Shader 1: 卡牌稀有度光晕 (`CardRarityGlow`)

```
效果: 卡牌边缘根据稀有度发出不同颜色的光
技术: Fresnel Effect × Emissive Color
参数: GlowColor(HDR), GlowIntensity(0-2), GlowWidth(0-1), PulseSpeed(0-5)
实现:
  1. 取法线 · 视线方向 = Fresnel 系数
  2. Fresnel × GlowWidth → 边缘遮罩
  3. 边缘遮罩 × GlowColor × GlowIntensity → Emissive 输出
  4. 加 sin(Time × PulseSpeed) × 0.3 → 呼吸闪烁
```

#### Shader 2: 选中高亮描边 (`OutlineHighlight`)

```
效果: 选中的卡牌/角色发出描边光
技术: 顶点挤出 + 常量颜色
参数: OutlineColor(HDR), OutlineWidth(0-0.05)
实现:
  1. 复制模型，顶点沿法线方向挤出 OutlineWidth
  2. 渲染为纯色 OutlineColor，Cull Front
  3. 原始模型正常渲染，Cull Back
```

#### Shader 3: 溶解死亡 (`HeroDissolve`)

```
效果: 角色阵亡时从下往上溶解消失
技术: Noise Texture + Alpha Clip
参数: DissolveAmount(0-1), EdgeColor(HDR), EdgeWidth(0-0.2), NoiseScale
实现:
  1. 采样 Noise Texture
  2. 物体空间 Y 坐标 + Noise → 与 DissolveAmount 比较
  3. 小于阈值的像素 clip 丢弃
  4. 阈值附近的像素混合 EdgeColor → 溶解边缘发光
```

#### Shader 4: 校园风 Toon Shading (`CampusToon`)

```
效果: 日系校园动画风格的卡通渲染
技术: Ramp Texture + 硬边光照
参数: ShadowThreshold(0-1), ShadowColor, HighlightColor, OutlineColor
实现:
  1. NdotL 映射到 Ramp Texture（2-3 级色阶）
  2. 暗部混合 ShadowColor，亮部混合 HighlightColor
  3. 叠加 Fresnel Rim Light（微弱的边缘光）
  4. 可选：加一层顶点挤出描边
```

### 2.5 后处理 Volume 配置

```csharp
// 每个场景的 Volume Profile

// 教室场景:
Bloom: On (Intensity 0.4)
Color Adjustments: Contrast +5, Saturation +8
Lift Gamma Gain: Gamma 略微提升 (让暗部不沉闷)
Vignette: On (Intensity 0.2)
// 特征: 温暖、明亮的教室氛围

// 操场场景:
Bloom: On (Intensity 0.6, 傍晚太阳光晕)
Color Adjustments: Saturation +15, Post Exposure +0.3
Lift Gamma Gain: Gain 偏暖 (模拟夕阳光)
// 特征: 热血、夕阳逆光

// 天台场景:
Bloom: On (Intensity 0.3)
Color Adjustments: Contrast +10
Lift Gamma Gain: Lift 偏蓝 (天空反射)
// 特征: 开阔、高对比度

// 图书馆场景:
Bloom: On (Intensity 0.15)  
Color Adjustments: Saturation -5, Contrast -5
Lift Gamma Gain: Gamma 提升 (弱光环境补亮)
Vignette: On (Intensity 0.4)
// 特征: 静谧、柔和

// 结算场景:
Bloom: On (Intensity 0.8, 舞台聚光灯感)
Color Adjustments: Saturation +20, Contrast +10
Vignette: On (Intensity 0.5)
// 特征: 戏剧性、舞台效果
```

### 2.6 性能优化清单

| 优化项 | 方法 | 目标 |
|--------|------|------|
| LOD 组 | 每个角色/场景物体设 3 级 LOD (100%/60%/30% 顶点数) | 远处物体减面 |
| 静态批处理 | 场景中不动的物体（课桌/书架）标记 Static | 减少 Draw Call 60% |
| GPU Instancing | 相同材质的重复物体（椅子×12）启用 GPU Instancing | 12 个 Draw Call → 1 个 |
| Occlusion Culling | 烘焙遮挡剔除数据（教室墙壁后不渲染） | 减少三角面 30% |
| 粒子池 | 所有特效使用 Object Pool，预实例化 20 个 | 避免运行时 Instantiate |
| 纹理图集 | UI 图标/小贴图合并为 Atlas (2048×2048) | 减少 50 个 Draw Call |
| Shader 变体剥离 | 仅保留 URP Lit + 自定义 Shader，剥离内置管线 | 减小 Wasm 体积 40% |
| 反射探针 | 每场景放置 1-2 个 Reflection Probe（低分辨率 128px） | 提升金属/光滑材质真实感 |

---

## 三、卡牌 3D 化

### 3.1 卡牌模型规格

```
卡牌尺寸（Unity 单位）: 1.1 × 1.55 × 0.02 (宽×高×厚)
比例: 标准卡牌 5:7
三角面数: ~200 (正面 + 背面 + 侧面 + 厚度)
材质: 
  正面: 程序化生成的卡面纹理 (1024×1448 px)
  背面: 统一卡背纹理 (512×724 px)
  侧面: 稀有度颜色边框
  厚度: 白色纸质感
```

### 3.2 卡牌程序化纹理生成

```csharp
// CardTextureGenerator.cs
// 在 Unity Editor 中运行，批量生成 60 张卡面的 3D 材质

public static Texture2D GenerateCardFace(CardData data)
{
    int w = 1024, h = 1448;
    var rt = RenderTexture.GetTemporary(w, h, 24);
    
    // 1. 绘制卡牌基底（纸张纹理）
    Graphics.Blit(paperTexture, rt);
    
    // 2. 绘制名称栏（顶部横条）
    DrawRect(rt, new Rect(40, 40, w-80, 120), nameBarColor);
    DrawText(rt, data.name, new Rect(60, 50, w-120, 100), titleFont);
    
    // 3. 绘制费用（左上角圆形）
    DrawCircle(rt, new Vector2(100, 190), 60, costCircleColor);
    DrawText(rt, data.cost.ToString(), new Rect(60, 160, 80, 60), numberFont);
    
    // 4. 绘制插画区域（中央 800×800）
    DrawCardIllustration(rt, data.illustrationSeed, new Rect(112, 260, 800, 800));
    
    // 5. 绘制描述文本框
    DrawTextBox(rt, data.description, new Rect(80, 1100, w-160, 200), bodyFont);
    
    // 6. 绘制属性（底部右下角）
    if (data.type == CardType.Minion)
    {
        DrawAttribute(rt, "ATK", data.attack, new Vector2(200, 1320), attackIcon);
        DrawAttribute(rt, "HP", data.health, new Vector2(w-200, 1320), healthIcon);
    }
    
    // 7. 稀有度边框光效
    DrawRarityBorder(rt, data.rarity);
    
    // 8. 职业颜色条纹（左侧竖条）
    DrawClassStripe(rt, data.classType);
    
    var result = new Texture2D(w, h);
    RenderTexture.active = rt;
    result.ReadPixels(new Rect(0, 0, w, h), 0, 0);
    result.Apply();
    
    RenderTexture.ReleaseTemporary(rt);
    return result;
}
```

### 3.3 手牌弧线布局

```csharp
// CardLayoutManager.cs
// 手牌在玩家前方呈弧形排列

public Vector3[] CalculateHandPositions(int cardCount, float radius, float arcAngle)
{
    var positions = new Vector3[cardCount];
    float angleStep = arcAngle / (cardCount - 1);
    float startAngle = -arcAngle / 2;

    for (int i = 0; i < cardCount; i++)
    {
        float angle = startAngle + i * angleStep;
        float rad = angle * Mathf.Deg2Rad;
        
        // 弧形位置
        float x = Mathf.Sin(rad) * radius;
        float z = Mathf.Cos(rad) * radius;
        
        // 高度：中间高两边低，模拟手牌自然弧度
        float normDist = Mathf.Abs(i - (cardCount - 1) / 2f) / ((cardCount - 1) / 2f);
        float y = -0.5f - normDist * 0.3f;
        
        // 旋转：每张卡牌略向外偏转
        float rotY = -angle * 0.6f;
        
        positions[i] = new Vector3(x, y, z);
    }
    return positions;
}
```

---

## 四、角色动画状态机

每个角色使用 Unity Animator Controller，包含以下状态和过渡：

```
┌─────────┐  PlayCard  ┌──────────┐
│  Idle   │───────────→│ Attack   │────→ back to Idle
│ (待机)   │←───────────│ (攻击)    │
└────┬────┘            └──────────┘
     │ TakeDamage
     ▼
┌──────────┐           ┌──────────┐
│  Hurt    │──────────→│ Idle     │
│ (受击)    │  recover  │          │
└────┬─────┘           └──────────┘
     │ HP <= 0
     ▼
┌──────────┐  finished ┌──────────┐
│  Death   │──────────→│ Disabled │
│ (死亡)    │           │ (从场景移除)│
└──────────┘           └──────────┘

过渡条件:
  Idle → Attack:  trigger "PlayCard" (由 CommandHandler 触发)
  Idle → Hurt:    trigger "TakeDamage"
  Idle → Death:   trigger "Die"
  Attack → Idle:  animation complete (Has Exit Time)
  Hurt → Idle:    animation complete
  Death → Disabled: animation complete
```

---

## 五、画面质量分级与自适应

```csharp
// GraphicsTierManager.cs
public enum GraphicsTier { Ultra, High, Medium, Low }

public class GraphicsTierManager : MonoBehaviour
{
    public GraphicsTier DetectTier()
    {
        // 检测 GPU 型号 + 屏幕分辨率
        int vram = SystemInfo.graphicsMemorySize; // MB
        int width = Screen.width;
        
        if (vram >= 4000 && width >= 1920) return GraphicsTier.Ultra;
        if (vram >= 2000 && width >= 1080) return GraphicsTier.High;
        if (vram >= 1000) return GraphicsTier.Medium;
        return GraphicsTier.Low;
    }

    public void ApplyTier(GraphicsTier tier)
    {
        switch (tier)
        {
            case GraphicsTier.Ultra:
                // 4x MSAA + Bloom + DoF + 2048 Shadow + 全粒子
                break;
            case GraphicsTier.High:
                // 2x MSAA + Bloom + 1024 Shadow + 粒子减半
                break;
            case GraphicsTier.Medium:
                // 无 MSAA + 无后处理 + 512 Shadow + 粒子四分之一
                break;
            case GraphicsTier.Low:
                // 最低画质: 无阴影 + 无后处理 + 无粒子 + LOD 强制最低
                break;
        }
    }
}
```

---

## 六、落地执行顺序（Claude 必须按此顺序）

```
Step 1: Unity 项目初始化
  ├── 创建 URP 项目 (Unity 2022.3 LTS)
  ├── 配置 URP 渲染管线（按 2.1 配置）
  ├── 导入 Addressables 包
  └── 建好目录结构（按双引擎提示词的目录）

Step 2: 下载资源
  ├── Mixamo: 22 个角色模型 + 5 套动画（idle/attack/hurt/death/victory）
  ├── Asset Store / Sketchfab: 5 个场景模型
  ├── Asset Store: 特效包 (Cartoon FX Free)
  ├── Freesound: 音效包
  ├── OpenGameArt: BGM 6 首
  └── ambientCG / Poly Haven: PBR 纹理 + HDR 天空盒

Step 3: 资源适配
  ├── 所有材质转 URP/Lit
  ├── 贴图统一设置 (Max Size / Compression / Mip Maps)
  ├── 角色设 LOD Group (3 级)
  └── 场景物体标记 Static + 烘焙 Occlusion Culling

Step 4: Shader 开发
  ├── CardRarityGlow (卡牌稀有度光晕)
  ├── OutlineHighlight (选中描边)
  ├── HeroDissolve (角色溶解死亡)
  └── CampusToon (校园卡通渲染，可选覆盖所有角色)

Step 5: 场景搭建
  ├── 教室: 课桌排列 + 黑板 + 窗户光 + Bloom
  ├── 操场: 跑道 + 球门 + 夕阳 HDRI + 高 Bloom
  ├── 天台: 围栏 + 城市远景 + 风粒子
  ├── 图书馆: 书架 + 台灯点光 + 浮尘粒子
  └── 结算: 舞台 + 聚光灯 + 彩带粒子

Step 6: 卡牌 3D 化
  ├── CardTextureGenerator.cs (程序化生成 60 张卡面)
  ├── CardLayoutManager.cs (手牌弧线布局)
  └── 卡牌预制体 (3D 薄片 + CardRarityGlow 材质)

Step 7: 角色动画
  ├── Animator Controller (5 状态 + 过渡)
  └── CharacterAnimator.cs (脚本控制动画切换)

Step 8: 后处理调校
  ├── 每个场景创建专属 Volume Profile
  └── GraphicsTierManager.cs (自适应质量)

Step 9: 集成到双引擎架构
  ├── CommandHandler.cs 对接 Phaser 命令
  ├── EventDispatcher.cs 对接 Phaser 事件
  └── 全流程跑通: 主菜单→选将→对局→结算
```

---

## 七、验收标准

| 指标 | 目标 |
|------|------|
| 场景视觉品质 | 5 个场景各有独特氛围，非复用 |
| 角色动画 | 22 个角色均有 idle/attack/hurt/death/victory 动画 |
| 卡牌品质 | 60 张卡牌有程序化卡面 + 稀有度光效 + 3D 厚度 |
| 特效覆盖 | 伤害/治疗/技能/出牌/死亡 5 类特效齐全 |
| 画面帧率 | 桌面 ≥ 55 FPS, 移动 ≥ 30 FPS (Unity 侧) |
| 资源体积 | 初始下载 ≤ 20MB, 场景角色按需加载 |
| 降级覆盖 | Low/Medium/High/Ultra 四档自动切换 |
| 可运行性 | 主菜单 → 选将 → 对局 → 结算 完整走通，视觉上为 3D 场景 |

---

## 八、输出要求

1. 所有资源必须实际从互联网下载，确有困难的用兜底方案，不得留空占位
2. Unity 项目完整可打开，所有脚本/场景/预制体就绪
3. 最终产物：从浏览器打开 index.html 看到 3D 校园杀对局画面
4. 与 Phaser 集成走通至少一条完整命令链路（如 "LOAD_SCENE" → Unity 切换场景）
5. 代码使用 C# + TypeScript，类型完备
*（内容由AI生成，仅供参考）*
