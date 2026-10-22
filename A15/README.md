# 第 15 篇：低功耗与电流实测，万用表也能量出 0.5 µA 的深睡电流

基线：tc_platform_sdk V3.5.1。

电流的测法（拔哪些跳帽、万用表串在哪里）见正文。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [PM_Demo_deepPad](PM_Demo_deepPad/) | `PM_Demo` | `PM_MODE` 改成 `DEEP_PAD_WAKEUP`：深睡，PD0 接高电平唤醒。 |
| [PM_Demo_dbg](PM_Demo_dbg/) | `PM_Demo` | 默认 Suspend 模式加调试标记：白灯 = 在 Suspend 里，红灯 = 在 `rc_24m_cal()` 里，每圈打印 `cpu_sleep_wakeup()` 的返回值。用来弄清默认例程的闪灯节奏。 |
| [PM_Demo_cur_suspend](PM_Demo_cur_suspend/) | `PM_Demo` | 测电流用：`CURRENT_TEST` 改成 1，定时唤醒间隔都改成 60 s，`PM_MODE` 保持 `SUSPEND_32K_RC_WAKEUP`。 |
| [PM_Demo_cur_deepPad](PM_Demo_cur_deepPad/) | `PM_Demo` | 同上，`PM_MODE` = `DEEP_PAD_WAKEUP`。 |
| [PM_Demo_cur_deepRetPad](PM_Demo_cur_deepRetPad/) | `PM_Demo` | 同上，`PM_MODE` = `DEEP_RET_PAD_WAKEUP`。 |
| [PM_Demo_cur_deep32k](PM_Demo_cur_deep32k/) | `PM_Demo` | 同上，`PM_MODE` = `DEEP_32K_RC_WAKEUP`。 |
| [PM_Demo_cur_deepRet32k](PM_Demo_cur_deepRet32k/) | `PM_Demo` | 同上，`PM_MODE` = `DEEP_RET_32K_RC_WAKEUP`。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| PM_Demo_deepPad | `demo/vendor/PM_Demo/app_config.h` | 8984 |
| PM_Demo_dbg | `demo/vendor/PM_Demo/app.c` | 9568 |
| PM_Demo_cur_suspend | `demo/vendor/PM_Demo/app.c` | 8788 |
| PM_Demo_cur_deepPad | `demo/vendor/PM_Demo/app.c`<br>`demo/vendor/PM_Demo/app_config.h` | 8912 |
| PM_Demo_cur_deepRetPad | `demo/vendor/PM_Demo/app.c`<br>`demo/vendor/PM_Demo/app_config.h` | 8912 |
| PM_Demo_cur_deep32k | `demo/vendor/PM_Demo/app.c`<br>`demo/vendor/PM_Demo/app_config.h` | 8800 |
| PM_Demo_cur_deepRet32k | `demo/vendor/PM_Demo/app.c`<br>`demo/vendor/PM_Demo/app_config.h` | 8784 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
