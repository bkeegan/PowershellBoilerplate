function CreateLocalGroup([string]$strGrpName,[string]$strInfo="Local Group",$strComputer="$env:COMPUTERNAME")
{
	#Written by Brenton Keegan on 8/12/13
	#this function creates a local user on the specified machine (default is the local machine)
	#Parameters:
	#1.$strUsername - username of the new user
	#2.$strInfo - description of user account.
	#3.$strComputer - computer to create the user on (Default is the local machine)
	
		[ADSI]$objLogonSrv="WinNT://$strComputer"
		$colGroups = ($objLogonSrv.psbase.children | Where-Object {$_.psBase.schemaClassName -eq "Group"} | Select-Object -expand Name)
		$bolFound = $colGroups -contains  $strGrpName
		
		if(!$bolFound)
		{
			$objGrp = $objLogonSrv.Create("Group",$strGrpName)
			$objGrp.Put("Description",$strInfo)
			$objGrp.SetInfo()
		}
}
