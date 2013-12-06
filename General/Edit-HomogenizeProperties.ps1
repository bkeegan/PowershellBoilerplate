<#
Edit-HomogenizeProperties.ps1 - Makes all objects in a specified array have the same properties inserting a specified fill value for missing properties that were added

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


function Edit-HomogenizeProperties
{
 	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("ao")]
		$arrayofObjects,
		
		[parameter(Mandatory=$false)]
		[alias("f")]
		$fillValue
	)	

	<# Description: This function takes an array of objects and homogenizes their properties - It does not change the values of existing properties but it will ensure 
	that all objects have all the same properties by adding the properties that exist in other objects to objects that do not have that property. The value of this property
	Will be the $fillValue variable. This function will return the same array of objects but with the filler properties added.
	
	1. $arrayofObjects - array of objects to homogenize
	2. $fillValue - value to assign to added properties
	
	#>
	foreach ($object in $arrayofObjects)
	{        
		$objectMembers = $object | Get-Member | where {$_.membertype -eq "NoteProperty"} | foreach {$_.name}
		Foreach($objectMember in $objectMembers)
		{
			Foreach($object2 in $arrayofObjects)
			{
				[string]$member = $objectMember
				$MemberMatch = $object2 | Get-Member | where {$_.membertype -eq "NoteProperty"} | Where {$_.name -eq $member} | foreach  {$_.name}
				If ($MemberMatch -eq $null)
				{                
					$object2 | Add-Member -Membertype NoteProperty -Name $member -Value $fillValue
				}
			}
		}
	}
	Return $arrayofObjects
}
