<#
Get-PhysicalVideoController.ps1 - performs a WMI query filtering out any video controllers not attached to a physical bus

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

function Get-PhysicalVideoController
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$false,ValueFromPipeline=$true)]
		[alias("c")]
		[string]$computer
	)
		
	if([string]$computer -eq "")
	{
		$computer = "localhost"
	}

	$return = Get-WMIObject -ComputerName $computer win32_videocontroller | Where {$_.PNPDeviceID -notmatch "[ROOT|SW]\\.+"}
	Return $return
}
