#REQUIRE function ConvertToBinary (also available in this repository)

Function CIDRtoSubnet($intCIDR,$bolGetHostCount=$false)
{
	<#
	Author: Brenton Keegan
	Description: This function takes cidr notation and outputs the corresponding subnet mask. This script can handle input with our without the preceeding forward-slash. 
	This function can optionally output the number of hosts instead of the subnet mask
	#>
	#strips out leading / 
	$intCIDR = $intCIDR -Replace "\/", ""

	$hostbits = (32 - $intCIDR) #get the number of bits for the host
	If($bolSubnetMask = $true)
	{
		Return [math]::pow(2,$hostbits) - 2 # Calculate total number of addrs minus network and broadcast
	}
	Else
	{
		#begin looping starting at one and going to 4 (each loop represents one octet) 
		for($i=1; $i -le 4; $i++)
		{	
			#set strSubnetBinary to an empty string - reset at the beginning holds one octet in binary
			$strSubnetBinary = ""
			for($q=1; $q -le 8;$q++)
			{
				#loop to 8 - each binary digit in octet
				If(($i*8 + $q)-8 -le $intCIDR)
				{
					#if current position in total subnet is less than cidr still in mask - write a 1
					$strSubnetBinary = $strSubnetBinary + "1"
				}
				Else
				{
					#now in host portion of subnet - write a 0
					$strSubnetBinary = $strSubnetBinary + "0"
				}
			}
			#append the octet converted to decimal to the final output
			$strSubnetDecimal = $strSubnetDecimal + [string](ConvertToBinary $strSubnetBinary $true)
			#if not on final octet append a .
			If($i -lt 4)
			{
				$strSubnetDecimal = $strSubnetDecimal + "."
			}
		} 
		
		Return $strSubnetDecimal
	}
}
