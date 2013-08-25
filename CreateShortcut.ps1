
function CreateShortcut($strExe,$StrWorkingDir,$strArgs,$strIcon,$strDescription,$strDestination)
{
	#function written by Brenton Keegan - creates an shortcut according to the entered parameters
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($strDestination)
	$shortcut.IconLocation = $strIcon
	$Shortcut.TargetPath = $StrWorkingDir + $strExe
	$shortCut.WorkingDirectory = $StrWorkingDir
	$shortCut.Arguments = $strArgs
	$shortCut.Description = $strDescription
	$Shortcut.Save()
}
