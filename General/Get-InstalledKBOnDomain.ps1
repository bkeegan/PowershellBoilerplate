<#
Get-InstalledKBOnDomain.ps1 - Gets Installed computers based on filter (OS and Update properties)

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

#PREREQ: Requires Get-InstalledKB - also available in this repository
#PREREQ: Requires Get-ADComputerByOS- also available in this repository

function Get-InstalledKBOnDomain
{
  [cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("f")]
		[string]$filter,
			
		[parameter(Mandatory=$true)]
		[alias("o")]
		[string]$operatingSystem,
		
		[parameter(Mandatory=$false)]
		[alias("v")]
		[string]$version,
		
		[parameter(Mandatory=$false)]
		[alias("e")]
		[string]$edition,
		
		[parameter(Mandatory=$false)]
		[alias("i")]
		[switch]$inverseQuery, 
	
		[parameter(Mandatory=$false)]
		[alias("x")]
		[switch]$exactQuery 	
	)
	
	Get-ADComputerByOS -o:$operatingSystem -v:$version -e:$edition -i:$inverseQuery -x:$exactQuery | foreach{Get-InstalledKB -f $filter -c $_.DNSHostName} 
	
}

function Get-InstalledKB
{
    [cmdletbinding()]
    Param
    (
      [parameter(Mandatory=$true)]
      [alias("f")]
      [string]$filter,
      
      [parameter(Mandatory=$false,ValueFromPipeline=$true)]
      [alias("c")]
      [string]$computer
    )
                
	if([string]$computer -eq "")
	{
	   $computer = "localhost"
	}
	$filterExpression = "`$`_."+"$filter"
	$wmiQuery = "Get-WMIObject -ComputerName $computer win32_quickfixengineering"
	$finalExpression = "$wmiQuery" + " | where {" + "$filterexpression" + "}"
	$finalExpression = [scriptblock]::Create($finalExpression)
	
	return (Invoke-Command $finalExpression)
}

function Get-ADComputerByOS
{
     <#Description: This cmdlet gets the last time a specified AD object was changed.
        1. $operatingSystem - Name of the operating system - examples "Windows" "Mac OS"
        2. $version - version of operating system - examples "7" "Vista" "X"
        3. $edition - Edition of operating system - examples "standard" "enterprise"
        4. $inverseQuery - Will inverse query and return any OS not like the previous parameters
		5. $exactQuery - will make query exact. By default search query is appended with a wildcard so "Windows Server 2008" will return 2008 and 2008 R2. -x makes query so previous query will only return Windows Server 2008
        #>
        
        [cmdletbinding()]
        Param
        (
			[parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[alias("o")]
			[string]$operatingSystem,
			
			[parameter(Mandatory=$false)]
			[alias("v")]
			[string]$version,
			
			[parameter(Mandatory=$false)]
			[alias("e")]
			[string]$edition,
			
			[parameter(Mandatory=$false)]
			[alias("i")]
			[switch]$inverseQuery, 
		
			[parameter(Mandatory=$false)]
			[alias("x")]
			[switch]$exactQuery 	
        )
	$searchFilter = "$operatingSystem"
	if($verson -ne "")
	{
		$searchFilter = $searchFilter + " " + "$version"
	}
	
	if($edition -ne "")
	{
		$searchFilter = $searchFilter + " " + "$edition"	
	}
	if($exactQuery -eq $false)
	{
		$searchFilter = $searchFilter + "*"
	}
	$searchFilter
	
	if($inverseQuery -eq $false)
	{
		Get-ADComputer -Filter {OperatingSystem -Like $searchFilter} -property name,operatingsystem
	}
	else
	{
		Get-ADComputer -Filter {OperatingSystem -NotLike $searchFilter} -property name,operatingsystem
	}
	
}
