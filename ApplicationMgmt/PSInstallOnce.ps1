<#
PSInstallOnce.ps1 - Script to execute installer with switches based on whether or not a specified local file exists.
Used in situations where an application needs only to be installed once and not updated thru this script. 
Designed to take parameters passed in from outside the script and used as a GPO in an Windows Domain.

Copyright (C) 2013  Brenton Keegan

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#>

#REQUIRES: WriteToEventLog (included in this repository)
#REQUIRES: WritetoLogFile (included in this repository)
#If you do not wish to use these functions you can substitutes the calls to the WriteToEventLog function with the native Powershell variant.


param (
	[string]$strInstallExe,
	[string]$strSwitches,
	[string]$strLocalFile,
	[string]$bolx64,
	[string]$strApplicationName,
	[string]$strOrg
 )
function PSInstallOnce($strInstallExe, $strSwitches, $strLocalFile,$bolx64,$strApplicationName,$strOrg)
{
	WriteToEventLog "Beginning Installation Process" "Information" "$strOrg $strApplicationName Install"
	#PSInstallOnce: Simple install script that installs an application depending on whether or not a specified file exists or not. Good for one-time installs that do not need continue updates.
	#1. $strInstallExe - full path of installer exe s e.g. "\\server\apps\installer.exe" 
	#2. $strSwitches - Switches to perform a silent install e.g. "/q /config=\\server\configs\settings.xml"
	#3. $strLocalFile - local file to check existence of - if file does not exist then installer will run else it will not execute te installer
	#4. $bolx64 - NOTE, not actually boolean because calling a script from a standard command prompt with powershell.exe requires all parameters to be string. Enter 0 if application is 32-bit (or more accurately installs in program files (x86) on x64 bit systems
	#5. $strApplicationName - friendly name of application - used in event logs
	#6. Name or abbrev. of organization this script is being used - appears in event logs only
	
	if((Test-path -Path "C:\Program Files (x86)\"))
	{
		WriteToEventLog "64 bit machine" "Information" "$strOrg $strApplicationName Install"
		#64 bit machine
		if($bolx64 -eq "0")
		{
			WriteToEventLog "Installer is 32-bit - converting path" "Information" "$strOrg $strApplicationName Install"
			$strLocalFile = $strLocalFile -replace "Program Files","Program Files (x86)"
			write-host $strLocalFile
		}
			
	}
	
	if(!(Test-path -Path $strLocalFile)) #executes script block if specified file does not exist.
	{
		$ErrorActionPreference = "SilentlyContinue" #req'd for try/catch statement
		Try 
		{
			WriteToEventLog "Running command $strInstallExe" "Information" "$strOrg $strApplicationName Install"
			$process = [System.Diagnostics.Process]::Start($strInstallExe, $strSwitches) #executes installer with switches and stores output in $process
			WriteToEventLog "Installation complete - exit code: $process" "Information" "$strOrg $strApplicationName Install"
		}
		Catch
		{
			#catches any errors.
			WriteToEventLog "Error running command $strInstallExe. $error " "ERROR" "$strOrg $strApplicationName Install"
		}
	}
	else
	{
		WriteToEventLog "$strLocalFile exists - not running $strInstallExe" "Information" "$strOrg $strApplicationName Install"
		
	}
WriteToEventLog "64 bit machine" "Information" "$strOrg $strApplicationName Install"	
}	
