# 第 12 篇：ADC 与校准，14 位里有几位是真的

基线：tc_platform_sdk V3.5.1。

`tools/` 里是 PB0 线性度扫描用的电脑端脚本，以及当可调电压源用的 NUCLEO-C542RC 固件。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [ADC_Demo_linlog](ADC_Demo_linlog/) | `ADC_Demo` | ADC_Demo（测 PB0）每次采样打印一行 `ADC <原始码> <毫伏>`，开机打印 OTP 里的 Vref 校准值 `ADC_INIT vref=… off=…`。给 `tools/a12_sweep.ps1` 用。 |
| [ADC_Demo_nocal](ADC_Demo_nocal/) | `ADC_Demo` | ADC_Demo 初始化后调 `adc_set_gpio_calib_vref(1175, 0)`，盖掉 OTP 校准值，用来和带校准的读数对比。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| ADC_Demo_linlog | `demo/vendor/ADC_Demo/ADC_V1.0/ADC_Demo/app.c` | 9096 |
| ADC_Demo_nocal | `demo/vendor/ADC_Demo/ADC_V1.0/ADC_Demo/app.c` | 7812 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

## tools

- `tools/a12_sweep.ps1`（PowerShell）：经 NUCLEO 的虚拟串口逐点设 DAC 电压，同时从 TLSR8208 的日志口（PD3）收 `ADC` 行，每点取平均，存成 CSV。端口、扫描范围、步进、缓冲开关都是参数，见文件开头的 `param()`。
- `tools/a12_analyze.py`（Python，只用标准库）：读扫描 CSV，最小二乘拟合后算 INL，输出结果文本、逐点 CSV 和 SVG 图。用法见文件开头。
- `tools/c5_dac_vcp/`：NUCLEO-C542RC 当可调电压源的固件（hex）和相对 ST 例程的差异，说明见该目录 README。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
