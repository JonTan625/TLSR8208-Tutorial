# 第 18 篇：配对、加密和绑定，Just Works 到底安不安全

基线：tc_ble_simple_sdk V3.4.2.2 + patch_0001。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [b80_ble_sample_a18bond](b80_ble_sample_a18bond/) | `b80_ble_sample` | ble_sample 打印配对、加密、绑定事件（`[A18][SMP]`）和重启后的广播类型（`[A18][ADV]`），用来看绑定后的定向广播和回连。 |
| [b80_feature_gatt_sec_L3](b80_feature_gatt_sec_L3/) | `b80_ble_feature_test` | ble_feature_test 改成 `TEST_GATT_SECURITY`，安全等级改成 Level 3（Passkey，PIN 码从串口打印）。 |
| [b80_feature_gatt_sec_L2](b80_feature_gatt_sec_L2/) | `b80_ble_feature_test` | `TEST_GATT_SECURITY`，安全等级保持例程默认的 Level 2，和 Level 3 对照。 |
| [b80_feature_gatt_sec_L3_nolog](b80_feature_gatt_sec_L3_nolog/) | `b80_ble_feature_test` | 同上，不打开日志，和正文开头写的 40948 字节一致。不打开日志就看不到串口打印的 PIN 码，只编译、没有单独上板。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| b80_ble_sample_a18bond | `drivers/printf.h`<br>`vendor/ble_sample/app.c` | 46980 |
| b80_feature_gatt_sec_L3 | `drivers/printf.h`<br>`vendor/ble_feature_test/feature_config.h`<br>`vendor/ble_feature_test/feature_gatt_security/app_config.h` | 42260 |
| b80_feature_gatt_sec_L2 | `drivers/printf.h`<br>`vendor/ble_feature_test/feature_config.h` | 42244 |
| b80_feature_gatt_sec_L3_nolog | `vendor/ble_feature_test/feature_config.h`<br>`vendor/ble_feature_test/feature_gatt_security/app_config.h` | 40948 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
