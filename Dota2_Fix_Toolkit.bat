@echo off
chcp 65001 >nul
title DOTA 2 卡顿与掉帧一键优化工具
color 0b

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 正在请求管理员权限以清理系统着色器缓存并应用优化...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:MENU
cls
echo ============================================================
echo               DOTA 2 防卡顿与流畅度优化工具
echo ============================================================
echo.
echo  [1] 一键执行推荐综合优化 (清理着色器 + 注入 autoexec + 优化网络)
echo  [2] 彻底清理显卡着色器缓存 (解决更新后频繁微顿、掉帧)
echo  [3] 自动生成/覆盖防卡顿 autoexec.cfg (降低团战特效与后台占用)
echo  [4] 重置 570 本地用户配置文件 (解决旧配置残留/云同步冲突)
echo  [5] 查看并复制推荐 Steam 启动项 (含关闭动态大厅参数)
echo  [6] 系统关键设置与鼠标回报率自查指引
echo  [0] 退出
echo.
echo ============================================================
set /p choice=请输入选项编号 [0-6]: 

if "%choice%"=="1" goto OPTIMIZE_ALL
if "%choice%"=="2" goto CLEAN_SHADERS
if "%choice%"=="3" goto CREATE_AUTOEXEC
if "%choice%"=="4" goto RESET_USERDATA
if "%choice%"=="5" goto SHOW_LAUNCH_OPTIONS
if "%choice%"=="6" goto SYSTEM_CHECK
if "%choice%"=="0" exit /b
goto MENU

