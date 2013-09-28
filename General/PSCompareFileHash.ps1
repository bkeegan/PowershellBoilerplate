<#
PSCompareFileHash.ps1 - Takes the input of 2 files and uses MD5 hashing to determine if they are the same. Returns $true if hashes are the same.

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


function PSCompareFileHash($strFile1,$strFile2)
{
	#this function takes the input of 2 files and uses MD5 hashing to determine if they are the same. Returns $true if hashes are the same.
	
	#hash algorithm object
	$HashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create("MD5")
	
	#compute file 1 hash
	$File1Bytes = [io.File]::ReadAllBytes($strFile1)				
	$File1Hash = $HashAlgorithm.ComputeHash($File1Bytes)		
					
	#computer file 2 hash
	$File2Bytes = [io.File]::ReadAllBytes($strFile2)				
	$File2Hash = $HashAlgorithm.ComputeHash($File2Bytes)	
					
	if($File1Hash -eq $File2Hash)
	{
		Return $true
	}
	else
	{
		Return $false
	}

}
