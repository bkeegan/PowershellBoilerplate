Function GetNumberOfHosts($intCIDR)
{
	<#
	Author: Brenton Keegan
	Description: This function returns the number of hosts for the CIDR notation inputed. (actually calculates it and not just a hardcoded return) Function will return number minus host/network address
	#>
	#strips out leading / 
	$intCIDR = $intCIDR -Replace "\/", ""

	$hostbits = (32 - $intCIDR) #get the number of bits for the host
	Return [math]::pow(2,$hostbits) - 2 # calcuate total number of addrs minus network and broadcast
	
}
