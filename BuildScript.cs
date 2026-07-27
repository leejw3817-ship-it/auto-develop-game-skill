"""
校园杀 UI 设计系统自动化校验器
自动检测：间距、圆角、色彩一致性，FairyGUI 组件合规，设计 Token 一致性

用法: python design_system_checker.py --project-dir "FairyGUI-Project路径"
"""

import os, sys, json, re, argparse
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple

# ============================================================
#  设计 Token 基准
# ============================================================

DESIGN_TOKENS = {
    "spacing": {
        "xs": 4, "sm": 8, "md": 16, "lg": 24, "xl": 32, "xxl": 48
    },
    "radius": {
        "sm": 4, "md": 8, "lg": 12, "full": 9999
    },
    "colors": {
        "primary_red":      "#E53935",
        "primary_blue":     "#1E88E5",
        "accent_gold":      "#FFD700",
        "bg_dark":          "#1A1A2E",
        "bg_card":          "#16213E",
        "text_primary":     "#FFFFFF",
        "text_secondary":   "#B0BEC5",
        "danger":           "#FF1744",
        "success":          "#00E676",
        "warning":          "#FFAB00",
    },
    "typography": {
        "h1": {"size": 32, "weight": "bold", "line_height": 1.2},
        "h2": {"size": 24, "weight": "bold", "line_height": 1.3},
        "h3": {"size": 18, "weight": "bold", "line_height": 1.4},
        "body": {"size": 14, "weight": "regular", "line_height": 1.5},
        "caption": {"size": 12, "weight": "regular", "line_height": 1.5},
    }
}

# ============================================================
#  核心校验器
# ============================================================

