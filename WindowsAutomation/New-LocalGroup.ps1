function New-LocalGroup
{
	<#Description: This cmdlet creates a group on the specified machine. 
	1. $groupName - name of the group 
	2. $description - description of group (default is empty string)
	3. $computer - computer to created group on - default is the local machine.

	#>
	
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("g")]
		[string]$groupName,
		
		[parameter(Mandatory=$false)]
		[alias("d")]
		[string]$description="",
		
		[parameter(Mandatory=$false)]
		[alias("c")]
		[string]$computer="$env:COMPUTERNAME"
		
	)

	[ADSI]$LogonServer="WinNT://$computer"
	$groups = ($LogonServer.psbase.children | Where-Object {$_.psBase.schemaClassName -eq "Group"} | Select-Object -expand Name)
	$result = $groups -contains  $groupName
	
	if(!$result)
	{
			$groupObject = $LogonServer.Create("Group",$groupName)
			$groupObject.Put("Description",$description)
			$groupObject.SetInfo()
	}
}
