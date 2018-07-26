$Computer = "localhost"
get-MemoryUsage -Computer $Computer

#Function will obtain CPU usage average of localhost
Function Get-CPUusageAverage {
    param($Computer)
    Get-WmiObject -computername $Computer -class win32_processor | Measure-Object -property LoadPercentage -Average | Select-Object Average
}
$Computer = "localhost"
Get-CPUusageAverage -Computer $Computer