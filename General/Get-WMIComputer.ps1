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
#PREREQ: requires Get-PhysicalVideoController  - also available in this repository
#PREREQ: requires Get-PhysicalNetworkAdapter  - also available in this repository
#PREREQ: requires win32_MonitorDetails WMI Provider: Available here: http://sourceforge.net/projects/wmimonitor/
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
	12. $all - returns all
	#>
    [cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("c")]
		$computer,
		
		[parameter(Mandatory=$false)]
		[alias("h")]
		[switch]$hostname, 	
		
		[parameter(Mandatory=$false)]
		[alias("m")]
		[switch]$model, 
		
		[parameter(Mandatory=$false)]
		[alias("sn")]
		[switch]$serialNumber, 

		[parameter(Mandatory=$false)]
		[switch]$os,
		
		[parameter(Mandatory=$false)]
		[alias("b")]
		[switch]$bios,
	
		[parameter(Mandatory=$false)]
		[alias("p")] #p for Processor
		[switch]$cpu,
		
		[parameter(Mandatory=$false)]
		[alias("ep")] #returns extended info about the cpus
		[switch]$extendedCPUInfo,
		
		[parameter(Mandatory=$false)]
		[alias("r")]
		[switch]$ram,
		
		[parameter(Mandatory=$false)]
		[alias("er")] #returns ram about each chip.
		[switch]$extendedRamInfo,
		
		[parameter(Mandatory=$false)]
		[switch]$hd,
		
		[parameter(Mandatory=$false)]
		[alias("ehd")] 
		[switch]$extendedHDInfo,
		
		[parameter(Mandatory=$false)]
		[alias("rd")] 
		[switch]$removableDisk,
		
		[parameter(Mandatory=$false)]
		[alias("n")]
		[switch]$nic,
		
		[parameter(Mandatory=$false)] #ignored unless -n is set.
		[alias("pno")]
		[switch]$physicalniconly,
			
		[parameter(Mandatory=$false)]
		[alias("v")]
		[switch]$vid,
		
		[parameter(Mandatory=$false)] #ignored unless -v is set.
		[alias("pvo")]
		[switch]$physicalvidonly,
		
		#needs monitorDetails WMI Provider: http://sourceforge.net/projects/wmimonitor/
		[parameter(Mandatory=$false)]
		[alias("mt")]
		[switch]$monitor,
		
		[parameter(Mandatory=$false)]
		[alias("emt")]
		[switch]$extendedMonitorInfo,
		
		[parameter(Mandatory=$false)]
		[alias("o")]
		[switch]$optic,					
		
		[parameter(Mandatory=$false)]
		[alias("s")] #s for sound
		[switch]$audio,				
	
		[parameter(Mandatory=$false)]
		[alias("u")]
		[switch]$usb,
		
		[parameter(Mandatory=$false)]
		[alias("mb")]
		[switch]$motherboard,
		
		[parameter(Mandatory=$false)]
		[alias("a")]
		[switch]$all,
		
		[parameter(Mandatory=$false)]
		[switch]$noUSB, #option to exclude USB because it generates a lot of data that's not often useful
		
		[parameter(Mandatory=$false)]
		[switch]$noExt #option to exclude anything classified as "extended info" - useful to use with -a but not include what might be consider superfluous info
	)
	
        
	if(ping $computer -eq $true)
	{
		$wmiTest = Get-WMIObject win32_bios -ComputerName $computer -EA SilentlyContinue
		If($wmiTest)
		{
			#custom object to store machine info
			$wmiComputer = New-Object PSObject 
			#WMI query if the user selected hostname OR model
			if(($hostname -eq $true) -or ($model -eq $true) -or ($all -eq $true))
			{
				$wmiSystem = Get-WMIObject win32_computersystem -ComputerName $computer
			}
			#hostname
			if(($hostname -eq $true) -or ($all -eq $true))
			{
				$wmiComputer | Add-Member -Membertype NoteProperty -Name Hostname -Value $wmiSystem.name
			}
			#model name
			if(($model -eq $true) -or ($all -eq $true))
			{
				$wmiComputer | Add-Member -Membertype NoteProperty -Name Model -Value $wmiSystem.Model
			}
			#serial number
			if(($serialNumber -eq $true) -or ($all -eq $true))
			{
				$wmiSystemEnclosure = Get-WMIObject win32_systemenclosure -ComputerName $computer
				$wmiComputer | Add-Member -Membertype NoteProperty -Name Serial -Value $wmiSystemEnclosure.SerialNumber
			}				
			#OS
			if(($os -eq $true) -or ($all -eq $true))
			{
				$wmiOS = Get-WMIObject win32_operatingsystem -ComputerName $computer
				$wmiComputer | Add-Member -Membertype NoteProperty -Name OSName -Value $wmiOS.Caption
				$wmiComputer | Add-Member -Membertype NoteProperty -Name OSArchitecture -Value $wmiOS.OSArchitecture
				$wmiComputer | Add-Member -Membertype NoteProperty -Name ServicePack -Value $wmiOS.CSDVersion			
			}
			
			if(($bios -eq $true) -or ($all -eq $true))
			{
				$wmiBIOS = Get-WMIObject win32_bios -ComputerName $computer
				$wmiComputer | Add-Member -Membertype NoteProperty -Name BIOSManufacturer -Value $wmiBIOS.Manufacturer
				$wmiComputer | Add-Member -Membertype NoteProperty -Name BIOSVersion -Value $wmiBIOS.SMBIOSBIOSVersion
			}
				
			#CPU
			if(($cpu -eq $true) -or ($all -eq $true))
			{
				$i = 0 
				$wmiCPU = Get-WMIObject win32_processor -ComputerName $computer
				foreach ($procChip in $wmiCPU)
				{
					$wmiComputer | Add-Member -Membertype NoteProperty -Name CPU$($i) -Value $procChip.name
					if(($extendedCPUInfo -eq $true) -or ($all -eq $true) -and ($noExt -ne $true))
					{
						$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($i)_Clock -value $procChip.MaxClockSpeed
						$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($i)_AddressWidth -value $procChip.AddressWidth
						$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($i)_DataWidth -value $procChip.DataWidth
						$wmiComputer | Add-Member -MemberType NoteProperty -Name CPU$($i)_L2Cache -value $procChip.L2CacheSize
					}
					$i++
				}
			}
			#RAM
			if(($ram -eq $true) -or ($all -eq $true))
			{
				$i = 0 
				$wmiRAM = Get-WMIObject win32_physicalmemory -ComputerName $computer	
				$FormattedRAMCapacity = (ConvertFrom-Bytes -b $wmiSystem.TotalPhysicalMemory -bi)
				$wmiComputer | Add-Member -Membertype NoteProperty -Name Memory -Value $FormattedRAMCapacity
				if(($extendedRamInfo -eq $true) -or ($all -eq $true) -and ($noExt -ne $true))
				{
					$wmiRAMArrary = Get-WMIObject win32_physicalmemoryarray -ComputerName $computer		
					$wmiComputer | Add-Member -Membertype NoteProperty -Name DIMMSlots -Value $wmiRAMArrary.MemoryDevices
					foreach($chip in $wmiRAM)
					{
						$formattedChipCapacity = (ConvertFrom-Bytes -b $chip.Capacity -bi)
						$wmiComputer | Add-Member -Membertype NoteProperty -Name RAMChip$($i)_Size -Value $formattedChipCapacity
						$wmiComputer | Add-Member -Membertype NoteProperty -Name RAMChip$($i)_Speed -Value $chip.Speed
						$i++
					}
				}
			}
					
			#HDs
			if(($hd -eq $true) -or ($all -eq $true))
			{				
				$i = 0 
				$wmiHD = Get-WMIObject win32_logicaldisk -Filter "DriveType=3" -ComputerName $computer
				foreach($harddrive in $wmiHD)
				{
					$formattedHDSize = (ConvertFrom-Bytes -b $harddrive.size -bi)
					$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($i)_ID -Value $harddrive.DeviceID
					$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($i)_Size -Value $formattedHDSize
					if(($extendedHDInfo -eq $true) -or ($all -eq $true) -and ($noExt -ne $true))
					{
						$formattedHDFreespace = (ConvertFrom-Bytes -b $harddrive.freespace -bi)
						$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($i)_Label -Value $harddrive.VolumeName
						$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($i)_Freespace -Value $formattedHDFreespace
						$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($i)_FileSystem -Value $harddrive.FileSystem
						$wmiComputer | Add-Member -Membertype NoteProperty -Name HD$($i)_VolumeSerial -Value $harddrive.VolumeSerialNumber
					}
					$i++
				}
			}
			#removable disks
			if(($removableDisk -eq $true) -or ($all -eq $true))
			{				
				$i = 0 
				$wmiRD = Get-WMIObject win32_logicaldisk -Filter "DriveType=2" -ComputerName $computer
				foreach($rd in $wmiRD)
				{
					$formattedRDSize = (ConvertFrom-Bytes -b $rd.size -bi)
					$wmiComputer | Add-Member -Membertype NoteProperty -Name RemovableDisk$($i)_ID -Value $rd.DeviceID
					$wmiComputer | Add-Member -Membertype NoteProperty -Name RemovableDisk$($i)_Size -Value $formattedRDSize
					if(($extendedHDInfo -eq $true) -or ($all -eq $true))
					{
						$formattedRDFreespace = (ConvertFrom-Bytes -b $rd.freespace -bi)
						$wmiComputer | Add-Member -Membertype NoteProperty -Name RemovableDisk$($i)_Label -Value $rd.VolumeName
						$wmiComputer | Add-Member -Membertype NoteProperty -Name RemovableDisk$($i)_Freespace -Value $formattedRDFreespace
						$wmiComputer | Add-Member -Membertype NoteProperty -Name RemovableDisk$($i)_FileSystem -Value $rd.FileSystem
						$wmiComputer | Add-Member -Membertype NoteProperty -Name RemovableDisk$($i)_VolumeSerial -Value $rd.VolumeSerialNumber
					}
					$i++
				}
			}
			#Nics
			if(($nic -eq $true) -or ($all -eq $true))
			{
				$i = 0 
				if($physicalniconly -eq $false)
				{
					$wmiNIC = Get-WMIObject win32_networkadapter -ComputerName $computer -filter "Adaptertype='Ethernet 802.3'"
				}
				else
				{
					$wmiNIC = Get-PhysicalNetworkAdapter -c $computer
				}
				
				$wmiNICConfig = Get-WMIObject win32_networkadapterconfiguration -ComputerName $computer
				foreach ($networkCard in $wmiNIC)
				{
					if([string]$networkCard.MACAddress -ne "")
					{
						$wmiComputer | Add-Member -Membertype NoteProperty -Name NIC$($i) -Value $networkCard.name
						$wmiComputer | Add-Member -Membertype NoteProperty -Name NIC$($i)_MACAddress -Value $networkCard.MACAddress
						foreach ($nicConfig in $wmiNICConfig)
						{
							if([string]$nicConfig.MACaddress -eq [string]$networkCard.MACAddress)
							{
								$wmiComputer | Add-Member -Membertype NoteProperty -Name NIC$($i)_IPAddress -Value $nicConfig.IPAddress
							}
						}
						$i++
					}
				}
			}
			#video
			if(($vid -eq $true) -or ($all -eq $true))
			{
				if($physicalvidonly -eq $false)
				{
					$wmiVideo = Get-WMIObject win32_videocontroller -ComputerName $computer
				}
				else
				{
					$wmiVideo = Get-PhysicalVideoController -c $computer
				}
				$i = 0 

				foreach ($vidcard in $wmiVideo)
				{
					$VidRamFormatted = (ConvertFrom-Bytes -b $vidcard.AdapterRAM -bi)
					$wmiComputer | Add-Member -Membertype NoteProperty -Name Video$($i)_Name -Value $vidcard.Name
					$wmiComputer | Add-Member -Membertype NoteProperty -Name Video$($i)_Memory -Value $VidRamFormatted
					$wmiComputer | Add-Member -Membertype NoteProperty -Name Video$($i)_Mode -Value $vidcard.VideoModeDescription
					
					$i++
				}
			}
			#monitor
			if(($monitor -eq $true) -or ($all -eq $true))
			{
				$i = 0
				$wmiMonitorDetails = Get-WMIObject win32_MonitorDetails -ComputerName $computer
				$wmiMonitor = Get-WMIObject -namespace "root\wmi" WmiMonitorBasicDisplayParams -ComputerName $computer

				foreach($monitordetail in $wmiMonitorDetails)
				{
					
					$wmiComputer | Add-Member -MemberType NoteProperty -Name Monitor$($i)_Model -Value $monitordetail.model
					if(($extendedMonitorInfo -eq $true) -or ($all -eq $true)-and ($noExt -ne $true))
					{
						$wmiComputer | Add-Member -MemberType NoteProperty -Name Monitor$($i)_SerialNumber -Value $monitordetail.serialnumber
						foreach($desktopmonitor in $wmiMonitor)
						{
							
							$aspectRatio = ($desktopmonitor.MaxHorizontalImageSize / $desktopmonitor.MaxVerticalImageSize)
							$pnpID = $desktopmonitor.InstanceName -replace "^.+\\", ""
							if($pnpID -eq [string]$monitordetail.pnpID + "_0")
							{
								switch($desktopmonitor.VideoInputType)
								{
									0{$connectionType = "Analog"}
									1{$connectionType = "Digital"}
								}
								$wmiComputer | Add-Member -MemberType NoteProperty -Name Monitor$($i)_ConnectionType -Value $connectionType
								$wmiComputer | Add-Member -MemberType NoteProperty -Name Monitor$($i)_AspectRatio -Value $aspectRatio
							}
						}
					}
					$i++
				}
				
				if(($extendedMonitorInfo -eq $true) -or ($all -eq $true) -and ($noExt -ne $true))
				{
					$i = 0

				}				
			}
			#Optical devices
			if(($optical -eq $true) -or ($all -eq $true))
			{
				$i = 0
				$wmiOptical = Get-WMIObject win32_CDROMDrive -ComputerName $computer
				foreach($opticaldrive in $wmiOptical)
				{
					$wmiComputer | Add-Member -MemberType NoteProperty -Name Optical$($i)_ID -Value $opticaldrive.ID
					$wmiComputer | Add-Member -MemberType NoteProperty -Name Optical$($i)_Name -Value $opticaldrive.Name
					$i++
				}
			}
			#sound devices
			if(($audio -eq $true) -or ($all -eq $true))
			{
				$i = 0 
				$wmiAudio = Get-WMIObject win32_sounddevice -ComputerName $computer
				foreach($sounddevice in $wmiAudio)
				{
					$wmiComputer | Add-Member -MemberType NoteProperty -Name Sound$($i)_Name -Value $sounddevice.ProductName
					$i++
				}
			}
			#usb devices
			if(($usb -eq $true) -or ($all -eq $true) -and ($noUSB -eq $false))
			{
				$i = 0
				$wmiUSB = Get-WMIObject Win32_USBControllerDevice |%{[wmi]($_.Dependent)} 
				Foreach($usbdevice in $wmiUSB) 
				{
					$wmiComputer | Add-Member -MemberType NoteProperty -Name USBDevice$($i) -Value $usbdevice.Description
					$i++
				}
			}
			#motherboard
			if(($motherboard -eq $true) -or ($all -eq $true))
			{
				$wmiMotherBoard = Get-WMIObject win32_baseboard
				$wmiComputer | Add-Member -MemberType NoteProperty -Name MotherBoardManufacturer -Value $wmiMotherBoard.Manufacturer
				$wmiComputer | Add-Member -MemberType NoteProperty -Name Name -Value $wmiMotherBoard.Name
				$wmiComputer | Add-Member -MemberType NoteProperty -Name SerialNumber -Value $wmiMotherBoard.SerialNumber
				$wmiComputer | Add-Member -MemberType NoteProperty -Name ProductNumber -Value $wmiMotherBoard.Product
			}
				
			Return $wmiComputer
		}
	}
}
