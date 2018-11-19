Import-Module AWSPowerShell.NetCore

$aws_access_key_id = ""
$aws_secret_access_key = ""
$aws_session_token = ""

#Sign in to AWS
Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

$InstanceList = Get-Content .\InstanceInput.txt
$SecurityGroupList = Import-CSV .\SGLogs.csv
$Region = "us-east-1"

ForEach($Instance in $Instances){
    $SecurityGroups = ($SecurityGroupList | Where-Object{$_.InstanceID -eq $Instance}).SGID
    Edit-EC2InstanceAttribute -InstanceId $Instance -Region $Region -Group $SecurityGroups
}