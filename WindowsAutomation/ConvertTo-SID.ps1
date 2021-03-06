<#
ConvertTo-SID.ps1 - Returns SID of local user account

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

function ConvertTo-SID
{
	#written by Brenton keegan on 11/6/2013 - Returns SID of local user account
	#1. $username - name of local user account to get the SID of.

	[cmdletbinding()]

	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("user")]
		[alias("u")]
		[string]$username
		
	)

	$user = New-Object System.Security.Principal.NTAccount($username)
	$sid = $user.Translate([System.Security.Principal.SecurityIdentifier])
	Return $sid.Value
}
