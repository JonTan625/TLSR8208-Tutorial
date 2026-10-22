param(
    [string]$C5Port    = 'COM5',   # NUCLEO-C542RC ST-LINK VCP (DAC source)
    [string]$TlsrPort  = 'COM7',   # CH340 on TLSR8208 PD3 (ADC_Demo_linlog prints)
    [int]$StartMv      = 200,
    [int]$StopMv       = 3100,
    [int]$StepMv       = 10,
    [int]$Buffer       = 1,        # 1: DAC buffer on (0.2 V..VDDA-0.2 V); 0: off (0..VREF+, ~13 kohm)
    [int]$VrefMv       = 3300,     # VREF+ of the NUCLEO (= VDD_MCU), measure it with the meter
    [int]$SettleMs     = 150,
    [int]$Samples      = 20,       # ADC lines averaged per point
    [string]$DmmMv     = '',       # e.g. '200,500,1000,1500,2000,2500,3000': pause and ask for the meter reading
    [int]$Set          = -1,       # only set this mV (with -Buffer/-VrefMv) and exit, for manual meter checks
    [string]$Out       = ''
)
# Keep this file ASCII-only: Windows PowerShell 5 reads BOM-less UTF-8 as GBK.
# Power order: TLSR8208 board first (ADC_Demo_linlog running), then this script.
# The script always leaves the DAC at 0 mV when it ends.
$ErrorActionPreference = 'Stop'

function Open-Port([string]$name) {
    $p = New-Object System.IO.Ports.SerialPort $name, 115200, 'None', 8, 'One'
    $p.NewLine = "`n"
    $p.ReadTimeout = 500
    $p.Open()
    $p.DiscardInBuffer()
    return $p
}

function C5-Cmd([System.IO.Ports.SerialPort]$p, [string]$cmd) {
    $p.DiscardInBuffer()
    $p.Write($cmd + "`r`n")
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while ($sw.ElapsedMilliseconds -lt 2000) {
        try { $line = $p.ReadLine().Trim() } catch [TimeoutException] { continue }
        if ($line.StartsWith('OK') -or $line.StartsWith('ERR')) { return $line }
    }
    throw "C5 no reply to '$cmd'"
}

function Parse-Kv([string]$line, [string]$key) {
    $m = [regex]::Match($line, "$key=(\d+)")
    if (-not $m.Success) { throw "no $key in '$line'" }
    return [int]$m.Groups[1].Value
}

function Read-Adc([System.IO.Ports.SerialPort]$p, [int]$n) {
    $p.DiscardInBuffer()
    $codes = New-Object System.Collections.Generic.List[int]
    $mvs = New-Object System.Collections.Generic.List[int]
    $first = $true
    $idle = [Diagnostics.Stopwatch]::StartNew()
    while ($codes.Count -lt $n) {
        try { $line = $p.ReadLine().Trim() }
        catch [TimeoutException] {
            if ($idle.ElapsedMilliseconds -gt 3000) { throw "no data on $($p.PortName) for 3 s" }
            continue
        }
        $idle.Restart()
        if ($first) { $first = $false; continue }   # first line may be cut by DiscardInBuffer
        $m = [regex]::Match($line, '^ADC (\d+) (\d+)$')
        if ($m.Success) { $codes.Add([int]$m.Groups[1].Value); $mvs.Add([int]$m.Groups[2].Value) }
    }
    $sum = 0; foreach ($c in $codes) { $sum += $c }
    $mean = $sum / $codes.Count
    $sq = 0.0; foreach ($c in $codes) { $sq += ($c - $mean) * ($c - $mean) }
    $msum = 0; foreach ($v in $mvs) { $msum += $v }
    return [pscustomobject]@{
        Mean = $mean; Std = [math]::Sqrt($sq / $codes.Count)
        Min = ($codes | Measure-Object -Minimum).Minimum
        Max = ($codes | Measure-Object -Maximum).Maximum
        MvMean = $msum / $mvs.Count
    }
}

$c5 = Open-Port $C5Port
$tl = $null
try {
    $r = C5-Cmd $c5 "R $VrefMv"
    $r = C5-Cmd $c5 "B $Buffer"
    if ($Set -ge 0) {
        $r = C5-Cmd $c5 "M $Set"
        "set: $r  (DAC keeps this value; run with -Set 0 to return to 0 V)"
        $c5.Close(); $c5 = $null
        return
    }

    if ($Out -eq '') { $Out = Join-Path $PSScriptRoot ("sweep_buf{0}_{1}.csv" -f $Buffer, (Get-Date -Format 'yyyyMMdd_HHmmss')) }
    $dmm = @{}
    if ($DmmMv -ne '') { foreach ($s in $DmmMv.Split(',')) { $dmm[[int]$s.Trim()] = $true } }

    $tl = Open-Port $TlsrPort
    $w = New-Object System.IO.StreamWriter($Out, $false, [Text.Encoding]::ASCII)
    $w.WriteLine("# a12_sweep vref_mv=$VrefMv buffer=$Buffer settle_ms=$SettleMs samples=$Samples start=$(Get-Date -Format s)")
    $w.WriteLine('target_mv,dac_code,buffer,adc_code_mean,adc_code_std,adc_code_min,adc_code_max,adc_mv_mean,dmm_mv')
    $w.Flush()

    for ($mv = $StartMv; $mv -le $StopMv; $mv += $StepMv) {
        $r = C5-Cmd $c5 "M $mv"
        if ($r.StartsWith('ERR')) { throw "C5 rejected M ${mv}: $r" }
        $code = Parse-Kv $r 'code'
        Start-Sleep -Milliseconds $SettleMs
        $a = Read-Adc $tl $Samples
        $dm = ''
        if ($dmm.ContainsKey($mv)) {
            $dm = Read-Host ("{0} mV (code {1}): meter reading at TLSR PB0 in mV" -f $mv, $code)
        }
        $line = '{0},{1},{2},{3:F2},{4:F2},{5},{6},{7:F1},{8}' -f $mv, $code, $Buffer, $a.Mean, $a.Std, $a.Min, $a.Max, $a.MvMean, $dm
        $w.WriteLine($line); $w.Flush()
        Write-Host $line
    }
    $w.Close()
    "done -> $Out"
}
finally {
    if ($c5 -ne $null) {
        try { [void](C5-Cmd $c5 'M 0') } catch { Write-Host "WARNING: could not set DAC to 0: $_" }
        $c5.Close()
    }
    if ($tl -ne $null) { $tl.Close() }
}
