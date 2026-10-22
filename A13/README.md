# 第 13 篇：SPI 与 I2C，先拿板上的 EEPROM 练手

基线：tc_platform_sdk V3.5.1。

| 目录 | 编译配置 | 改了什么 |
|---|---|---|
| [Debug_Demo_eeprom](Debug_Demo_eeprom/) | `Debug_Demo` | 把正文的 `ee_test()` 放进 Debug_Demo，在 `user_init()` 末尾调用并打印 `rbuf`。**这个目录是按正文代码重建的**：我当时上板的那一版没有留源码，重建后编出来也是 9372 字节，和当时一样，但没法逐字节比对，这一版也没有再上板。开发板 J44、J45、J46 跳帽要插着。 |

## 每个目录里有什么

- 改过的源文件，按 SDK 根目录下的相对路径摆放（Platform 是 `tc_platform_sdk-V3.5.1/`，BLE 是 `b80_ble_sdk/`）；
- `改动.diff`：相对官方 SDK 的差异（BLE 是打完 patch_0001 之后）；
- `<目录名>.bin`：我按这些文件编出来的固件，BDT 从 Flash 地址 0 下载。

| 目录 | 替换文件 | bin 字节 |
|---|---|---|
| Debug_Demo_eeprom | `demo/vendor/Debug_Demo/app.c` | 9372 |

sha256 见 `改动清单.json`。

## 怎么用

1. 准备一份干净的 SDK（见仓库根目录 README），先备份要被覆盖的文件。
2. 把某个目录里除 `改动.diff` 和 `.bin` 以外的文件，按原路径覆盖到 SDK 根目录；或者在 SDK 根目录执行 `git apply <目录>/改动.diff`（SDK 用 git 管着的话）。
3. IoT Studio 导入 `project/tlsr_tc32/B80`，选表里的编译配置编译。
4. 换下一个目录之前，先把上一个目录改过的文件恢复成原样。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
