<#
Compare-FileHash.ps1 - Takes the input of 2 files and uses MD5 hashing to determine if they are the same. Returns $true if hashes are the same.

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


function Compare-FileHash
{
	#this cmdlet takes the input of 2 files and uses MD5 hashing to determine if they are the same. Returns $true if hashes are the same.

	[cmdletbinding()]
	Param
	(
		
		[parameter(Mandatory=$true)]
		[alias("1")]
		[string]$file1,
		
		[parameter(Mandatory=$true)]
		[alias("2")]
		[string]$file2,
		
		[parameter(Mandatory=$false)]
		[alias("a")]
		[string]$algorithm="MD5"
		
	)

	#hash algorithm object
	$hashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create($algorithm)

	#compute file 1 hash
	$file1Bytes = [io.File]::ReadAllBytes($file1)				
	$file1Hash = $hashAlgorithm.ComputeHash($File1Bytes)		

	#computer file 2 hash
	$file2Bytes = [io.File]::ReadAllBytes($file2)				
	$file2Hash = $hashAlgorithm.ComputeHash($file2Bytes)	
	
	[string]$file1Hash
	[string]$file2Hash
	
	if($file1Hash -eq $file2Hash)
	{
		Return $true
	}
	else
	{
		Return $false
	}

}
