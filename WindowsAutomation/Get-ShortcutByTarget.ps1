<#
Get-ShortcutByTarget.ps1 - Gets shortcut(s) (.url or .lnk files) by a specified target (exact or contains)

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


function Get-ShortcutByTarget
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("p")]
		[string]$searchPath,
		
		[parameter(Mandatory=$true)]
		[alias("t")]
		[string]$target,
		
		[parameter(Mandatory=$false)]
		[alias("url")]
		[switch]$webURL,
		
		[parameter(Mandatory=$false)]
		[alias("r")]
		[switch]$recurse,
		
		[parameter(Mandatory=$false)]
		[alias("x")]
		[switch]$exactMatch
		
	)
	if($webURL -eq $true)
	{
		$extensionType = ".url"
	}
	else
	{
		$extensionType = ".lnk"	
	}
	
	if($recurse -eq $true)
	{
		$shortcuts = Get-ChildItem $searchPath -r | Where {$_.extension -eq $extensionType}
	}
	else
	{
		$shortcuts = Get-ChildItem $searchPath | Where {$_.extension -eq $extensionType}	
	}
	$matchingShortcuts = @()
	$shell = New-Object -COM WScript.Shell
	foreach($shortcut in $shortcuts)
	{	
		[string]$shortcutTargetTarget = $shell.CreateShortcut($shortcut.fullname).targetpath
		if($exactMatch -eq $true)
		{
			if($shortcutTargetTarget -eq $target)
			{
				$matchingShortcuts = $matchingShortcuts + $shortcut
			}
		}
		else
		{
			if($shortcutTargetTarget.Contains($target))
			{
				$matchingShortcuts = $matchingShortcuts + $shortcut
			}
		}
	}
	
	return $matchingShortcuts 
	
}
