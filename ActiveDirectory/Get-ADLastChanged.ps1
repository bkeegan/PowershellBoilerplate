<#
Get-ADLastChanged.ps1 - Gets the last time an object was changed.

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

function Get-ADLastChanged
{
     <#Description: This cmdlet gets the last time a specified AD object was changed.
        1. $ADObjectDN - Distinguished name of AD object.
        #>
        
        [cmdletbinding()]
        Param
        (
                [parameter(Mandatory=$true,ValueFromPipeline=$true)]
                [alias("o")]
                [string]$ADobjectDN
                
        )
		
	Import-Module activedirectory
	Get-ADObject -Identity $ADobjectDN -Property name,whenchanged | Select whenchanged | foreach {$_.whenchanged}


}
