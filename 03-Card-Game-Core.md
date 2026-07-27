---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_5f3336e6890711f1a68c525400826444
    ReservedCode1: gOt7Pghbifk/1qHXMEpTTVwUsoD5LjB2R4UcCKNJKwRdOHBOSR4sTO//JGymzSmafHA8zri2MSTyNiyQasTmmug7u9iCrmvyKUzhEXcF1/Xe471F/l5WR5GrEUnLLEBuXFr7yj39UE3P4V0SxtrP81q5y7L4h+pI42i9D/vrsi8O8xxk5JVJ1B+q+X8=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_5f3336e6890711f1a68c525400826444
    ReservedCode2: gOt7Pghbifk/1qHXMEpTTVwUsoD5LjB2R4UcCKNJKwRdOHBOSR4sTO//JGymzSmafHA8zri2MSTyNiyQasTmmug7u9iCrmvyKUzhEXcF1/Xe471F/l5WR5GrEUnLLEBuXFr7yj39UE3P4V0SxtrP81q5y7L4h+pI42i9D/vrsi8O8xxk5JVJ1B+q+X8=
---

# FairyGUI 校园杀 UI 包 — Claude 自动操作提示词

> 环境已搭好，FairyGUI Editor 已启动，项目 CampusKill 已创建，5 个 UI 包空文件夹已建好。
> 你的任务：在 FairyGUI Editor 中完成 6 个 UI 包的全部组件设计，然后导出 .bytes 文件。

---

## 一、当前环境

| 项目 | 值 |
|------|-----|
| FairyGUI Editor 路径 | `D:\Program Files\FairyGUI-Editor\FairyGUI-Editor\FairyGUI-Editor.exe` |
| 项目名称 | CampusKill |
| 项目路径 | `C:\Users\31184\Desktop\校园杀v0.1\FairyGUI-Project` |
| 分辨率 | 1280 × 720 |
| 已建包文件夹 | MainMenu / HeroSelect / BattleHUD / ResultPanel / CardTooltip / ResponsivePanel |
| 设计主题 | 日系校园热血 |
| 主色 | `#E53935` 斗志红 |
| 辅色 | `#1E88E5` 理性蓝 |
| 强调色 | `#FFB300` 警示琥珀 |
| 成功色 | `#43A047` 和平绿 |
| 背景深色 | `#1A1A2E` |
| 文字主色 | `#FFFFFF` / `#333333`（根据背景） |

---

## 二、操作前准备

### 2.1 确认 FairyGUI Editor 窗口在前台

1. Alt+Tab 切换到 FairyGUI Editor
2. 确认标题栏显示 "FairyGUI 编辑器 - CampusKill"
3. 如果窗口不在前台，用任务栏图标激活

### 2.2 确认项目结构

在左侧项目面板中应看到 6 个包节点：
```
CampusKill
├── MainMenu
├── HeroSelect
├── BattleHUD
├── ResultPanel
├── CardTooltip
└── ResponsivePanel
```

如果缺少任何一个，右键项目根 → 新建包 → 输入名称。

---

## 三、UI 包设计规格

> 操作模式：选中目标包 → 在右侧组件面板右键 → 新建组件 →
> 按表格设置属性 → 保存。
>
> 每次创建组件后截一张图确认位置和样式正确，再继续下一个。

---

### 包 1：MainMenu（主菜单）

右键 `MainMenu` 包 → 新建组件，依次创建：

#### 组件 1-1：bg_overlay
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `bg_overlay`，宽 1280，高 720 |
| 2 | 工具栏选「矩形」，在画布拖满整个区域 |
| 3 | 选中矩形 → 右侧属性面板 → 填充颜色 `#000000`，不透明度 60% |

#### 组件 1-2：logo_text
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `logo_text` |
| 2 | 工具栏选「文本」，在画布点击 |
| 3 | 文本内容：`校园杀` |
| 4 | 字体大小：48px，加粗 |
| 5 | 字体颜色：`#E53935` |
| 6 | 位置：X=640（居中），Y=200 |
| 7 | 自动大小：宽度和高度都设为自动 |

#### 组件 1-3：btn_1v1
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `btn_1v1`，类型选「按钮」 |
| 2 | 宽 240，高 60 |
| 3 | 背景：矩形，填充 `#E53935`，圆角 12px |
| 4 | 标题文字：`1v1 对战`，白色，24px，加粗，居中 |
| 5 | 位置：X=640（居中），Y=360 |

