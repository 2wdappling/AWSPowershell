## Add Instance to SG
## Written 11/19/2018
## Drew Appling
## 2nd Watch

Import-Module AWSPowerShell.NetCore

$aws_access_key_id = ""
$aws_secret_access_key = ""
$aws_session_token = ""

#Sign in to AWS
Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -SessionToken $aws_session_token

$InstanceList = Get-Content .\InstanceInput.txt
$VPC_SGList = Import-CSV .\VPC-SG.csv
$Region = "us-east-1"
$SGLogs = New-Object System.Collections.ArrayList
$ScriptLogs = New-Object System.Collections.ArrayList

ForEach ($Instance in $InstanceList) {
    #Grab the AWS Instance
    Write-Output "-------Starting Script on $Instance-------"
    Write-Output "Pulling Instance $Instance from AWS"
    $AWSInstance = (Get-EC2Instance -InstanceId $Instance -Region $Region).Instances
    #If the instance exists
    If ($AWSInstance) {
        Write-Output "Instance Found"        
        $VPC = $AWSInstance.VPCID
        $SecurityGroups = $AWSInstance.SecurityGroups
        $SGCount = ($SecurityGroups | Measure-Object).Count
        #Log existing SGs
        Write-Output "$SGCount Security Groups Found"        
        Write-Output "Logging Existing Security Groups"
        ForEach ($SGID in $SecurityGroups) {
            $SGLog = New-Object -TypeName PSobject
            $SGLog | Add-Member -MemberType NoteProperty -Name "InstanceID" -Value $Instance
            $SGLog | Add-Member -MemberType NoteProperty -Name "SGID" -Value $SGID.GroupID
            $SGLog | Add-Member -MemberType NoteProperty -Name "VPCID" -Value $VPC
            $SGLogs.Add($SGLog)
            $SGLog
        }        
        $SG = $null   
        $SGtoAdd = ($VPC_SGList | Where-Object {$_.VPC -eq $VPC}).SGID
        If (($SecurityGroups | Where-Object {$_.GroupID -eq $SGtoAdd})) {
            Write-Output "$SGtoAdd is already added"
            $SGStatus = "SG Already Added"
        }
        Else {
            Write-Output "$SGtoAdd Adding Security Group to Instance $Instance"
            Write-Output "Building SecurityGroup List"
            If (($SGCount -gt 1) -and ($SGCount -le 5)) {
                $i = 1
                ForEach ($SGroup in $SecurityGroups) {
                    If ($i -eq $SGCount) {
                        $SG = $SG + $SGroup.GroupId
                    }
                    Else {
                        $SG = $SG + $Sgroup.GroupID + ','
                        $i = $i + 1
                    }
                }
            }
            ElseIf ($SGCount -eq 1) {
                $SG = $SecurityGroups.GroupId
            }
            $SG = ($SG + ', ' + $SGtoAdd).Split(",")
            Write-Output "Security Group List:"
            Write-Output "$SG"
            Edit-EC2InstanceAttribute -InstanceId $Instance -Region $Region -Group $SG
            #Validate SG was added
            Write-Output "-------Validating Changes-------"
            $AWSInstance = (Get-EC2Instance -InstanceId $Instance -Region $Region).Instances
            $SecurityGroupsNew = $AWSInstance.SecurityGroups 
            $SGCountNew = ($SecurityGroupsNew | Measure-Object).Count
            If ($SGCountNew -gt $SGCount) {
                If (($SecurityGroupsNew | Where-Object {$_.GroupID -eq $SGtoAdd})) {
                    $SGStatus = "Successfully Added SG"
                    Write-Output "Succesfully Added SG"
                }
                Else {
                    $SGStatus = "Failed to Add SG"
                    Write-Output "Failed to Add SG"
                }
            }
            Else {
                $SGStatus = "No Change Made"
                Write-Output "No Change Made"
            }
        }

    }
    Else {
        Write-Output "Could not find $Instance"
        $SGStatus = "No Instance"
    }

    #Logging
    $ScriptLog = New-Object -TypeName PSobject 
    $ScriptLog | Add-Member -MemberType NoteProperty -Name "InstanceID" -Value $Instance
    $ScriptLog | Add-Member -MemberType NoteProperty -Name "Status" -Value $SGStatus
    $ScriptLog | Add-Member -MemberType NoteProperty -Name "NumSG" -Value $SGCount
    $SCriptLogs.Add($ScriptLog)
    $ScriptLog
}

Write-Output "Script Complete"
#Log to CSV
$ScriptLogs | Export-CSV .\ScriptLog.csv -NoTypeInformation
$SGLogs | Export-CSV .\SGLogs.csv -NoTypeInformation