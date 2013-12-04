<#
Get-FilesFromZone.ps1 - Returns files originating from different zones (ie, Internet, Trusted Sites etc). Queries Zone.Identifier ADS of files in specified folder.

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

#PREREQ: Requites Get-NTFSDataStreams - also available in this repository.

function Get-FilesFromZone
{
	<#Description: Gets files from a non-local source. By default it will return any file with zone.identifer data. Use the optional switches to narrow results 
	1.$path - folder to search
	2.$recurse - optional switch to recurse through all subfolders
	3.$intranet - return intranet files only - can be combined with other source types
	4.$trusted - return trusted site files only - can be combined with other source types
	5.$internet - return internet files only - can be combined with other source types
	6.$untrusted - return untrusted site files only - can be combined with other source types	
	#>
	
	
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("p")]
		$path,
		
		[parameter(Mandatory=$false)]
		[alias("r")]
		[switch]$recurse,
			
		[parameter(Mandatory=$false)]
		[alias("intra")]
		[switch]$intranet,	
			
		[parameter(Mandatory=$false)]
		[alias("t")]
		[switch]$trusted,
		
		[parameter(Mandatory=$false)]
		[alias("inter")]
		[switch]$internet,
		
		[parameter(Mandatory=$false)]
		[alias("u")]
		[switch]$untrusted
		
		
	)
	if($recurse -eq $false)
	{
		$nonLocalFiles = Get-NTFSDataStreams -p $path | where {$_.stream -eq "Zone.Identifier"}	
	}
	else
	{
		$nonLocalFiles = Get-NTFSDataStreams -p $path -r | where {$_.stream -eq "Zone.Identifier"}		
	}
	
	$regexFilter = "ZoneId=["
	
	if($intranet -eq $true)
	{
		$regexFilter = "$regexFilter"+"1|"
	}
	if($trusted -eq $true)
	{
		$regexFilter = "$regexFilter"+"2|"
	}
	if($internet -eq $true)
	{
		$regexFilter = "$regexFilter"+"3|"
	}
	if($untrusted -eq $true)
	{
		$regexFilter = "$regexFilter"+"4|"
	}
	
	$regexFilter = $regexFilter -replace "\|$","]"
	$filesToReturn = @()
	foreach($file in $nonLocalFiles)
	{
		$zonedata = Get-Content $file.FileName -stream "Zone.Identifier"
		$result = $zonedata -match $regexFilter
		if($result -ne $null)
		{
			$filesToReturn = $filesToReturn + $file.FileName
		}
	}
	for($i=0;$i -le $filesToReturn.GetUpperBound(0);$i++)
	{
		Get-Item $filesToReturn[$i]
	}
}