#### 组件 1-4：btn_3v3
| 步骤 | 操作 |
|------|------|
| 1 | 复制 btn_1v1，重命名 `btn_3v3` |
| 2 | 标题文字改为：`3v3 身份局` |
| 3 | Y 位置改为 440 |

#### 组件 1-5：btn_settings
| 步骤 | 操作 |
|------|------|
| 1 | 复制 btn_1v1，重命名 `btn_settings` |
| 2 | 标题文字改为：`设置` |
| 3 | 背景颜色改为 `#666666` |
| 4 | Y 位置改为 520 |

#### 组件 1-6：txt_version
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `txt_version` |
| 2 | 文本内容：`v0.2` |
| 3 | 字体大小：14px，颜色 `#999999` |
| 4 | 位置：X=1240，Y=690（右下角） |

#### 按钮动效设置（btn_1v1 / btn_3v3 / btn_settings）
| 步骤 | 操作 |
|------|------|
| 1 | 选中按钮组件 |
| 2 | 右侧属性面板 → 过渡 → 点击「+」 |
| 3 | 触发方式：鼠标悬停 |
| 4 | 缩放：ScaleX=1.05，ScaleY=1.05 |
| 5 | 持续时间：0.2 秒 |

#### 包 1 完成验证
- [ ] bg_overlay：全屏半透明黑色遮罩
- [ ] logo_text：红色 "校园杀" 大字居中
- [ ] btn_1v1：红色圆角按钮，悬停放大
- [ ] btn_3v3：同上
- [ ] btn_settings：灰色按钮
- [ ] txt_version：右下角灰色小字

---

### 包 2：HeroSelect（选将界面）

右键 `HeroSelect` 包 → 新建组件：

#### 组件 2-1：title_bar
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `title_bar`，宽 1280，高 60 |
| 2 | 矩形背景：宽 1280，高 60，填充 `#E53935` |
| 3 | 添加文本 "选择你的英雄"，白色 28px 加粗，居中 |

#### 组件 2-2：hero_list
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `hero_list`，类型选「列表」 |
| 2 | 宽 600，高 500 |
| 3 | 位置：X=40，Y=80 |
| 4 | 列表模式：单选 |
| 5 | 滚动设置：垂直滚动，虚拟列表勾选（如果有此选项） |
| 6 | 折叠式隐藏：开启（不渲染屏幕外的项） |

#### 组件 2-3：hero_item
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `hero_item`，宽 580，高 100 |
| 2 | 背景：矩形，填充 `#2A2A3E`，圆角 8px，不透明度 90% |
| 3 | 圆形头像：图形-圆形，直径 80，X=20，Y=10，填充灰色 `#666666` |
| 4 | 文本-名字：X=120，Y=15，字体 20px 白色加粗 |
| 5 | 文本-描述：X=120，Y=45，字体 14px `#AAAAAA`，宽 440 |

- [ ] 将 hero_item 设置为 hero_list 的列表项

#### 组件 2-4：skill_panel
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `skill_panel`，宽 500，高 400 |
| 2 | 位置：X=700，Y=80 |
| 3 | 背景：矩形，填充 `#1E1E30`，圆角 12px |
| 4 | 标题文本："技能详情"，20px `#1E88E5`，X=20，Y=20 |

#### 组件 2-5：skill_item
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `skill_item`，宽 460，高 auto |
| 2 | 文本-技能名：18px 加粗 `#1E88E5` |
| 3 | 文本-技能描述：14px `#CCCCCC`，多行，行高 1.6 |

#### 组件 2-6：btn_confirm
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `btn_confirm`，类型选「按钮」，宽 200，高 55 |
| 2 | 背景：`#E53935`，圆角 12px |
| 3 | 标题："确认选择"，白色 22px 加粗 |
| 4 | 位置：X=640（居中），Y=580 |

#### 组件 2-7：timer_ring
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `timer_ring`，类型选「进度条」 |
| 2 | 宽 80，高 80，环形模式 |
| 3 | 最大值 30，当前值 30 |
| 4 | 前景色：渐变 绿→黄→红 |
| 5 | 位置：标题栏右侧 X=1200，Y=5 |

#### 包 2 完成验证
- [ ] title_bar：红色顶栏 + 白色标题
- [ ] hero_list：左侧可滚动列表
- [ ] hero_item：含圆形头像 + 名字 + 描述
- [ ] skill_panel：右侧技能展示区
- [ ] btn_confirm：底部红色确认按钮
- [ ] timer_ring：30 秒环形倒计时

