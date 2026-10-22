# 第 8 篇：UART 与日志口，printf 为什么是模拟出来的

基线：tc_platform_sdk V3.5.1。

硬件 UART 的 DMA 模式就是 UART_Demo 默认配置，不需要改。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [Debug_Demo_irq1ms_pb3](Debug_Demo_irq1ms_pb3/) | `Debug_Demo` | Debug_Demo 加一个 Timer0 每 1 ms 的中断，中断里只清标志、计数 `timer0_irq_cnt`，进出中断时把 PB3 拉高、拉低。用来看中断打断 GPIO 模拟串口后 printf 的乱码，PB3 可以接示波器看中断占了多久。 |
| [UART_Demo_ndma](UART_Demo_ndma/) | `UART_Demo` | UART_Demo 的 `UART_MODE` 从 `UART_DMA` 改成 `UART_NDMA`，非 DMA 模式收发回传。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| Debug_Demo_irq1ms_pb3 | `demo/vendor/Debug_Demo/app.c`<br>`demo/vendor/Debug_Demo/main.c` | 8972 |
| UART_Demo_ndma | `demo/vendor/UART_Demo/UART_V1.0/UART_Demo/app_config.h` | 9192 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
