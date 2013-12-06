<#
ConvertTo-Decimal.ps1 - Converts a binary or hexadecimal number to decimal

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

function ConvertTo-Decimal
{
    <# Description: Converts a decimal of hexadecimal number to binary 
		1. $binary - specify a binary number to convert to decimal
		2. $hex - specify a hexadecimal number to convert to decimal. If this is specified the -b value will be ignored.
		#>
		
		[cmdletbinding()]
		Param
		(
			[parameter(Mandatory=$false,ValueFromPipeline=$true)]
			[alias("b")]
			$binary,
			
			[parameter(Mandatory=$false,ValueFromPipeline=$true)]
			[alias("h")]
			$hex
		)
		
		if(($hex -eq $null) -and ($binary -eq $null))
		{
			Throw "You must specify a binary or hexadecimal number to convert to decimal"
		}

		if($hex -ne $null)
		{
			return [Convert]::ToInt32($hex,16)
		}
		return [convert]::ToInt32($binary,2)
}