---

### 包 3：BattleHUD（对局核心 HUD）

右键 `BattleHUD` 包 → 这是最复杂的包，逐区创建：

#### 3-A 顶部栏

**组件 3-1：top_bar**
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `top_bar`，宽 1280，高 50 |
| 2 | 背景矩形：填充 `#000000`，不透明度 60% |

**组件 3-2：txt_turn**（放在 top_bar 内部）
| 步骤 | 操作 |
|------|------|
| 1 | 在 top_bar 内添加文本 |
| 2 | 文本："第 1 回合"，白色 16px |
| 3 | X=20，Y=15（左对齐） |

**组件 3-3：phase_indicator**
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `phase_indicator`，宽 500，高 50 |
| 2 | 在 top_bar 内，X=390（居中），Y=0 |
| 3 | 5 个文本横向排列，间距 20px |
| 4 | 文本内容："判定" / "摸牌" / "出牌" / "弃牌" / "回合结束" |
| 5 | 字体 16px，默认颜色 `#888888` |
| 6 | 当前阶段高亮：颜色 `#E53935`，加粗 |

**组件 3-4：timer_bar**
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `timer_bar`，类型选「进度条」 |
| 2 | 宽 200，高 16 |
| 3 | 最大值 20，当前值 20 |
| 4 | 前景色 `#E53935`，背景色 `#333333` |
| 5 | 在 top_bar 内，X=1050，Y=17（右侧） |

#### 3-B 玩家区域（左下）

**组件 3-5：player_panel**
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `player_panel`，宽 400 |
| 2 | 位置：X=20，Y=620（左下） |

在 player_panel 内：

**组件 3-5a：avatar_player**
| 步骤 | 操作 |
|------|------|
| 1 | 图形-圆形，直径 80 |
| 2 | 填充灰色 `#666666` |
| 3 | 位置：X=10，Y=10 |

**组件 3-5b：hp_bar_player**
| 步骤 | 操作 |
|------|------|
| 1 | 进度条，宽 250，高 16 |
| 2 | 最大值 5，当前值 5（5 格血） |
| 3 | 前景色 `#E53935` |
| 4 | 位置：X=100，Y=20，放在头像右侧 |
| 5 | 标签文本 "HP" 在进度条左侧 |

**组件 3-5c：txt_hand_count**
| 步骤 | 操作 |
|------|------|
| 1 | 文本："手牌: 4"，14px 白色 |
| 2 | 位置：X=100，Y=45 |

**组件 3-5d：equip_area**
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `equip_area`，宽 360，高 100 |
| 2 | 4 个 60×90 格子横向排列，间距 15px |
| 3 | 每个格子：矩形边框，`#555555`，标签："武器"/"防具"/"+1马"/"-1马" |
| 4 | 位置：X=100，Y=70 |

#### 3-C 对手区域（右上，镜像）

**组件 3-6：enemy_panel**
| 步骤 | 操作 |
|------|------|
| 1 | 复制 player_panel，重命名 `enemy_panel` |
| 2 | 宽 400 |
| 3 | 位置：X=860，Y=70（右上） |
| 4 | 水平翻转内部布局（头像在右，血条在左） |
| 5 | 或简单保持相同布局即可 |

#### 3-D 底部操作区

**组件 3-7：bottom_bar**
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `bottom_bar`，宽 1280，高 80 |
| 2 | 背景：`#000000`，不透明度 50% |
| 3 | 位置：X=0，Y=640（底部） |

在 bottom_bar 内：

**组件 3-7a：btn_end_turn**
| 步骤 | 操作 |
|------|------|
| 1 | 按钮，宽 160，高 50 |
| 2 | 标题："结束回合"，白色 20px |
| 3 | 背景 `#E53935`，圆角 10px |
| 4 | 位置：X=1060，Y=15 |

**组件 3-7b：btn_confirm**
| 步骤 | 操作 |
|------|------|
| 1 | 按钮，宽 120，高 45 |
| 2 | 标题："确定"，白色 18px |
| 3 | 背景 `#E53935`，默认隐藏 |
| 4 | 位置：X=900，Y=18 |

**组件 3-7c：btn_cancel**
| 步骤 | 操作 |
|------|------|
| 1 | 按钮，宽 120，高 45 |
| 2 | 标题："取消"，白色 18px |
| 3 | 背景 `#666666`，默认隐藏 |
| 4 | 位置：X=1040，Y=18 |

#### 3-E 战斗日志（右侧）

