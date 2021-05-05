### Import Config File ##############################################################
. "$PSScriptRoot\Config.ps1"
#####################################################################################

### Import Language File ############################################################
. "$PSScriptRoot\Language\$Lang.ps1"
#####################################################################################

### Import Environment Variables ####################################################
. "$PSScriptRoot\bin\Environment.ps1"
#####################################################################################

### Log Function ####################################################################
Function Write-Log {

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

### Create Shortcut #################################################################
Function CreateShortcut {
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut($env:ALLUSERSPROFILE + "\Desktop\Windows 10 Upgrade.lnk")
$ShortCut.TargetPath="$WorkFolder\bin\RunSilent.exe"
$ShortCut.WorkingDirectory = "$WorkFolder\bin";
$ShortCut.WindowStyle = 1;
$ShortCut.IconLocation = "$WorkFolder\Images\Icon.ico";
$ShortCut.Description = "Windows 10 Upgrade";
$ShortCut.Save()
}

### Start ###########################################################################
#region
If (Test-Path $InitialLog) {Remove-Item $InitialLog -Force}
$Info = "Start Script"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Start" -Type Info
#endregion

### Prepare Eventlog ################################################################
#region
$Info = "Prepare Eventlog"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Eventlog" -Type Info
New-EventLog -LogName Application -Source Win10Inplace -ErrorAction SilentlyContinue -ErrorVariable ErrorAction
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Start" -Type Error}
    Else {
        $Info = "Prepared Eventlog"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Eventlog" -Type Info
        }
#endregion

### Write Initial Eventlog Entry ####################################################
#region
$Message = "Start Script
InPlace Version: $InplaceVersionText
"
Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 1 -Message "$Message"
#endregion

### Work Folder #####################################################################
#region
$Info = "Prepare Workfolder $WorkFolder"
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
#endregion

### Registry Work Folder ############################################################
#region
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
        $Info = "Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate Already Exist"
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
#endregion

### Check OS Already Compliant ######################################################
#region
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
        $AlreadyCompliant = $False
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
#endregion

### Copy Files ######################################################################
#region
$Info = "Copy Files"
Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "Copy" -Type Info
Move-Item $InitialLog -Destination $WorkFolder -ErrorVariable ErrorAction -Force
If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "Copy" -Type Error}
    Else {
    $Info = "Moved Initial Log From $InitialLog To $WorkFolder"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Copy" -Type Info
    }
If (Test-Path $InitialLog) {Remove-Item $InitialLog -Force}
Copy-Item $PSScriptRoot\* $WorkFolder -Recurse -Verbose -Force -PassThru -ErrorVariable ErrorAction
If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "Copy" -Type Error}
    Else {
    $Info = "Files Copied To Workfolder"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Copy" -Type Info
    }
If (!($AlreadyCompliant -eq $true)) {CreateShortcut}
#endregion

