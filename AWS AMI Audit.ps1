Import-Module AWSPowerShell

#Pull content from the encrypted text file created in AWS Import Keys.ps1 and save as objects

$aws_access_key_id = ""
$aws_secret_access_key = ""
#$aws_session_token = ""
#Sign in to AWS
Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key #-SessionToken $aws_session_token

#Input CSV for list of AMIs to grab info from
$AMIInput = Import-CSV .\AMIs-IN.csv

$Region = "us-east-1"
$AMIReport = New-Object System.Collections.ArrayList
ForEach($AMI in $AMIInput){
    $AMIImage = Get-EC2Image -ImageID $AMI.Asset_Name -Region $Region
    $AMITags = $AMIImage.Tags
    $AMIInfo = New-Object -TypeName PSobject
    $AMIInfo | add-member -MemberType NoteProperty -Name "AMI_ID" -Value $AMI.Asset_Name
    $AMIInfo | add-member -MemberType NoteProperty -Name "AMI_Name" -Value $AMIImage.Name
    ForEach($Tag in $AMITags){
        $AMIInfo | add-member -MemberType NoteProperty -Name $Tag.Key -Value $Tag.Value
    }
    $AMIInfo
    $AMIReport.Add($AMIInfo) | Out-Null
}

$AMIReport | Export-CSV .\AMIReport.CSV -NoTypeInformation