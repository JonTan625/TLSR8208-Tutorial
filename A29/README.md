# 第 29 篇：综合项目，在开发板上做一个 BLE 遥控器原型

基线：tc_ble_simple_sdk V3.4.2.2 + patch_0001。

遥控器原型的改动在 `app_config.h`（四个开关和键值表）、`app_ui.c`（键值翻译）、`app_att.c`/`app_att.h`（电量上报）、`app.c`（包含 `battery_check.h`、调用电量更新）；`app.c` 里另外带着第 16、18 篇的日志代码。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [b80_ble_sample_a29rc](b80_ble_sample_a29rc/) | `b80_ble_sample` | 遥控器原型：四个键分别是音量加、音量减、静音、播放暂停，电池检测打开，电量按 2.0~3.0 V 线性换算后 Notify。 |
| [b80_ble_sample_a29rcB](b80_ble_sample_a29rcB/) | `b80_ble_sample` | 同一个原型，广播名和设备名改成 eSamp_B，开机打印 `[A29][VER] B`，给 OTA 来回切换测试用。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| b80_ble_sample_a29rc | `drivers/printf.h`<br>`vendor/ble_sample/app.c`<br>`vendor/ble_sample/app_att.c`<br>`vendor/ble_sample/app_att.h`<br>`vendor/ble_sample/app_config.h`<br>`vendor/ble_sample/app_ui.c` | 51444 |
| b80_ble_sample_a29rcB | `drivers/printf.h`<br>`vendor/ble_sample/app.c`<br>`vendor/ble_sample/app_att.c`<br>`vendor/ble_sample/app_att.h`<br>`vendor/ble_sample/app_config.h`<br>`vendor/ble_sample/app_ui.c` | 51476 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
