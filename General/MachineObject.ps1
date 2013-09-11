Function MachineObject($strComputer,$arrDatastore,$bolUSB=$true,$bolLegacy=$true,$hshCreds="",$bolImpersonate=$true)
{
		<#
		Description: This function collects information about a machine and stores it in a custom object and stores it in an array of objects. 
		This function is meant to be be called in a loop thru several targets - be it a subnet or a list of machines from an AD query. 
		This function will export a CSV with all machines it was able to perform a WMI query on. This script collects fairly detailed information and it handles variable amounts of data being returned from each machine.
		For example if one machine has 4 ram chips and another 2, the machine with only 2 will have properties added for the other 2 chips with "N/A" as the value.
		If one machine in a list of targets has 16 ram chips then ALL computers will have properties for 16 indivudal ramchips however chips not present will have values of "N/A"
		This applies for any set of data with a variable amount of returns (ie, multiple HDs, multiple CPUs, etc)
		
		#Known Bug: I haven't been able to find a good way to store the properties. So the final CSV might have properties out of order. (ie, it might look something like this CPU,HD, RamChip1,RamChip2,Video,NIC,RamChip3). Data won't be malformed - just not ordered.
		It's fairly easy to reorder the fields in Excel/LibreOffice after the fact - but me a little bit but it will have to do until I find a way to sort them.
		
		Parameters:
		1. $strComputer. Target machine. Should enumerate thru list in loop
		2. $arrDatastore - array to store all objects. You should declare an array outside of this function and pass it thru this function. This function will add the object that corresponds to the machine and return the array when it's done.
		3. $bolUSB - report connected USB devices (includes Hubs) - default is true - set this to false to not report on connected usb devices (this can generate a lot of information so I made this one so you can toggle it)
		4. $bolLegacy (default is $true) - will use DCOM style method of communicating with target machine. set to $false to use PSremoting/WS-MAN instead.
		5. TODO - $hshCreds - hashtable of credentials to try. By default it will always try to impersonate unless you set $bolImpersonate to $false. Be default this is set to an empty string. If it's not empty it will attempt to enumerate thru the credential pairs 
		6. TODO - $bolImpersonate - Will not try to impersonate credentials that the script is running as when making WMI connections. If this is set to false than a hashtable must be specified. If set to true it will attempt to impersonate BEFORE iterating thru specified credential list
		#>
		
		#WMI Objects
		if ($bolLegacy -eq $true)
		{
			$objHDs = Get-WMIObject win32_logicaldisk -Filter "DriveType=3" -ComputerName $strComputer
			$objOS = Get-WMIObject win32_operatingsystem -ComputerName $strComputer
			$objSystem = Get-WMIObject win32_computersystem -ComputerName $strComputer
			$objSystemEnclosure = Get-WMIObject win32_systemenclosure -ComputerName $strComputer
			$objBIOS = Get-WMIObject win32_bios -ComputerName $strComputer
			$objRAM = Get-WMIObject win32_physicalmemory -ComputerName $strComputer
			$objRAMArrary = Get-WMIObject win32_physicalmemoryarray -ComputerName $strComputer
			$objNIC = Get-WMIObject win32_networkadapter -ComputerName $strComputer -filter "Adaptertype='Ethernet 802.3'"
			$objCPU = Get-WMIObject win32_processor -ComputerName $strComputer
			$objVideo = Get-WMIObject win32_videocontroller -ComputerName $strComputer
			$objOptical = Get-WMIObject win32_CDROMDrive -ComputerName $strComputer
			$objSound = Get-WMIObject win32_sounddevice -ComputerName $strComputer
		
		if($bolUSB -eq $true)
		{
			$objUSB = Get-WMIObject Win32_USBControllerDevice |%{[wmi]($_.Dependent)}
		}
		
		}
		Else
		{
			$objHDs = Get-CIMInstance win32_logicaldisk -Filter "DriveType=3" -ComputerName $strComputer
			$objOS = Get-CIMInstance win32_operatingsystem -ComputerName $strComputer
			$objSystem = Get-CIMInstance win32_computersystem -ComputerName $strComputer
			$objSystemEnclosure = Get-CIMInstance win32_systemenclosure -ComputerName $strComputer
			$objBIOS = Get-CIMInstance win32_bios -ComputerName $strComputer
			$objRAM =Get-CIMInstance win32_physicalmemory -ComputerName $strComputer
			$objRAMArrary = Get-CIMInstance win32_physicalmemoryarray -ComputerName $strComputer
			$objNIC = Get-CIMInstance win32_networkadapter -ComputerName $strComputer -filter "Adaptertype='Ethernet 802.3'"
			$objCPU = Get-CIMInstance win32_processor -ComputerName $strComputer
			$objVideo = Get-CIMInstance win32_videocontroller -ComputerName $strComputer
			$objOptical = Get-CIMInstance win32_CDROMDrive -ComputerName $strComputer
			$objSound = Get-CIMInstance win32_sounddevice -ComputerName $strComputer
		
		if($bolUSB -eq $true)
		{
			$objUSB = Get-CIMInstance Win32_USBControllerDevice |%{[wmi]($_.Dependent)}
		}
		
		}

		#format RAM measurements
		
		#$FormattedRAM 
		
		$c = 0 #cpu counter
		$r = 0 #ram chip counter
		$n = 0 #NIC counter
		$h = 0 #HD counters
		$b = 0 #Video card counter
		$o = 0 #optical drive counter
		$u = 0 #usb counter
		$s = 0 #sound device counter
		
		#custom object to store machine info
		$objSysinfo = New-Object PSObject 
		
		#basic info - hostname, model, serial, OS
		$objSysinfo | Add-Member -Membertype NoteProperty -Name Hostname -Value $objSystem.name
		$objSysinfo | Add-Member -Membertype NoteProperty -Name Model -Value $objSystem.Model
		$objSysinfo | Add-Member -Membertype NoteProperty -Name Serial -Value $objSystemEnclosure.SerialNumber
		$objSysinfo | Add-Member -Membertype NoteProperty -Name OSVersion -Value $objOS.Version
		
		#processors
		Foreach ($procchip in $objCPU)
		{
			$objSysinfo | Add-Member -Membertype NoteProperty -Name CPU$($c) -Value $procchip.name
			$objSysInfo | Add-Member -MemberType NoteProperty -Name CPU$($c)_Clock -value $procchip.MaxClockSpeed
			$objSysInfo | Add-Member -MemberType NoteProperty -Name CPU$($c)_AddressWidth -value $procchip.AddressWidth
			$objSysInfo | Add-Member -MemberType NoteProperty -Name CPU$($c)_DataWidth -value $procchip.DataWidth
			$objSysInfo | Add-Member -MemberType NoteProperty -Name CPU$($c)_L2Cache -value $procchip.L2CacheSize
			$c++
			
		}
		$FormattedRAM = ConvertBytes($objSystem.TotalPhysicalMemory)
		$objSysinfo | Add-Member -Membertype NoteProperty -Name Memory -Value $FormattedRAM
		$objSysinfo | Add-Member -Membertype NoteProperty -Name DIMMSlots -Value $objRAMArrary.MemoryDevices

		Foreach($chip in $objRAM)
		{
			$FormattedChipRAM = ConvertBytes($chip.Capacity)
			$objSysinfo | Add-Member -Membertype NoteProperty -Name RAMChip$($r)_Size -Value $FormattedChipRAM
			$objSysinfo | Add-Member -Membertype NoteProperty -Name RAMChip$($r)_Speed -Value $chip.Speed
			$r++
	
		}
		
		Foreach($hd in $objHDs)
		{
			$FormattedHDSize = ConvertBytes($hd.size)
			$FormattedHDFreespace = ConvertBytes($hd.freespace)
			$objSysinfo | Add-Member -Membertype NoteProperty -Name HD$($h)_ID -Value $hd.DeviceID
			$objSysinfo | Add-Member -Membertype NoteProperty -Name HD$($h)_Label -Value $hd.VolumeName
			$objSysinfo | Add-Member -Membertype NoteProperty -Name HD$($h)_Freespace -Value $FormattedHDFreespace
			$objSysinfo | Add-Member -Membertype NoteProperty -Name HD$($h)_Size -Value $FormattedHDSize
			$h++
		
		}
		
		#Nics
		Foreach ($nic in $objNIC)
		{
			$objSysinfo | Add-Member -Membertype NoteProperty -Name NIC$($n) -Value $nic.name
			$objSysinfo | Add-Member -Membertype NoteProperty -Name NIC$($n)_MACAddress -Value $nic.MACAddress
			$n++
		}
		
		#video
		Foreach ($vidcard in $objVideo)
		{
			$VidRamFormatted = ConvertBytes($vidcard.AdapterRAM)
			$objSysinfo | Add-Member -Membertype NoteProperty -Name Video$($v)_Name -Value $vidcard.Name
			$objSysinfo | Add-Member -Membertype NoteProperty -Name Video$($v)_Memory -Value $VidRamFormatted
			$v++
		}
		
		#Optical devices
		Foreach($opticaldrive in $objOptical)
		{
			$objSysinfo | Add-Member -MemberType NoteProperty -Name Optical$($o)_ID -Value $opticaldrive.ID
			$objSysinfo | Add-Member -MemberType NoteProperty -Name Optical$($o)_Name -Value $opticaldrive.Name
			$o++
		
		}
		
		#usb devices
		if($bolUSB -eq $true)
		{
			Foreach($usbdevice in $objUSB) 
			{
				$objSysinfo | Add-Member -MemberType NoteProperty -Name USBDevice$($u) -Value $usbdevice.Description
				$u++
			
			}
		}
		
		#sound devices
		Foreach($sounddevice in $objSound)
		{
			$objSysinfo | Add-Member -MemberType NoteProperty -Name Sound$($s)_Name -Value $sounddevice.ProductName
			$s++
		
		}
		
		
		$objSysinfo | Add-Member -Membertype NoteProperty -Name BIOSVersion -Value $objBIOS.SMBIOSBIOSVersion

		Return $ObjSysInfo
}
