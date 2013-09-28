<#
PSPopulateShortcuts.ps1 - Copies all shortcut files down from a repositry to a specified destination

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

#REQUIRE: WriteToEventLog (included in this repository)
#REQUIRE: WritetoLogFile (included in this repository)
#REQUIRE: GetScriptInfo (included in this repository)
#REQUIRE: CompareFileHash (included in this repository)
#If you do not wish to use these functions you can substitutes the calls to the WriteToEventLog function with the native Powershell variant.

function PSPopulateShortcuts($strRepository,$strDestinationDir)
{
	<#Description: This function copies all shortcut files down from a repositry to a specified destination
	ONLY if the target path of the shortcut exists on the host
	1. $strRepository - repository of all shortcuts
	2. $strDestionationDir - directory where shortcuts will be copied to
	#>
	WriteToEventLog "Beginning Shortcut Creation Script" "Information" "Shortcut Creation Script"
	#$ErrorActionPreference = "SilentlyContinue" #req'd for try/catch statement
	
	$objShell = New-Object -COM WScript.Shell
	$ShortCuts = Get-ChildItem -Path $strRepository
	Foreach($shortcut in $ShortCuts)
	{
		
		if((Test-Path $objShell.CreateShortcut($shortcut.fullname).targetpath)) 
		{
			Try
			{
				if(!(Test-Path "$strDestinationDir\$($shortcut.name)"))
				{
					Copy-item $shortcut.fullname $strDestinationDir
					WriteToEventLog "Shortcut does not exist. Copied Shortcut $($shortcut.fullname) to $strDestinationDir" "Information" "Shortcut Creation Script"

				}
				Else
				{
					#If shortcut already exists on host use hashing to determine if a different version is in repository
					If(((PSCompareFileHash $shortcut.fullname "$strDestinationDir\$($shortcut.name)") -eq $false))
					{
						Copy-item $shortcut.fullname $strDestinationDir
						WriteToEventLog "Shortcut in repository is different than on localhost. Copied Shortcut $($shortcut.fullname) to $strDestinationDir" "Information" "Shortcut Creation Script"

					}
				
				}
				
			}
			Catch
			{
				WriteToEventLog "Error copying shortcut. $error" "ERROR" "Shortcut Creation Script"
			}	
		}
		Else
		{
			WriteToEventLog "Program for $($shortcut.fullname) not found on localhost" "Information" "Shortcut Creation Script"

		}
	}
}
