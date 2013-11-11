<#
Remove-SpecifiedItems.ps1 - Removes Specified Items from a target folder.

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

Function Remove-SpecifiedItems
{
	#1.a list of folders/files to delete separated by the a semicolon (;). Semicolon was chosen because it's an illegal NTFS character and won't ever be in a folder/file path
	#2.directory to target
	
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("items")]
		[alias("i")]
		[string]$itemsToDelete,
		
		[parameter(Mandatory=$true)]
		[alias("target")]
		[alias("t")]
		[string]$targetdirectory
	)
	
	$itemsToDeleteArray = $itemsToDelete -split (";")
	Get-ChildItem $targetdirectory | Select -Property name | foreach {$_.name
			$item = [string]$_.name
			if($itemsToDeleteArray -contains $item)
			{
					Remove-Item "$targetdirectory\$item"
			}
	} | Out-Null
}
