function CreateLocalUser([string]$strUsername,[string]$strPwd,[string]$strInfo="User Account",$strComputer="$env:COMPUTERNAME")
{
	#Written by Brenton Keegan on 8/12/13
	#this function creates a local user on the specified machine (default is the local machine)
	#Parameters:
	#1.$strUsername - username of the new user
	#2.$strPwd - password of the new user
	#3.$strInfo - description of user account.
	#4.$strComputer - computer to create the user on (Default is the local machine)
	
		[ADSI]$objLogonSrv="WinNT://$strComputer"
		$colUsers = ($objLogonSrv.psbase.children | Where-Object {$_.psBase.schemaClassName -eq "User"} | Select-Object -expand Name)
		$bolFound = $colUsers -contains  $strUsername
		
		if(!$bolFound)
		{
			$objUser = $objLogonSrv.Create("User",$strUsername)
			$objUSer.SetPassword($strPwd)
			$objUser.Put("Description",$strInfo)
			$objUser.SetInfo()
		}
}
