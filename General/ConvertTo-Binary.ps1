<#
ConvertTo-Binary.ps1 - Converts a decimal of hexadecimal number to binary

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

function ConvertTo-Binary
{
        <# Description: Converts a decimal of hexadecimal number to binary 
		1. $decimal - specify a decimal number to convert to binary
		2. $hex - specify a hexadecimal number to return to binary. If this is specified the -n value will be ignored.
		3. $octet - if this switch is used this cmdlet will return a full octet (ie -n 4 will return 00000100 instead of 100)
		#>
		
		[cmdletbinding()]
		Param
		(
			[parameter(Mandatory=$false,ValueFromPipeline=$true)]
			[alias("n")]
			$decimal,
			
			[parameter(Mandatory=$false,ValueFromPipeline=$true)]
			[alias("h")]
			$hex,
			
			[parameter(Mandatory=$false)]
			[alias("o")]
			[switch]$octet
		)
		
		if(($hex -eq $null) -and ($decimal -eq $null))
		{
			Write-Error "You must specify a hexadecimal or decimal number to convert to binary"
			Return
		}

		if($hex -ne $null)
		{
			$decimal = [Convert]::ToInt32($hex,16)
		}
		
		$binaryNumber = [Convert]::ToString($decimal,2)
		
		if($octet -eq $true)
		{
			If($binaryNumber.length -lt 8)
			{
				for($i=1;$i -le (8 - $binaryNumber.length);$i++)
				{
					$zerosToAdd = $zerosToAdd + "0" 
				}
			}
			$binaryNumber = $zerosToAdd + $binaryNumber
		}
		
		return $binaryNumber
}
