<#
Get-ScriptInfo.ps1 - Gets info about the script that is currently running

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
function Get-ScriptInfo
{
	<#Description: Gets info about the script that is currently running
	1. see the switch block below for acceptable input
	#>
	
	
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("i")] #stands for info
		[string]$dataToReturn
	)

	Switch($dataToReturn)
	{
		"filename"{$returnData = Split-Path $MyInvocation.ScriptName -leaf}
		"file"{$returnData = Split-Path $MyInvocation.ScriptName -leaf}
		
		"path"{$returnData = Split-Path $MyInvocation.ScriptName}
		"parentdirectory"{$returnData = Split-Path $MyInvocation.ScriptName}
		
		"fullpath"{$returnData = (Split-Path $MyInvocation.ScriptName) + "\" + (Split-Path $MyInvocation.ScriptName -leaf)}
		
		"Lines"{$returnData = Get-Content ((Split-Path $MyInvocation.ScriptName) + "\" + (Split-Path $MyInvocation.ScriptName -leaf)) | Measure-Object -Line | foreach {$_.lines}}
		"LOC" {$returnData = Get-Content ((Split-Path $MyInvocation.ScriptName) + "\" + (Split-Path $MyInvocation.ScriptName -leaf)) | Measure-Object -Line | foreach {$_.lines}}
	}

	Return $returnData
	
}
