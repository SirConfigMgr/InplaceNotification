$WorkFolder = (Get-ItemProperty HKLM:\SOFTWARE\DMS\WindowsInplaceUpdate -Name WorkFolder  -ErrorAction Stop).WorkFolder
$InplaceVersion = (Get-ItemProperty HKLM:\SOFTWARE\DMS\WindowsInplaceUpdate -Name InplaceVersion  -ErrorAction Stop).InplaceVersion
$TSPackageID = (Get-ItemProperty HKLM:\SOFTWARE\DMS\WindowsInplaceUpdate -Name TSPackageID  -ErrorAction Stop).TSPackageID

New-Item -Path $WorkFolder\$InplaceVersion\StartBySchedTask.txt
Get-WmiObject -Namespace "root\ccm\scheduler" -Class ccm_scheduler_history | where {$_.ScheduleID -like "*$TSPackageID*"} | Remove-WmiObject
Get-Service | where {$_.Name -eq "CCMExec"} | Restart-Service