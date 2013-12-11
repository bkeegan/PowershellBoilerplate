<#
Get-WMIPhysicalNicConfig.ps1 - Gets the nic configuration from Nics attached to hardware buses.

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

#PREREQ: Requires Get-PhysicalNetworkAdapter - available in this repository

function Get-WMIPhysicalNicConfig
{
    [cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$false,ValueFromPipeline=$true)]
		[alias("c")]
		[string]$computer
	)
	
	if($computer -eq "")
	{
		$computer = "localhost"
	}
	
	$nics = Get-PhysicalNetworkAdapter -c $computer
	$nicConfigs = Get-WMIObject win32_networkadapterconfiguration -ComputerName $computer
	
	
	foreach($nicConfig in $nicConfigs)
	{
		if([string]$nicConfig.MACAddress -ne "")
		{
			foreach($nic in $nics)
			{

				If([string]$nicConfig.MACAddress -eq [string]$nic.MACAddress)
				{
					Return $nicConfig
				}
			
			}
		}
	
	}
}
