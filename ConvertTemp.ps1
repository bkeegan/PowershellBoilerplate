function ConvertTemp([float]$fltTemperature,[boolean]$bolCtoF=$true,[boolean]$bolRound=$true)
{
	#function by brenton keegan - written on 8/9/2013. Converts Celsius to Fahrenheit and vice-versa
	#params: 
	#		$fltTemperature - integer of the number to convert 
	#		$bolCtoF - Default is True. Will assume specified number is Celsius and convert to Fahrenheit - set to False to do vice-versa
	#		$bolRound - default is True - rounds result to nearest whole number
	
	if($bolCtoF -eq $true) 
	{
		$fltResult = ($fltTemperature*(9/5) + 32)
	}
	Else
	{
		$fltResult = ($fltTemperature - 32) * (5/9)
	}

	if($bolRound -eq $true)
	{
		Return [Math]::Round($fltResult)
	}
	Else
	{
		Return $fltResult
	}
}