**组件 3-8：log_panel**
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `log_panel`，宽 300，高 420 |
| 2 | 背景：`#000000`，不透明度 50%，圆角 8px |
| 3 | 位置：X=960，Y=100（右侧） |

在 log_panel 内：

**组件 3-8a：log_list**
| 步骤 | 操作 |
|------|------|
| 1 | 列表，宽 280，高 400，垂直滚动 |
| 2 | 位置：X=10，Y=10 |

**组件 3-8b：log_item**
| 步骤 | 操作 |
|------|------|
| 1 | 文本组件，自动高度，宽 260 |
| 2 | 字体 14px |
| 3 | 颜色根据类型：伤害=红`#FF4444` / 治疗=绿`#44FF44` / 系统=白`#CCCCCC` |
| 4 | 设为 log_list 的列表项 |

#### 包 3 完成验证
- [ ] top_bar：回合数 + 阶段指示器 + 倒计时条
- [ ] player_panel：头像 + 血条 + 手牌数 + 装备区
- [ ] enemy_panel：右上镜像
- [ ] bottom_bar：结束回合 + 确定/取消按钮
- [ ] log_panel + log_list：可滚动战斗日志

---

### 包 4：ResultPanel（结算界面）

右键 `ResultPanel` 包 → 新建组件：

#### 组件 4-1：bg_overlay
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `bg_overlay`，宽 1280，高 720 |
| 2 | 矩形全屏遮罩，填充 `#000000`，不透明度 70% |

#### 组件 4-2：result_text
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `result_text` |
| 2 | 文本："胜利！"，48px 加粗 |
| 3 | 颜色：`#FFD700`（金色） |
| 4 | 位置：X=640（居中），Y=180 |

#### 组件 4-3：mvp_panel
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `mvp_panel`，宽 400，高 300 |
| 2 | 背景矩形：`#1E1E30`，圆角 16px |
| 3 | 位置：X=640（居中），Y=280 |
| 4 | 标题文本："MVP"，28px 金色 `#FFD700`，居中 |
| 5 | 英雄头像占位：圆形 100×100，灰色，居中 |
| 6 | 英雄名字：22px 白色，居中 |

#### 组件 4-4：stats_table
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `stats_table`，宽 500 |
| 2 | 位置：X=640（居中），Y=600 |
| 3 | 4 行数据，每行：标签(左) + 数值(右) |
| 4 | 行 1：伤害量 → 数值 |
| 5 | 行 2：治疗量 → 数值 |
| 6 | 行 3：出牌数 → 数值 |
| 7 | 行 4：回合数 → 数值 |
| 8 | 标签 16px `#AAAAAA`，数值 20px 白色加粗 |

#### 组件 4-5：btn_rematch
| 步骤 | 操作 |
|------|------|
| 1 | 按钮，命名 `btn_rematch`，宽 200，高 55 |
| 2 | 标题："再来一局"，白色 22px 加粗 |
| 3 | 背景：`#E53935`，圆角 12px |
| 4 | 位置：X=540，Y=720 |

#### 组件 4-6：btn_lobby
| 步骤 | 操作 |
|------|------|
| 1 | 按钮，命名 `btn_lobby`，宽 180，高 50 |
| 2 | 标题："返回大厅"，白色 18px |
| 3 | 背景：`#666666`，圆角 10px |
| 4 | 位置：X=740，Y=720 |

#### 包 4 完成验证
- [ ] 全屏遮罩
- [ ] "胜利！" 金色大字
- [ ] MVP 展示卡片
- [ ] 4 项数据统计
- [ ] 两个底部按钮

---

### 包 5：CardTooltip（卡牌详情浮层）

右键 `CardTooltip` 包 → 新建组件：

#### 组件 5-1：tip_bg
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `tip_bg`，宽 220，高 320 |
| 2 | 矩形背景：`#2A2A3E`，圆角 8px |
| 3 | 添加投影：X=2，Y=4，模糊=8，颜色黑色 40% |

#### 组件 5-2：card_image
| 步骤 | 操作 |
|------|------|
| 1 | 在 tip_bg 内添加装载器（Loader） |
| 2 | 宽 200，高 280 |
| 3 | 位置：X=10，Y=10 |
| 4 | 填充灰色 `#555555`（占位） |

#### 组件 5-3：txt_card_name
| 步骤 | 操作 |
|------|------|
| 1 | 文本，命名 `txt_card_name` |
| 2 | 位置：X=10，Y=295 |
| 3 | 18px 白色加粗 |

