#######################################################################################
#
# V2.1
# Rene.Hartmann
# 23.02.2018
#
# Changelog
#
# V1.1     23.04.2018     Rene.Hartmann
#                         Progressbar durch UPGBackground ersetzt
#
# V1.2     24.04.2018     Rene.Hartmann
#                         Neues Design
#
# V1.3     06.08.2018     Rene.Hartmann
#                         Zeitauswahl hinzugefügt
#
# V1.4     07.08.2018     Rene.Hartmann
#                         VPN Abfrage hinzugefügt
#
# V2.0     20.08.2018     Rene.Hartmann
#                         Logging erweitert
#
# V2.1     25.09.2018     Rene.Hartmann
#                         Scheduled Task Option für Win7 eingefügt
#                         CMTrace-Kompatible Log Option hinzugefügt
#                         
#
#######################################################################################

### Custom Variables ##################################################################
$InplaceVersion = 17134
$InplaceVersionText = "Windows 10 April 2018 Update Build 1803"
$TSPackageID = "DMS0073F"
$CompanyCode = "DMS"
$WorkFolder = "C:\ProgramData\$CompanyCode\Inplace"
$Background = "bg.png"
$Logo = "Logo.png"
$VPNAdresses = @("10.26.254*","172.18.249*","172.26.125*","172.26.252*","172.26.120*")
$Header = "Logo" # 'Logo' or 'Title'
$Lang = "DE" # 'DE' or 'EN' 
#######################################################################################

### Import Language File ##############################################################
. "$PSScriptRoot\$Lang.ps1"
#######################################################################################

### Variables #########################################################################
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
$LogoPath = "$WorkFolder\$Logo"
#######################################################################################

