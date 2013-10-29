Get-ADComputer -Filter {OperatingSystem -Like "Windows 7*"} | Select -property DNSHostName | FT
