function HomogenizeProperties($arrObjects,$strPlaceHolderValue)
{
	<#
	Description: This function takes an array of objects and homogenizes their properties - It does not change the values of existing properties but it will ensure 
	that all objects have all the same properties by adding the properties that exist in other objects to objects that do not have that property. The value of this property
	Will be the $strPlaceHolderValue variable. This function will return the same array of objects but with the filler properties added.
	
	1. $arrObjects - array of objects to homogenize
	2. $strPlaceHolderValue - value to assign to added properties
	
	#>
	foreach ($object in $arrObjects)
	{	
		$objmembers = $object | Get-Member | where {$_.membertype -eq "NoteProperty"} | foreach {$_.name}
		Foreach($objmember in $objmembers)
		{
			Foreach($object2 in $arrObjects)
			{
				[string]$strMember = $objmember
				$MemberMatch = $object2 | Get-Member | where {$_.membertype -eq "NoteProperty"} | Where {$_.name -eq $strMember} | foreach  {$_.name}
				If ($MemberMatch -eq $null)
				{		
					$object2 | Add-Member -Membertype NoteProperty -Name $strMember -Value $strPlaceHolderValue
					
				}
			}
		}
	}
	Return $arrObjects
}
