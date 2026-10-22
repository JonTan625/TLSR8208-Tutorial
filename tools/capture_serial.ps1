param([string]$Port = 'COM7', [int]$Seconds = 600, [string]$Out = "$PSScriptRoot\serial.log")
# Incremental capture: append and flush on every read so the log can be read mid-run.
# Keep this file ASCII-only: Windows PowerShell 5 reads BOM-less UTF-8 as GBK and may swallow line breaks.
$ErrorActionPreference = 'Stop'
$sp = New-Object System.IO.Ports.SerialPort $Port, 115200, 'None', 8, 'One'
$sp.Open()
$fs = [IO.File]::Open($Out, 'Create', 'Write', 'Read')
$total = 0
$sw = [Diagnostics.Stopwatch]::StartNew()
while ($sw.Elapsed.TotalSeconds -lt $Seconds) {
    $n = $sp.BytesToRead
    if ($n -gt 0) { $b = New-Object byte[] $n; [void]$sp.Read($b, 0, $n); $fs.Write($b, 0, $n); $fs.Flush(); $total += $n }
    else { Start-Sleep -Milliseconds 50 }
}
$sp.Close(); $fs.Close()
"captured $total bytes -> $Out"
