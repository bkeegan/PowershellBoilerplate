<#
New-ADComputerAccountSeries.ps1 - Creates AD machine accounts based on the entered parameters. Designed for prepopulating AD with machine accounts for computer labs.

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

function New-ADComputerAccountSeries
{        
	#creates AD accounts based on the entered parameters. Designed to prepopulate AD accounts for computer labs. Presently this script is quick and dirty and could be better.
	#1. $name - root name of PC
	#2. $rootOU - Root OU to create OU in that will house computer account
	#3. Number of machines accounts to create
	#4. AD groups to make each machine account a member of separated by a semicolon ex: "group1;group2"
	#5. Default will name the OU will $name. Use this parameter to override this behavior with a specific value.
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("n")]
		[string]$name,
		
		[parameter(Mandatory=$true)]
		[alias("r")]
		[string]$rootOU,
		
		[parameter(Mandatory=$true)]
		[alias("c")]
		[int]$count, 
	
		[parameter(Mandatory=$false)]
		[alias("g")]
		[string]$groupMembership,
		
		[parameter(Mandatory=$false)]
		[alias("o")]
		[string]$OUName 
			
	)
	
	
	#imports
	Import-Module activedirectory
	#Gets the domain name of the machine this script is running from - used to populate the DNS hostname field.
	$domain = Get-WMIObject win32_computersystem | foreach {$_.domain}
	
	$groupMembershipArray = $groupMembership -split (";")
	
	#logic to set the OU name 
	If(!($OUName))
	{
		$OUName = $name
	}

	#create OU - will error out if OU exists.
	New-ADOrganizationalUnit -Name $OUName -Path $rootOU

	#create machine accounts - will error out if they exist exists.
	for($i=1;$i -le $count;$i++)
	{
		$currentComputerName = "$name"+"$i"
		$currentDate = Get-Date -format g
		$currentDescription = "Created via script on: $currentDate"
		New-ADComputer -Name $currentComputerName -SamAccountName $currentComputerName -Path "OU=$OUName,$rootOU" -Enabled $true -Description $currentDescription -DNSHostName "$currentComputerName.$domain"
		
		#add newly created machine account to groups.
		foreach($group in $groupMembershipArray)                
		{
			Add-ADGroupMember -Identity $group -Member "CN=$currentComputerName,OU=$OUName,$rootOU"
		}
	}
}
