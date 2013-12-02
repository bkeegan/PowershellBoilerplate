<#
Install-Patches.ps1 - Installs patches in order based on creation date.

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

#PREREQ: Needs Get-FileHash and Get-ScriptInfo - both available in this repository.

function Install-Patches
{
	<#Description: This cmdlet installs patches in order based on the created date of the patch file. 
	This cmdlet keeps track of which patch has been installed by recording the hash of the patch file in a text file in the install directory
	1. $patchDirectory- repository of all patches
	2. $installDirectory - directory where application is installed
	3. $switches - switches for silent install of patches
	4. $logName - name of the log to write events to
	5. $logSource - source of log events
	#>
	
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("p")]
		[string]$patchDirectory,
		
		[parameter(Mandatory=$true)]
		[alias("i")]
		[string]$installDirectory,
		
		[parameter(Mandatory=$true)]
		[alias("s")]
		[string]$switches,
		
		[parameter(Mandatory=$false)]
		[alias("l")]
		[string]$logName="Application",
		
		[parameter(Mandatory=$false)]
		[alias("ls")]
		[string]$logSource="WSH"
	)

	Write-EventLog -Logname $logName -Source $logSource -EventID 1000 -EntryType "Information" -Message "Beginning Patch Process"	

	if(!(Test-path $installDirectory))
	{
		Write-EventLog -Logname $logName -Source $logSource -EventID 1000 -EntryType "Information" -Message "Application not installed - skipping patch process"
	}
	else
	{
		[array]$patches = Get-ChildItem $patchDirectory | Sort-Object -Property CreationTime
		$scriptname = Get-ScriptInfo -i "filename"
		if(!(Test-Path "$installDirectory\$scriptname.log"))
		{
			#No patchlog exists - assumes fresh install and installs oldest patch in repository.
			Write-EventLog -Logname $logName -Source $logSource -EventID 1000 -EntryType "Information" -Message "No Patch Log Found - installing oldest patch in repository"
			$process = [System.Diagnostics.Process]::Start("$patchDirectory\$($patches[0])", $strSwitches)
			$filehash = Get-FileHash -f "$patchDirectory\$($patches[0])"
			Add-Content "$installDirectory\$scriptname.log" "$filehash"
		}
		else
		{
			[array]$installedPatches = Get-Content "$installDirectory\$scriptname.log"
			If($installedPatches.GetUpperBound(0) -ne $patches.GetUpperBound(0))
			{
				$latestInstalledPatch = $installedPatches[$installedPatches.GetUpperBound(0)]
				For($i=0;$i -le $installedPatches.GetUpperBound(0);$i++) 
				{
					
					$filehash = Get-FileHash -f "$patchDirectory\$($patches[$i])"
					If($filehash -eq $latestInstalledPatch)
					{
						#Found latest installed patch - install next available patch
						$y = $i + 1
						$filehash = Get-FileHash -f "$patchDirectory\$($patches[$y])"
						Write-EventLog -Logname $logName -Source $logSource -EventID 1000 -EntryType "Information" -Message "Installing $patchDirectory\$($patches[$y])"
						$process = [System.Diagnostics.Process]::Start("$patchDirectory\$($patches[$y])", $strSwitches)
						Add-Content "$installDirectory\$scriptname.log" "$filehash"
					}
				}
			}
			else
			{
				Write-EventLog -Logname $logName -Source $logSource -EventID 1000 -EntryType "Information" -Message "Application Up to Date"
			}
		}
	}
}
