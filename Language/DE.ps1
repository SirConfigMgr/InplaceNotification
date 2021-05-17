#German Language File

### Text Variables ####################################################################
# Main Window
$WindowTitle = "Windows 10 Upgrade"
$CountdownText = "Die Installation startet automatisch in:"
$RemainText1 = "Tage verbleibend"
$RemainText2 = "1 Tag verbleibend"
$RemainText3 = "heute f�llig"
$InplaceTitle = "Windows 10 Upgrade"
If ($EndDateEnabled -eq $True) {$Global:InplaceText = "Liebe Kolleginnen und Kollegen,&#xD;&#xA;&#xD;&#xA;das Windows 10 $InplaceBuild Upgrade steht Ihnen jetzt zur Verf�gung. Sie haben die M�glichkeit das &#xD;&#xA;Upgrade sofort zu installieren oder die Installation bis zum $EndDate Uhr zu verschieben.&#xD;&#xA;&#xD;&#xA;Das Upgrade bietet viele Neuerungen und behebt einige Fehler. Installieren Sie das Upgrade daher &#xD;&#xA;bitte zeitnah.&#xD;&#xA;&#xD;&#xA;Planen Sie f�r das Upgrade etwa zwei Stunden ein. Alle Dateien, Anwendungen und Einstellungen &#xD;&#xA;bleiben erhalten.&#xD;&#xA; &#xD;&#xA;Bei Fragen wenden Sie sich bitte an den HelpDesk&#xD;&#xA;&#xD;&#xA;Ihre IT"}
Else {$Global:InplaceText = "Liebe Kolleginnen und Kollegen,&#xD;&#xA;&#xD;&#xA;das Windows 10 $InplaceBuild Upgrade steht Ihnen jetzt zur Verf�gung. Sie haben die M�glichkeit das &#xD;&#xA;Upgrade sofort zu installieren oder die Installation zu verschieben (maximal $MaximumTime Tage).&#xD;&#xA;&#xD;&#xA;Das Upgrade bietet viele Neuerungen und behebt einige Fehler. Installieren Sie das Upgrade daher &#xD;&#xA;bitte zeitnah.&#xD;&#xA;&#xD;&#xA;Planen Sie f�r das Upgrade etwa zwei Stunden ein. Alle Dateien, Anwendungen und Einstellungen &#xD;&#xA;bleiben erhalten.&#xD;&#xA; &#xD;&#xA;Bei Fragen wenden Sie sich bitte an den HelpDesk&#xD;&#xA;&#xD;&#xA;Ihre IT"}
$NoButtonText = "Erneut erinnern"
$OkButtonText = "Jetzt aktualisieren"
$OtherTimeButtonText = "Anderer Zeitpunkt"

# Check Window
$CheckWindowTitle = "Pr�fung"
$CheckWindowText = "Beheben Sie die obigen Punkte und starten Sie das&#xD;&#xA;Upgrade anschlie�end erneut aus dem Softwarecenter&#xD;&#xA;bzw. �ber das Desktop-Icon."
$CheckWindowText2 = "Achtung! Ihr PC erf�llt nicht alle Voraussetzungen:"
$RebootTextOK = "Kein Neustart ausstehend"
$RebootTextNotOK = "Neustart ausstehend"
$RebootText = "Starten Sie den Computer vor dem Upgrade neu."
$PowerTextOK = "Stromkabel angeschlossen"
$PowerTextNotOK = "Aktueller Akkubetrieb"
$PowerText = "Schlie�en Sie ein Stromkabel an."
$VPNTextOK = "Keine aktive VPN-Verbindung"
$VPNTextNotOK = "VPN verbunden"
$VPNText = "Upgrade nur im Firmennetz m�glich."
$SpaceTextOK = "Genug freier Festplattenspeicher"
$SpaceTextNotOK = "Freier Festplattenspeicher unter $MinFreeSpace GB"
$SpaceText = "Sorgen Sie f�r gen�gend freien Speicherplatz, indem Sie nicht mehr&#xD;&#xA;ben�tigte Dateien l�schen."
$NoButtonText2 = "Schlie�en"
$Message0 = "Erneut erinnern"
$Message1 = "Sie werden in 24 Stunden erneut erinnert. "

# Other Time Window
$OtherTimeWindowTitle = "Zeitpunkt w�hlen"
$OtherTimeText = "Bitte w�hlen Sie den gew�nschten Zeitpunkt. Das Upgrade &#xD;&#xA;wird dann automatisch gestartet."
$OtherTimeCancelButtonText = "Abbrechen"
$OtherTimeOkButtonText = "OK"
$OtherTimeComboText1 = "Stunde"
$OtherTimeComboText2 = "Stunden"
$Message2 = "Achtung"
$Message3 = "Datum �berschreitet den maximalen Zeitraum.  "
$Message4 = "Datum liegt in der Vergangenheit. "

# SplashScreen 1
$SplashText1 = "Hallo"
$SplashText2 = "PC bitte nicht ausschalten"
$SplashText3 = "Windows 10 Upgrade wird ausgef�hrt"
$SplashTextArray1 = @(
    ""
    "Wir aktualisieren den PC auf Windows 10 $InplaceBuild"
    "Das wird etwa 90 Minuten dauern"
    "Der PC wird mehrfach neugestartet"
    "Alle Daten und Programme bleiben erhalten"
    "Wir sind bald fertig..."
    )

# SplashScreen 1
$SplashText4 = "Wir sind fast fertig..."
$SplashText5 = "Windows 10 Upgrade wird ausgef�hrt"
$SplashTextArray2 = @(
    ""
    "Wir aktualisieren noch einige Apps..."
    "... und installieren ein paar Updates"
    "Noch einen kleinen Augenblick"
)
#######################################################################################