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

function Update-GroupPolicyOnDomainComputers 
{
	<#  
	.SYNOPSIS  
		Forces a computer group policy refresh on domain computers with accounts in a specified container. 
	.DESCRIPTION  
		This script queries active directory using the get-adobject cmdlet and returns only computer accounts existing in a specified container (specified by DN). This script will use WinRM to execute gpupdate /force /target:computer on every computer returned from the active directory query. Any output will be displayed in the console. 
	.NOTES  
		File Name  : Update-GroupPolicyOnDomainComputers.ps1 
		Author     : Brenton Keegan
		Requires   : PowerShell 3, activedirectory module  
	.LINK  
		https://github.com/bkeegan/PowershellBoilerplate
	.EXAMPLE
		Update-GroupPolicyOnDomainComputers -t "OU=Servers,DC=Domain,DC=Local" -s Base
		
		Description
		-----------
		The command below will run gpupdate /force /target:computer on the computers that have domain accounts under the specified OU. This will not apply to any computers with accounts in sub-containers.
	.EXAMPLE
		Update-GroupPolicyOnDomainComputers -t "OU=Servers,DC=Domain,DC=Local"

		Description
		-----------
		The command below will run gpupdate /force /target:computer on the computers that have domain accounts under the specified OU. This will also apply to any computers with accounts in sub-containers as the default searchscope is Subtree 
	.PARAMETER target
		Distiguished name of target container. (ex. OU=Server,DC=Domain,DC=Local)
	.PARAMETER searchScope
		Passes through to the searchscope parameter of the get-adobject cmdlet. Default is "Subtree"
	.INPUTS
		String. Distinguished name of AD container.
	.OUTPUTS
		Displays the return from the attempt to run gpupdate /force /target:computer on all remote computers
	
	#>
	
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
