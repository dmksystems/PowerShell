#Enable Bitlocker

$TPM = Get-TPM
$LogFileBDE = "Path to Log File"
$LogFileTPM = "Path to TPM Errors File"

$test = (Get-BitLockerVolume -MountPoint C:).VolumeStatus
if($test -ne "FullyEncrypted"){
if(($TPM.TpmPresent -eq 'True') -and ($TPM.TpmEnabled -eq 'True')){
	$test = (Get-BitLockerVolume -MountPoint C:).VolumeStatus
	if($test -eq "FullyDecrypted"){
	Write-Host "Turn on Bitlocker"
	manage-bde -on C: -RecoveryPassword -skiphardwaretest
	}
	$test = (Get-BitLockerVolume -MountPoint C:).VolumeStatus
	$count = 0
	while(($test -ne "FullyEncrypted") -and ($count -le 60)){
		Write-Host "Test Encryption Status"
		$count = $count+1
		Sleep 10
		$test = (Get-BitLockerVolume -MountPoint C:).VolumeStatus
	}
	$test = (Get-BitLockerVolume -MountPoint C:).VolumeStatus
	[pscustomobject]@{ComputerName = $env:computername;BDEStatus = $test;} | Export-CSV -Path $LogFileBDE -Append -NoTypeInformation
}
else{
   Write-Host "TPM Issue"
   [pscustomobject]@{ComputerName = $env:computername;TpmPresent = $TPM.TpmPresent;TpmReady = $TPM.TpmReady;TpmEnabled = $TPM.TpmEnabled;} | Export-CSV -Path $LogFileTPM -Append -NoTypeInformation
}
}