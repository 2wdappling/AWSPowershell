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
$IAMRoleARN = ""
$IAMRoleNew = "SSM-WorkerManagement"

$Regions = Get-AWSRegion
ForEach ($Region in $Regions) {
    $Instances = (Get-EC2Instance -Region $Region.Region).Instances
    ForEach ($Instance in $Instances) {
        $InstanceTagValue = ($Instance.Tags | ForEach-Object{If($_.Key -eq $Tag){$_.Value}}).ToString()
        $InstanceIAMARN = $Instance.IamInstanceProfile.Arn
        If(($InstanceTagValue -eq $TagValue)-and($InstanceIAMARN -eq $IAMRoleARN)){            
            Get-EC2IamInstanceProfileAssociation -Region $Region.Region -Filter @{name='instance-id'; values=$Instance.InstanceId} | Unregister-EC2IamInstanceProfile -Region $Region.Region 
            Register-EC2IamInstanceProfile -InstanceID $Instance.InstanceID -Region $Region.Region -IamInstanceProfile_Name $IAMRoleNew
        }
        $InstanceTagValue = $null
        $InstanceIAMARN = $null       
    }
}