#### 组件 5-4：txt_cost
| 步骤 | 操作 |
|------|------|
| 1 | 文本，命名 `txt_cost` |
| 2 | 位置：X=190，Y=295（右上角） |
| 3 | 20px `#FFB300` 加粗 |

#### 组件 5-5：txt_desc
| 步骤 | 操作 |
|------|------|
| 1 | 文本，命名 `txt_desc` |
| 2 | 位置：X=10，Y=320 |
| 3 | 14px `#CCCCCC`，多行，最大高度 80 |

#### 组件 5-6：rarity_border
| 步骤 | 操作 |
|------|------|
| 1 | 矩形边框，命名 `rarity_border` |
| 2 | 宽 220，高 320 |
| 3 | 描边 4px，无填充 |
| 4 | 稀有度颜色：白 `#FFFFFF` / 蓝 `#4488FF` / 紫 `#9944FF` / 橙 `#FF8844` / 红 `#FF4444` |

#### 整体动效：弹入弹出
| 步骤 | 操作 |
|------|------|
| 1 | 选中 tip_bg |
| 2 | 过渡 → 显示 |
| 3 | Scale：0.8 → 1.0 |
| 4 | 持续时间：0.3 秒，缓动：Back.EaseOut |

#### 包 5 完成验证
- [ ] 220×320 卡片浮层带投影
- [ ] 卡牌图 + 名字 + 费用 + 描述
- [ ] 5 色稀有度边框
- [ ] 弹性弹出动画

---

### 包 6：ResponsivePanel（响应询问弹窗）

右键 `ResponsivePanel` 包 → 新建组件：

#### 组件 6-1：modal_bg
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `modal_bg`，宽 1280，高 720 |
| 2 | 矩形全屏：`#000000`，不透明度 50% |

#### 组件 6-2：dialog_card
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `dialog_card`，宽 600，高 420 |
| 2 | 背景矩形：`#FFFFFF`，圆角 16px |
| 3 | 阴影：X=0，Y=8，模糊=20，颜色黑色 30% |
| 4 | 位置：X=640（居中），Y=360（居中） |

在 dialog_card 内：

#### 组件 6-2a：title_text
| 步骤 | 操作 |
|------|------|
| 1 | 文本："请选择是否出【闪】" |
| 2 | 22px 加粗 `#333333` |
| 3 | 位置：X=30，Y=25 |

#### 组件 6-2b：card_list
| 步骤 | 操作 |
|------|------|
| 1 | 列表，宽 540，高 160 |
| 2 | 水平排列，可滚动 |
| 3 | 位置：X=30，Y=80 |

#### 组件 6-2c：card_option_item
| 步骤 | 操作 |
|------|------|
| 1 | 新建组件，命名 `card_option_item`，宽 100，高 140 |
| 2 | 卡牌图占位：矩形 90×130，`#555555` |
| 3 | 设为 card_list 的列表项 |

#### 组件 6-2d：btn_option_yes / btn_option_no
| 步骤 | 操作 |
|------|------|
| 1 | 按钮 "出闪"，宽 200，高 50，背景 `#E53935`，白色文字 |
| 2 | 按钮 "不出"，宽 200，高 50，背景 `#AAAAAA`，白色文字 |
| 3 | 两个按钮水平排列，间距 30px |
| 4 | 位置：X=300（居中），Y=280 |

#### 组件 6-2e：timer_ring
| 步骤 | 操作 |
|------|------|
| 1 | 进度条-环形，直径 60 |
| 2 | 最大值 10，当前值 10 |
| 3 | 前景色：`#E53935` → `#FFB300` → `#AAAAAA` 渐变 |
| 4 | 位置：X=520，Y=20（右上角） |

#### 组件 6-2f：note_text
| 步骤 | 操作 |
|------|------|
| 1 | 文本："10 秒后自动选择默认选项" |
| 2 | 12px `#999999` |
| 3 | 位置：X=30，Y=370 |

#### 包 6 完成验证
- [ ] 半透明遮罩
- [ ] 居中白色弹窗带阴影
- [ ] 标题文字动态变化
- [ ] 可选手牌水平列表
- [ ] 确认/取消按钮
- [ ] 10 秒环形倒计时
- [ ] 灰色提示文字

---

## 四、导出 .bytes 文件

设计完成后，将 6 个 UI 包导出为 Unity 可用的 .bytes 文件。

### 4.1 发布设置

