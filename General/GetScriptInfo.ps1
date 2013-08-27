function GetScriptInfo($strInfo)
{
	#quick function to return a selected piece of information about the currently running script.
	#1. $strInfo - Can be "filename" - will return the name of the .ps1 file, "path" will return the full path of the parent directory and "fullpath" will return the full path of the script, "LOC" (lines of code) will return the amount of lines in a script.
	
	$strFilename = Split-Path $MyInvocation.ScriptName -leaf
	$strPath = Split-Path $MyInvocation.ScriptName
	$strFullPath = $strPath + "\" + $strFilename
	[int]$intLOC = Get-Content $strFullPath | Measure-Object -Line | foreach {$_.lines}
	
		Switch($strInfo)
		{
		"filename"{Return $strFilename}
		"path"{Return $strPath}
		"fullpath"{Return $strFullPath}
		"LOC" {Return $intLOC}
		}	
}
