# 第 22 篇：BLE 进阶，DLE、MTU、2M PHY 和几个小工具

基线：tc_ble_simple_sdk V3.4.2.2 + patch_0001。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [b80_feature_dle_a22_v2](b80_feature_dle_a22_v2/) | `b80_ble_feature_test` | ble_feature_test 改成 `TEST_LL_DATA_LENGTH_EXTENSION_SLAVE`（DLE 从机）并加日志：打印 DLE、MTU 协商结果和连接参数更新；手机往 SPP 特征写 `T` 后连续 Notify 10 s 测吞吐。这个模式打开日志后 RAM 不够，所以把 `drivers/printf.c` 的 `io_putchar()` 从 RAM 挪到 Flash，同时把逐位等待改成按绝对时刻对齐（在 Flash 里跑慢，原来的相对等待会累积误差，字节会乱）。 |
| [b80_feature_phyconn_log](b80_feature_phyconn_log/) | `b80_ble_feature_test` | `TEST_PHY_CONN`（1M/2M 切换）打印每次发出的 PHY 请求和 PHY 更新事件。 |
| [b80_feature_phyconn_v2](b80_feature_phyconn_v2/) | `b80_ble_feature_test` | 同上，改成记录回调参数 `p[0]`（1 字节当前 PHY）的历史给 Tdebug 读，并关掉睡眠（`BLE_APP_PM_ENABLE` 0），BDT 才连得上。 |
| [b80_feature_softtimer](b80_feature_softtimer/) | `b80_ble_feature_test` | `TEST_USER_BLT_SOFT_TIMER`（软件定时器），没有别的改动。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| b80_feature_dle_a22_v2 | `drivers/printf.c`<br>`drivers/printf.h`<br>`vendor/ble_feature_test/feature_DLE_slave/app.c`<br>`vendor/ble_feature_test/feature_config.h` | 45620 |
| b80_feature_phyconn_log | `drivers/printf.h`<br>`vendor/ble_feature_test/feature_config.h`<br>`vendor/ble_feature_test/feature_phy_conn/app.c` | 42036 |
| b80_feature_phyconn_v2 | `drivers/printf.h`<br>`vendor/ble_feature_test/feature_config.h`<br>`vendor/ble_feature_test/feature_phy_conn/app.c`<br>`vendor/ble_feature_test/feature_phy_conn/app_config.h` | 39252 |
| b80_feature_softtimer | `vendor/ble_feature_test/feature_config.h` | 40612 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
