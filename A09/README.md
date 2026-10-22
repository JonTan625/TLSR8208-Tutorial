# 第 9 篇：定时器与看门狗，两只看门狗各管什么

基线：tc_platform_sdk V3.5.1。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [Debug_Demo_wdboot](Debug_Demo_wdboot/) | `Debug_Demo` | 不调 `wd_32k_stop()`（注释掉 `common.c` 里那一行），开机次数记在 `DEEP_ANA_REG2`（0x3c，只有断电才复位），并把模拟寄存器 0x70 和 32K 定时器读数存进全局变量给 BDT 的 Tdebug 看。用来判断 32K 看门狗上电默认是不是开着。**读上电默认状态时，VCC 和 SWS 线要一起断开**，否则 SWS 倒灌供电，模拟寄存器会保留旧值。 |
| [Timer_Demo_gpioWidth](Timer_Demo_gpioWidth/) | `Timer_Demo` | Timer_Demo 改成 `TIMER_GPIO_WIDTH_MODE`，测量前先把 PA6 拉高 1 ms，给 Timer0 一个明确的起始下降沿（例程原来少了这一步）。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| Debug_Demo_wdboot | `demo/vendor/Debug_Demo/app.c`<br>`demo/vendor/common/common/common.c` | 8684 |
| Timer_Demo_gpioWidth | `demo/vendor/TIMER_Demo/app.c`<br>`demo/vendor/TIMER_Demo/app_config.h` | 7620 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
