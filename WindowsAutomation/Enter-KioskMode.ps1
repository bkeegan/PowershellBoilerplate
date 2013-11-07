<#
Enter-KioskMode.ps1 - Puts a machine in Kiosk mode

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

function Enter-KioskMode
{
	#Written by Brenton Keegan on 11/7/2013
	#this cmdlet puts a machine in "kiosk mode" by replacing the shell with the specified exe/args and automatically logging in with the specified user account.
	#this cmdlet is designed to use a domain logon and to be paired with a GPO that applies additional restrictions.
	#Please note, this method is insecure as in a username/password will be stored in clear-text in the registry and wherever you specified the parameters.
	#1. $pathToExe - full path (with arguments if applicable) of kiosk application - will replace the explorer shell.
	#2. $user - username to autologon as
	#3. $password - password of the specified username
	#4. $domain - user's domain
	
	[cmdletbinding()]

	Param
	(
		[parameter(Mandatory=$true)]
		[alias("exe")]
		[alias("e")]
		[string]$pathToExe,
		
		[parameter(Mandatory=$true)]
		[alias("user")]
		[alias("u")]
		[string]$domainuser,
		
		[parameter(Mandatory=$true)]
		[alias("pwd")]
		[alias("p")]
		[string]$password,

		[parameter(Mandatory=$true)]
		[alias("d")]
		[string]$domain
	)
	#replace shell with specified executable
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name Shell -Value $pathToExe
	#set the default logon, user, domain
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $domainuser
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName -Value $domain
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $password
	#enable autologon
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
}
