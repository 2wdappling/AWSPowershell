Import-Module AWSPowerShell

#Pull content from the encrypted text file created in AWS Import Keys.ps1 and save as objects

$aws_access_key_id = ""
$aws_secret_access_key = ""
$aws_session_token = ""
#Sign in to AWS
Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

#Tag to search for
$Tag = "HPC_Role"
$TagValue = "worker"

#IAMRoleARN to search for, use the instance profile arn when searching instances
# arn:aws:iam::accountnumber:instance-profile/iamrolename
$IAMRoleARN = ""


$Regions = Get-AWSRegion
$InstanceReport = New-Object System.Collections.ArrayList
ForEach ($Region in $Regions) {
    $Instances = (Get-EC2Instance -Region $Region.Region).Instances
    ForEach ($Instance in $Instances) {
        $InstanceTagValue = ($Instance.Tags | ForEach-Object{If($_.Key -eq $Tag){$_.Value}}).ToString()
        $InstanceIAMARN = $Instance.IamInstanceProfile.Arn
        If(($InstanceTagValue -eq $TagValue)-and($InstanceIAMARN -eq $IAMRoleARN)){            
                Write-Output $Instance.PrivateIPAddress
                Write-Output $Instance.InstanceID
                $InstanceInfo = New-Object -TypeName PSobject
                $InstanceInfo | add-member -MemberType NoteProperty -Name "Region" -Value $Region.Region
                $InstanceInfo | add-member -MemberType NoteProperty -Name "InstanceID" -Value $Instance.InstanceID
                $InstanceInfo | add-member -MemberType NoteProperty -Name "PrivateIPAddress" -Value $Instance.PrivateIPAddress
                $InstanceInfo | add-member -MemberType NoteProperty -Name $Tag -Value ($Instance.Tags | ForEach-Object{If($_.Key -eq $Tag){$_.Value}}).ToString()
                $InstanceInfo | add-member -MemberType NoteProperty -Name "IAMRole" -Value (($Instance.IamInstanceProfile).arn).tostring()
                $InstanceReport.Add($InstanceInfo) | Out-Null            
        }
                
    }
}