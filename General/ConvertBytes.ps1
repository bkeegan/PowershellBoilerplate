function ConvertBytes($intInBytes)
{
	$i = 0

	<#
	Author: Brenton Keegan - Written on 8/24/2013
	Description: This function converts a number in bytes to the most appropiate derivative measurement. It does so by continually dividing by 1024 until the number is less than 1.
	Once it reaches this point it divides the input number by 1024 to the power of the number of times it looped -1. 
	
	$intInBytes: The input in bytes 
	#>

	#intConversion is the variable that is used to determine how much to divide by
	$intConversion = $intInBytes

	#continually loop dividing intConversion by 1024 as long as it's is greater than 1
	Do 
	{
		$intConversion = $intConversion/1024
		$i++
	} While($intConversion -ge 1)

	#increment back one step so $i is equal to the number of times the input number needs to be divided by 1024 to yield the smallest number that is not less than 1
	$i--
	#determine the resultant unit of measurement
	switch($i)
	{
		0{$strUnits = "Bytes"}
		1{$strUnits = "KiB"}
		2{$strUnits = "MiB"}
		3{$strUnits = "GiB"}
		4{$strUnits = "TiB"}
		5{$strUnits = "PiB"}
		6{$strUnits = "EiB"}
		7{$strUnits = "ZiB"}
		8{$strUnits = "YiB"}
	}
	#actual number to output - divides the input number by 1024 to the power of $i
	$intInBytes = ($intInBytes / [math]::pow(1024,$i))
	$intInBytes = "{0:N2}" -f $intInBytes
	#returns a string with appended by the unit of measurement
	Return [string]$intInBytes + $strUnits

}
