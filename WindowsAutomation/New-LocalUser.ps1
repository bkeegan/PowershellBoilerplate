<#
New-LocalUser.ps1 - Creates a local user account. 

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

function New-LocalUser
{
        #Written by Brenton Keegan on 8/12/13
		#Modified on 11/6/13
			#utilizes cmdletbinding
			#removed hungarian variable notation
			#added force switch

        #this function creates a local user on the specified machine (default is the local machine)
        #Parameters:
        #1.$username - username of the new user
        #2.$pwd - password of the new user
        #3.$description - description of user account.
        #4.$computer - computer to create the user on (Default is the local machine)
		#5.$force - if account already exists it will delete account and recreate
		
		[cmdletbinding()]

		Param
		(
			[parameter(Mandatory=$true,ValueFromPipeline=$true)]
			[alias("user")]
			[alias("u")]
			[string]$username,
			
			[parameter(Mandatory=$true)]
			[alias("pwd")]
			[alias("p")]
			[string]$password,
			
			[parameter(Mandatory=$false)]
			[alias("d")]
			[string]$description="Local User Account",
			
			[parameter(Mandatory=$false)]
			[alias("machine")]
			[alias("c")]
			[string]$computer="$env:COMPUTERNAME",
			
			[parameter(Mandatory=$false)]
			[alias("f")]
			[switch]$force
		)
        
		[ADSI]$logonServer="WinNT://$computer"
		$localUsers = ($logonServer.psbase.children | Where-Object {$_.psBase.schemaClassName -eq "User"} | Select-Object -expand Name)
		$result = $localUsers -contains  $username
		
		if(($result) -and ($force -eq $true))
		{
			$logonServer.Delete("user",$username)
		}
		
		if((!$result) -or ($force -eq $true))
		{
				$userAcct = $logonServer.Create("User",$username)
				$userAcct.SetPassword($password)
				$userAcct.Put("Description",$description)
				$userAcct.SetInfo()
		}
}