class DesignSystemChecker:
    """设计系统一致性检查器"""
    
    def __init__(self, project_dir: str):
        self.project_dir = Path(project_dir)
        self.issues: List[Dict] = []
        self.component_count = 0
        self.passed = 0
        self.failed = 0
        
    def run_all(self):
        """执行全部检查"""
        print("=" * 60)
        print("  校园杀 UI 设计系统校验")
        print("=" * 60)
        
        self._check_fairygui_xml()
        self._check_color_consistency()
        self._check_spacing_consistency()
        self._check_radius_consistency()
        self._check_component_completeness()
        self._check_typography()
        
        self._print_summary()
        
    # ----------------------------------------------------------
    #  检查 1: FairyGUI XML 结构校验
    # ----------------------------------------------------------
    def _check_fairygui_xml(self):
        print("\n📐 检查 1: FairyGUI XML 结构校验")
        
        xml_dir = self.project_dir / "assets"
        if not xml_dir.exists():
            print("  ⚠ assets 目录不存在")
            return
            
        xml_files = list(xml_dir.rglob("*.xml"))
        if not xml_files:
            print("  ⚠ 未找到 XML 文件")
            return
            
        # 按包分组
        packages = defaultdict(list)
        for xf in xml_files:
            # 从路径推断包名: assets/包名/组件名.xml
            package = xf.parent.name if xf.parent != xml_dir else "root"
            packages[package].append(xf)
            
        for pkg_name, files in sorted(packages.items()):
            valid = 0
            for f in files:
                try:
                    content = f.read_text(encoding="utf-8")
                    # 基础 XML 合法性
                    if content.strip().startswith("<?xml") or content.strip().startswith("<"):
                        valid += 1
                    else:
                        self._add_issue("xml_invalid", f"无效 XML: {f.name}")
                except Exception as e:
                    self._add_issue("xml_read_error", f"读取失败 {f.name}: {e}")
            
            self.component_count += len(files)
            status = "✅" if valid == len(files) else "⚠"
            print(f"  {status} {pkg_name}: {valid}/{len(files)} 组件")
            
    # ----------------------------------------------------------
    #  检查 2: 色彩一致性
    # ----------------------------------------------------------
    def _check_color_consistency(self):
        print("\n🎨 检查 2: 色彩一致性")
        
        allowed_colors = set(self._normalize_color(c) 
                           for c in DESIGN_TOKENS["colors"].values())
        
        xml_dir = self.project_dir / "assets"
        if not xml_dir.exists():
            print("  ⚠ 跳过（无 XML 文件）")
            return
            
        # 从组件中提取颜色值
        color_pattern = re.compile(r'#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?')
        all_colors = defaultdict(int)
        
        for xml_file in xml_dir.rglob("*.xml"):
            try:
                content = xml_file.read_text(encoding="utf-8")
                for match in color_pattern.finditer(content):
                    color = self._normalize_color(match.group())
                    all_colors[color] += 1
            except:
                pass
                
        if not all_colors:
            print("  ⚠ 未在 XML 中找到颜色值")
            return
            
        violations = []
        for color, count in sorted(all_colors.items(), key=lambda x: -x[1]):
            is_allowed = color in allowed_colors
            marker = "✅" if is_allowed else "❌"
            print(f"  {marker} {color} ({count}次)")
            if not is_allowed:
                violations.append(color)
                
        if violations:
            print(f"\n  ⚠ 发现 {len(violations)} 个非标准颜色")
            print("    允许的颜色: " + ", ".join(DESIGN_TOKENS["colors"].values()))
            self._add_issue("color_new", f"非标准颜色: {', '.join(violations)}")
            
    # ----------------------------------------------------------
    #  检查 3: 间距一致性
    # ----------------------------------------------------------
    def _check_spacing_consistency(self):
        print("\n📏 检查 3: 间距一致性")
        
        allowed_spacings = set(DESIGN_TOKENS["spacing"].values())
        
        xml_dir = self.project_dir / "assets"
        if not xml_dir.exists():
            print("  ⚠ 跳过")
            return
            
        # 提取 XY 坐标差值，检查是否使用了 4px 栅格
        spacing_violations = []
        xy_pattern = re.compile(r'x="(\d+)".*?y="(\d+)"')
        gap_pattern = re.compile(r'gap="(\d+)"')
        
        for xml_file in xml_dir.rglob("*.xml"):
            try:
                content = xml_file.read_text(encoding="utf-8")
                
                for match in gap_pattern.finditer(content):
                    gap = int(match.group(1))
                    if gap not in allowed_spacings:
                        spacing_violations.append((xml_file.name, f"gap={gap}"))
                        
            except:
                pass
                
        if spacing_violations:
            for fname, detail in spacing_violations[:10]:
                print(f"  ❌ {fname}: {detail}")
            print(f"\n  ⚠ {len(spacing_violations)} 处间距违规")
            self._add_issue("spacing", f"{len(spacing_violations)} 处间距不符合 4px 栅格")
        else:
            print("  ✅ 间距符合 4px 栅格标准")
            
    # ----------------------------------------------------------
    #  检查 4: 圆角一致性
    # ----------------------------------------------------------
    def _check_radius_consistency(self):
        print("\n⭕ 检查 4: 圆角一致性")
        
        allowed_radius = set(DESIGN_TOKENS["radius"].values())
        
        xml_dir = self.project_dir / "assets"
        if not xml_dir.exists():
            print("  ⚠ 跳过")
            return
            
        radius_violations = []
        radius_pattern = re.compile(r'(?:corner|radius|borderRadius)\s*=\s*"(\d+)', re.I)
        
        for xml_file in xml_dir.rglob("*.xml"):
            try:
                content = xml_file.read_text(encoding="utf-8")
                for match in radius_pattern.finditer(content):
                    r = int(match.group(1))
                    if r not in allowed_radius and r > 0:
                        radius_violations.append((xml_file.name, r))
            except:
                pass
                
        if radius_violations:
            for fname, r in radius_violations[:10]:
                print(f"  ❌ {fname}: radius={r} (允许: {sorted(allowed_radius)})")
            print(f"\n  ⚠ {len(radius_violations)} 处圆角违规")
            self._add_issue("radius", f"{len(radius_violations)} 处圆角不符合规范")
        else:
            print("  ✅ 圆角符合设计规范")
            
    # ----------------------------------------------------------
    #  检查 5: 组件完整性
    # ----------------------------------------------------------
    def _check_component_completeness(self):
        print("\n🧩 检查 5: 组件完整性")
        
        expected_packages = {
            "MainMenu":     ["Title", "StartBtn", "SettingsBtn", "CardGallery"],
            "HeroSelect":   ["HeroList", "HeroCard", "HeroPreview", "ConfirmBtn"],
            "BattleHUD":    ["HandArea", "CardItem", "HPTracker", "PhaseBar",
                            "DrawPile", "DiscardPile", "EndTurnBtn"],
            "ResultPanel":  ["WinScreen", "LoseScreen", "StatsPanel", "ReplayBtn"],
            "CardTooltip":  ["TooltipPanel", "CardImage", "DescText", "CostBadge"],
            "ResponsivePanel": ["SafeArea", "ScaleController", "OrientationHandler"],
        }
        
        xml_dir = self.project_dir / "assets"
        if not xml_dir.exists():
            print("  ⚠ 跳过")
            return
            
        for pkg_name, expected_components in expected_packages.items():
            pkg_dir = xml_dir / pkg_name
            if not pkg_dir.exists():
                print(f"  ❌ 包不存在: {pkg_name}")
                self._add_issue("pkg_missing", f"包缺失: {pkg_name}")
                continue
                
            actual_files = {f.stem for f in pkg_dir.glob("*.xml")}
            missing = set(expected_components) - actual_files
            extra = actual_files - set(expected_components)
            
            status = "✅" if not missing else "❌"
            print(f"  {status} {pkg_name}: {len(actual_files)}/{len(expected_components)} 预期组件")
            if missing:
                print(f"    缺失: {', '.join(sorted(missing))}")
                self._add_issue("component_missing", f"{pkg_name} 缺失: {', '.join(sorted(missing))}")
            if extra:
                print(f"    额外: {', '.join(sorted(extra))}")
                
    # ----------------------------------------------------------
    #  检查 6: 字体排版
    # ----------------------------------------------------------
    def _check_typography(self):
        print("\n🔤 检查 6: 字体排版")
        
        xml_dir = self.project_dir / "assets"
        if not xml_dir.exists():
            print("  ⚠ 跳过")
            return
            
        size_violations = 0
        size_pattern = re.compile(r'fontSize\s*=\s*"(\d+)"', re.I)
        allowed_sizes = {t["size"] for t in DESIGN_TOKENS["typography"].values()}
        
        for xml_file in xml_dir.rglob("*.xml"):
            try:
                content = xml_file.read_text(encoding="utf-8")
                for match in size_pattern.finditer(content):
                    size = int(match.group(1))
                    if size not in allowed_sizes and size > 0:
                        size_violations += 1
                        if size_violations <= 5:
                            print(f"  ❌ {xml_file.name}: fontSize={size} (允许: {sorted(allowed_sizes)})")
            except:
                pass
                
        if size_violations:
            print(f"\n  ⚠ {size_violations} 处字号违规")
            self._add_issue("typography", f"{size_violations} 处字号不符合规范")
        else:
            print("  ✅ 字号符合排版规范")
            
    # ----------------------------------------------------------
    #  工具方法
    # ----------------------------------------------------------
    def _normalize_color(self, color: str) -> str:
        """统一颜色为大写无 alpha 的 6 位 hex"""
        c = color.upper().lstrip("#")
        if len(c) == 8:
            c = c[:-2]  # 去掉 alpha
        return f"#{c}"
        
    def _add_issue(self, rule: str, detail: str):
        self.issues.append({"rule": rule, "detail": detail})
        
    def _print_summary(self):
        print(f"\n{'=' * 60}")
        print(f"  校验完成")
        print(f"  组件总数: {self.component_count}")
        print(f"  问题数量: {len(self.issues)}")
        if self.issues:
            print(f"\n  问题清单:")
            for i, iss in enumerate(self.issues, 1):
                print(f"  {i}. [{iss['rule']}] {iss['detail']}")
        else:
            print(f"  ✅ 所有检查通过！")
        print(f"{'=' * 60}")

# ============================================================
#  实时监看模式（开发中自动校验）
# ============================================================

def watch_mode(project_dir: str):
    """文件变化时自动运行校验"""
    import time
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler
    
    class DesignWatchdog(FileSystemEventHandler):
        def on_modified(self, event):
            if event.src_path.endswith(".xml"):
                print(f"\n🔍 检测到变化: {Path(event.src_path).name}")
                checker = DesignSystemChecker(project_dir)
                checker.run_all()
                
    print(f"👀 监看模式启动: {project_dir}")
    observer = Observer()
    observer.schedule(DesignWatchdog(), project_dir, recursive=True)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="校园杀 UI 设计系统校验")
    parser.add_argument("--project-dir", default=".", help="FairyGUI 项目路径")
    parser.add_argument("--watch", action="store_true", help="监看模式")
    args = parser.parse_args()
    
    if args.watch:
        watch_mode(args.project_dir)
    else:
        checker = DesignSystemChecker(args.project_dir)
        checker.run_all()
        
        if checker.issues:
            sys.exit(1)  # CI 中失败返回非 0
