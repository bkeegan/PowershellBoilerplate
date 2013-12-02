<#
Get-FileHash.ps1 - Returns the hash of the specified file

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

function Get-FileHash
{
	<#Description: This cmdlet returns the hash of a specified file
	1. $file - file to return the hash of
	#>
	
	
	[cmdletbinding()]
	Param
	(
		
			[parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[alias("f")]
			[string]$file,
			
			[parameter(Mandatory=$false)]
			[alias("a")]
			[string]$algorithm="MD5"
			
	)

	#hash algorithm object
	$hashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create($algorithm)
	#compute file hash
	$fileBytes = [io.File]::ReadAllBytes($file)                                
	$fileHash = $hashAlgorithm.ComputeHash($fileBytes)   
	
	Return [string]$fileHash

}
