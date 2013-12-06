<#
ConvertTo-Subnet.ps1 - Converts CIDR notation to subnet. 

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

#PREREQ function ConvertTo-Decimal (also available in this repository)

function ConvertTo-Subnet
{
        <# Description: This function takes cidr notation and outputs the corresponding subnet mask. This script can handle input with our without the preceeding forward-slash. 
        This function can optionally output the number of hosts instead of the subnet mask
        #>
		
		[cmdletbinding()]
		Param
		(
			[parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[alias("c")]
			$CIDR,

			[parameter(Mandatory=$false)]
			[alias("h")]
			[switch]$numberOfHosts
		)
		
        #strips out leading / - will do nothing if no / is present
        $CIDR = $CIDR -Replace "\/", ""
		#strips out leading \ if user erroneously used backslash
		$CIDR = $CIDR -Replace "\\", ""
		
		$invalidCIDRMsg = "Invalid CIDR notation. Please specify an integer between 0 and 32 with or without the proceeding slash"
		
		#convert to integer - will fail if input contains something else besides a number
		Try
		{
			$CIDR = [int]$CIDR
		}
		Catch
		{
			Throw $invalidCIDRMsg
		}
		
		
		if(($CIDR -lt 0) -or ($CIDR -GT 32))
		{
			Throw $invalidCIDRMsg
		
		}
		
        $hostbits = (32 - [int]$CIDR) #get the number of bits for the host
        if($numberOfHosts -eq $true)
        {
			return [math]::pow(2,$hostbits) - 2 # Calculate total number of addrs minus network and broadcast
        }
        else
        {
			#begin looping starting at one and going to 4 (each loop represents one octet) 
			for($i=1; $i -le 4; $i++)
			{        
				#set subnetBinary to an empty string - reset at the beginning holds one octet in binary
				$subnetBinary = ""
				for($q=1; $q -le 8;$q++)
				{
					#loop to 8 - each binary digit in octet
					if(($i*8 + $q)-8 -le $CIDR)
					{
						#if current position in total subnet is less than cidr still in mask - write a 1
						$subnetBinary = $subnetBinary + "1"
					}
					else
					{
						#now in host portion of subnet - write a 0
						$subnetBinary = $subnetBinary + "0"
					}
				}
				#append the octet converted to decimal to the final output
				$subnetDecimal = $subnetDecimal + [string](ConvertTo-Decimal -b $subnetBinary)
				#if not on final octet append a .
				if($i -lt 4)
				{
					$subnetDecimal = $subnetDecimal + "."
				}
			} 
		
			return $subnetDecimal
        }
}
