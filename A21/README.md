# 第 21 篇：ble_module，把开发板变成串口透传模块

ble_module 用的是默认配置，没有改固件。


## tools

- `tools/a21_uart.ps1`：我测透传时用的电脑端串口脚本：依次发送 `-OutDir` 目录里的 `send_001.txt`、`send_002.txt`……（十六进制字节，可以有空格），收到的字节记进 `uart_log.txt` 和 `uart_rx_raw.bin`，目录里出现 `capture.stop` 文件就停。

每个固件测到哪一步（只编译、上板看现象还是仪器实测），以文章开头的「验证状态」为准。
