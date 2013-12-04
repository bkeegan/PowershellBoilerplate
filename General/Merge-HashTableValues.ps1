<#
Merge-HashTableValues.ps1 - Merges values of two hashs tables.

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

function Merge-HashTableValues
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true)]
		$ht1,
		
		[parameter(Mandatory=$true)]
		$ht2
	)
   <#Description:
	This function combines the values of 2 hashtables. This is used when you have hashtables that list items and a count. This function combines the hashtables values.
	For example if a hash table has an entry 'item1' with the value of 42 and the second hash table also has item2 with the value of 1337
	The resultant hash table will have a value of 1379 for item1. If the first hash table has a key 'item2' and the second has 'item3' the resultant hash table will have both item2 and item3 with their respective values.
	#>

	$ht1.Keys | 
	Foreach {
			$key = $_ #because $key is more readable than $_
			if($ht2.containskey($key))
			{
					$ht2[$key] = $ht2[$key] + $ht1[$key]
			}
			else
			{
					$ht2.add($key,$ht1[$key])
			}
			
	}
	Return $ht2
}
