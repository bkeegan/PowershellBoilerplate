function IncrementIPAddr($strIPAddr)
{
	<#Author: Brenton Keegan - 8/27/13
	Description: This function takes an inputted IP address and adds one to it.
	Example 192.168.0.255 will become 192.168.1.0
	#>
	
	#split into into array of individually manipulable values
	$arrOctets = $strIPAddr.split(".")


	#step backwards thru the array until it finds an octet that's not at max (255)
	for($i=3;$i -ge 0;$i--)
	{
		[int]$intOctet = $arrOctets[$i]
		if([int]$intOctet -lt 255)
		{
			$intOctet++
			$arrOctets[$i] = $intOctet
			Break
		}
		Else
		{
			$arrOctets[$i] = 0
		}
	}
	#reassemble string from array
	for($i=0;$i -le 3;$i++)
	{
		$strOutput = $strOutput + $arrOctets[$i]
		If($i -lt 3)
		{
			$strOutput = $strOutput + "."
		}
	}
	
	Return $strOutput
	
}

