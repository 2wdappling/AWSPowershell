#function will obtain disk space available for localhost
Function get-CPercentFree {
    param($Computer)
    Get-WmiObject -Class win32_Volume -ComputerName $Computer -Filter "DriveLetter = 'C:'" |
        Select-object @{Name = "C PercentFree"; Expression = { “{0:N2}” -f (($_.FreeSpace / $_.Capacity) * 100) }
    }
}
$Computer = "localhost"
get-CPercentFree -Computer $Computer