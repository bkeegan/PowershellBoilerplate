<#
Step-IPv4Address.ps1 - Steps to the next IP address. 

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

function Step-IPv4Address
{
	<#Description: Steps to the next IP address. 
	Example 192.168.0.255 will become 192.168.1.0
	#>
		
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("ip")]
		$ipv4addr
	)	
	
	#split into into array of individually manipulable values
	$octets = $ipv4addr.split(".")

	#step backwards thru the array until it finds an octet that's not at max (255)
	for($i=3;$i -ge 0;$i--)
	{
		[int]$octet = $octets[$i]
		if([int]$octet -lt 255)
		{
			$octet++
			$octets[$i] = $octet
			Break
		}
		Else
		{
			$octets[$i] = 0
		}
	}
	#reassemble string from array
	for($i=0;$i -le 3;$i++)
	{
		$output = $output + $octets[$i]
		If($i -lt 3)
		{
			$output = $output + "."
		}
	}
	
	return $output
}
