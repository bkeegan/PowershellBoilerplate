Get-ADUser -Identity brenton.keegan -Property name,whenchanged | Select whenchanged | foreach {$_.whenchanged}
