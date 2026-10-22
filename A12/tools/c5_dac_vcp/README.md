# NUCLEO-C542RC 当可调电压源

我手边没有可调电源和电位器，测 TLSR8208 的 ADC 线性度时，用一块 NUCLEO-C542RC 的 DAC 输出电压。

- 基于 STM32C5 SDK 2.1.0 的 `examples/hal/dac/simple_conversion`，改了 5 个文件，差异见 `改动.diff`（路径相对例程根目录）。
- DAC1_OUT1 = PA4（Arduino 排座 A2），12 位右对齐；USART2 加上 PA3 接收，经 ST-LINK 虚拟串口收命令，115200 8N1。
- `c5_a12_dac_vcp.hex` 是我编好、上板用过的版本，用 STM32CubeProgrammer 烧录。

串口命令，一行一条（CR 或 LF 结尾），每条回一行 `OK code=.. mv=.. buf=.. vref=..` 或 `ERR ..`：

| 命令 | 作用 |
|---|---|
| `M <mV>` | 按毫伏设输出，code = round(mV × 4095 / vref) |
| `C <code>` | 直接设 12 位码值（0~4095） |
| `B <0或1>` | 关 / 开输出缓冲（开：0.2 V ~ VDDA−0.2 V） |
| `R <mV>` | 设 `M` 换算用的 VREF+，用万用表量 VDD_MCU 后填进去 |
| `?` | 报告当前状态 |

上电默认：缓冲开、码值 0、vref 3300。

接线：PA4 → TLSR8208 的 PB0（开发板 J13 第 6 脚），两板 GND 相连。**先给 TLSR8208 板上电，再给 NUCLEO 上电**，避免 PB0 倒灌。

许可：改自 ST 官方例程，版权归 STMicroelectronics，遵循 ST 原文件头中的许可。
