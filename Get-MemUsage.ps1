#function will obtain MemoryUsage of localhost.
$Computer = "localhost"
Function get-MemoryUsage {
    param($Computer)
    Get-WmiObject -Class win32_operatingsystem -computername $Computer |
        Select-Object @{Name = "MemoryUsage"; Expression = { “{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) * 100) / $_.TotalVisibleMemorySize) }
    }
}