### Create Reg Keys For Countdown ###################################################
#region
$Today = Get-Date
If (!($AlreadyCompliant -eq $True)) {
    $Info = "Prepare Countdown"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
    If ($EndDateEnabled -eq $False) {
        Try {
            $TargetDate = (Get-ItemProperty HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name TargetDate  -ErrorAction Stop).TargetDate
            $Info = "Target-Date $TargetDate"
            Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
            }
            Catch {
                $TargetDate = ($Today).AddDays($MaximumTime)
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
            }
            Elseif ($EndDateEnabled -eq $True) {
                Try {
                    $TargetDate = (Get-ItemProperty HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name TargetDate  -ErrorAction Stop).TargetDate
                    $Info = "Target-Date $TargetDate"
                    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
                    }
                    Catch {
                        $TargetDate = [datetime]::ParseExact($EndDate,'dd.MM.yyyy HH:mm',$null)
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
                    }

    $RemainingDays = (New-TimeSpan $Today $TargetDate).Days
    $Info = "Remaining Days  $RemainingDays"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "Countdown" -Type Info
    }
#endregion

### Check If Script Is Startet By Scheduled Task ####################################
#region
$Info = "Check If Script Is Startet By Scheduled Task"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
If (Test-Path $WorkFolder\$InplaceVersion\StartBySchedTask.txt) {
    $StartBySchedTask = $True
    $Info = "True - No User Interaction"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Warning
    }
    Else {
        $Info = "False"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }
#endregion

### Check If Scheduled Task Is Created And Target Date Is Reached ###################
#region
$Info = "Check If Scheduled Task Is Created And Target Date Is Reached"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info

If ($OSBuild -eq 7601) {
$Task = Get-ScheduledJob -Name "Windows 10 Inplace Update" -ErrorAction SilentlyContinue
    }

If ($OSBuild -gt 7601) {
$Task = Get-ScheduledTask -TaskName "Windows 10 Inplace Update" -ErrorAction SilentlyContinue
    }

If ($Task) {
    $Info = "Scheduled Task Found"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
    $SchedTaskDate = (Get-ItemProperty HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name SchedTaskDate  -ErrorAction Stop).SchedTaskDate
    $Info = "Scheduled Task Date Is $SchedTaskDate"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
    If (($Today).tostring("yyyy-MM-dd") -eq $SchedTaskDate) {
        $Info = "Scheduled Task Target Date Reached"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Warning
        $TargetDayReached = $True
        If (Test-Path -Path $WorkFolder\$InplaceVersion\TargetDateNotReached.txt) {
            Remove-Item -Path $WorkFolder\$InplaceVersion\TargetDateNotReached.txt -ErrorVariable ErrorAction -Force
            If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
            Else {
                $Info = "Deleted File $WorkFolder\$InplaceVersion\TargetDateNotReached.txt"
                Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "SchedTask" -Type Info
                }
            }
        }
    Elseif (($Today).tostring("yyyy-MM-dd") -gt $SchedTaskDate) {
        $Info = "Scheduled Task Target Date Reached"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Warning
        $TargetDayReached = $True
        If (Test-Path -Path $WorkFolder\$InplaceVersion\TargetDateNotReached.txt) {
            Remove-Item -Path $WorkFolder\$InplaceVersion\TargetDateNotReached.txt -ErrorVariable ErrorAction -Force
            If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
            Else {
                $Info = "Deleted File $WorkFolder\$InplaceVersion\TargetDateNotReached.txt"
                Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "SchedTask" -Type Info
                }
            }
        }
    Else {
        $Info = "Scheduled Task Target Date Not Reached"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        $TargetDayReached = $False
        If (!(Test-Path -Path $WorkFolder\$InplaceVersion\TargetDateNotReached.txt)) {
        New-Item -Path $WorkFolder\$InplaceVersion\TargetDateNotReached.txt -ErrorVariable ErrorAction
        If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
            Else {
            $Info = "Created File $WorkFolder\$InplaceVersion\TargetDateNotReached.txt"
            Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "SchedTask" -Type Info
            }
        }
    }
}
    Else {
        $Info = "No Scheduled Task Found"
        Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }
#endregion

### Xaml Code Main Form #############################################################
Function GenerateForm {
Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 2 -Message "Show Inplace Message."
$Info = "Show Inplace Message"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "MainWindow" -Type Info

[xml]$inputXML = @"

<Controls:MetroWindow
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
        GlowBrush="{DynamicResource AccentColorBrush}"
        BorderBrush="{DynamicResource AccentColorBrush}"
        BorderThickness="1"
        WindowStartupLocation="CenterScreen"
        Title="Windows Upgrade"
        Height="600" 
        Width="1000" 
        Background="$BackgroundColor" 
        Topmost="True" 
        ResizeMode="NoResize" 
        ShowMinButton="False" 
        ShowMaxRestoreButton="False" 
        ShowCloseButton="False" 
        WindowButtonCommandsOverlayBehavior="HiddenTitleBar">

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Themes/$WindowThemeColor.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.FlatButton.xaml" />
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Window.Resources>

    <Grid>
        <Label x:Name="text" Content="$InplaceText" HorizontalAlignment="Left" Margin="29,168,0,0" VerticalAlignment="Top" Height="297" Width="645" FontSize="14" Foreground="$TextColor"/>
        <Button x:Name="okbutton" Content="$OkButtonText" HorizontalAlignment="Left" Margin="290,502,0,0" VerticalAlignment="Top" Width="141"/>
        <Button x:Name="nobutton" Content="$NoButtonText" HorizontalAlignment="Left" Margin="579,502,0,0" VerticalAlignment="Top" Width="120"/>
        <Button x:Name="othertimebutton" Content="$OtherTimeButtonText" HorizontalAlignment="Left" Margin="436,502,0,0" VerticalAlignment="Top" Width="138"/>
        <Image x:Name="logo" Margin="10,10,771,419" Source="$ScriptPath\Images\$Logo" RenderOptions.BitmapScalingMode="Fant" Stretch="Fill" Width="200" Height="133"/>
        <Image x:Name="windowslogo" Margin="691,154,51,165" Source="$ScriptPath\Images\$WindowsLogo" Stretch="Fill" RenderOptions.BitmapScalingMode="NearestNeighbor" RenderOptions.EdgeMode="Aliased"/>
        <Label x:Name="timelefttext" Content="" HorizontalAlignment="Left" Margin="710,505,0,0" VerticalAlignment="Top" Foreground="$TimeLeftColor"/>
        <Label x:Name="TimeRemaining_Label" Content="$CountdownText" HorizontalAlignment="Left" Margin="290,465,0,0" VerticalAlignment="Top" FontSize="14" Width="364" Foreground="$CountDownLabelTextColor" FontWeight="Bold"/>
        <Label x:Name="Countdown_Label" Content="00:00:00" HorizontalAlignment="Left" Margin="550,465,0,0" VerticalAlignment="Top" Foreground="$CountDownTextColor" FontSize="14" FontWeight="Bold"/>
    </Grid>

</Controls:MetroWindow>

"@ 
# Load Xaml Code 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Form1=[Windows.Markup.XamlReader]::Load( $reader )

# Gui Objects
#region
$text = $Form1.Findname("text")
$okbutton = $Form1.Findname("okbutton")
$nobutton = $Form1.Findname("nobutton")
$othertimebutton = $Form1.Findname("othertimebutton")
$logo = $Form1.Findname("logo")
$line = $Form1.Findname("line")
$windowslogo = $Form1.Findname("windowslogo")
$timelefttext = $Form1.Findname("timelefttext")
$TimeRemaining_Label = $Form1.Findname("TimeRemaining_Label")
$Countdown_Label = $Form1.Findname("Countdown_Label")
#endregion

# Actions
#region
$othertimebutton.Add_Click({
    OtherTime
})

$nobutton.Add_Click({
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form1,"Test","Test",[MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative)
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
    NextRunTimer
    [System.Environment]::Exit(99)
})

$okbutton.Add_Click({
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
    If (Get-Process -Name lync -InformationAction SilentlyContinue) {Stop-Process -Name lync -Force -InformationAction SilentlyContinue}
    $form1.Close()
})
#endregion

# Variable Text
#region
If ($RemainingDays -gt 1) {$timelefttext.Content = "$RemainingDays $RemainText1"}
    Elseif ($RemainingDays -eq 1) {$timelefttext.Content = "$RemainText2"}
    Elseif ($RemainingDays -le 0) {$timelefttext.Content = "$RemainText3"}

If ($RemainingDays -le 0) {
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval=1000
    $timer.add_Tick({CountDown})
    $script:StartTime = (Get-Date).AddMinutes($TotalTime)
    $timer.Start()
    $TimeRemaining_Label.Visibility = "Visible"
    $Countdown_Label.Visibility = "Visible"
    }
    Else {
        $TimeRemaining_Label.Visibility = "Hidden"
        $Countdown_Label.Visibility = "Hidden"
        }
#endregion

$Form1.ShowDialog() | out-null
}

### Xaml Code Check Form ############################################################
Function ShowMessage {
[xml]$inputXML = @"
<Controls:MetroWindow
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
        GlowBrush="Black"
        BorderThickness="0"
        WindowStartupLocation="CenterScreen"
        Title="$CheckWindowTitle"
        Height="500" 
        Width="500" 
        Background="$BackgroundColor" 
        Topmost="True" 
        ResizeMode="NoResize" 
        ShowMinButton="False" 
        ShowMaxRestoreButton="False" 
        ShowCloseButton="False" 
        WindowButtonCommandsOverlayBehavior="HiddenTitleBar">

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Themes/$WindowThemeColor.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.FlatButton.xaml" />
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Window.Resources>

    <Grid>
        <Label x:Name="CheckWindowText2" Content="$CheckWindowText2" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Height="82" Width="472" Foreground="$TextColor" FontSize="14"/>
        <Label x:Name="ok1" Content="√" HorizontalAlignment="Left" Margin="10,73,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FF08F91E" Height="35"/>
        <Label x:Name="ok2" Content="√" HorizontalAlignment="Left" Margin="10,148,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FF08F91E" Height="35"/>
        <Label x:Name="ok3" Content="√" HorizontalAlignment="Left" Margin="10,223,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FF08F91E" Height="35"/>
        <Label x:Name="ok4" Content="√" HorizontalAlignment="Left" Margin="10,298,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FF08F91E" Height="35"/>
        <Label x:Name="x1" Content="X" HorizontalAlignment="Left" Margin="10,72,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FFF91E08" Height="35"/>
        <Label x:Name="x2" Content="X" HorizontalAlignment="Left" Margin="10,147,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FFF91E08" Height="35"/>
        <Label x:Name="x3" Content="X" HorizontalAlignment="Left" Margin="10,222,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FFF91E08" Height="35"/>
        <Label x:Name="x4" Content="X" HorizontalAlignment="Left" Margin="10,297,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold" Foreground="#FFF91E08" Height="35"/>
        <Label x:Name="textspace1" Content="Label" HorizontalAlignment="Left" Margin="35,76,0,0" VerticalAlignment="Top" Width="300" FontSize="14" Foreground="$TextColor"/>
        <Label x:Name="textbattery1" Content="Label" HorizontalAlignment="Left" Margin="35,149,0,0" VerticalAlignment="Top" Width="300" FontSize="14" Foreground="$TextColor"/>
        <Label x:Name="textreboot1" Content="Label" HorizontalAlignment="Left" Margin="35,224,0,0" VerticalAlignment="Top" Width="300" FontSize="14" Foreground="$TextColor"/>
        <Label x:Name="textVPN1" Content="Label" HorizontalAlignment="Left" Margin="35,299,0,0" VerticalAlignment="Top" Width="300" FontSize="14" Foreground="$TextColor"/>
        <Label x:Name="textspace" Content="$SpaceText" HorizontalAlignment="Left" Margin="35,106,0,0" VerticalAlignment="Top" Width="429" Height="39" Foreground="$TextColor"/>
        <Label x:Name="textbattery" Content="$PowerText" HorizontalAlignment="Left" Margin="35,183,0,0" VerticalAlignment="Top" Width="429" Height="34" Foreground="$TextColor"/>
        <Label x:Name="textreboot" Content="$RebootText" HorizontalAlignment="Left" Margin="35,253,0,0" VerticalAlignment="Top" Width="429" Height="34" Foreground="$TextColor"/>
        <Label x:Name="textVPN" Content="$VPNText" HorizontalAlignment="Left" Margin="35,328,0,0" VerticalAlignment="Top" Width="429" Height="34" Foreground="$TextColor"/>
        <Button x:Name="nobutton2" Content="$NoButtonText2" HorizontalAlignment="Left" Margin="383,430,0,0" VerticalAlignment="Top" Width="81"/>
        <Label x:Name="CheckWindowText" Content="$CheckWindowText" HorizontalAlignment="Left" Margin="35,384,0,0" VerticalAlignment="Top" Width="343" Height="75" Foreground="$TextColor" FontSize="12"/>
    </Grid>

</Controls:MetroWindow>

"@ 
# Load Xaml Code 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Form2=[Windows.Markup.XamlReader]::Load( $reader )

# GUI Objects
#region
$CheckWindowText = $Form2.Findname("CheckWindowText")
$CheckWindowText2 = $Form2.Findname("CheckWindowText2")
$ok1 = $Form2.Findname("ok1")
$ok2 = $Form2.Findname("ok2")
$ok3 = $Form2.Findname("ok3")
$ok4 = $Form2.Findname("ok4")
$x1 = $Form2.Findname("x1")
$x2 = $Form2.Findname("x2")
$x3 = $Form2.Findname("x3")
$x4 = $Form2.Findname("x4")
$textspace1 = $Form2.Findname("textspace1")
$textspace = $Form2.Findname("textspace")
$textbattery1 = $Form2.Findname("textbattery1")
$textbattery = $Form2.Findname("textbattery")
$textreboot1 = $Form2.Findname("textreboot1")
$textreboot = $Form2.Findname("textreboot")
$textVPN1 = $Form2.Findname("textVPN1")
$textVPN = $Form2.Findname("textVPN")
$nobutton2 = $Form2.Findname("nobutton2")
#endregion

# Actions
#region
$nobutton2.Add_Click({
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

})
#endregion

# Variable Text
#region
$ok1.Visibility = "Visible"
$ok2.Visibility = "Visible"
$ok3.Visibility = "Visible"
$ok4.Visibility = "Visible"
$X1.Visibility = "Hidden"
$X2.Visibility = "Hidden"
$X3.Visibility = "Hidden"
$X4.Visibility = "Hidden"
$textspace.Visibility = "Hidden"
$textbattery.Visibility = "Hidden"
$textreboot.Visibility = "Hidden"
$textVPN.Visibility = "Hidden"

$textspace1.Content = "$SpaceTextOK"
$textbattery1.Content = "$PowerTextOK"
$textreboot1.Content = "$RebootTextOK"
$textVPN1.Content = "$VPNTextOK"

If ($LowSpace -eq $true) {
    $textspace.Visibility = "Visible"
    $textspace1.Content = "$SpaceTextNotOK"
    $X1.Visibility = "Visible"
    $ok1.Visibility = "Hidden"
    $Info = "Low Disk Space"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }
If ($Battery -eq $true) {
    $textbattery.Visibility = "Visible"
    $textbattery1.Content = "$PowerTextNotOK"
    $X2.Visibility = "Visible"
    $ok2.Visibility = "Hidden"
    $Info = "No Power Connected"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }
If ($RebootRequired -eq $true) {
    $textreboot.Visibility = "Visible"
    $textreboot1.Content = "$RebootTextNotOK"
    $X3.Visibility = "Visible"
    $ok3.Visibility = "Hidden"
    $Info = "Reboot Required"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }
If ($VPN -eq $true) {
    $textVPN.Visibility = "Visible"
    $textVPN1.Content = "$VPNTextNotOK"
    $X4.Visibility = "Visible"
    $ok4.Visibility = "Hidden"
    $Info = "VPN Connected"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "CheckWindow" -Type Error
    }
#endregion

$Form2.ShowDialog() | out-null
}

### Xaml Code Other Time Form #######################################################
Function OtherTime {
[xml]$inputXML = @"
<Controls:MetroWindow
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
        GlowBrush="Black"
        BorderThickness="0"
        WindowStartupLocation="CenterScreen"
        Title="$OtherTimeWindowTitle"
        Height="220" 
        Width="390" 
        Background="$BackgroundColor" 
        Topmost="True" 
        ResizeMode="NoResize" 
        ShowMinButton="False" 
        ShowMaxRestoreButton="False" 
        ShowCloseButton="False" 
        WindowButtonCommandsOverlayBehavior="HiddenTitleBar">

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Themes/$WindowThemeColor.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.FlatButton.xaml" />
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Window.Resources>

    <Grid>
        <Button x:Name="timebutton_ok" Content="$OtherTimeOkButtonText" HorizontalAlignment="Left" Margin="97,150,0,0" VerticalAlignment="Top" Width="90"/>
        <Button x:Name="timebutton_Cancel" Content="$OtherTimeCancelButtonText" HorizontalAlignment="Left" Margin="197,150,0,0" VerticalAlignment="Top" Width="90"/>
        <DatePicker x:Name="dateTimePicker1" HorizontalAlignment="Left" Margin="190,70,0,0" VerticalAlignment="Top" SelectedDateFormat="Short" Width="164" SelectedDate="{Binding Path = SellStartDate, StringFormat = {}{0:dd-MM-yyyy}}" />
        <Label x:Name="label1" Content="$OtherTimeText" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" FontSize="14" Foreground="$TextColor"/>
        <ComboBox x:Name="hour" HorizontalAlignment="Left" Margin="40,70,0,0" VerticalAlignment="Top" Width="60"/>
        <ComboBox x:Name="minute" HorizontalAlignment="Left" Margin="105,70,0,0" VerticalAlignment="Top" Width="60"/>
    </Grid>

</Controls:MetroWindow>
"@ 
# Load Xaml Code 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Form3=[Windows.Markup.XamlReader]::Load( $reader )

# GUI Objects
#region
$timebutton_ok = $Form3.Findname("timebutton_ok")
$timebutton_Cancel = $Form3.Findname("timebutton_Cancel")
$dateTimePicker1 = $Form3.Findname("dateTimePicker1")
$label1 = $Form3.Findname("label1")
$hour = $Form3.Findname("hour")
$minute = $Form3.Findname("minute")

#endregion

# Actions
#region
$timebutton_ok.Add_Click({
$Scheduler = $True
$SelectedDateTime = $datetimepicker1.Text + "_" + $hour.SelectedItem + $minute.SelectedItem
$Time = [datetime]::ParseExact($SelectedDateTime,'dd.MM.yyyy_HHmm',$null)
$SchedTaskDate = ($Time).tostring("yyyy-MM-dd")

$Info = "User Chose Another Time -  Prepare Scheduled Task"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info

$Future = (New-TimeSpan -Start $Time -End $PickerMaxDate).TotalMinutes
$Past = (New-TimeSpan -Start (Get-Date) -End $Time).TotalMinutes

If ($Future -lt 0) {
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form3,$Message2,$Message3,[MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative)
    }
Elseif ($Past -lt 0) {
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form3,$Message2,$Message4,[MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative)
    }
Else {

If ($OSBuild -eq 7601) {
$OldTask = Get-ScheduledJob -Name "Windows 10 Inplace Update"
If ($OldTask) {
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
Register-ScheduledJob –Name "Windows 10 Inplace Update" -Trigger $trigger -FilePath "$WorkFolder\SchedTaskRun.ps1" -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy ByPass" -ErrorVariable ErrorAction
If ($ErrorAction) {Write-Log -Path $LogFile -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
Else {
    $Info = "Registered Scheduled Task on $Time"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
    New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name SchedTaskDate -Value $SchedTaskDate -ErrorVariable ErrorAction -Force
    If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
    Else {
        $Info = "Created Registry Value SchedTaskDate: $SchedTaskDate"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }
    }
}

If ($OSBuild -gt 7601) {
$Action = New-ScheduledTaskAction -Execute '"C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"' -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy ByPass -File $WorkFolder\CallTS.ps1"
$Principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
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
    $Info = "Registered Scheduled Task on $Time"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
    New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name SchedTaskDate -Value $SchedTaskDate -ErrorVariable ErrorAction -Force
    If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
    Else {
        $Info = "Created Registry Value SchedTaskDate: $SchedTaskDate"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }
    }
}
Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 9 -Message "User deferred Update to $Time."
$Info = "Close Window."
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "End" -Type Info
$form3.Close()
$form1.Close()
[System.Environment]::Exit(99)
}
})

$timebutton_Cancel.Add_Click({
    $form3.close()
})
#endregion

# Variable Text
#region
$PreselectedHour = ((Get-Date).AddHours(1)).Hour
$PreselectedMinute = (Get-Date).Minute
$houritems = @("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")
$minuteitems = @("00","15","30","45")
Foreach ($Item in $houritems) {$hour.Items.Add("$Item")}
Foreach ($Item in $minuteitems) {$minute.Items.Add("$Item")}
$hour.SelectedIndex = $hour.items.IndexOf("$PreselectedHour")
$minute.SelectedIndex = $minute.items.IndexOf("00")

Try {$PickerMaxDate = [datetime]::ParseExact($TargetDate,'dd.MM.yyyy HH:mm:ss',$null)}
    Catch {$PickerMaxDate = $TargetDate}
$dateTimePicker1.DisplayDateStart="$Today" 
$dateTimePicker1.DisplayDateEnd="$PickerMaxDate"
$dateTimePicker1.DisplayDate = ($Today).AddDays(1)
$dateTimePicker1.SelectedDate = ($Today).AddDays(1)


#endregion

$Form3.ShowDialog() | out-null
}

### Function To Check Disk Space ####################################################
Function CheckDiskSpace {
$global:LowSpace = $false
$FreeSpace = (gwmi win32_logicaldisk -filter "DeviceID='c:'").Freespace/1GB
If ($FreeSpace -lt $MinFreeSpace) {
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

### Timer For Nex Run ###############################################################
Function NextRunTimer {
$Info = "User Chose Later -  Prepare Scheduled Task"
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
$NextRunTimer = (Get-Date).AddDays(1)
$SchedTaskDate = ($NextRunTimer).tostring("yyyy-MM-dd")
$Action = New-ScheduledTaskAction -Execute '"C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"' -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy ByPass -File $WorkFolder\CallTS.ps1"
$Principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
$Trigger =  New-ScheduledTaskTrigger -Once -At $NextRunTimer

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
    $Info = "Registered Scheduled Task on $NextRunTimer"
    Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "SchedTask" -Type Info
    New-ItemProperty -Path HKLM:\SOFTWARE\$CompanyCode\WindowsInplaceUpdate -Name SchedTaskDate -Value $SchedTaskDate -ErrorVariable ErrorAction -Force
    If ($ErrorAction) {Write-Log -Path $InitialLog -Message ($ErrorAction | Out-String) -Component "SchedTask" -Type Error}
    Else {
        $Info = "Created Registry Value SchedTaskDate: $SchedTaskDate"
        Write-Log -Path $InitialLog -Message ($Info | Out-String) -Component "SchedTask" -Type Info
        }
    }

Write-EventLog -LogName Application -Source Win10Inplace -EntryType Information -EventId 9 -Message "User selected later."
$Info = "Close Window."
Write-Log -Path $LogFile -Message ($Info | Out-String) -Component "End" -Type Info
$form3.Close()
$form1.Close()
}

### Countdown #######################################################################
Function CountDown {
    [TimeSpan]$span = $script:StartTime - (Get-Date)
    "{0:hh}:{0:mm}:{0:ss}" -f $span
    $Countdown_Label.Content = "{0:hh}:{0:mm}:{0:ss}" -f $span
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

### Show GUI ########################################################################

# Run Test  
If (($AlreadyCompliant -eq $true)) {GenerateForm} #/ Test

# Start GUI
#If (!($AlreadyCompliant -eq $true)) {GenerateForm}