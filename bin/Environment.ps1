### Variables #########################################################################
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Windows.Forms,System.Drawing
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
Add-Type -Path "$PSSCriptRoot\MahApps.Metro.dll"
Add-Type -Path "$PSSCriptRoot\System.Windows.Interactivity.dll"
$Global:CheckError = ""
$Global:LowSpace = ""
$Global:RebootRequired = ""
$Global:Battery = ""
$Global:VPN = ""
$ComputerType = ""
$PublicDesktop = ([Environment]::GetEnvironmentVariable("Public"))+"\Desktop"
$TotalTime = 120
$LogFile = "$WorkFolder\Inplace.log"
$InitialLog = "C:\Inplace.log"
$DateFileName = Get-Date -format yyyyMMdd_HHmm
$OSBuild = ([environment]::OSVersion.Version).Build
$LogoPath = "$WorkFolder\Images\$Logo"
$LinePath = "$WorkFolder\Images\$Line"
$WindowsLogoPath = "$WorkFolder\Images\$WindowsLogo"
$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$BitlockerStatus = (Get-BitLockerVolume | Where-Object {$_.MountPoint -eq "C:"}).ProtectionStatus
[Byte[]] $Key = (1..16)

### Load WPF Framework ##############################################################
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing
$Global:AssemblyLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:ScriptPath = Split-Path -Path $PSSCriptRoot -Parent
#$Global:AssemblyLocation = Join-Path -Path $ScriptPath -ChildPath .\bin
foreach ($Assembly in (Dir $AssemblyLocation -Filter *.dll)) {
     [System.Reflection.Assembly]::LoadFrom($Assembly.fullName) | out-null
}
#######################################################################################