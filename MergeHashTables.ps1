function MergeHashTables($ht1,$ht2)
{
	<#
	Author: Brenton Keegan - 8/27/2013
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
