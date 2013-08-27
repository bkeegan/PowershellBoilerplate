function WriteToLogFile($strData,[string]$strLogFile = "$env:temp\PSLog.txt",[boolean]$bolAppend=$true,$strTimeStamp=(Get-Date -Format g),[string]$strEncode="Unicode")
{
	#this helper function was created by Brenton Keegan on 8/10/13. This simplifies the process of creating a lot file
	#Parameters:
	#	1. $strData - actual text to put into log
	#	2. $strLogFile - path of log file. Default is %temp$\PSLog.txt
	#	3. $bolAppend - Append to current file. Default is true (appends) 
	#	4. $strTimeStamp - timestamp of log entry - default will be the time the function was called. You can specify something different if you are writing past events and have time information for it or would like to specify different formatting.
	#	5. $strEncoding	- encoding of log file. default is Unicode. I'd like to note that it seems the default encoding for Out-File is UCS-2 Little Endian. I thought Unicode would be a better default.
	#		Acceptable input: "Unicode", "UTF7", "UTF8", "UTF32", "ASCII", "BigEndianUnicode", "Default", "OEM"
	
	#WARNING: the WriteToEventLog function should not be referenced in this script as this function is used to aid WriteToEventLog - referencing that function in this script would create a circular reference.
	
	#rather than dynamically put in the -Append operator on the Out-File command I just delete the file if it's set to overwrite.
	
	#===INPUT VALIDATION/SANITIZATION 
	#check boolean value - if not true boolean datatype than convert
	if($bolAppend -is [boolean] -eq $false) 
	{
		#attempt to interpret - converts matching string names to true boolean. 1 is the integer equivalent of $true in powershell. -1 is the integer equivalent of $true in vbscript.
		# 0 is the integer equivalent in both PS and vbscript
		if(($bolAppend -eq "True") -or ($bolAppend -eq (1)) -or ($bolAppend -eq (-1)))
		{
			[boolean]$bolAppend = $true
		}
		Elseif(($bolAppend -eq "False") -or ($bolAppend -eq (0)))
		{
			[boolean]$bolAppend = $false		
		}
	}
	
	#make sure encoding type is good
	if(($strEncode -ne "Unicode") -and ($strEncode -ne "UTF7") -and ($strEncode -ne "UTF8") -and ($strEncode -ne "UTF32") -and ($strEncode -ne "ASCII") -and ($strEncode -ne "BigEndianUnicode") -and ($strEncode -ne "Default") -and ($strEncode -ne "OEM"))
	{
		#default to Unicode if invalid formatting was entered
		$strEncode = "Unicode"
	}	
	
	#try to write the log - if it fails, throw an error event in the application log using the default cmdlet
	Try
	{
		if($bolAppend -eq $false)
		{
			Remove-Item $strLogFile
		}
		
		$strTimeStamp + "`t" + $strData | Out-File  $strLogFile -Append -Encoding $strEncode # "`t" is TAB
	}
	Catch
	{
		$strErr = $error[0]
		#default logging cmdlet used because WriteToEventLog calls this function and using WriteToEventLog here would create a circular reference
		Write-EventLog -LogName "Application" -Source "WSH" -EntryType "Error" -EventID 42 -Message "Unable to write $strData to $strLogFile because of $strErr"
	}
}
WriteToLogFile "test111" "$env:temp\PSLog.txt" $true (Get-Date -Format g) "Unicode"
