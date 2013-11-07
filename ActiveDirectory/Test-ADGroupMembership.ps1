<#
Test-ADGroupMembership.ps1 - Returns $true if the specified user is a member of at least one of the specified groups.

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

function Test-ADGroupMembership
{	
	#written by Brenton Keegan on 11/6/13. Returns $true if the specified user is a member of at least one of the specified groups.
	#1. $username - SAMAccountname of user to perform test on
	#2. $groupnames - Group names separated by semicolons
	
	[cmdletbinding()]
	
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("user")]
		[alias("u")]
		[string]$username,
		
		[parameter(Mandatory=$true)]
		[alias("groups")]
		[alias("g")]
		[string]$groupnames
	)
	
	import-module activedirectory
	
	$groupnamesArray = $groupnames -split(";")
	$isMemberof = $false
	
	Foreach ($group in $groupnamesArray)
	{
	
		$result = Get-ADGroupMember $group | Where {$_.SamAccountName -eq $username} | foreach {$_.SamAccountName
			If($_.SamAccountName -contains $username)
			{
				$isMemberof = $true
			}
		} 	
	} 
	
	Return $isMemberof 
}
