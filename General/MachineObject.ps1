<#
Get-WMIComputer.ps1 - Returns a custom object containing information about a computer gathered via WMI.

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

#PREREQ: requires ConvertFrom-Bytes - also available in this repository

function Get-WMIComputer
{
        <#
        Description: Returns a custom object containing information about a computer gathered via WMI. 
        1. $computer. Target machine. Should enumerate thru list in loop
        2. $basic - Returns basic info about the machine (hostname, serialnumber, model etc)
        3. $cpu - returns CPU name(s)
			4. $extendedCPUInfo - returns clockspeed, data/address width etc)
			5. $ram - returns total RAM
			6. $extendedRamInfo - returns info on each ram chip
			7. $hd - returns HD ID and size
			8. $extendedHDinfo - returns label and freespace
			9. $nic - returns nic names and MAC addresses
			10. $vid - returns video card information
			11. $optical - returns info on optical disk drives
			12. $audio - returns info on audio devices.	
			11. $usb - returns USB bus info
        #>
        [cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("c")]
		$computer,
		
		[parameter(Mandatory=$false)]
		[switch]$basic, #returns hostname, model, BIOS version, OS version
		
		[parameter(Mandatory=$false)]
		[switch]$cpu,
		
		[parameter(Mandatory=$false)]
		[alias("ecpu")] #returns extended info about the cpus
		[switch]$extendedCPUInfo,
		
		[parameter(Mandatory=$false)]
		[switch]$ram,
		
		[parameter(Mandatory=$false)]
		[alias("eram")] #returns ram about each chip.
		[switch]$extendedRamInfo,
		
		[parameter(Mandatory=$false)]
		[switch]$hd,
		
		[parameter(Mandatory=$false)]
		[alias("ehd")] #returns free/used space.
		[switch]$extendedHDInfo,
		
		[parameter(Mandatory=$false)]
		[switch]$nic,

		[parameter(Mandatory=$false)]
		[switch]$vid,

		[parameter(Mandatory=$false)]
		[switch]$optic,					
		
		[parameter(Mandatory=$false)]
		[switch]$audio,				
	
		[parameter(Mandatory=$false)]
		[switch]$usb
	)

        #custom object to store machine info
        $wmiComputer = New-Object PSObject 
        
        if($basic -eq $true)
	{
		$wmiOS = Get-WMIObject win32_operatingsystem -ComputerName $computer
		$wmiSystem = Get-WMIObject win32_computersystem -ComputerName $computer
		$wmiSystemEnclosure = Get-WMIObject win32_systemenclosure -ComputerName $computer
		$wmiBIOS = Get-WMIObject win32_bios -ComputerName $computer
		$wmiComputer | Add-Member -Membertype NoteProperty -Name Hostname -Value $wmiSystem.name
		$wmiComputer | Add-Member -Membertype NoteProperty -Name Model -Value $wmiSystem.Model
		$wmiComputer | Add-Member -Membertype NoteProperty -Name Serial -Value $wmiSystemEnclosure.SerialNumber
		$wmiComputer | Add-Member -Membertype NoteProperty -Name OSVersion -Value $wmiOS.Version
		$wmiComputer | Add-Member -Membertype NoteProperty -Name BIOSVersion -Value $wmiBIOS.SMBIOSBIOSVersion
        }
        
	#CPU
        if($cpu -eq $true)
	{
		$c = 0 #cpu counter
		$wmiCPU = Get-WMIObject win32_processor -ComputerName $computer
		foreach ($procChip in $wmiCPU)
		{
			$wmiComputer | Add-Member -Membertype NoteProperty -Name CPU$($c) -Value $procChip.name
			if($extendedCPUInfo -eq $true)
			{
				$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($c)_Clock -value $procChip.MaxClockSpeed
				$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($c)_AddressWidth -value $procChip.AddressWidth
				$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($c)_DataWidth -value $procChip.DataWidth
				$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($c)_L2Cache -value $procChip.L2CacheSize
			}
			$c++
		}
	}
	#RAM
	if($ram -eq $true)
	{
		$r = 0 #ram chip counter
		$wmiRAM = Get-WMIObject win32_physicalmemory -ComputerName $computer	
		$FormattedRAMCapacity = (ConvertFrom-Bytes -b $wmiSystem.TotalPhysicalMemory -bi)
		$wmiComputer | Add-Member -Membertype NoteProperty -Name Memory -Value $FormattedRAMCapacity
		if($extendedRamInfo -eq $true)
		{
			$wmiRAMArrary = Get-WMIObject win32_physicalmemoryarray -ComputerName $computer		
			$wmiComputer | Add-Member -Membertype NoteProperty -Name DIMMSlots -Value $wmiRAMArrary.MemoryDevices
			foreach($chip in $wmiRAM)
			{
				$formattedChipCapacity = (ConvertFrom-Bytes -b $chip.Capacity -bi)
				$wmiComputer | Add-Member -Membertype NoteProperty -Name RAMChip$($r)_Size -Value $formattedChipCapacity
				$wmiComputer | Add-Member -Membertype NoteProperty -Name RAMChip$($r)_Speed -Value $chip.Speed
				$r++
			}
		}
	}
			
	#HDs
	if($hd -eq $true)
	{				
		$h = 0 #HD counters
		$wmiHD = Get-WMIObject win32_logicaldisk -Filter "DriveType=3" -ComputerName $computer
		foreach($hd in $wmiHDs)
		{
			$formattedHDSize = (ConvertFrom-Bytes -b $hd.size -bi)
			$formattedHDFreespace = (ConvertFrom-Bytes -b $hd.freespace bi)
			$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($h)_ID -Value $hd.DeviceID
			$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($h)_Size -Value $formattedHDSize
			if($extendedHDInfo -eq $true)
			{
				$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($h)_Label -Value $hd.VolumeName
				$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($h)_Freespace -Value $formattedHDFreespace
			}
			$h++
		}
        }
        
        #Nics
        if($nic -eq $true)
	{
		$n = 0 #NIC counter
		$wmiNIC = Get-WMIObject win32_networkadapter -ComputerName $computer -filter "Adaptertype='Ethernet 802.3'"
		foreach ($networkCard in $wmiNIC)
		{
			$wmiComputer | Add-Member -Membertype NoteProperty -Name NIC$($n) -Value $networkCard.name
			$wmiComputer | Add-Member -Membertype NoteProperty -Name NIC$($n)_MACAddress -Value $networkCard.MACAddress
			$n++
		}
        }
        
        #video
	if($vid -eq $true)
	{
		$v = 0 #Video card counter
		$wmiVideo = Get-WMIObject win32_videocontroller -ComputerName $computer
		foreach ($vidcard in $wmiVideo)
		{
			$VidRamFormatted = (ConvertFrom-Bytes -b $vidcard.AdapterRAM -bi)
			$wmiComputer | Add-Member -Membertype NoteProperty -Name Video$($v)_Name -Value $vidcard.Name
			$wmiComputer | Add-Member -Membertype NoteProperty -Name Video$($v)_Memory -Value $VidRamFormatted
			$v++
		}
        }
        
        #Optical devices
	if($optical -eq $true)
	{
		$o = 0 #optical drive counter
		$wmiOptical = Get-WMIObject win32_CDROMDrive -ComputerName $computer
		foreach($opticaldrive in $wmiOptical)
		{
			$wmiComputer | Add-Member -MemberType NoteProperty -Name Optical$($o)_ID -Value $opticaldrive.ID
			$wmiComputer | Add-Member -MemberType NoteProperty -Name Optical$($o)_Name -Value $opticaldrive.Name
			$o++
		}
	}
	
	#sound devices
        if($audio -eq $true)
	{
		$s = 0 #sound device counter
		$wmiAudio = Get-WMIObject win32_sounddevice -ComputerName $computer
		foreach($sounddevice in $wmiSound)
		{
			$wmiComputer | Add-Member -MemberType NoteProperty -Name Sound$($s)_Name -Value $sounddevice.ProductName
			$s++
		
		}
	}
        
        #usb devices
	if($usb -eq $true)
        {
		$u = 0 #usb counter
		$wmiUSB = Get-WMIObject Win32_USBControllerDevice |%{[wmi]($_.Dependent)} 
		Foreach($usbdevice in $wmiUSB) 
		{
			$wmiComputer | Add-Member -MemberType NoteProperty -Name USBDevice$($u) -Value $usbdevice.Description
			$u++
		}
        }
        
        Return $wmiComputer
}