### Log Function ######################################################################
function Write-Log {

[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    [String]$Path,

    [parameter(Mandatory=$true)]
    [String]$Message,

    [parameter(Mandatory=$true)]
    [String]$Component,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Info", "Warning", "Error")]
    [String]$Type
    )

Switch ($Type) {
    "Info" {[int]$Type = 1}
    "Warning" {[int]$Type = 2}
    "Error" {[int]$Type = 3}
    }

$Content = "<![LOG[$Message]LOG]!>" +`
        "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`" " +`
        "date=`"$(Get-Date -Format "M-d-yyyy")`" " +`
        "component=`"$Component`" " +`
        "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
        "type=`"$Type`" " +`
        "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +`
        "file=`"`">"

Add-Content -Path $Path -Value $Content
}

### Start #############################################################################
If (Test-Path $InitialLog) {Remove-Item $InitialLog -Force}
$Info = "Start Script"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Start" -Type Info

### Prepare Eventlog ##################################################################
$Info = "Prepare Eventlog"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Eventlog" -Type Info
New-EventLog -LogName Application -Source Win10Inplace -ErrorAction SilentlyContinue -ErrorVariable ErrorAction
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Start" -Type Error}
    Else {
        $Info = "Prepared Eventlog"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Eventlog" -Type Info
        }

### Write Initial Eventlog Entry ######################################################
$Message = "Start Script
InPlace Version: $InplaceVersionText
"
Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 1 -Message "$Message"


### Work Folder #######################################################################
$Info = "Prepare Workfolder"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "WorkFolder" -Type Info
If (!(Test-Path -Path $WorkFolder)) {
    New-Item -Path $WorkFolder -ItemType directory -ErrorVariable ErrorAction
    If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "WorkFolder" -Type Error}
    Else {
        $Info = "Prepared Workfolder"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "WorkFolder" -Type Info
        }
    }
    Else {
        $Info = "Workfolder Already Exist"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "WorkFolder" -Type Warning
        }
If (Test-Path $LogFile) {Move-Item $LogFile "$WorkFolder\Inplace_$DateFileName.log"}
If (!(Test-Path -Path $WorkFolder\$InplaceVersion)) {
    New-Item -Path $WorkFolder\$InplaceVersion -ItemType directory -ErrorVariable ErrorAction
    If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "WorkFolder" -Type Error}
    Else {
        $Info = "Prepared Subfolder"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "WorkFolder" -Type Info
        }
    }
    Else {
        $Info = "Folder $WorkFolder\$InplaceVersion Already Exist"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "WorkFolder" -Type Warning
        }

### Registry Work Folder ##############################################################
$Info = "Prepare Registry"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
$Info = "Create Keys"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info

If (!(Test-Path HKLM:\SOFTWARE\$CompanyCode)) {
    New-Item -Path HKLM:\SOFTWARE\$CompanyCode -ErrorVariable ErrorAction
    If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Registry" -Type Error}
    Else {
        $Info = "Created HKLM:\SOFTWARE\$CompanyCode"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
        }
    }
    Else {
        $Info = "Path HKLM:\SOFTWARE\$CompanyCode Already Exist"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Warning
        }
If (!(Test-Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate)) {
    New-Item -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -ErrorVariable ErrorAction
    If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Registry" -Type Error}
    Else {
        $Info = "Created HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
        }
    }
    Else {
        $Info = "Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Warning
    }
$Info = "Create Values"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name InplaceVersion -Value $InplaceVersion -PropertyType String -ErrorVariable ErrorAction -Force
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Registry" -Type Error}
    Else {
        $Info = "Created Value InplaceVersion $InplaceVersion"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
        }
New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name InplaceVersionText -Value $InplaceVersionText -ErrorVariable ErrorAction -Force
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Registry" -Type Error}
    Else {
        $Info = "Created Value InplaceVersionText $InplaceVersionText"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
        }
New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name WorkFolder -Value $WorkFolder -ErrorVariable ErrorAction -Force
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Registry" -Type Error}
    Else {
        $Info = "Created Value WorkFolder $WorkFolder"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
        }
New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name InplaceFolder -Value $WorkFolder\$InplaceVersion -ErrorVariable ErrorAction -Force
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Registry" -Type Error}
    Else {
        $Info = "Created Value InplaceFolder $WorkFolder\$InplaceVersion"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
        }
New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name TSPackageID -Value $TSPackageID -ErrorVariable ErrorAction -Force
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Registry" -Type Error}
    Else {
        $Info = "Created Value TSPackageID $TSPackageID"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Registry" -Type Info
        }

### Check OS Already Compliant #######################################################
$Info = "Check OS Version Compliance"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Compliance" -Type Info
If ($OSBuild -ge $InplaceVersion) {
    $AlreadyCompliant = $True
    Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 6 -Message "System Already Compliant"
    $Info = "OS Already Compliant"
    Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Compliance" -Type Info
    If (!(Test-Path -Path $WorkFolder\$InplaceVersion\Inplace_Compliant.txt)) {
       New-Item -Path $WorkFolder\$InplaceVersion\Inplace_Compliant.txt -ErrorVariable ErrorAction
       If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Compliance" -Type Error}
            Else {
            $Info = "Created File $WorkFolder\$InplaceVersion\Inplace_Compliant.txt"
            Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Compliance" -Type Info
            }
        }
    }
    Else {
        $Info = "System Not Compliant - Update Needed"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Compliance" -Type Warning
        If (Test-Path -Path $WorkFolder\$InplaceVersion\Inplace_Compliant.txt) {
            Remove-Item -Path $WorkFolder\$InplaceVersion\Inplace_Compliant.txt -ErrorVariable ErrorAction -Force
            If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Compliance" -Type Error}
            Else {
                $Info = "Deleted File $WorkFolder\$InplaceVersion\Inplace_Compliant.txt"
                Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Compliance" -Type Info
                }
        }
    }

### Copy Files #######################################################################
$Info = "Copy Files"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Copy" -Type Info
Move-Item $InitialLog -Destination $WorkFolder -ErrorVariable ErrorAction -Force
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Copy" -Type Error}
    Else {
    $Info = "Moved Initial Log"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Copy" -Type Info
    }
If (Test-Path $InitialLog) {Remove-Item $InitialLog -Force}
Copy-Item $PSScriptRoot\*.* $WorkFolder -Verbose -Force -PassThru -ErrorVariable ErrorAction
If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "Copy" -Type Error}
    Else {
    $Info = "Files Copied To Workfolder"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Copy" -Type Info
    }
If (!($AlreadyCompliant -eq $true)) {
    Copy-Item "$PSScriptRoot\Windows 10 Update.lnk" $PublicDesktop -Verbose -Force -PassThru -ErrorVariable ErrorAction
    If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "Copy" -Type Error}
    Else {
        $Info = "Copied Desktopicon"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Copy" -Type Info
        }
    }

### Create Reg Keys For Countdown ###################################################
$Today = Get-Date
If (!($AlreadyCompliant -eq $True)) {
    $Info = "Prepare Countdown"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
    Try {
        $TargetDate = (Get-ItemProperty HKLM:\SOFTWARE\DMS\WindowsInplaceUpdate -Name TargetDate  -ErrorAction Stop).TargetDate
        $Info = "Target-Date $TargetDate"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
        }
        Catch {
            $TargetDate = ($Today).AddDays(14)
            $Info = "Target-Date $TargetDate"
            Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
            New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name StartDate -Value $Today -ErrorVariable ErrorAction -Force
            If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "Countdown" -Type Error}
            Else {
                $Info = "Created Value StartDate $Today"
                Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
                }
            New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name TargetDate -Value $TargetDate -ErrorVariable ErrorAction -Force
            If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "Countdown" -Type Error}
            Else {
                $Info = "Created Value TargetDate $TargetDate"
                Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
                }
            }
    $RemainingDays = (New-TimeSpan $Today $TargetDate).Days
    $Info = "Remaining Days  $RemainingDays"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
    }


### Check If Script Is Startet By Scheduled Task ####################################
$Info = "Check If Script Is Startet By Scheduled Task"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
If (Test-Path $WorkFolder\$InplaceVersion\StartBySchedTask.txt) {
    $Info = "True - No User Interaction"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Warning
    }
    Else {
        $Info = "False"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }


### Main Window #####################################################################
Function GenerateForm {

Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 2 -Message "Show Inplace Message."
$Info = "Show Inplace Message"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "MainWindow" -Type Info

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null



$form1 = New-Object System.Windows.Forms.Form
$othertimebutton = New-Object System.Windows.Forms.Button
$timelefttext = New-Object System.Windows.Forms.Label
$text = New-Object System.Windows.Forms.Label
$nobutton = New-Object System.Windows.Forms.Button
$okbutton = New-Object System.Windows.Forms.Button
$logo = New-Object System.Windows.Forms.PictureBox
$titel = New-Object System.Windows.Forms.Label
$timer = New-Object System.Windows.Forms.Timer
$TimeRemaining_Label = New-Object System.Windows.Forms.Label
$Countdown_Label = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

$handler_nobutton_Click= 
{
If (!(Test-Path -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt)) {
    New-Item -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt -ErrorVariable ErrorAction
    If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "MainWindow" -Type Error}
    Else {
        $Info = "Created File $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "MainWindow" -Type Info
        }
    }
$form1.Close()
Write-EventLog -LogName Application -Source Win10Inplace -EntryType Warning -EventId 4 -Message "User deferred Update."
$Info = "User Deferred Update - Close Window"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "MainWindow" -Type Warning
[System.Environment]::Exit(99)
}

$okbutton_OnClick= 
{
$Info = "User Started Update - Start Prereq Check"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "MainWindow" -Type Info
CheckDiskSpace
CheckBattery
CheckRebootPending
CheckVPN
If ($global:CheckError -eq $true) {
    ShowMessage
    }
    Else {
    If (Test-Path -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt) {
        Remove-Item -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt -ErrorVariable ErrorAction -Force
        If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "MainWindow" -Type Error}
        Else {
            $Info = "Removed File $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt"
            Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "MainWindow" -Type Info
            }
        }
    Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 3 -Message "$InplaceVersionText started."
    $Info = "Check Passed -  Start $InplaceVersionText And Close Window"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "MainWindow" -Type Info
    }
$form1.Close()
}

$othertimebutton_OnClick= 
{
OtherTime

}

$OnLoadForm_StateCorrection=
{
	$form1.WindowState = $InitialFormWindowState
}


If ($RemainingDays -le 0) {
    $timer.Interval=1000
    $timer.add_Tick({CountDown})
    $script:StartTime = (Get-Date).AddMinutes($TotalTime)
    $timer.Start()
    $TimeRemaining_Label.Visible = $true
    $Countdown_Label.Visible = $true
    }
    Else {
        $TimeRemaining_Label.Visible = $false
        $Countdown_Label.Visible = $false
        }

$form1.BackgroundImage = [System.Drawing.Image]::FromFile("$WorkFolder\$Background")
$form1.BackColor = [System.Drawing.Color]::FromArgb(255,0,51,102)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 580
$System_Drawing_Size.Width = 980
$form1.MaximumSize = $System_Drawing_Size
$form1.MinimumSize = $System_Drawing_Size
$form1.ClientSize = $System_Drawing_Size
$form1.ControlBox = $False
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.ShowIcon = $False
$form1.Text = "$WindowTitle"
$form1.StartPosition = 1

$TimeRemaining_Label.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$TimeRemaining_Label.DataBindings.DefaultDataSourceUpdateMode = 0
$TimeRemaining_Label.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",12,1,3,0)
$TimeRemaining_Label.ForeColor = "Red"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 220
$System_Drawing_Point.Y = 450
$TimeRemaining_Label.Location = $System_Drawing_Point
$TimeRemaining_Label.Name = "TimerText"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 300
$TimeRemaining_Label.Size = $System_Drawing_Size
$TimeRemaining_Label.TabIndex = 6
$TimeRemaining_Label.Text = "$CountdownText"
$form1.Controls.Add($TimeRemaining_Label)

$Countdown_Label.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$Countdown_Label.DataBindings.DefaultDataSourceUpdateMode = 0
$Countdown_Label.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",12,1,3,0)
$Countdown_Label.ForeColor = "Red"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 313
$System_Drawing_Point.Y = 470
$Countdown_Label.Location = $System_Drawing_Point
$Countdown_Label.Name = "Timer"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$Countdown_Label.Size = $System_Drawing_Size
$Countdown_Label.TabIndex = 7
$Countdown_Label.Text = "00:00:00"
$form1.Controls.Add($Countdown_Label)

$timelefttext.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$timelefttext.DataBindings.DefaultDataSourceUpdateMode = 0
$timelefttext.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 545
$System_Drawing_Point.Y = 505
$timelefttext.Location = $System_Drawing_Point
$timelefttext.Name = "timelefttext"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 127
$timelefttext.Size = $System_Drawing_Size
$timelefttext.TabIndex = 5

If ($RemainingDays -gt 1) {$timelefttext.Text = "$RemainingDays $RemainText1"}
    Elseif ($RemainingDays -eq 1) {$timelefttext.Text = "$RemainText2"}
    Elseif ($RemainingDays -le 0) {$timelefttext.Text = "$RemainText3"}

$form1.Controls.Add($timelefttext)

$text.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$text.DataBindings.DefaultDataSourceUpdateMode = 0
$text.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,0,3,0)
$text.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 15
$System_Drawing_Point.Y = 161
$text.Location = $System_Drawing_Point
$text.Name = "text"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 286
$System_Drawing_Size.Width = 429
$text.Size = $System_Drawing_Size
$text.TabIndex = 4
$text.Text = $InplaceText

$form1.Controls.Add($text)


$nobutton.DataBindings.DefaultDataSourceUpdateMode = 0
$nobutton.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 467
$System_Drawing_Point.Y = 500
$nobutton.Location = $System_Drawing_Point
$nobutton.Name = "nobutton"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$nobutton.Size = $System_Drawing_Size
$nobutton.TabIndex = 3
$nobutton.Text = "$NoButtonText"
$nobutton.UseVisualStyleBackColor = $False
$nobutton.add_Click($handler_nobutton_Click)

If ($RemainingDays -eq 0) {$nobutton.Enabled = $false}

$form1.Controls.Add($nobutton)


$okbutton.DataBindings.DefaultDataSourceUpdateMode = 0
$okbutton.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 245
$System_Drawing_Point.Y = 500
$okbutton.Location = $System_Drawing_Point
$okbutton.Name = "okbutton"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 106
$okbutton.Size = $System_Drawing_Size
$okbutton.TabIndex = 1
$okbutton.Text = "$OkButtonText"
$okbutton.UseVisualStyleBackColor = $False
$okbutton.add_Click($okbutton_OnClick)
$form1.Controls.Add($okbutton)

$othertimebutton.DataBindings.DefaultDataSourceUpdateMode = 0
$othertimebutton.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 357
$System_Drawing_Point.Y = 500
$othertimebutton.Location = $System_Drawing_Point
$othertimebutton.Name = "othertimebutton"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 103
$othertimebutton.Size = $System_Drawing_Size
$othertimebutton.TabIndex = 2
$othertimebutton.Text = "$OtherTimeButtonText"
$othertimebutton.UseVisualStyleBackColor = $False
$othertimebutton.add_Click($othertimebutton_OnClick)
$form1.Controls.Add($othertimebutton)

$logo.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$logo.DataBindings.DefaultDataSourceUpdateMode = 0
$logo.Image = [System.Drawing.Image]::FromFile("$LogoPath")
$logo.ImageLocation = ""
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 15
$System_Drawing_Point.Y = 10
$logo.Location = $System_Drawing_Point
$logo.Name = "logo"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 126
$System_Drawing_Size.Width = 307
$logo.Size = $System_Drawing_Size
$logo.TabIndex = 1
$logo.TabStop = $False

$titel.DataBindings.DefaultDataSourceUpdateMode = 0
$titel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",16,0,3,0)
$titel.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 9
$titel.Location = $System_Drawing_Point
$titel.Name = "titel"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 39
$System_Drawing_Size.Width = 216
$titel.Size = $System_Drawing_Size
$titel.TabIndex = 0
$titel.Text = "$InplaceTitle"

If ($Header -eq "Title") {$form1.Controls.Add($titel)}
Elseif ($Header -eq "Logo") {$form1.Controls.Add($logo)}
Else {$form1.Controls.Add($titel)}


$InitialFormWindowState = $form1.WindowState

$form1.add_Load($OnLoadForm_StateCorrection)

$form1.ShowDialog()| Out-Null

}

### Function To Check Disk Space ####################################################
Function CheckDiskSpace {
$global:LowSpace = $false
$FreeSpace = (gwmi win32_logicaldisk -filter "DeviceID='c:'").Freespace/1GB
If ($FreeSpace -lt 10) {
    $global:LowSpace = $true
    $global:CheckError = $true
    }
}

### Function To Check Power Cable Plugged In ########################################
Function CheckBattery {
$ComputerType = [string](Get-WmiObject -Class win32_systemenclosure | select chassistypes).ChassisTypes
If ($ComputerType -eq "8" -or $ComputerType -eq "9" -or $ComputerType -eq "10" -or $ComputerType -eq "14" -or $ComputerType -eq "30" -or $ComputerType -eq "31") {
    $CSModel = (Get-WmiObject -Class Win32_ComputerSystem).Model
    If (!($CSModel -like "*Virtual*")) {
        $global:Battery = $false
        $PowerOnLine = [BOOL](Get-WmiObject -Class BatteryStatus -Namespace root\wmi).PowerOnLine
        If ($PowerOnLine -ne $true) {
            $global:Battery = $true
            $global:CheckError = $true
            }
        }
    }
}

### Function To Check Reboot Pending ################################################
Function CheckRebootPending {
$global:RebootRequired = $false
if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) {
    $global:RebootRequired = $true
    $global:CheckError = $true
    }
    elseif (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) {
        $global:RebootRequired = $true
        $global:CheckError = $true
        }
    try { 
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if(($status -ne $null) -and $status.RebootPending){
            $global:RebootRequired = $true
            $global:CheckError = $true
            }
        }
        catch{$global:RebootRequired = $false}
}

### Function To Check VPN Connectivity ##############################################
Function CheckVPN {
$global:VPN = $False
$IPAddresses = (Get-NetIPAddress).IPAddress
Foreach ($VPNIP in $VPNAdresses) {
    $VPNActive = $IPAddresses -like $VPNIP
    If ($VPNActive) {
        $global:VPN = $True
        $global:CheckError = $true
        }
    }
}

### Check Window ####################################################################
Function ShowMessage {

[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null

$form2 = New-Object System.Windows.Forms.Form
$label7 = New-Object System.Windows.Forms.Label
$textreboot = New-Object System.Windows.Forms.Label
$textVPN = New-Object System.Windows.Forms.Label
$textbattery = New-Object System.Windows.Forms.Label
$textspace = New-Object System.Windows.Forms.Label
$textreboot1 = New-Object System.Windows.Forms.Label
$textbattery1 = New-Object System.Windows.Forms.Label
$textVPN1 = New-Object System.Windows.Forms.Label
$textspace1 = New-Object System.Windows.Forms.Label
$nobutton2 = New-Object System.Windows.Forms.Button
$text2 = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
$X4 = New-Object System.Windows.Forms.Label
$X3 = New-Object System.Windows.Forms.Label
$X2 = New-Object System.Windows.Forms.Label
$X1 = New-Object System.Windows.Forms.Label
$ok4 = New-Object System.Windows.Forms.Label
$ok3 = New-Object System.Windows.Forms.Label
$ok2 = New-Object System.Windows.Forms.Label
$ok1 = New-Object System.Windows.Forms.Label

$nobutton2_OnClick= 
{
If (!(Test-Path -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt)) {
    New-Item -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt  | Out-File $LogFile -Append
    If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "CheckWindow" -Type Error}
    Else {
        $Info = "Created File $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Info
        }
    }
Write-EventLog -LogName Application -Source Win10Inplace -EntryType Error -EventId 7 -Message "Requirements not met."
$Info = "Requirements Not Met - Close Window"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Warning
$form2.close()
[System.Environment]::Exit(99)
}

$OnLoadForm_StateCorrection=
{
	$form2.WindowState = $InitialFormWindowState
}

$form2.BackgroundImage = [System.Drawing.Image]::FromFile("$WorkFolder\$Background")
$form2.BackColor = [System.Drawing.Color]::FromArgb(255,0,51,102)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 500
$System_Drawing_Size.Width = 500
$form2.MaximumSize = $System_Drawing_Size
$form2.MinimumSize = $System_Drawing_Size
$form2.ClientSize = $System_Drawing_Size
$form2.ControlBox = $False
$form2.DataBindings.DefaultDataSourceUpdateMode = 0
$form2.Name = "form2"
$form2.ShowIcon = $False
$form2.Text = "$CheckWindowTitle"
$form2.StartPosition = 1

$X4.DataBindings.DefaultDataSourceUpdateMode = 0
$X4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$X4.ForeColor = [System.Drawing.Color]::FromArgb(255,255,0,0)
$X4.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 230
$X4.Location = $System_Drawing_Point
$X4.Name = "X4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$X4.Size = $System_Drawing_Size
$X4.TabIndex = 18
$X4.Text = "X"
$x4.Visible = $false
$form2.Controls.Add($X4)

$X3.DataBindings.DefaultDataSourceUpdateMode = 0
$X3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$X3.ForeColor = [System.Drawing.Color]::FromArgb(255,255,0,0)
$X3.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 181
$X3.Location = $System_Drawing_Point
$X3.Name = "X3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$X3.Size = $System_Drawing_Size
$X3.TabIndex = 18
$X3.Text = "X"
$x3.Visible = $false
$form2.Controls.Add($X3)

$X2.DataBindings.DefaultDataSourceUpdateMode = 0
$X2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$X2.ForeColor = [System.Drawing.Color]::FromArgb(255,255,0,0)
$X2.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 135
$X2.Location = $System_Drawing_Point
$X2.Name = "X2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$X2.Size = $System_Drawing_Size
$X2.TabIndex = 17
$X2.Text = "X"
$x2.Visible = $false
$form2.Controls.Add($X2)

$X1.DataBindings.DefaultDataSourceUpdateMode = 0
$X1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$X1.ForeColor = [System.Drawing.Color]::FromArgb(255,255,0,0)
$X1.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 70
$X1.Location = $System_Drawing_Point
$X1.Name = "X1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$X1.Size = $System_Drawing_Size
$X1.TabIndex = 16
$X1.Text = "X"
$x1.Visible = $false
$form2.Controls.Add($X1)

$ok4.DataBindings.DefaultDataSourceUpdateMode = 0
$ok4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$ok4.ForeColor = [System.Drawing.Color]::FromArgb(255,0,255,0)
$ok4.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 230
$ok4.Location = $System_Drawing_Point
$ok4.Name = "ok4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$ok4.Size = $System_Drawing_Size
$ok4.TabIndex = 15
$ok4.Text = "√"
$form2.Controls.Add($ok4)

$ok3.DataBindings.DefaultDataSourceUpdateMode = 0
$ok3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$ok3.ForeColor = [System.Drawing.Color]::FromArgb(255,0,255,0)
$ok3.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 181
$ok3.Location = $System_Drawing_Point
$ok3.Name = "ok3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$ok3.Size = $System_Drawing_Size
$ok3.TabIndex = 15
$ok3.Text = "√"
$form2.Controls.Add($ok3)

$ok2.DataBindings.DefaultDataSourceUpdateMode = 0
$ok2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$ok2.ForeColor = [System.Drawing.Color]::FromArgb(255,0,255,0)
$ok2.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 135
$ok2.Location = $System_Drawing_Point
$ok2.Name = "ok2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$ok2.Size = $System_Drawing_Size
$ok2.TabIndex = 14
$ok2.Text = "√"
$form2.Controls.Add($ok2)

$ok1.DataBindings.DefaultDataSourceUpdateMode = 0
$ok1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$ok1.ForeColor = [System.Drawing.Color]::FromArgb(255,0,255,0)
$ok1.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 70
$ok1.Location = $System_Drawing_Point
$ok1.Name = "ok1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 22
$System_Drawing_Size.Width = 22
$ok1.Size = $System_Drawing_Size
$ok1.TabIndex = 13
$ok1.Text = "√"
$form2.Controls.Add($ok1)

$label7.DataBindings.DefaultDataSourceUpdateMode = 0
$label7.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$label7.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$label7.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 91
$System_Drawing_Point.Y = 355
$label7.Location = $System_Drawing_Point
$label7.Name = "label7"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 60
$System_Drawing_Size.Width = 284
$label7.Size = $System_Drawing_Size
$label7.TabIndex = 19
$label7.Text = "$CheckText"
$form2.Controls.Add($label7)

$textreboot.DataBindings.DefaultDataSourceUpdateMode = 0
$textreboot.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textreboot.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textreboot.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 209
$textreboot.Location = $System_Drawing_Point
$textreboot.Name = "textreboot"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 345
$textreboot.Size = $System_Drawing_Size
$textreboot.TabIndex = 12
$textreboot.Text = "$RebootText"
$textreboot.Visible = $false
$form2.Controls.Add($textreboot)

$textVPN.DataBindings.DefaultDataSourceUpdateMode = 0
$textVPN.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textVPN.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textVPN.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 260
$textVPN.Location = $System_Drawing_Point
$textVPN.Name = "textVPN"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 33
$System_Drawing_Size.Width = 345
$textVPN.Size = $System_Drawing_Size
$textVPN.TabIndex = 12
$textVPN.Text = "$VPNText"
$textVPN.Visible = $false
$form2.Controls.Add($textVPN)

$textbattery.DataBindings.DefaultDataSourceUpdateMode = 0
$textbattery.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textbattery.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textbattery.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 163
$textbattery.Location = $System_Drawing_Point
$textbattery.Name = "textbattery"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 311
$textbattery.Size = $System_Drawing_Size
$textbattery.TabIndex = 11
$textbattery.Text = "$PowerText"
$textbattery.Visible = $false
$form2.Controls.Add($textbattery)

$textspace.DataBindings.DefaultDataSourceUpdateMode = 0
$textspace.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textspace.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textspace.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 98
$textspace.Location = $System_Drawing_Point
$textspace.Name = "textspace"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 33
$System_Drawing_Size.Width = 311
$textspace.Size = $System_Drawing_Size
$textspace.TabIndex = 10
$textspace.Text = "$SpaceText"
$textspace.Visible = $false
$form2.Controls.Add($textspace)

$textreboot1.DataBindings.DefaultDataSourceUpdateMode = 0
$textreboot1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textreboot1.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textreboot1.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 186
$textreboot1.Location = $System_Drawing_Point
$textreboot1.Name = "textreboot1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 169
$textreboot1.Size = $System_Drawing_Size
$textreboot1.TabIndex = 9
$form2.Controls.Add($textreboot1)

$textVPN1.DataBindings.DefaultDataSourceUpdateMode = 0
$textVPN1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textVPN1.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textVPN1.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 235
$textVPN1.Location = $System_Drawing_Point
$textVPN1.Name = "textVPN1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 220
$textVPN1.Size = $System_Drawing_Size
$textVPN1.TabIndex = 9
$form2.Controls.Add($textVPN1)

$textbattery1.DataBindings.DefaultDataSourceUpdateMode = 0
$textbattery1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textbattery1.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textbattery1.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 140
$textbattery1.Location = $System_Drawing_Point
$textbattery1.Name = "textbattery1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 192
$textbattery1.Size = $System_Drawing_Size
$textbattery1.TabIndex = 8
$form2.Controls.Add($textbattery1)

$textspace1.DataBindings.DefaultDataSourceUpdateMode = 0
$textspace1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$textspace1.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$textspace1.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 74
$textspace1.Location = $System_Drawing_Point
$textspace1.Name = "textspace1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 300
$textspace1.Size = $System_Drawing_Size
$textspace1.TabIndex = 7
$form2.Controls.Add($textspace1)

$nobutton2.DataBindings.DefaultDataSourceUpdateMode = 0
$nobutton2.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 407
$System_Drawing_Point.Y = 420
$nobutton2.Location = $System_Drawing_Point
$nobutton2.Name = "nobutton2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$nobutton2.Size = $System_Drawing_Size
$nobutton2.TabIndex = 3
$nobutton2.Text = "$NoButtonText2"
$nobutton2.UseVisualStyleBackColor = $False
$nobutton2.add_Click($nobutton2_OnClick)
$form2.Controls.Add($nobutton2)

$text2.DataBindings.DefaultDataSourceUpdateMode = 0
$text2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
$text2.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$text2.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 13
$System_Drawing_Point.Y = 13
$text2.Location = $System_Drawing_Point
$text2.Name = "text2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 61
$System_Drawing_Size.Width = 247
$text2.Size = $System_Drawing_Size
$text2.TabIndex = 0
$text2.Text = "$CheckWindowText2"

$form2.Controls.Add($text2)

$ok1.Visible = $true
$ok2.Visible = $true
$ok3.Visible = $true
$ok4.Visible = $true

$textspace1.Text = "$SpaceTextOK"
$textbattery1.Text = "$PowerTextOK"
$textreboot1.Text = "$RebootTextOK"
$textVPN1.Text = "$VPNTextOK"

If ($LowSpace -eq $true) {
    $textspace.Visible = $true
    $textspace1.Text = "$SpaceTextNotOK"
    $textspace.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $textspace1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $X1.Visible = $true
    $ok1.Visible = $false
    $Info = "Low Disk Space"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }
If ($Battery -eq $true) {
    $textbattery.Visible = $true
    $textbattery1.Text = "$PowerTextNotOK"
    $textbattery.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $textbattery1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $X2.Visible = $true
    $ok2.Visible = $false
    $Info = "No Power Connected"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }
If ($RebootRequired -eq $true) {
    $textreboot.Visible = $true
    $textreboot1.Text = "$RebootTextNotOK"
    $textreboot.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $textreboot1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $X3.Visible = $true
    $ok3.Visible = $false
    $Info = "Reboot Required"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }
If ($VPN -eq $true) {
    $textVPN.Visible = $true
    $textVPN1.Text = "$VPNTextNotOK"
    $textVPN.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $textVPN1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,1,3,0)
    $X4.Visible = $true
    $ok4.Visible = $false
    $Info = "VPN Connected"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }

$InitialFormWindowState = $form2.WindowState
$form2.add_Load($OnLoadForm_StateCorrection)
$form2.ShowDialog()| Out-Null

}

### Countdown #######################################################################
Function CountDown {
    [TimeSpan]$span = $script:StartTime - (Get-Date)
    "{0:hh}:{0:mm}:{0:ss}" -f $span
    $Countdown_Label.Text = "{0:hh}:{0:mm}:{0:ss}" -f $span
	If ($span.TotalSeconds -like "0*") {
        $timer.Stop()
        If (Test-Path -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt) {
            Remove-Item -Path $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt -ErrorVariable ErrorAction -Force
            If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "CheckWindow" -Type Error}
            Else {
                $Info = "Removed File $WorkFolder\$InplaceVersion\DoNot_WindowsInplaceUpgrade.txt"
                Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
                }
            }
        Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 8 -Message "$InplaceVersionText started after countdown"
        $Info = "$InplaceVersionText started after countdown"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Warning
        $form1.Close()
	}
}

### Time Picker Window ##############################################################
Function OtherTime {

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

$form3 = New-Object System.Windows.Forms.Form
$label1 = New-Object System.Windows.Forms.Label
$timebutton_Cancel = New-Object System.Windows.Forms.Button
$timebutton_ok = New-Object System.Windows.Forms.Button
$timecombobox = New-Object System.Windows.Forms.ComboBox
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

$timebutton_Cancel_OnClick= 
{
$form3.close()

}

$timebutton_ok_OnClick= 
{

If ($timecombobox.SelectedItem -like "*1*") {$Hours = 1}
Elseif ($timecombobox.SelectedItem -like "*2*") {$Hours = 2}
Elseif ($timecombobox.SelectedItem -like "*3*") {$Hours = 3}
Elseif ($timecombobox.SelectedItem -like "*4*") {$Hours = 4}
Elseif ($timecombobox.SelectedItem -like "*5*") {$Hours = 5}
Elseif ($timecombobox.SelectedItem -like "*6*") {$Hours = 6}

$Time = (Get-Date).AddHours($Hours).ToString("HH:mm")

$Info = "User Chose Another Time -  Prepare Scheduled Task"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info

If ($OSBuild -eq 7601) {
$OldTask = Get-ScheduledJob -Name "Windows 10 Inplace Update"If ($OldTask) {
    Unregister-ScheduledJob -InputObject $OldTask -ErrorVariable ErrorAction
    If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
    Else {
        $Info = "Unregistered Old Scheduled Task"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }
    }
    Else {
        $Info = "No Old Scheduled Task found"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }

$Info = "Register New Scheduled Task"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info

$Trigger = New-JobTrigger -Once -At $Time
Register-ScheduledJob –Name "Office 2013 Update" -Trigger $trigger -FilePath "$WorkFolder\SchedTaskRun.ps1" -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy ByPass" -ErrorVariable ErrorAction
If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
Else {
    $Info = "Registered Scheduled Task"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
    }
}

If ($OSBuild -gt 7601) {
$Action = New-ScheduledTaskAction -Execute '"C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"' -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy ByPass -File $WorkFolder\SchedTaskRun.ps1"
$Principal = New-ScheduledTaskPrincipal -GroupId "NT Authority\System" -RunLevel Highest
$Trigger =  New-ScheduledTaskTrigger -Once -At $Time

$OldTask = Get-ScheduledTask -TaskName "Windows 10 Inplace Update"
If ($OldTask) {
    Unregister-ScheduledTask -TaskName "Windows 10 Inplace Update" -ErrorVariable ErrorAction -Confirm:$false
    If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
    Else {
        $Info = "Unregistered Old Scheduled Task"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }
    }
    Else {
        $Info = "No Old Scheduled Task Found"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }

$Info = "Register New Scheduled Task"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info

Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "Windows 10 Inplace Update" -Principal $Principal -ErrorVariable ErrorAction
If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
Else {
    $Info = "Registered Scheduled Task"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
    }
}

Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 9 -Message "User deferred Update for $Hours Hours."
$Info = "User deferred Update for $Hours Hours - Close Window"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
$form3.Close()
$form1.Close()
[System.Environment]::Exit(99)
}

$OnLoadForm_StateCorrection=
{
	$form3.WindowState = $InitialFormWindowState
}


$form3.BackgroundImage = [System.Drawing.Image]::FromFile("$WorkFolder\$Background")
$form3.BackColor = [System.Drawing.Color]::FromArgb(255,0,51,102)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 220
$System_Drawing_Size.Width = 390
$form3.MaximumSize = $System_Drawing_Size
$form3.MinimumSize = $System_Drawing_Size
$form3.ClientSize = $System_Drawing_Size
$form3.DataBindings.DefaultDataSourceUpdateMode = 0
$form3.Name = "form1"
$form3.Text = "$OtherTimeWindowTitle"
$form3.StartPosition = 1


$label1.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$label1.DataBindings.DefaultDataSourceUpdateMode = 0
$label1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,0,3,0)
$label1.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 13
$System_Drawing_Point.Y = 13
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 40
$System_Drawing_Size.Width = 300
$label1.Size = $System_Drawing_Size
$label1.TabIndex = 3
$label1.Text = "$OtherTimeText"
$form3.Controls.Add($label1)


$timebutton_Cancel.DataBindings.DefaultDataSourceUpdateMode = 0
$timebutton_Cancel.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 287
$System_Drawing_Point.Y = 146
$timebutton_Cancel.Location = $System_Drawing_Point
$timebutton_Cancel.Name = "timebutton_Cancel"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$timebutton_Cancel.Size = $System_Drawing_Size
$timebutton_Cancel.TabIndex = 2
$timebutton_Cancel.Text = "$OtherTimeCancelButtonText"
$timebutton_Cancel.UseVisualStyleBackColor = $False
$timebutton_Cancel.add_Click($timebutton_Cancel_OnClick)
$form3.Controls.Add($timebutton_Cancel)


$timebutton_ok.DataBindings.DefaultDataSourceUpdateMode = 0
$timebutton_ok.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 13
$System_Drawing_Point.Y = 146
$timebutton_ok.Location = $System_Drawing_Point
$timebutton_ok.Name = "timebutton_ok"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$timebutton_ok.Size = $System_Drawing_Size
$timebutton_ok.TabIndex = 1
$timebutton_ok.Text = "$OtherTimeOkButtonText"
$timebutton_ok.UseVisualStyleBackColor = $False
$timebutton_ok.add_Click($timebutton_ok_OnClick)
$form3.Controls.Add($timebutton_ok)

$timecombobox.DataBindings.DefaultDataSourceUpdateMode = 0
$timecombobox.FormattingEnabled = $True
$timecombobox.Items.Add("In 1 $OtherTimeComboText1")|Out-Null
$timecombobox.Items.Add("In 2 $OtherTimeComboText2")|Out-Null
$timecombobox.Items.Add("In 3 $OtherTimeComboText2")|Out-Null
$timecombobox.Items.Add("In 4 $OtherTimeComboText2")|Out-Null
$timecombobox.Items.Add("In 5 $OtherTimeComboText2")|Out-Null
$timecombobox.Items.Add("In 6 $OtherTimeComboText2")|Out-Null
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 80
$System_Drawing_Point.Y = 63
$timecombobox.Location = $System_Drawing_Point
$timecombobox.Name = "timecombobox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 212
$timecombobox.Size = $System_Drawing_Size
$timecombobox.TabIndex = 0
$timecombobox.SelectedIndex = 0
$form3.Controls.Add($timecombobox)


$InitialFormWindowState = $form3.WindowState
$form3.add_Load($OnLoadForm_StateCorrection)
$form3.ShowDialog()| Out-Null

} 

### Scheduled Start Check Requirements ##############################################
If ($StartBySchedTask -eq $True) {
    CheckDiskSpace
    CheckBattery
    CheckRebootPending
    CheckVPN
    If ($global:CheckError -eq $true) {
        (Get-Date -format g) + " Requirements Not Met" | Out-File $LogFile -Append
        If ($VPN -eq $True) {
            $VPNMessage = "VPN Connected"
            $Info = "VPN Connected"
            Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTaskPrereqCheck" -Type Error
            }
            Else {$VPNMessage = "Not Connected"}
        If ($Battery -eq $True) {
            $BatteryMessage = "On Battery - No Power Connected"
            $Info = "On Battery - No Power Connected"
            Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTaskPrereqCheck" -Type Error
            }
            Else {$BatteryMessage = "Power Connected"}
        If ($RebootRequired -eq $True) {
            $RebootRequiredMessage = "Reboot Required"
            $Info = "Reboot Required"
            Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTaskPrereqCheck" -Type Error
            }
            Else {$RebootRequiredMessage = "Not Required"}
        If ($LowSpace -eq $True) {
            $LowSpaceMessage = "Low Space"
            $Info = "Low Space"
            Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTaskPrereqCheck" -Type Error
            }
            Else {$LowSpaceMessage = "Enough Space"}

        $Message = "Requirements Not Met.
        VPN: $VPNMessage
        Battery: $BatteryMessage
        Reboot: $RebootRequiredMessage
        Space: $LowSpaceMessage
        "

        Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 3 -Message $Message
        [System.Environment]::Exit(99)
        }
        Else {
            If (Test-Path $WorkFolder\$InplaceVersion\StartBySchedTask.txt) {
                Remove-item $WorkFolder\$InplaceVersion\StartBySchedTask.txt -ErrorVariable ErrorAction -Force
                If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "SchedTaskPrereqCheck" -Type Error}
                Else {
                    $Info = "Removed File $WorkFolder\$InplaceVersion\StartBySchedTask.txt"
                    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTaskPrereqCheck" -Type Info
                    }
                }
            }
    }

### Run Test ########################################################################   
If (($AlreadyCompliant -eq $true)) {GenerateForm} #/ Test

### Start GUI #######################################################################
#If (!($AlreadyCompliant -eq $true) -and $StartBySchedTask -eq $Null) {GenerateForm}
