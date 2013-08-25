function IsADMemberOf ($strMember, $strGroup) 
{
	#Author: Brenton Keegan
	#this function will return True if the specified name is found within a group. This performs an AD query
	#Parameters:
		#strMember: Member to find - queries the "name" property in AD
		#strGroup: Name of the group
	#Examples:
		#isMemberof("brenton.keegan","IT Staff")
	#NOTE: This function requires the activedirectory module. Run: Import-module activedirectory
	
	[string]$ADMember = Get-ADGroupMember $strGroup | Where {$_.name -eq $strMember} | foreach {$_.name}
	If (!$ADMember) 
	{
		Return $False
	}
	Else
	{
		Return $True
	}

}
