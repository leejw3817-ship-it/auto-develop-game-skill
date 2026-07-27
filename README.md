#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Chrome 扩展自动化测试脚本
    自动检测扩展是否安装、点击测试、API 调用验证
#>

param(
    [string]$ExtensionId = "",
    [string]$TestPage = "http://localhost:3000",
    [switch]$Headless = $false
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Chrome 扩展自动化测试" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# 1. 检测 Chrome 安装
Write-Host "`n[1/5] 检测 Chrome 安装..." -ForegroundColor Yellow
$chromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
)

$chromePath = $null
foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        $chromePath = $path
        Write-Host "  ✅ 找到 Chrome: $chromePath" -ForegroundColor Green
        break
    }
}

if (-not $chromePath) {
    Write-Host "  ❌ 未找到 Chrome，尝试 Edge..." -ForegroundColor Red
    $chromePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $chromePath)) {
        Write-Host "  ❌ 未找到任何 Chromium 浏览器" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ 使用 Edge: $chromePath" -ForegroundColor Green
}

# 2. 检查扩展是否安装
Write-Host "`n[2/5] 检查扩展安装状态..." -ForegroundColor Yellow
$extensionsDir = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"
if (-not (Test-Path $extensionsDir)) {
    Write-Host "  ⚠ 扩展目录不存在，尝试 Edge..." -ForegroundColor Yellow
    $extensionsDir = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Extensions"
}

$installed = $false
if (Test-Path $extensionsDir) {
    $extFolders = Get-ChildItem $extensionsDir -Directory | ForEach-Object {
        $manifestPath = "$($_.FullName)\*\manifest.json"
        $manifests = Get-ChildItem $manifestPath -ErrorAction SilentlyContinue
        if ($manifests) {
            foreach ($m in $manifests) {
                try {
                    $json = Get-Content $m.FullName -Raw | ConvertFrom-Json
                    [PSCustomObject]@{
                        Id = $_.Name
                        Name = $json.name
                        Version = $json.version
                        Path = $_.FullName
                    }
                } catch {}
            }
        }
    }
    
    if ($extFolders) {
        $installed = $true
        $extFolders | Format-Table -AutoSize
        Write-Host "  ✅ 找到 $($extFolders.Count) 个扩展" -ForegroundColor Green
    }
}

if (-not $installed) {
    Write-Host "  ❌ 未找到已安装的扩展" -ForegroundColor Red
    exit 1
}

# 3. 启动 Chrome DevTools Protocol 测试
Write-Host "`n[3/5] 启动浏览器调试模式..." -ForegroundColor Yellow

$userDataDir = "$env:TEMP\chrome-test-profile"
$debugPort = 9222

# 检查是否已有调试实例
$existing = Get-Process chrome -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "  ⚠ Chrome 已在运行，尝试连接现有实例..." -ForegroundColor Yellow
}

$argList = @(
    "--remote-debugging-port=$debugPort",
    "--user-data-dir=`"$userDataDir`"",
    "--no-first-run",
    "--no-default-browser-check"
)
if ($Headless) {
    $argList += "--headless"
}

$proc = Start-Process -FilePath $chromePath -ArgumentList $argList -PassThru -WindowStyle Minimized
Start-Sleep -Seconds 3

# 4. CDP API 自动化操作
Write-Host "`n[4/5] CDP 自动化操作..." -ForegroundColor Yellow

$cdpScript = @"
const CDP = require('chrome-remote-interface');
const fs = require('fs');

(async () => {
    let client;
    try {
        client = await CDP({ port: $debugPort });
        const { Page, Runtime, Network } = client;
        
        await Page.enable();
        await Runtime.enable();
        await Network.enable();
        
        // 导航到测试页面
        console.log('⏳ 导航到测试页面: $TestPage');
        await Page.navigate({ url: '$TestPage' });
        await Page.loadEventFired();
        console.log('✅ 页面加载完成');
        
        // 检测扩展注入
        const injected = await Runtime.evaluate({
            expression: `
                (() => {
                    // 检测扩展是否注入了全局变量或 DOM 元素
                    const extIndicators = [];
                    if (window.marvis_browser) extIndicators.push('marvis_browser global');
                    if (document.querySelector('[data-extension-id]')) extIndicators.push('DOM marker found');
                    return { indicators: extIndicators, url: window.location.href };
                })()
            `
        });
        console.log('扩展指示器:', JSON.stringify(injected.result.value));
        
        // 模拟点击扩展按钮
        const clickResult = await Runtime.evaluate({
            expression: `
                (() => {
                    const btn = document.querySelector('[data-action="test-extension"]');
                    if (btn) {
                        btn.click();
                        return { clicked: true, element: btn.outerHTML };
                    }
                    return { clicked: false, available: Array.from(document.querySelectorAll('*')).slice(0,10).map(e => e.tagName) };
                })()
            `
        });
        console.log('点击结果:', JSON.stringify(clickResult.result.value));
        
        // 获取控制台输出
        const consoleOutput = [];
        Runtime.consoleAPICalled((params) => {
            consoleOutput.push(params.args.map(a => a.value).join(' '));
        });
        
        await new Promise(r => setTimeout(r, 2000));
        console.log('控制台输出:', consoleOutput);
        
        const passed = injected.result.value.indicators.length > 0;
        console.log(passed ? '✅ 扩展测试通过' : '❌ 扩展测试失败');
        
        // 截图
        const { data } = await Page.captureScreenshot();
        fs.writeFileSync('extension_test_screenshot.png', Buffer.from(data, 'base64'));
        console.log('📸 截图已保存');
        
    } catch (e) {
        console.error('❌ 错误:', e.message);
    } finally {
        if (client) await client.close();
        process.exit(0);
    }
})();
"@

$cdpScriptFile = "$env:TEMP\cdp_test.js"
$cdpScript | Set-Content $cdpScriptFile -Encoding UTF8

try {
    node $cdpScriptFile
} catch {
    Write-Host "  ⚠ CDP 测试需要 Node.js 和 chrome-remote-interface" -ForegroundColor Yellow
    Write-Host "  安装: npm install -g chrome-remote-interface" -ForegroundColor Yellow
    
    # 降级: 使用 PowerShell WebClient 直接测试 HTTP
    Write-Host "  降级为 HTTP 测试..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$debugPort/json" -UseBasicParsing
        $tabs = $response.Content | ConvertFrom-Json
        Write-Host "  ✅ 调试端口响应，发现 $($tabs.Count) 个标签页" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ 无法连接到调试端口" -ForegroundColor Red
    }
}

# 5. 清理
Write-Host "`n[5/5] 清理..." -ForegroundColor Yellow
if ($proc -and -not $proc.HasExited) {
    $proc.Kill()
    Write-Host "  ✅ Chrome 进程已关闭" -ForegroundColor Green
}

Write-Host "`n测试完成！" -ForegroundColor Cyan
