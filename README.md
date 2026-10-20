# DOTA 2 卡顿与掉帧一键优化工具 (Dota2_Fix_Toolkit)

本工具专为解决近期《DOTA 2》客户端出现的掉帧、团战卡顿、更新后微顿以及网络抖动等问题设计。

---

## 包含功能

1. **彻底清理显卡着色器缓存**
   * 自动清理 DirectX (`D3DSCache`)、NVIDIA (`DXCache`/`GLCache`)、AMD (`DxCache`) 缓存，解决大版本更新后着色器重复编译引起的间歇性微顿。
2. **自动注入/生成防卡顿 `autoexec.cfg`**
   * 自动寻址 Steam 及 Dota 2 目录，注入经过社区验证的网络平滑参数（`rate`、`cl_interp_ratio 2`）与多核渲染优化命令（`mat_queue_mode 2`）。
   * 自动对原 `autoexec.cfg` 进行备份（`.bak`）。
3. **安全重置 570 本地用户数据**
   * 备份并清空本地旧版冲突配置与坏损的云同步缓存。
4. **一键显示推荐启动项**
   * 提供官方与实测最有效的启动参数：`-novid -high -prewarm +map_enable_background_maps 0`。
5. **硬件冲突排查指引**
   * 指引调整 4K/8K 鼠标高回报率、AMD fTPM 顿卡 Bug 及显卡面板配置。

---

## 使用方法 (Windows)

1. 双击运行 `Dota2_Fix_Toolkit.bat`（脚本会自动申请管理员权限）。
2. 在弹出菜单中输入 `1`，即可一键完成全套标准优化。
3. 按照提示，在 Steam 的 Dota 2 启动项中粘贴推荐启动参数即可。
