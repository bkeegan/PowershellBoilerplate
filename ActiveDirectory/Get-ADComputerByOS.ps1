<#
Get-ADComputerByOS.ps1 - Gets AD computer accounts by Operating System

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

#PREREQ: Requires activedirectory module to be installed where script is running

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
		
	$searchFilter = "$operatingSystem" + " " + "$version" + " " + "$edition"
	
	if($exactQuery -ne $false)
	{
		$searchFilter = $searchFilter + "*"
	}
	
	if($inverseQuery -eq $false)
	{
		Get-ADComputer -Filter {OperatingSystem -Like $searchFilter} -property name,operatingsystem
	}
	else
	{
		Get-ADComputer -Filter {OperatingSystem -NotLike $searchFilter} -property name,operatingsystem
	}
	
}
