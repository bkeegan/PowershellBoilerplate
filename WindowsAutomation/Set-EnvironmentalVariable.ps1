<#
Set-EnvironmentalVariable.ps1 - Sets a machine or user environmental variable based on input

Copyright (C) 2014  Brenton Keegan

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
function Set-EnvironmentalVariable
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("n")]
		[string]$name,
		
		[parameter(Mandatory=$true)]
		[alias("v")]
		[string]$value,
	
		[parameter(Mandatory=$false)]
		[alias("m")]
		[switch]$machineVar # if set to true - will create machine variable - user is default
	)
	
	#using the .net method described here seemed to require local admin rights even if it was only create a user variable
	#http://technet.microsoft.com/en-us/library/ff730964.aspx
	#used setx command as this can successfully create a user var without a admin rights
	
	
	if($machineVar -eq $false)
	{
		setx $name $value
	}
	else
	{
		setx $name $value -m		
	}
}
