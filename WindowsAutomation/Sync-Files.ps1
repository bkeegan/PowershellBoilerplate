<#
Sync-Files.ps1 - Downloads files from a specified source only if they have changed or do not exist at destination.

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

function Sync-Files
{
	<#Description: This cmdlet syncs all files on a specified source to a specified destination ONLY if the files do not exist at the destination or the files on the source are different.
		1. $sourceDirectory - source files. Source files will remain unchanged.
		2. $destinationDirectory - directory file will be copied to. If directory does not exist it will be created.
		3. $registryLocation - #destination to pull from registry.This is useful in determining a location that differs depending on the context that does not have an environmental variable. If you wish to create new subfolders underneath this path, the contents of the -d switch will be appended.
	#>
	
	[cmdletbinding()]
	Param
	(
		
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("source")]
		[alias("s")]
		[string]$sourceDirectory,
		
		[parameter(Mandatory=$false)]
		[alias("destination")]
		[alias("d")]
		[string]$destinationDirectory,
		
		[parameter(Mandatory=$false)]
		[alias("r")]
		[string]$registryLocation
		
	)
	
	if($registryLocation)
	{
		#this script uses the Get-Item method which requires a drive-like notation for the registry path. Match/replace for alternate notations.
		#will convert HKEY_XXX_XXX and HKXX (without the colon) to HKXX:\
		$registryLocation = $registryLocation -replace "HKEY_CLASSES_ROOT", "HKCR:"
		$registryLocation = $registryLocation -replace "HKCR\\", "HKCR:\"
		$registryLocation = $registryLocation -replace "HKEY_CURRENT_USER", "HKCU:"
		$registryLocation = $registryLocation -replace "HKCU\\", "HKCU:\"
		$registryLocation = $registryLocation -replace "HKEY_LOCAL_MACHINE", "HKLM:"
		$registryLocation = $registryLocation -replace "HKLM\\", "HKLM:\"
		$registryLocation = $registryLocation -replace "HKEY_USERS", "HKU:"
		$registryLocation = $registryLocation -replace "HKU\\", "HKU:\"
		$registryLocation = $registryLocation -replace "HKEY_CURRENT_CONFIG", "HKCC:"
		$registryLocation = $registryLocation -replace "HKCC\\", "HKCC:\"		
		
		$regKey = $registryLocation -replace "[^\\]+$",""
		$result = $registryLocation -match "[^\\]+$"
		$regValue = $matches[0]
		$registryDestination = (Get-Item $regKey).GetValue($regValue) 
		$destinationDirectory = $registryDestination + "\$destinationDirectory"
	}
	
	#WriteToEventLog "Beginning CopyFiles Script" "Information" $strLogname
	#$ErrorActionPreference = "SilentlyContinue" #req'd for try/catch statement

	#create destination directory if it doesn't exist
	If (!(test-path $destinationDirectory))
	{
		New-Item -ItemType directory -Path $destinationDirectory
	}
	
	
	$objShell = New-Object -COM WScript.Shell
	$Files = Get-ChildItem -Path $sourceDirectory
	foreach($file in $files)
	{

		Try
		{
			if(!(Test-Path "$destinationDirectory\$($file.name)"))
			{
				Copy-item $file.fullname $destinationDirectory
				#WriteToEventLog "File does not exist. Copied File $($file.fullname) to $destinationDirectory" "Information" $strLogname
			}
			else
			{
				#If file already exists on host use hashing to determine if a different version is in repository
				if(((Compare-FileHash -1 $file.fullname -2 "$destinationDirectory\$($file.name)") -eq $false))
				{
					Copy-item $file.fullname $destinationDirectory
					#WriteToEventLog "File $($file.fullname) in repository is different than on localhost. Copied file $($file.fullname) to $destinationDirectory" "Information" "CopyFiles Script"
				}
			}
		}
		Catch
		{
			#WriteToEventLog "Error copying file. $error" "ERROR" $strLogname
		}	
	}
}
