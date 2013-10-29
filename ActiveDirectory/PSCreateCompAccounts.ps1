<#
PSCreateCompAccounts.ps1 - Creates AD machine accounts based on the entered parameters. Designed for prepopulating AD with machine accounts for computer labs.

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

param (
	[string]$strRootOU,
	[string]$strRoomPrefix,
	[string]$strRoomNumber,
	[int]$intCount,
	[string]$strGroups,
	[string]$strRenameOU

)

function PSCreateCompAccounts($strRootOU,$strRoomPrefix,$strRoomNumber,$intCount,$strGroups,$strRenameOU)
{	
	#creates AD accounts based on the entered parameters. Designed to prepopulate AD accounts for computer labs. Presently this script is quick and dirty and could be better.
	#1. strRootOU - Root OU to create OU in that will house computer accounts
	#2. strRoomPrefix - used in naming convention ex, "Lab", "Room" etc.
	#3. strRoomNumber - room number of the lab
	#4. Number of machines accounts to create
	#5. AD groups to make each machine account a member of seperated by a semicolon ex: "group1;group2"
	#6. Default will name the OU (the one created in strRootOU) will be the room number - specify "" to take default or enter an explicit OU name.

	#imports
	Import-Module activedirectory
	#Gets the domain name of the machine this script is running from - used to populate the DNS hostname field.
	$strDomain = gwmi win32_computersystem | foreach {$_.domain}
	
	$arrGroupNames = $strGroups -split (";")
	
	#logic to set the OU name 
	If($strRenameOU -eq "")
	{
		$strOUName = $strRoomNumber
		Write-Host "No OU naming override set - using room number for the OU name"
	}
	Else
	{
		$strOUName = $strRenameOU
	}
	Write-host "Full OU path is $strOUName,$strRootOU"
	
	
	#create OU - will error out if OU exists.
	Try
	{
		New-ADOrganizationalUnit -Name $strOUName -Path $strRootOU
		Write-host "The OU OU=$strOUName,$strRootOU was created"
	}
	Catch
	{	
		Write-host "ERROR OCCURED adding OU=$strOUName,$strRootOU"
	}
	
	#create machine accounts - will error out if they exist exists.
	For($i=1;$i -le $intCount;$i++)
	{
		Try
		{
			$strCurrentComputerName = "$strRoomPrefix-$strRoomNumber-$i"
			$CurrentDate = Get-Date -format g
			$strCurrentDescription = "Created via script on: $CurrentDate"
			New-ADComputer -Name $strCurrentComputerName -SamAccountName $strCurrentComputerName -Path "OU=$strOUName,$strRootOU" -Enabled $true -Description $strCurrentDescription -DNSHostName "$strCurrentComputerName.$strDomain"
			Write-Host "Created computer account: $strCurrentComputerName"
		}
		Catch
		{
			Write-host "ERROR OCCURED creating machine account $strCurrentComputerName"
		}
		#add newly created machine account to groups.
		Foreach($strGroup in $arrGroupNames)		
		{
			Try
			{
				Add-ADGroupMember -Identity $strGroup -Member "CN=$strCurrentComputerName,OU=$strOUName,$strRootOU"
				Write-host Added $strCurrentComputerName to $strGroup
			}
			Catch
			{
				Write-host "ERROR OCCURED adding $strCurrentComputerName to $strGroup"
			}
		}
	}
}	

PSCreateCompAccounts $strRootOU $strRoomPrefix $strRoomNumber $intCount $strGroups $strRenameOU
