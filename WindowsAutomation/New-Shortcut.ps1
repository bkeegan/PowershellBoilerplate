<#
New-Shortcut.ps1 - Creates a shortcut based on the specified parameters

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

function New-Shortcut
{
	#written by Brenton Keegan on 11/6/13
	#1. $target - exe of shortcut (not full path) (example 'winword.exe')
	#2. $workingDirectory - path of exe (example 'c:\program files\microsoft office\Office15'
	#3. $destiation - folder where to put the shortcut
	#4. $name - name of shortcut - if none specified exe (without extension) will be used
	#5. $argeuements - any command line arguement for exe
	#6. $icon - icon of exe, use comma to denote index (example 'c:\windows\system32\shell32.dll,2') - default will be $target,0
	#7. $comment - default is empty string
	#8. $force - if shortcut exists it will delete and recreate
	
	
	[cmdletbinding()]
	
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("t")]
		[string]$target,
		
		[parameter(Mandatory=$true)]
		[alias("w")]
		[string]$workingDirectory,
		
		[parameter(Mandatory=$true)]
		[alias("d")]
		[string]$destination,
	
		[parameter(Mandatory=$false)]
		[alias("n")]
		[string]$name = ($target -replace '\..+$',''),
	
		[parameter(Mandatory=$false)]
		[alias("a")]
		[string]$arguments="",
		
		[parameter(Mandatory=$false)]
		[alias("i")]
		[string]$icon="$target,0",
		
		[parameter(Mandatory=$false)]
		[alias("c")]
		[string]$comment="",
		
		[parameter(Mandatory=$false)]
		[alias("f")]
		[switch]$force
		
	)	
	
	if((Test-Path "$destination\$name.lnk") -and ($force -eq $true))
	{
		Remove-Item "$destination\$name.lnk"
	}
	
	if(!(Test-Path "$destination\$name.lnk") -or ($force -eq $true))
	{
		$wshShell = New-Object -comObject WScript.Shell
		$shortcut = $wshShell.CreateShortcut("$destination\$name.lnk")
		$shortcut.IconLocation = $icon
		$shortcut.TargetPath = "$workingDirectory\$target"
		$shortcut.WorkingDirectory = $workingDirectory
		$shortcut.Arguments = $arguments
		$shortcut.Description = $comment
		$shortcut.Save()
	}

}