| 步骤 | 操作 |
|------|------|
| 1 | 菜单 → 文件 → 项目设置 |
| 2 | 选择「发布」选项卡 |
| 3 | 发布路径设为：`C:\Users\31184\Desktop\校园杀v0.1\CampusKillUnity\Assets\_Project\FairyGUI\Packages` |
| 4 | 勾选「二进制格式」（生成 .bytes 而非 .xml） |
| 5 | 点击确定 |

### 4.2 逐个发布

| 步骤 | 操作 |
|------|------|
| 1 | 在项目面板右键 `MainMenu` → 发布 |
| 2 | 等待完成 |
| 3 | 同样操作：HeroSelect / BattleHUD / ResultPanel / CardTooltip / ResponsivePanel |

### 4.3 导出验证

确认以下 6 个文件已生成：
- [ ] `MainMenu.bytes`
- [ ] `HeroSelect.bytes`
- [ ] `BattleHUD.bytes`
- [ ] `ResultPanel.bytes`
- [ ] `CardTooltip.bytes`
- [ ] `ResponsivePanel.bytes`

---

## 五、交付验证弹窗

所有操作完成后，生成以下 HTML 验证弹窗，保存到 `C:\Users\31184\Desktop\校园杀v0.1\FairyGUI-Project\verification.html`，双击由开发者逐项确认。

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>FairyGUI 校园杀 UI 包 — 交付验证</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: "Microsoft YaHei", sans-serif; background: #1A1A2E; color: #eee; padding: 30px; }
h1 { color: #E53935; text-align: center; margin-bottom: 8px; font-size: 28px; }
.subtitle { text-align: center; color: #888; margin-bottom: 24px; font-size: 14px; }
.progress-wrap { text-align: center; margin-bottom: 24px; }
.progress-bar { width: 600px; max-width: 100%; height: 8px; background: #333; border-radius: 4px; margin: 0 auto; overflow: hidden; }
.progress-fill { height: 100%; background: linear-gradient(90deg, #E53935, #43A047); border-radius: 4px; transition: width 0.3s; width: 0%; }
.counter { font-size: 14px; color: #FFB300; margin-top: 8px; display: block; }
.category { background: #222240; border-radius: 12px; padding: 20px; margin-bottom: 16px; }
.category h2 { color: #E53935; font-size: 18px; margin-bottom: 12px; border-bottom: 1px solid #333; padding-bottom: 8px; }
.check-item { display: flex; align-items: flex-start; padding: 10px 0; border-bottom: 1px solid #2A2A3E; }
.check-item:last-child { border-bottom: none; }
.check-item input[type="checkbox"] { width: 20px; height: 20px; margin-right: 12px; margin-top: 2px; accent-color: #43A047; cursor: pointer; }
.check-item .info { flex: 1; }
.check-item .info strong { display: block; font-size: 15px; color: #eee; margin-bottom: 4px; }
.check-item .info p { font-size: 13px; color: #999; margin-bottom: 2px; }
.check-item .info textarea { width: 100%; height: 48px; margin-top: 6px; background: #1A1A2E; border: 1px solid #E53935; border-radius: 6px; color: #ff6b6b; padding: 6px 10px; font-size: 13px; resize: vertical; display: none; }
.tag { font-size: 11px; padding: 2px 8px; border-radius: 10px; background: #333; color: #AAA; white-space: nowrap; margin-left: 10px; }
footer { text-align: center; margin-top: 24px; padding-top: 20px; border-top: 1px solid #333; }
footer button { padding: 12px 40px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; margin: 0 8px; }
#btn-done { background: #E53935; color: #fff; }
#btn-done:disabled { background: #444; color: #888; cursor: not-allowed; }
#btn-save { background: #1E88E5; color: #fff; }
#btn-skip { background: #666; color: #ccc; }
.failures { background: #332020; border-radius: 12px; padding: 20px; margin-top: 16px; display: none; }
.failures h2 { color: #ff6b6b; font-size: 16px; margin-bottom: 8px; }
.failures li { color: #ff6b6b; font-size: 13px; margin-left: 20px; margin-bottom: 4px; }
</style>
</head>
<body>

<h1>🏫 校园杀 FairyGUI UI 包 — 交付验证</h1>
<p class="subtitle">6 个 UI 包 · 42 个组件 · 完成时间：<span id="completedAt">---</span></p>

<div class="progress-wrap">
  <div class="progress-bar"><div class="progress-fill" id="progressFill"></div></div>
  <span class="counter" id="counter">0 / 36 项通过</span>
</div>

<div id="categories"></div>

<div class="failures" id="failures">
  <h2>未通过项 (<span id="failCount">0</span>)</h2>
  <ul id="failureList"></ul>
</div>

<footer>
  <button id="btn-save" onclick="saveResult()">导出验证报告 JSON</button>
  <button id="btn-skip" onclick="skipVerify()">跳过验证（记录风险）</button>
  <button id="btn-done" disabled onclick="confirmDone()">全部通过 — 确认交付</button>
</footer>

<script>
const checks = [
  { cat: 'MainMenu 主菜单', items: [
    {id:'m1','全屏半透明黑色遮罩','1280×720，不透明度 60%'},
    {id:'m2','红色文字 "校园杀"','48px 加粗，居中偏上'},
    {id:'m3','按钮 "1v1 对战"','240×60，圆角 12，红色，悬停放大 1.05'},
    {id:'m4','按钮 "3v3 身份局"','样式同 1v1'},
    {id:'m5','按钮 "设置"','灰色背景'},
    {id:'m6','版本号 v0.2','右下角灰色小字'}
  ]},
  { cat: 'HeroSelect 选将界面', items: [
    {id:'h1','红色顶栏 + 标题','"选择你的英雄" 白色 28px'},
    {id:'h2','左侧英雄列表','可滚动，虚拟列表模式'},
    {id:'h3','英雄项：圆形头像+名字+描述','100×100圆形，名字20px白色'},
    {id:'h4','右侧技能展示面板','标题"技能详情"，蓝色'},
    {id:'h5','底部确认按钮','200×55，红色圆角'},
    {id:'h6','环形倒计时 30 秒','直径 80，绿→黄→红渐变'}
  ]},
  { cat: 'BattleHUD 对局HUD', items: [
    {id:'b1','顶部栏：回合数 + 阶段 + 倒计时','三区齐全，阶段高亮红色'},
    {id:'b2','玩家面板：头像+血条+手牌数','左下，400px 宽'},
    {id:'b3','装备区 4 格','武器/防具/+1马/-1马，灰色边框'},
    {id:'b4','对手面板','右上镜像位置'},
    {id:'b5','底部操作栏：结束回合按钮','红色 160×50'},
    {id:'b6','确定/取消按钮','默认隐藏，需要时显示'},
    {id:'b7','战斗日志列表','右侧 300×420，可滚动，50条上限'}
  ]},
  { cat: 'ResultPanel 结算界面', items: [
    {id:'r1','全屏遮罩不透明度 70%','黑色半透明'},
    {id:'r2','金色 "胜利！" 大字','48px 居中，金色 #FFD700'},
    {id:'r3','MVP 展示卡片','400×300，头像+名字'},
    {id:'r4','数据统计 4 项','伤害量/治疗量/出牌数/回合数'},
    {id:'r5','"再来一局" 按钮','红色 200×55'},
    {id:'r6','"返回大厅" 按钮','灰色 180×50'}
  ]},
  { cat: 'CardTooltip 卡牌浮层', items: [
    {id:'c1','220×320 浮层带投影','阴影 Y8 模糊20'},
    {id:'c2','卡牌图占位 200×280','灰色填充'},
    {id:'c3','卡名 + 费用 + 描述','右上费用金色20px加粗'},
    {id:'c4','5 色稀有度边框','白/蓝/紫/橙/红 4px'},
    {id:'c5','弹性弹出动画','0.3s Back.EaseOut'}
  ]},
  { cat: 'ResponsivePanel 响应弹窗', items: [
    {id:'p1','半透明遮罩','全屏 50%'},
    {id:'p2','白色居中弹窗 600×420','圆角 16，阴影'},
    {id:'p3','动态标题文字','22px 加粗 #333'},
    {id:'p4','可选手牌水平列表','100×140 卡牌小图'},
    {id:'p5','确认/取消按钮','水平排列，间距 30'},
    {id:'p6','10 秒环形倒计时 + 提示','直径 60，右上方'}
  ]},
  { cat: '导出验证', items: [
    {id:'e1','MainMenu.bytes 已生成','路径确认'},
    {id:'e2','HeroSelect.bytes 已生成','路径确认'},
    {id:'e3','BattleHUD.bytes 已生成','路径确认'},
    {id:'e4','ResultPanel.bytes 已生成','路径确认'},
    {id:'e5','CardTooltip.bytes 已生成','路径确认'},
    {id:'e6','ResponsivePanel.bytes 已生成','路径确认'}
  ]}
];

let total = 0; checks.forEach(c => total += c.items.length);
document.getElementById('completedAt').textContent = new Date().toLocaleString();

const catsDiv = document.getElementById('categories');
checks.forEach(cat => {
  const sec = document.createElement('div'); sec.className = 'category';
  sec.innerHTML = `<h2>${cat.cat} (${cat.items.length}项)</h2>`;
  cat.items.forEach(item => {
    const div = document.createElement('div'); div.className = 'check-item';
    div.innerHTML = `
      <input type="checkbox" data-id="${item.id}" onchange="updateProgress()">
      <div class="info">
        <strong>${item[1]}</strong>
        <p>预期：${item[2]}</p>
        <textarea placeholder="请描述未通过的具体表现..." oninput="updateProgress()"></textarea>
      </div>
      <span class="tag">手动验证</span>`;
    sec.appendChild(div);
  });
  catsDiv.appendChild(sec);
});

function updateProgress() {
  const cbs = document.querySelectorAll('.check-item input[type="checkbox"]');
  let passed = 0, failed = 0;
  const failList = [];

  cbs.forEach(cb => {
    const item = cb.closest('.check-item');
    const textarea = item.querySelector('textarea');
    if (cb.checked) {
      passed++;
      textarea.style.display = 'none';
    } else {
      failed++;
      textarea.style.display = 'block';
      if (textarea.value.trim()) {
        failList.push(`${cb.dataset.id}: ${textarea.value.trim()}`);
      } else {
        failList.push(`${cb.dataset.id}: 未通过（未填写原因）`);
      }
    }
  });

  const pct = Math.round(passed / total * 100);
  document.getElementById('progressFill').style.width = pct + '%';
  document.getElementById('counter').textContent = `${passed} / ${total} 项通过`;

  const failures = document.getElementById('failures');
  const failUl = document.getElementById('failureList');
  const failCount = document.getElementById('failCount');
  if (failed > 0) {
    failures.style.display = 'block';
    failCount.textContent = failed;
    failUl.innerHTML = failList.map(f => `<li>${f}</li>`).join('');
  } else {
    failures.style.display = 'none';
  }

  document.getElementById('btn-done').disabled = (passed < total);
}

function saveResult() {
  const result = { task: 'FairyGUI 校园杀 UI 包交付验证', completedAt: new Date().toISOString(), items: [] };
  document.querySelectorAll('.check-item').forEach(item => {
    const cb = item.querySelector('input[type="checkbox"]');
    const textarea = item.querySelector('textarea');
    result.items.push({ id: cb.dataset.id, pass: cb.checked, note: cb.checked ? '' : textarea.value });
  });
  const blob = new Blob([JSON.stringify(result, null, 2)], {type: 'application/json'});
  const a = document.createElement('a'); a.href = URL.createObjectURL(blob);
  a.download = 'fairygui-verification-report.json'; a.click();
}

function skipVerify() {
  if (confirm('跳过验证意味着部分 UI 组件可能存在问题，确定跳过？')) {
    alert('已记录 ⚠️ 跳过验证，风险自负。');
  }
}

function confirmDone() {
  alert('🎉 全部 36 项验证通过！FairyGUI UI 包交付完成。\n6 个 .bytes 文件已就绪。');
}
</script>
</body>
</html>
```

---

## 六、禁止行为

1. **禁止跳过组件**：每个包中的每个组件都必须创建，不得省略
2. **禁止随意调整尺寸**：严格按照表格中的宽高和坐标设置
3. **禁止遗漏动效**：按钮过渡和弹窗动画必须设置
4. **禁止不验证就交付**：交付前必须先打开 verification.html，确认所有复选框可正常勾选
5. **禁止修改颜色主题**：红 `#E53935` / 蓝 `#1E88E5` / 金 `#FFD700` 不可替换

---

## 七、验收标准

全部 36 项验证通过 = 任务完成。FairyGUI 操作结束后的最终回复必须包含：
1. 已完成的组件数量统计（目标：42 个）
2. 6 个 .bytes 文件的绝对路径列表
3. 验证弹窗路径：`C:\Users\31184\Desktop\校园杀v0.1\FairyGUI-Project\verification.html`

---

**操作顺序建议**：MainMenu → HeroSelect → ResultPanel → CardTooltip → ResponsivePanel → BattleHUD（最复杂的放最后，熟练了再做）
**预计耗时**：1-1.5 小时
*（内容由AI生成，仅供参考）*
