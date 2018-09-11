Import-Module AWSPowerShell

#Pull content from the encrypted text file created in AWS Import Keys.ps1 and save as objects

#$aws_access_key_id = ""
#$aws_secret_access_key = ""
#$aws_session_token = ""
#Sign in to AWS
#Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

$Regions = Get-AWSRegion
$InstanceReport = New-Object System.Collections.ArrayList
ForEach ($Region in $Regions) {
    $Instances = (Get-EC2Instance -Region $Region.Region).Instances
    ForEach ($Instance in $Instances) {
        Write-Output $Instance.PrivateIPAddress
        Write-Output $Instance.InstanceID
        $InstanceTags = $Instance.Tags
        $InstanceInfo = New-Object -TypeName PSobject
        $InstanceInfo | add-member -MemberType NoteProperty -Name "Region" -Value $Region.Region
        $InstanceInfo | add-member -MemberType NoteProperty -Name "InstanceID" -Value $Instance.InstanceID
        $InstanceInfo | add-member -MemberType NoteProperty -Name "InstanceType" -Value $Instance.InstanceType
        $InstanceInfo | add-member -MemberType NoteProperty -Name "PrivateIPAddress" -Value $Instance.PrivateIPAddress
        $InstanceInfo | Add-Member -MemberType NoteProperty -Name "Platform" -Value $Instance.Platform
        $InstanceInfo | Add-Member -MemberType NoteProperty -Name "PublicIPAddress" -Value $Instance.PublicIpAddress
        $InstanceInfo | Add-Member -MemberType NoteProperty -Name "PublicDNS" -Value $Instance.PublicDnsName
        $InstanceInfo | Add-Member -MemberType NoteProperty -Name "VPCID" -Value $Instance.VpcId
        $InstanceInfo | Add-Member -MemberType NoteProperty -Name "SubnetID" -Value $Instance.SubnetId
        $InstanceInfo | Add-Member -MemberType NoteProperty -Name "State" -Value $Instance.State.Name.Value
        ForEach ($Tag in $InstanceTags) {
            $InstanceInfo | add-member -MemberType NoteProperty -Name $Tag.Key -Value $Tag.Value
        }            
        $InstanceReport.Add($InstanceInfo) | Out-Null
    }
}