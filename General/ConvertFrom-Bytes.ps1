<#
ConvertFrom-Bytes.ps1 - Converts a number measured in bytes and converts it to the most appropiate denomination

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


function ConvertFrom-Bytes
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$false,ValueFromPipeline=$true)]
		[alias("b")]
		$bytes,
		
		[parameter(Mandatory=$false)]
		[alias("bi")] #will return binary bytes. ie 1024 bytes is 1 KiB (kilobibytes)
		[switch]$binaryBytes
	)	

        <# Description: Converts a number measured in bytes and converts it to the most appropiate denomination. Ex. 1000 bytes will convert to 1 KB.
        1. bytes - bytes to convert to a different denomination.
        2. Option to return true binary bytes (ex. 1024 bytes = 1 KiB)
        #>

	if($binaryBytes -eq $true)
	{
		$divisor = 1024
	}
	else
	{
		$divisor = 1000	
	}
	
    	#stores result of division and then divided again until result is less than 1
	$divisorQuotent = $bytes

	#continually loop dividing intConversion by 1024 as long as it's is greater than 1
	$i = 0
	do 
	{
	$divisorQuotent = $divisorQuotent/$divisor
			$i++
	} while($divisorQuotent -ge 1)

	#increment back one step so $i is equal to the number of times the input number needs to be divided by 1024 to yield the smallest number that is not less than 1
	$i--
	#determine the resultant unit of measurement
	switch($i)
	{
			0{$denomination = "Bytes"}
			1{$denomination = "KB"}
			2{$denomination = "MB"}
			3{$denomination = "GB"}
			4{$denomination = "TB"}
			5{$denomination = "PB"}
			6{$denomination = "EB"}
			7{$denomination = "ZB"}
			8{$denomination = "YB"}
	}
	
	If(($binaryBytes -eq $true) -and ($denomination.length -eq 2))
	{
		#change denomination if binarybytes mode is set. (changes KB to KiB)
		$denomination = $denomination.insert(1,"i")
	}
	
	#actual number to output - divides the input number by $divisor to the power of $i
	$bytes = ($bytes / [math]::pow($divisor,$i))
	#returns a string with appended by the unit of measurement
	Return [string]$bytes + $denomination
}
