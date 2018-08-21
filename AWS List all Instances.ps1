Import-Module AWSPowerShell

#Pull content from the encrypted text file created in AWS Import Keys.ps1 and save as objects

$aws_access_key_id = ""
$aws_secret_access_key = ""
$aws_session_token = ""
#Sign in to AWS
Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

#Need to find a way to pull this info from AWS as new instances will require manual addition
$Regions = Get-AWSRegion
$InstanceReport = New-Object System.Collections.ArrayList
ForEach ($Region in $Regions) {
    $Instances = (Get-EC2Instance -Region $Region.Region).Instances
    ForEach ($Instance in $Instances) {
                Write-Output $Instance.PrivateIPAddress
                Write-Output $Instance.InstanceID
                $InstanceInfo = New-Object -TypeName PSobject
                $InstanceInfo | add-member -MemberType NoteProperty -Name "Region" -Value $Region.Region
                $InstanceInfo | add-member -MemberType NoteProperty -Name "InstanceID" -Value $Instance.InstanceID
                $InstanceInfo | add-member -MemberType NoteProperty -Name "PrivateIPAddress" -Value $Instance.PrivateIPAddress
                $InstanceInfo | add-member -MemberType NoteProperty -Name "Name" -Value ($Instance.Tags | ForEach-Object{If($_.Key -eq "Name"){$_.Value}}).ToString()
                
                $InstanceReport.Add($InstanceInfo) | Out-Null
           
                
    }
}