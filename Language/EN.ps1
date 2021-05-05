#English Language File

### Text Variables ####################################################################
# Main Window
$WindowTitle = "Windows 10 Update"
$CountdownText = "Installation starts automatically in:"
$RemainText1 = "Days left"
$RemainText2 = "1 day left"
$RemainText3 = "due today"
$InplaceTitle = "Windows 10 Upgrade"
If ($EndDateEnabled -eq $True) {$Global:InplaceText = "Dear colleagues,&#xD;&#xA;&#xD;&#xA;the Windows 10 $InplaceBuild upgrade is now available. You have the option to install the &#xD;&#xA;upgrade immediately or postpone the installation until $EndDate. &#xD;&#xA;&#xD;&#xA;The upgrade offers many new features and fixes some bugs. &#xD;&#xA;Therefore, please install the upgrade as soon as possible. &#xD;&#xA;Allow about two hours for the upgrade. All files, applications, and settings will be preserved. &#xD;&#xA; &#xD;&#xA;If you have any questions, please contact the HelpDesk. &#xD;&#xA;&#xD;&#xA;Your IT"}
Else {$Global:InplaceText = "Dear colleagues,&#xD;&#xA;&#xD;&#xA;the Windows 10 $InplaceBuild upgrade is now available. You have the option to install the &#xD;&#xA;upgrade immediately or postpone the installation (maximum $MaximumTime days). &#xD;&#xA;&#xD;&#xA;The upgrade offers many new features and fixes some bugs. &#xD;&#xA;Therefore, please install the upgrade as soon as possible. &#xD;&#xA;Allow about two hours for the upgrade. All files, applications, and settings will be preserved. &#xD;&#xA; &#xD;&#xA;If you have any questions, please contact the HelpDesk. &#xD;&#xA;&#xD;&#xA;Your IT"}
$NoButtonText = "Later"
$OkButtonText = "Upgrade now"
$OtherTimeButtonText = "Other time"

# Check Window
$CheckWindowTitle = "Check"
$CheckWindowText = "Resolve the above issues and then&#xD;&#xA;restart the upgrade from the Software Center&#xD;&#xA;or the new desktop icon."
$CheckWindowText2 = "Attention!!&#xD;&#xA;Your PC does not met all requirements:"
$RebootTextOK = "No restart needed"
$RebootTextNotOK = "Restart needed"
$RebootText = "Restart your computer before upgrade"
$PowerTextOK = "Powercable connected"
$PowerTextNotOK = "Currently on battery power"
$PowerText = "Connect a power cable."
$VPNTextOK = "No active VPN connection"
$VPNTextNotOK = "VPN connected"
$VPNText = "Upgrade not possible with VPN connected"
$SpaceTextOK = "Enough free diskspace"
$SpaceTextNotOK = "Free diskspace below 10 GB"
$SpaceText = "Make sure you have enough free space by deleting unneeded files."
$NoButtonText2 = "Close"
$Message1 = "Remind again","You will be reminded again in 24 hours. "

# Other Time Window
$OtherTimeWindowTitle = "Select time"
$OtherTimeText = "Please select the desired time.&#xD;&#xA;The upgrade will start automatically."
$OtherTimeCancelButtonText = "Cancel"
$OtherTimeOkButtonText = "OK"
$OtherTimeComboText1 = "Hour"
$OtherTimeComboText2 = "Hours"
$Message2 = "Attention"
$Message3 = "Date exceeds the maximum period.  "
$Message4 = "Date is in the past. "

# SplashScreen 1
$SplashText1 = "Hi"
$SplashText2 = "Please do not turn off PC"
$SplashText3 = "Windows 10 upgrade is running"
$SplashTextArray1 = @(
    ""
    "We upgrade the PC to Windows 10 $InplaceBuild"
    "This will take about 90 minutes"
    "The PC is restarted several times"
    "All data and programs are preserved"
    "We will be ready soon..."
    )

# SplashScreen 1
$SplashText4 = "We are almost done..."
$SplashText5 = "Windows 10 upgrade is running"
$SplashTextArray2 = @(
    ""
    "We are still updating some apps..."
    "... and install a few updates"
    "One more little moment"
)
#######################################################################################