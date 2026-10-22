# 第 20 篇：BLE 主机 ble_master，让两块板子自己连上

基线：tc_ble_simple_sdk V3.4.2.2 + patch_0001。

从机用 ble_sample（广播名 eSample）。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [b80_master_log](b80_master_log/) | `b80_master` | ble_master 打印名字以 "eSa" 开头的广播的 RSSI（每秒最多一次）、连接建立和断开原因。 |
| [b80_master_rxcnt](b80_master_rxcnt/) | `b80_master` | 在上一个基础上加 4 个全局变量（收到的广播总数、最强 RSSI、"eSa" 广播数和最近一次的 RSSI），用 BDT 的 Tdebug 读，判断板子收不收得到广播。 |
| [b80_master_custom_pair](b80_master_custom_pair/) | `b80_master` | 正文里的「自定义配对」组合：`BLE_HOST_SMP_ENABLE` 改成 0、`ACL_CENTRAL_CUSTOM_PAIR_ENABLE` 改成 1，并把 `blm_host.c` 里的 `pCon` 改成 `pConnEvt`（不改就编译报错）。**只编译、没有上板**。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| b80_master_log | `drivers/printf.h`<br>`vendor/ble_master/blm_host.c` | 33604 |
| b80_master_rxcnt | `drivers/printf.h`<br>`vendor/ble_master/blm_host.c` | 33684 |
| b80_master_custom_pair | `vendor/ble_master/app_config.h`<br>`vendor/ble_master/blm_host.c`<br>`vendor/common/custom_pair.h` | 29316 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
