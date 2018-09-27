### Import Config File ################################################################
. "$PSScriptRoot\Config.ps1"
#######################################################################################

New-Item -Path $WorkFolder\$InplaceVersion\StartBySchedTask.txt
Get-WmiObject -Namespace "root\ccm\scheduler" -Class ccm_scheduler_history | where {$_.ScheduleID -like "*$TSPackageID*"} | Remove-WmiObject
Get-Service | where {$_.Name -eq "CCMExec"} | Restart-Service