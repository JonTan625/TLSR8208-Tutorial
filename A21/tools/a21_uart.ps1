# A21-1: talk to ble_module over COM7 (PB4 = module TX, PB5 = module RX, 115200 8N1).
# Logs every RX chunk; sends send_001.txt, send_002.txt, ... (hex bytes, spaces allowed) once each, in order.
# Stops when capture.stop appears. Nothing is deleted.
param([string]$Port = 'COM7', [string]$OutDir = '.', [int]$MaxSeconds = 3600)
$ErrorActionPreference = 'Stop'
$rawPath = Join-Path $OutDir 'uart_rx_raw.bin'
$logPath = Join-Path $OutDir 'uart_log.txt'
$stopPath = Join-Path $OutDir 'capture.stop'
$sp = [System.IO.Ports.SerialPort]::new($Port, 115200, 'None', 8, 'One')
$sp.DtrEnable = $false; $sp.RtsEnable = $false
$watch = [Diagnostics.Stopwatch]::StartNew()
$start = Get-Date
$raw = [IO.FileStream]::new($rawPath, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite)
$log = [IO.StreamWriter]::new($logPath, $false, [Text.UTF8Encoding]::new($false))
$log.WriteLine("start=" + $start.ToString('yyyy-MM-dd HH:mm:ss.fff') + " port=$Port 115200 8N1"); $log.Flush()
function Now { ($start.AddMilliseconds($watch.ElapsedMilliseconds)).ToString('HH:mm:ss.fff') }
$n = 1; $rx = 0
try {
    $sp.Open()
    Write-Output "UART READY $Port"
    while ($watch.Elapsed.TotalSeconds -lt $MaxSeconds -and -not (Test-Path -LiteralPath $stopPath)) {
        $k = $sp.BytesToRead
        if ($k -gt 0) {
            $b = [byte[]]::new($k); $r = $sp.Read($b, 0, $k)
            $raw.Write($b, 0, $r); $raw.Flush(); $rx += $r
            $log.WriteLine((Now) + "`tRX`t" + [BitConverter]::ToString($b, 0, $r).Replace('-', ' ')); $log.Flush()
        }
        $f = Join-Path $OutDir ('send_{0:D3}.txt' -f $n)
        if (Test-Path -LiteralPath $f) {
            $hex = (Get-Content -LiteralPath $f -Raw).Trim() -split '\s+' | Where-Object { $_ -ne '' }
            $tx = [byte[]]($hex | ForEach-Object { [Convert]::ToByte($_, 16) })
            $sp.Write($tx, 0, $tx.Length)
            $log.WriteLine((Now) + "`tTX`t" + [BitConverter]::ToString($tx).Replace('-', ' ') + "`t(" + (Split-Path $f -Leaf) + ")"); $log.Flush()
            $n++
        }
        Start-Sleep -Milliseconds 20
    }
} finally {
    $log.WriteLine("stop=" + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff') + " rx_bytes=$rx sent_files=$($n - 1)")
    $log.Dispose(); $raw.Dispose()
    if ($sp.IsOpen) { $sp.Close() }
    $sp.Dispose()
    Write-Output "UART STOPPED rx=$rx sent=$($n - 1)"
}
