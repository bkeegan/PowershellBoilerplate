#REQUIRES function - WriteToLogFile and GetScriptInfo (both are in this repository)

function WriteToEventLog([string]$strMsg,[string]$strType="Information",[string]$strSource="WSH",[string]$strLog="Application",$bolduplicatetxtlog=$false,$intID=42,$intCat=0)
{
<#
	WriteToEventLog: Written by Brenton Keegan
		-8/10/13: Version 1.0
		-8/11/13: Version 1.1 - Added syslog severities > Windows event types. Fixed bug where script would use default settings if parameters were entered with a leading/trailing whitespace ie - "Application "
		-TODO: - Spellchecking event types - ie (detect something like iformatio as Information)
				-invoke .NET methods of writing to an event log as yet another option to try
		
		
	Description: A highly fault tolerate event logging script. This script is designed to be easy to use (ie running WriteToEventLog "log text" will log an event) 
				and be highly reliable to guarantee a log entry of some kind.
	
	The ordering of the parameters and defaults is designed so very little work (as in typing code) is required to write common events (see examples below)
	$strMsg - message text
	$strType - event type, default is Information
	$strSource - event source, default is "WSH" - stands for "windows script host". Default source for scripts generated by vbscript. Couldn't find a more appropiate default for powershell.
	$strLog - log to write to - default is Application
	$bolduplicatetxtlog - write duplicate events to a txt file - Default is false
	$intID - eventID - default is 42 
	$intCat - event category - default is 0 (none)
	
	# Examples:
	# WriteToEventLog "Details" - This will write an information message in the Application log
	# WriteToEventLog  "Error Msg" "Error" - This will write an error message in the Application log
	# WriteToEventLog "Advanced Msging" "Warning" "CustomScript" "CustomLog" $true - This will write a Warning message with a custom source in a custom log and write a duplicate text file in %temp% 
	
	Logic: Since logging is used to diagnose problems I wrote this script to be highly fault tolerate and to avoid situations where problems are occuring and information is not being collected.
	This script is also designed to handle bad input and make a best attempt to log the information anyway.
	Below is the 4 methods (in order) that are attempted to write a windows event log. If all fail it will write it to a log file in the %temp% folder
	-first round: Write-EventLog cmdlet - this will work just fine most of the time
	-second round: invoke the command-line variant: eventcreate
	-third round: assemble a vbscript file that writes an event log entry and execute it
	-forth round: Last ditch -  write it to a text file and stash in in %temp%

#>
	#====INPUT VALIDATION/SANITIZATION - if script user enters invalid parameters it will do it's best to interpret it and if it can't it will revert to defaults
	#make sure $intID is actually an integer and not "some text" or or any integer that's out of range (<0 and >65535)
	if($intID -is [int] -eq $false)
	{
		Try
		{
			#tries to just convert the variable to an integer - this will work if something like "1234" as opposed to 1234 was entered. Otherwise the catch will change it to default ID
			$intID = [int]$intID
		}
		Catch
		{
			#changes it to the default - user put in something that wasn't a number.
			[int]$intID = 42
		}
	}
	Else
	{
		if(($intID -gt 65535) -or ($intID -lt 0))
		{
			#intID is too big or negative (evt log IDs can can't be greater than 65535 or negative). reverting to default ID
			$intID = 42
		}
		
	}
	
	#check $intCat - event log categories are stored in an Int16 datatype - max value is 32767. It cannot be negative. Also make sure it's not "some text"
	if($intCat -is [int] -eq $false)
	{
		Try
		{
			#tries to just convert the variable to an integer - this will work if something like "1234" as opposed to 1234 was entered. Otherwise the catch will change it to default ID
			$intCat = [int]$intCat
		}
		Catch
		{
			#changes it to the default - user put in something that wasn't a number.
			[int]$intCat = 0
		}
	}
	Else
	{
		if(($intCat -gt 32767) -or ($intCat -lt 0))
		{
			#intCat is too big or negative (evt log Categories can can't be greater than 32767 or negative). reverting to default category
			$intCat = 0
		}
			
	}	
	
	#trims leading/trailing whitespace:
	$strType = $strType -Replace "^[ \t]+|[ \t]+$", ""
	$strSource = $strSource -Replace "^[ \t]+|[ \t]+$", ""
	$strLog = $strLog -Replace "^[ \t]+|[ \t]+$", ""
	
	#If for whatever reason this script is fed syslog severities instead of Windows Event typtes - make a converstion
	Switch($strType)
	{
		"debug"{$strType = "Information"}
		"7"{$strType = "Information"} #7 - number corresponding to debug
		"info"{$strType = "Information"}
		"6"{$strType = "Information"} #6 - info
		"notice"{$strType = "Warning"}
		"5"{$strType = "Warning"} #5 - notice
		"warn"{$strType = "Warning"}
		"4"{$strType = "Warning"} #4 - warn
		"err"{$strType = "Error"}
		"3"{$strType = "Error"} #3 - err
		"crit"{$strType = "Error"} #these and below should be "Critical" but Critical Windows Events are reserved and cannot be written in a script.
		"2"{$strType = "Error"} #2 - crit
		"alert"{$strType = "Error"}
		"1"{$strType = "Error"} #1 - alert
		"emerg"{$strType = "Error"}
		"0"{$strType = "Error"} #0 - emerg
		"panic"{$strType = "Error"} #alternate name for severity 0
	}

	#if "Critical" event was attempted - convert to Error as it's more appropriate
	if($strType -eq "Critical") 
	{
		$strType = "Error"
	}
	
	#make sure valid event type was entered.
	if(($strType -ne "Information") -and ($strType -ne "Warning") -and ($strType -ne "Error")) #note: there is a "Critical" type but apparently you cant write events with that type - suppose it's reserved.
	{
		$strType = "Information" #invalid event log type was entered - defaulting to information
	}
	
	#validate boolean value for writing duplicate txt file. Tries to interpret string values "True" and "False" and convert them to boolean
	
	if($bolduplicatetxtlog -is [boolean] -eq $false) 
	{
		#attempt to interpret - converts matching string names to true boolean. 1 is the integer equivalent of $true in powershell. -1 is the integer equivalent of $true in vbscript.
		# 0 is the integer equivalent in both PS and vbscript
		if(($bolduplicatetxtlog -eq "True") -or ($bolduplicatetxtlog -eq (1)) -or ($bolduplicatetxtlog -eq (-1)))
		{
			[boolean]$bolduplicatetxtlog = $true
		}
		Elseif(($bolduplicatetxtlog -eq "False") -or ($bolduplicatetxtlog -eq (0)))
		{
			[boolean]$bolduplicatetxtlog = $false		
		}
	}
	
	#===Info for Txt File logging
	[string]$strCurrentDate = Get-Date -Format MMddyyyy
	$strScriptname = GetScriptInfo "filename"
	$strScriptname = $strScriptname -Replace "\.",""
	$strLogFilename = $strScriptname + "_" + $strCurrentDate + ".txt"
	#sets all errors as terminating errors- try/catch situations will only work if errors are terminating and depending on the context some errors may not be terminating and logic will break
	$ErrorActionPreference = 'Stop'
	
	
	#====LOG AND SOURCE VALIDATION
	#check if log exists - create it if it doesn't
	Try 
	{
		$strlogExists = Get-EventLog -list | Where-Object {$_.logdisplayname -eq $strLog} 
		if (! $strlogExists) 
		{
			#writes new log and added source. 
			New-EventLog -LogName $strLog -Source $strSource
		}

	}
	Catch 
	{
		#if it fails to create event log - Dump error to text file in - this likely means it's running as non-admin. Default to Application
		
		WriteToLogFile $error[0] $env:temp\$strLogFilename
		WriteToLogFile "Could not create log - writing to default log 'Application'" $env:temp\$strLogFilename
		$strLog = "Application"
	}

	Try
	{
		#check for the existence of of a log source in the registry
		#other sources recommended invoking the [System.Diagnostics.EventLog]::SourceExists .NET method but this will check if source exists in ANY log
		#the script will fail if the source exists in one log but this function is set to write an event with that source in different log.
		#Another method I saw used the Get-Eventlog cmdlet and filtered down the results to match a source name but this would fail if the source already existed but there happened to be no logs with that source present
		#Querying the registry, although cumbersome, is the only way I could find that is definitive. 
		#$strRegSource = Get-ChildItem -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\$strLog | where-object {$_.name -eq "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\$strLog\$strSource"} | foreach {$_.name}
		
		$bolSourceExistsinLog = Test-path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\$strLog\$strSource						
		if($bolSourceExistsinLog -eq $false)
		{
			
			#Source does NOT exist in the specified log but might exist in other log. You cannot have the same Source in multiple logs
			#this checks ALL logs for the specified source to see if it exists elsewhere
			If([System.Diagnostics.EventLog]::SourceExists($strSource)) 
			{
				
				$strSource = $strSource + "_" + $strlog #adjust specified source
				#source exists on system - create a new source but append the specified name with _$strLog
				#but first make sure it hasn't already done so!
				$bolNewSourceExistsinLog = Test-path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\$strLog\$strSource #note adjusted source
				if($bolNewSourceExistsinLog -eq $false)
				{
					
					[System.Diagnostics.EventLog]::CreateEventSource($strSource, $strLog) #note adjusted source
					
				}
			}
			Else 
			{

				#Source does not exist on system at all - create source in specified log
				[System.Diagnostics.EventLog]::CreateEventSource($strSource, $strLog)
			}
		}
	}
	Catch
	{
		#may not have rights to create source - set to default source
		WriteToLogFile $error[0] $env:temp\$strLogFilename
		$strSource = "WSH"
	}
	
	#=======WRITE TO EVENT LOG
	Try
	{
		#NOTE: if this cmd is run as administrator - ie the script is executed with elevated permissions this command will error but not terminate and the catch below will not run unless $ErrorActionPreference = 'Stop' is set.
		Write-EventLog -LogName $strLog -Source $strSource -EventID $intID -EntryType $strType -Message $strMsg -Category $intCat

	}
	Catch
	{
		#failed to create actual event - dump error text file
		WriteToLogFile $error[0] $env:temp\$strLogFilename
		#try alternative method - invoke command-line variant: eventcreate
		Try
		{
			#please note that with the commandline version you CANNOT write to non-custom event sources. name of script is used in case original script params specified pre-existing non-custom source (ie WSH)
			if($intID -eq 0)
			{
				#eventid cannot be zero with eventcreate - setting to 1
				$intID = 1
			}	
			#NOTE: 2>&1 redirects stderr to stdout 
			$arrCmdResult = eventcreate /L $strLog /T $strType /SO $MyInvocation.MyCommand.Name /ID $intID /D "Written with eventcreate:$strMsg" 2>&1

			if($arrCmdResult[0] -match "^SUCCESS:" -ne $true)
			{
				#dump error and actual event to log file
				
				WriteToLogFile $arrCmdResult $env:temp\$strLogFilename
				WriteToLogFile "The following log information was written to the event log with eventcreate: Log:$strLog, Source:$strSource, EventID:$intID, EventType:$strType, EventMessage:$strMsg" $env:temp\$strLogFilename
			}
		}
		Catch 
		{
			#returned an error.... dumping to log
			WriteToLogFile $error[0] $env:temp\$strLogFilename
			#assemble VBscript to write to event log
			Try
			{
				
				#vbscript LogEvent method requires integer values for event type. 
				Switch($strType)
				{
					"Error"{$intEvtType = 1}
					"Warning"{$intEvtType = 2}
					"Information"{$intEvtType = 4}
				}
				#this assembles a vbscript line by line and puts in in %temp%
				"On Error Resume Next"  | Out-file "$env:temp\WriteEvent.vbs"
				"Set objShell = CreateObject(" + '"' + "WScript.Shell" + '"' + ")" | Out-file -Append "$env:temp\WriteEvent.vbs"
				"objshell.LogEvent $intEvtType," + '"' + $strMsg + '"' | Out-File -Append "$env:temp\WriteEvent.vbs"
				"If err.number <> 0 then" | Out-file -Append "$env:temp\WriteEvent.vbs"
				"WScript.StdOut.Write err.number" | Out-file -Append "$env:temp\WriteEvent.vbs"
				"end if" | Out-file -Append "$env:temp\WriteEvent.vbs"
				$strVBResult = cscript.exe $env:temp\WriteEvent.vbs 2>&1
				
				#note - I do not attempt to clean up the .vbs file at this point. 
				
				if ($strVBResult[3] -match "[0-9]+" -eq $true)
				{
					#VBscript error was returned 
					#write error to log and write original event log information to log as last-ditch attempt to log information
					WriteToLogFile "VbScript Error: $strVBResult" $env:temp\$strLogFilename
					WriteToLogFile "The following log information could not be written to the event log: Log:$strLog, Source:$strSource, EventID:$intID, EventType:$strType, EventMessage:$strMsg" $env:temp\$strLogFilename
				}
				
			}
			Catch
			{
				#Powershell encountered some error - resort to text log
				WriteToLogFile $error[0] $env:temp\$strLogFilename
				WriteToLogFile "The following log information could not be written to the event log: Log:$strLog, Source:$strSource, EventID:$intID, EventType:$strType, EventMessage:$strMsg" $env:temp\$strLogFilename
				Return $false
			}
			
		}
		
	}
	
	#write to log file anyway if option was set
	If($bolduplicatetxtlog = $true)
	{
		WriteToLogFile "The following was written to the event log - this is a duplicate text log entry: Log:$strLog, Source:$strSource, EventID:$intID, EventType:$strType, EventMessage:$strMsg" "$env:temp\$strLogFilename" 
	}
}
