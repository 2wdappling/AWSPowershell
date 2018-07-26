#Import AWS keys in to an encrypted file to be accessed by other scripts
# Drew Appling 07/25/2018

$awskeys = @((Read-Host 'AWS Access Key ID' | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString),(Read-Host 'AWS Secret Access Key' | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString),(Read-Host 'AWS Session Token' | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString))

$awskeys | out-file encrypted.txt
