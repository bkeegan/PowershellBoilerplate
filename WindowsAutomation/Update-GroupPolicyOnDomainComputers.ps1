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
