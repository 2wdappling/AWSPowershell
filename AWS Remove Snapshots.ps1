#Remove AWS Snapshots using CSV -- Drew Appling 07/25/2018
#Required CSV fields = SnapshotID, Region
#Fill in Access Key ID, Secret Access Key and Session Token
### To do: check for snapshot prior to deletion, look up better ways of checking if it's attached to an AMI
### Better reporting

Import-Module AWSPowerShell

#Pull content from the encrypted text file created in AWS Import Keys.ps1 and save as objects
$access_key = Get-Content .\encrypted.txt
$aws_access_key_id = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($access_key[0]))
$aws_secret_access_key = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($access_key[1]))
$aws_session_token = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($access_key[2]))

#Required fields SnapshotID, Region
$Snapshots = Import-Csv .\snapshots.csv

#Sign in to AWS
Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

#Create an Object colletion, this will be used for reporting and will export to a CSV and is similar to a table
$SnapshotStatusCollection = New-Object System.Collections.ArrayList

#Place keeping and used for reporting
$NumRecords = ($Snapshots | Measure-Object).Count
$Num = 1

#Loop through each row in CSV
ForEach ($Snapshot in $Snapshots) {
    #This is here mostly for console output and progress monitoring
    Write-Output "$Num of $NumRecords"":$Snapshot"
    Try {
        #Try to remove the Snapshot
        Remove-EC2Snapshot -SnapshotId $Snapshot.SnapshotID -Region $Snapshot.Region -Confirm:$false
    }
    Catch {
        #Create object to be added to the $SnapshotStatusCollection object collection, this is pretty much a row in a table
        $SnapshotStatus = New-Object -TypeName PSobject
        $SnapshotStatus | add-member -MemberType NoteProperty -Name "SnapshotID" -Value $Snapshot.SnapshotID
        $SnapshotStatus | Add-Member -MemberType NoteProperty -Name "Region" -Value $Snapshot.Region
        #This will be empty unless the Snapshot is attached to an AMI, Remove-EC2Snapshot errors out and this grabs the AMI name if there's an error
        $SnapshotStatus | Add-Member -MemberType NoteProperty -Name "AMI" -Value $_.ToString().split(' ')[8]
        #Add the $SnapshotStatus object to $SnapshotStatusCollection object collection
        $SnapshotStatusCollection.Add($Snapshotstatus) | Out-Null
    }
    $Num += 1
}

#Save report as CSV, AMI column populates if the snapshot is attached to an AMI
$SnapshotStatusCollection | export-csv .\Snapshotreport.csv -notypeinformation