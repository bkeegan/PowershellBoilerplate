<# 
.SYNOPSIS 
	Returns the object for a Special Folder.
.DESCRIPTION 
	On Microsoft Windows, a special folder is a folder which is presented to the user through an interface as an abstract concept instead of an absolute folder path. They are fetched based on numerical ID. list of IDs can be found here:
	http://code.snapstream.com/api/bm11/SnapStream.Util.CSIDL.html
.NOTES 
    File Name  : Get-SpecialFolderObject.ps1 
    Author     : Brenton keegan - brenton.keegan@gmail.com 
    Licenced under GPLv2  
.LINK 
	https://github.com/bkeegan/PowershellBoilerplate
    License: https://github.com/bkeegan/PowershellBoilerplate/blob/master/LICENSE.md
.EXAMPLE 
	Get-SpecialFolderObject -id 0
	This command will return the special folder object for ID 0 (User's Desktop folder)

#> 

function Get-SpecialFolderObject
{
	[cmdletbinding()]
	Param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[alias("i")]
		[alias("id")]
		$CSIDL
	)

    $shellObject = new-object -com "shell.application"
    $folder = $shellObject.NameSpace($CSIDL)
    $specialFolder = $folder.self
	Return $specialFolder
}
