#REQUIRES function ConvertBytes (also in this repository)

Function HTMLDiskReport($strComputer,$strFile="c:\temp\diskreport.html",$bolFirst=$true,$strTitle = "Disk Usage Report - " + (Get-Date -format g))
{
	<#	
		Author: Brenton Keegan - Written on 8/24/2013
		Description: This function build a HTML report enumerating each disk (where WMI reports drivetype=3, ie local disk) and outputs the used to total space as a color-coded percentage bar in an html document.
		This script does NOT make used of the Powershell native ConvertTo-HTML function as I found this function too limiting. Rather this simply assembles an HTML file manually. 
		Maybe there's a way to get more flexiblity out of the ConvertTo-HTML function but I couldn't find a way.
		You can encompass this script in a loop thru a subnet, list of machines pulled from AD or whatever group of IPs/Machinenames you want to target.
		
		$strComputer - computer to pull information from - Use IP or hostname
		$strFile - file to put HTML report. Default is C:\temp\diskreport.html
		$bolFirst - Set this if this is the FIRST entry written by this function. Default is $true. This writes initial html header information. HTML will be invalid if not set on the first run. If set on subsequent run previously written information will be erased.
		$strTitle - Title of HTML document - also used in top banner. Default is Disk Usage Report - %datestamp%
		
	#>
	
	#stores information from WMI query in $objResults
	$objResults = get-WmiObject win32_logicaldisk -filter "DriveType=3" -ComputerName $strComputer 
	#HTML doctype - could put this in as a function parameter but I'm far too lazy.
	$strDocType = "<!DOCTYPE html PUBLIC `"-//W3C//DTD XHTML 1.0 Strict//EN`"  `"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd`">"
	#CSS as a here-string so formatting stays nice and readable
#NOTE: script breaks if you ident this here-string. here-strings seem to be really finicky (makes sense as here-strings by definition are taking the value AND the formatting)
$strCSS = @"
<style>
.header{
	background-color:#000000;
	width=100%;
	text-decoration:none;
	color:white;
	font-family:Arial, Helvetica, sans-serif;
	font-size:16pt;
	font-weight:bolder;
	font-style:normal;
	}
.subheader{
	background-color:#777777;
	width=100%;
	text-decoration:none;
	color:white;
	font-family:Arial, Helvetica, sans-serif;
	font-size:16pt;
	font-weight:bolder;
	font-style:normal;
	}
	}
a:link{
	text-decoration:underline;
	color:#527ca4;
	font-family:Arial,Helvetica,sans-serif;
	font-size:14pt;
	font-weight:normal;
	font-style:italic;
	}
a:visited{
	text-decoration:underline;
	color:#385774;
	font-family:Arial,Helvetica,sans-serif;
	font-size:14pt;
	font-weight:normal;
	font-style:italic;
	}
.itemdiv{
	PADDING-TOP:2px;
	PADDING-RIGHT:2px;
	PADDING-BOTTOM:2px;
	FLOAT:Left;
	Width:25%;
	}
.bulletdiv{
	PADDING-TOP:2px;
	PADDING-RIGHT:2px;
	PADDING-BOTTOM:2px;
	FLOAT:Left;
	Width:20px;
	font-size:1.2em;
	font-weight:bold;
	}
.indentdiv{
	FLOAT:Left;
	Width:25%
	}
	
.linediv{
	float:left;
	PADDING-TOP:2px;
	PADDING-BOTTOM:2px;
	Width:100%;
	}
#progress{
	width: 500px;   
	border: 1px solid black;
	position: relative;
	padding: 3px;
	FLOAT:Left;
}

#percent{
	position: absolute;   
	left: 50%;
}

#bar{
	height: 20px;

	FLOAT:Left;
}
</style>
"@

	If($bolFirst -eq $true)
	{
		#If the $bolFirst is set to $true it will write the doctype, header, css and top banner in the body
		$strDocType | Out-File $strFile #append flag not set - will overwrite if $strFile already exists all following writes will append
		"<head>" | Out-File -Append $strFile
		"<title>$strTitle</title>" | Out-File -Append $strFile
		$strCSS | Out-File -Append $strFile
		"<div class=header>$strTitle</div>" | Out-File -Append $strFile
	}
	"<div class=subheader>$strComputer</div>" | Out-File -Append $strFile
	Foreach ($drive in $objResults) 
	{
		#gets total size and used space converted to most appropriate measurement (smallest number not smaller than 1)
		$TotalSize = ConvertDriveUnits($drive.size)
		$UsedSpace = $drive.size - $drive.freespace
		$UsedSpace = ConvertDriveUnits($UsedSpace)
		#gets used space as a percentage
		$intPercentage = 100 - ($drive.freespace / $drive.size) * 100
		#determines what color to makes the percentage bar. I thought about making it shift between green and red based on the precise percentage but decided not to do that for now. 
		#strColor stores the hex value of the color to inject into the HTML div style
		switch($intPercentage)
		{
			{$_ -ge 90}{$strColor = "#FF0000"} #red
			{($_ -ge 85 -and $_ -lt 90)}{$stColor = "#FF7700"} #orange
			{($_ -ge 75 -and $_ -lt 85)}{$strColor = "#FFFF00"} #yellow
			default{$strColor = "#00FF00"} #green
		}
		#Writes a line for each drive it found with the DriveID and Used/Total over a percentage bar colored accordingly. Width of the percentage bar is directly derived from the numbers pulled from WMI.
		"<div class=linediv><div class=indentdiv></div><div class=bulletdiv>$($drive.DeviceID)</div><div id=progress><span id=percent>$UsedSpace\$TotalSize)</span><div id=bar style=width:$intPercentage%;background-color:$strColor></div></div></div>" | Out-file -Append $strFile

	}
}
