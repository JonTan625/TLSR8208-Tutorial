# 第 17 篇：自定义 GATT 服务，手机写一个字节点灯、每秒收一次 Notify

基线：tc_ble_simple_sdk V3.4.2.2 + patch_0001。

自定义服务的改动在 `app_att.c`、`app_att.h` 和 `app.c` 的 `main_loop()`；`app.c` 里另外带着第 16、18 篇的日志代码。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [b80_ble_sample_a17gatt](b80_ble_sample_a17gatt/) | `b80_ble_sample` | 新增一个 128 位 UUID 的服务：LED 特征（写 1 字节点白灯）和计数特征（连接后每秒 Notify 一次）。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| b80_ble_sample_a17gatt | `drivers/printf.h`<br>`vendor/ble_sample/app.c`<br>`vendor/ble_sample/app_att.c`<br>`vendor/ble_sample/app_att.h` | 47380 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
