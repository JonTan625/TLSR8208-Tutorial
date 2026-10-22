# 第 10 篇：PWM 与红外，6 路 PWM 只有 PWM0 会发红外

基线：tc_platform_sdk V3.5.1。

PWM 和红外发射的波形我没有用示波器测过，下面四个固件只保证能编译、改法和正文一致。红外学习 IR_LEARN_Demo 用的是默认配置。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [PWM_Demo_normal_pc1](PWM_Demo_normal_pc1/) | `PWM_Demo` | `PWM_MODE` 改成 1（连续模式），补上 B80 分支漏掉的选脚 `gpio_set_func(PWM_PIN, AS_PWMx)` 和 `pwm_start(PWM0_ID)`。PC1 输出 1 kHz、40%。 |
| [PWM_Demo_normal_pa5](PWM_Demo_normal_pa5/) | `PWM_Demo` | 同上，输出脚改到 PA5（绿灯 D2），看亮度。 |
| [PWM_Demo_irdma_pa2](PWM_Demo_irdma_pa2/) | `PWM_Demo` | `PWM_MODE` 改成 5（红外 DMA FIFO），输出脚用例程默认的 PA2。 |
| [PWM_Demo_irdma_pc1](PWM_Demo_irdma_pc1/) | `PWM_Demo` | 红外 DMA FIFO，输出脚改到 PC1。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| PWM_Demo_normal_pc1 | `demo/vendor/PWM_Demo/app_config.h`<br>`demo/vendor/PWM_Demo/app_normal.c` | 6908 |
| PWM_Demo_normal_pa5 | `demo/vendor/PWM_Demo/app_config.h`<br>`demo/vendor/PWM_Demo/app_normal.c` | 6904 |
| PWM_Demo_irdma_pa2 | `demo/vendor/PWM_Demo/app_config.h` | 7544 |
| PWM_Demo_irdma_pc1 | `demo/vendor/PWM_Demo/app_config.h`<br>`demo/vendor/PWM_Demo/app_ir_dma_fifo.c` | 7548 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
