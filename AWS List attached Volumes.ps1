Import-Module AWSPowerShell

#Pull content from the encrypted text file created in AWS Import Keys.ps1 and save as objects

#$aws_access_key_id = ""
#$aws_secret_access_key = ""
#$aws_session_token = ""
#Sign in to AWS
#Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

$Regions = Get-AWSRegion
$EBSReport = New-Object System.Collections.ArrayList
ForEach ($Region in $Regions) {
    $EBSVolumes = Get-EC2Volume -Region $Region.Region
    ForEach ($EBSVolume in $EBSVolumes) {
        
        $VolumeTags = $EBSVolume.Tags
        $VolumeAttachments = $EBSVolume.Attachment
        $EBSInfo = New-Object -TypeName PSobject
        $EBSInfo | add-member -MemberType NoteProperty -Name "Region" -Value $Region.Region
        $EBSInfo | Add-Member -MemberType NoteProperty -Name "AvailabilityZone" -Value $EBSVolume.AvailabilityZone
        $EBSInfo | add-member -MemberType NoteProperty -Name "VolumeID" -Value $EBSVolume.VolumeID
        $EBSInfo | add-member -MemberType NoteProperty -Name "VolumeType" -Value $EBSVolume.VolumeType
        $EBSInfo | add-member -MemberType NoteProperty -Name "Size" -Value $EBSVolume.Size
        $EBSInfo | Add-Member -MemberType NoteProperty -Name "Encrypted" -Value $EBSVolume.Encrypted
        $EBSInfo | Add-Member -MemberType NoteProperty -Name "CreationTime" -Value $EBSVolume.CreateTime
        $EBSInfo | Add-Member -MemberType NoteProperty -Name "IOPS" -Value $EBSVolume.IOPS
        $EBSInfo | Add-Member -MemberType NoteProperty -Name "SnapshotID" -Value $EBSVolume.SnapshotID
        $EBSInfo | Add-Member -MemberType NoteProperty -Name "State" -Value $EBSVolume.State.Value
        ForEach ($Attachment in $VolumeAttachments){
            $EBSInfo | Add-Member -MemberType NoteProperty -Name $Attachment.
        }
        ForEach ($Tag in $VolumeTags) {
            $EBSInfo | add-member -MemberType NoteProperty -Name $Tag.Key -Value $Tag.Value
        }            
        $EBSReport.Add($EBSInfo) | Out-Null
    }
}