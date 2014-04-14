<#
Update-GroupPolicyOnDomainComputers.ps1 - runs gpupdate on domain computers in a specified OU.

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

<#  
.SYNOPSIS  
	executes computer group policy on domain computers in a specified OU.
.DESCRIPTION  
	This script queries
.NOTES  
	File Name  : Update-GroupPolicyOnDomainComputers.ps1 
	Author     : Brenton Keegan
 	Requires   : PowerShell 2  
.LINK  
	https://github.com/bkeegan/PowershellBoilerplate
#>


function Update-GroupPolicyOnDomainComputers 
{
	[cmdletbinding()]
		Param
		(
			
			[parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[alias("target")]
			[alias("t")]
			[string]$targetOU,
			
			[parameter(Mandatory=$false)]
			[alias("s")]
			[string]$searchScope
		
		)
	#imports
	import-module activedirectory
	
	$computers = Get-ADObject -filter * -searchbase $targetOU -searchscope $searchScope | where {$_.objectclass -eq "computer"}
	foreach($computer in $computers)
	{
		write-host "Updating policy on $($computer.name)"
		invoke-command -computername $computer.name {gpupdate /force /target:computer}
	}
}
