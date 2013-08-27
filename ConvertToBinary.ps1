function ConvertToBinary($intNumber,$bolReverse=$false)
{
	<#
	Author: Brenton Keegan - 8/27/13
	Description: function to encapsulate the .NET methods of converning a number to/from binary
	#>
	If($bolReverse -eq $false)
	{
		Return [Convert]::ToString($intNumber,2)
	}
	Else
	{
		Return [convert]::ToInt32($intNumber,2)
	}
	


}
