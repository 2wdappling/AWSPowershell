#AWS Find Instance, searches each region for instance ID and returns instance details
#Drew Appling 07/26/2018

Import-Module AWSPowerShell

#Pull content from the encrypted text file created in AWS Import Keys.ps1 and save as objects
$access_key = Get-Content .\encrypted.txt
$aws_access_key_id = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($access_key[0]))
$aws_secret_access_key = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($access_key[1]))
$aws_session_token = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($access_key[2]))

#Sign in to AWS
Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

#Need to find a way to pull this info from AWS as new instances will require manual addition
$Regions = @("us-east-1", "us-east-2", "us-west-1", "us-west-2", "ap-northeast-1", "ap-northeast-2", "ap-northeast-3", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ca-central-1", "cn-north-1", "cn-northwest-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3","sa-east-1")
#(Get-AWSRegion).Name
#InstanceID to search for
$InstanceID = "insertIDhere"

#Operator for tracking if the instance has been found
$InstanceFound = $false
do {
    ForEach($Region in $Regions){
        $Instance = Get-EC2Instance -InstanceId $InstanceID -Region $Region
        if($Instance){
            $InstanceFound = $true
            $Instance
            $Region
        }
    }
} until ($InstanceFound -eq $true)
