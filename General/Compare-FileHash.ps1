<# 
.SYNOPSIS 
	Compares the hash of two specified files, returns True if they are identical, False if they are different.
.DESCRIPTION 
	Used to determine if two files are identical. This file reads a file's bytes and performs a hash algorithm on those bytes. Any change in the file will result in a hash change. 
	The hash algorithm that is used can be specified via the -a parameter. Valid options are listed here: http://msdn.microsoft.com/en-us/library/wet69s13(v=vs.110).aspx. If no algorithm is specified, MD5 will be used.
.NOTES 
    File Name  : Compare-FileHash.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv2  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate
    License: https://github.com/bkeegan/PowershellBoilerplate/blob/master/LICENSE.md
.EXAMPLE 
	Compare-FileHash -f1 "C:|test\file1.ext" -f2 "C:|test\file2.ext" -a "SHA1"
	This command will compare the hash of file1.ext and file2.ext using the SHA1 algorithm.
#> 

function Compare-FileHash
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		[alias("f1")]
		[string]$file1,
		
		[parameter(Mandatory=$true)]
		[alias("f2")]
		[string]$file2,
		
		[parameter(Mandatory=$false)]
		[alias("a")]
		[string]$algorithm="MD5"
		
	)
	
	if((Test-Path $file1) -eq $true -and (Test-Path $file2) -eq $true)
	{	
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
	else
	{
		if((Test-Path $file1) -eq $false)
		{
			Throw "Cannot find path $file1 because it does not exist."
		}
		else
		{
			Throw "Cannot find path $file2 because it does not exist."
		}
	}
}
