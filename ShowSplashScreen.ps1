Add-Type -AssemblyName System.Windows.Forms

$Screens = [System.Windows.Forms.Screen]::AllScreens

Foreach ($Screen in $screens) { 
    $PowerShell = [Powershell]::Create()
    [void]$PowerShell.AddScript({Param($ScriptLocation, $DeviceName); powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "$ScriptLocation\CreateSplashScreen.ps1" -DeviceName $DeviceName})
    [void]$PowerShell.AddArgument($PSScriptRoot)
    [void]$PowerShell.AddArgument($Screen.DeviceName)
    [void]$PowerShell.BeginInvoke()
}

Start-Sleep -Seconds 10
