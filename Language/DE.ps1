#German Language File

### Text Variables ####################################################################
# Main Window
$WindowTitle = "Windows 10 Upgrade"
$CountdownText = "Die Installation startet automatisch in:"
$RemainText1 = "Tage verbleibend"
$RemainText2 = "1 Tag verbleibend"
$RemainText3 = "heute fällig"
$InplaceTitle = "Windows 10 Upgrade"
If ($EndDateEnabled -eq $True) {$Global:InplaceText = "Liebe Kolleginnen und Kollegen,&#xD;&#xA;&#xD;&#xA;das Windows 10 $InplaceBuild Upgrade steht Ihnen jetzt zur Verfügung. Sie haben die Möglichkeit das &#xD;&#xA;Upgrade sofort zu installieren oder die Installation bis zum $EndDate Uhr zu verschieben.&#xD;&#xA;&#xD;&#xA;Das Upgrade bietet viele Neuerungen und behebt einige Fehler. Installieren Sie das Upgrade daher &#xD;&#xA;bitte zeitnah.&#xD;&#xA;&#xD;&#xA;Planen Sie für das Upgrade etwa zwei Stunden ein. Alle Dateien, Anwendungen und Einstellungen &#xD;&#xA;bleiben erhalten.&#xD;&#xA; &#xD;&#xA;Bei Fragen wenden Sie sich bitte an den HelpDesk&#xD;&#xA;&#xD;&#xA;Ihre IT"}
Else {$Global:InplaceText = "Liebe Kolleginnen und Kollegen,&#xD;&#xA;&#xD;&#xA;das Windows 10 $InplaceBuild Upgrade steht Ihnen jetzt zur Verfügung. Sie haben die Möglichkeit das &#xD;&#xA;Upgrade sofort zu installieren oder die Installation zu verschieben (maximal $MaximumTime Tage).&#xD;&#xA;&#xD;&#xA;Das Upgrade bietet viele Neuerungen und behebt einige Fehler. Installieren Sie das Upgrade daher &#xD;&#xA;bitte zeitnah.&#xD;&#xA;&#xD;&#xA;Planen Sie für das Upgrade etwa zwei Stunden ein. Alle Dateien, Anwendungen und Einstellungen &#xD;&#xA;bleiben erhalten.&#xD;&#xA; &#xD;&#xA;Bei Fragen wenden Sie sich bitte an den HelpDesk&#xD;&#xA;&#xD;&#xA;Ihre IT"}
$NoButtonText = "Erneut erinnern"
$OkButtonText = "Jetzt aktualisieren"
$OtherTimeButtonText = "Anderer Zeitpunkt"

# Check Window
$CheckWindowTitle = "Prüfung"
$CheckWindowText = "Beheben Sie die obigen Punkte und starten Sie das&#xD;&#xA;Upgrade anschließend erneut aus dem Softwarecenter&#xD;&#xA;bzw. über das Desktop-Icon."
$CheckWindowText2 = "Achtung! Ihr PC erfüllt nicht alle Voraussetzungen:"
$RebootTextOK = "Kein Neustart ausstehend"
$RebootTextNotOK = "Neustart ausstehend"
$RebootText = "Starten Sie den Computer vor dem Upgrade neu."
$PowerTextOK = "Stromkabel angeschlossen"
$PowerTextNotOK = "Aktueller Akkubetrieb"
$PowerText = "Schließen Sie ein Stromkabel an."
$VPNTextOK = "Keine aktive VPN-Verbindung"
$VPNTextNotOK = "VPN verbunden"
$VPNText = "Upgrade nur im Firmennetz möglich."
$SpaceTextOK = "Genug freier Festplattenspeicher"
$SpaceTextNotOK = "Freier Festplattenspeicher unter $MinFreeSpace GB"
$SpaceText = "Sorgen Sie für genügend freien Speicherplatz, indem Sie nicht mehr&#xD;&#xA;benötigte Dateien löschen."
$NoButtonText2 = "Schließen"
$Message0 = "Erneut erinnern"
$Message1 = "Sie werden in 24 Stunden erneut erinnert. "

# Other Time Window
$OtherTimeWindowTitle = "Zeitpunkt wählen"
$OtherTimeText = "Bitte wählen Sie den gewünschten Zeitpunkt. Das Upgrade &#xD;&#xA;wird dann automatisch gestartet."
$OtherTimeCancelButtonText = "Abbrechen"
$OtherTimeOkButtonText = "OK"
$OtherTimeComboText1 = "Stunde"
$OtherTimeComboText2 = "Stunden"
$Message2 = "Achtung"
$Message3 = "Datum überschreitet den maximalen Zeitraum.  "
$Message4 = "Datum liegt in der Vergangenheit. "

# SplashScreen 1
$SplashText1 = "Hallo"
$SplashText2 = "PC bitte nicht ausschalten"
$SplashText3 = "Windows 10 Upgrade wird ausgeführt"
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
$SplashText5 = "Windows 10 Upgrade wird ausgeführt"
$SplashTextArray2 = @(
    ""
    "Wir aktualisieren noch einige Apps..."
    "... und installieren ein paar Updates"
    "Noch einen kleinen Augenblick"
)
#######################################################################################