:: ============================================================
:: 辅助函数：定位 Steam 和 Dota 2 路径
:: ============================================================
:DETECT_PATHS
set "STEAMPATH="
for /f "tokens=2* skip=2" %%a in ('reg query "HKEY_CURRENT_USER\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "STEAMPATH=%%b"
if not defined STEAMPATH (
    for /f "tokens=2* skip=2" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do set "STEAMPATH=%%b"
)
if defined STEAMPATH set "STEAMPATH=%STEAMPATH:/=\%"

set "DOTACFG="
if defined STEAMPATH (
    if exist "%STEAMPATH%\steamapps\common\dota 2 beta\game\dota\cfg" (
        set "DOTACFG=%STEAMPATH%\steamapps\common\dota 2 beta\game\dota\cfg"
    )
)
goto :eof

:: ============================================================
:: 1. 综合优化
:: ============================================================
:OPTIMIZE_ALL
cls
echo [1/3] 正在清理显卡着色器缓存...
call :DO_CLEAN_SHADERS
echo.
echo [2/3] 正在生成防卡顿 autoexec.cfg...
call :DO_CREATE_AUTOEXEC
echo.
echo [3/3] 设置完成！
echo.
echo 请配合推荐启动项使用，详情请按任意键查看...
pause >nul
goto SHOW_LAUNCH_OPTIONS

:: ============================================================
:: 2. 清理着色器缓存
:: ============================================================
:CLEAN_SHADERS
cls
echo 正在清理系统 DirectX / NVIDIA / AMD 着色器缓存...
echo (注意：清理后首次进游戏可能需要1-2分钟预热，之后将极其流畅)
call :DO_CLEAN_SHADERS
echo.
echo 着色器缓存清理完毕！
pause
goto MENU

:DO_CLEAN_SHADERS
:: DirectX 缓存
if exist "%LOCALAPPDATA%\D3DSCache" (
    del /f /s /q "%LOCALAPPDATA%\D3DSCache\*.*" >nul 2>&1
    echo  - 已清理 DirectX 着色器缓存 (D3DSCache)
)
:: NVIDIA DX 缓存
if exist "%LOCALAPPDATA%\NVIDIA\DXCache" (
    del /f /s /q "%LOCALAPPDATA%\NVIDIA\DXCache\*.*" >nul 2>&1
    echo  - 已清理 NVIDIA DXCache 缓存
)
:: NVIDIA GL 缓存
if exist "%LOCALAPPDATA%\NVIDIA\GLCache" (
    del /f /s /q "%LOCALAPPDATA%\NVIDIA\GLCache\*.*" >nul 2>&1
    echo  - 已清理 NVIDIA GLCache 缓存
)
:: AMD 缓存
if exist "%LOCALAPPDATA%\AMD\DxCache" (
    del /f /s /q "%LOCALAPPDATA%\AMD\DxCache\*.*" >nul 2>&1
    echo  - 已清理 AMD DxCache 缓存
)
goto :eof

:: ============================================================
:: 3. 生成 autoexec.cfg
:: ============================================================
:CREATE_AUTOEXEC
cls
call :DO_CREATE_AUTOEXEC
pause
goto MENU

:DO_CREATE_AUTOEXEC
call :DETECT_PATHS
if not defined DOTACFG (
    echo [警告] 未能通过注册表自动找到 Dota 2 cfg 目录。
    set /p DOTACFG=请手动输入你的 Dota 2 cfg 完整路径 (如 D:\Steam\steamapps\common\dota 2 beta\game\dota\cfg): 
)

if not exist "%DOTACFG%" (
    echo [错误] 路径不存在: %DOTACFG%
    goto :eof
)

echo 正在写入优化配置文件到: %DOTACFG%\autoexec.cfg ...
if exist "%DOTACFG%\autoexec.cfg" (
    copy /y "%DOTACFG%\autoexec.cfg" "%DOTACFG%\autoexec.cfg.bak" >nul
    echo  - 已自动备份原配置为 autoexec.cfg.bak
)

(
echo // ============================================================
echo // DOTA 2 针对性防卡顿/防掉帧优化配置 ^(自动生成^)
echo // ============================================================
echo.
echo // --- 网络通信优化 ^(抗抖动与丢包平滑^) ---
echo rate "786432"                          // 设置最大网络吞吐率
echo cl_updaterate "30"                     // 稳定客户端与服务器同步频率
echo cl_interp_ratio "2"                    // 启用双倍插值缓冲，平滑微弱网络丢包
echo.
echo // --- 渲染与多核性能 ---
echo mat_queue_mode "2"                     // 强制多线程渲染队列
echo engine_no_focus_sleep "50"             // 切出桌面时降低帧率节能防过热
echo r_dota_disable_portrait_world_renderer "1" // 优化界面UI肖像渲染负载
echo.
echo // --- 帧率平稳控制 ---
echo fps_max "0"                            // 解锁引擎内置限制^(建议由显卡驱动锁稳定帧^)
echo.
echo echo ">>> Dota2 防卡顿优化配置已成功加载 <<<"
) > "%DOTACFG%\autoexec.cfg"

echo  - autoexec.cfg 优化文件已成功生成！
goto :eof

:: ============================================================
:: 4. 重置 570 用户配置
:: ============================================================
:RESET_USERDATA
cls
call :DETECT_PATHS
if not defined STEAMPATH (
    echo [错误] 未能检测到 Steam 安装路径。
    pause
    goto MENU
)

echo 正在扫描 Steam 用户目录...
set "FOUND=0"
for /d %%D in ("%STEAMPATH%\userdata\*") do (
    if exist "%%D\570" (
        set "FOUND=1"
        echo 发现 Dota 2 本地配置文件: %%D\570
        echo 正在进行安全备份为: %%D\570_backup ...
        if exist "%%D\570_backup" rd /s /q "%%D\570_backup"
        xcopy "%%D\570" "%%D\570_backup" /e /i /y >nul
        rd /s /q "%%D\570"
        echo  - 已成功重置用户目录 %%D\570 (原文件已备份)
    )
)

if "%FOUND%"=="0" (
    echo 未在 %STEAMPATH%\userdata\ 下找到 570 缓存文件夹。
) else (
    echo.
    echo 重置完成！下次启动 Dota 2 时游戏将重新生成纯净配置。
)
pause
goto MENU

:: ============================================================
:: 5. 推荐启动项
:: ============================================================
:SHOW_LAUNCH_OPTIONS
cls
echo ============================================================
echo                     推荐 Steam 启动项
echo ============================================================
echo.
echo 官方排查与实测最有效的参数组合：
echo.
echo ------------------------------------------------------------
echo 国服玩家:
echo -perfectworld -novid -high -prewarm +map_enable_background_maps 0
echo.
echo 国际服玩家:
echo -novid -high -prewarm +map_enable_background_maps 0
echo ------------------------------------------------------------
echo.
echo 各参数说明:
echo   +map_enable_background_maps 0 : [核心] 关闭大厅极耗资源的3D动态背景
echo   -prewarm                      : [核心] 提前加载资源，防开团初次顿卡
echo   -high                         : 自动赋予游戏高CPU优先级
echo   -novid                        : 跳过开场 Valve 动画
echo.
echo [设置方法]:
echo 1. 打开 Steam 库 -> 右键点击 Dota 2 -> 属性
echo 2. 在【通用】标签页底部的【启动选项】中粘贴上述参数即可。
echo.
pause
goto MENU

:: ============================================================
:: 6. 系统自查指引
:: ============================================================
:SYSTEM_CHECK
cls
echo ============================================================
echo                  核心硬件与系统排查指引
echo ============================================================
echo.
echo 1. 【鼠标回报率检查】(极度关键)
echo    - 现象：静止时画面流畅，一甩动/移动鼠标画面就严重卡顿、丢帧。
echo    - 解决：打开鼠标驱动 (罗技G HUB / 雷蛇雷云 / 卓威)，将回报率
echo           从 4000Hz/8000Hz 调低至 1000Hz 或 500Hz。
echo.
echo 2. 【N卡控制面板设置】
echo    - 打开 NVIDIA 控制面板 -> 管理 3D 设置 -> 程序设置选择 Dota 2
echo    - 将【着色器缓存大小】修改为【10 GB】或【无限制】
echo    - 首选图形处理器确保为【高性能 NVIDIA 处理器】(针对笔记本)
echo.
echo 3. 【AMD 锐龙平台突发卡顿 1 秒 (fTPM)】
echo    - 现象：游戏中无规律出现持续 1 秒定格伴随音频电流声。
echo    - 解决：重启进入主板 BIOS，将 fTPM (AMD CPU fTPM) 设为 Disabled
echo           或更新主板 BIOS 至最新 AGESA 版本。
echo.
pause
goto MENU
