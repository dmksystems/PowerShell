$env:SEE_MASK_NOZONECHECKS = 1
$Path = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.DisplayName -ne $null} | ?{ $_.DisplayName -like "*Rapid7*"}
$SourcePath = 'SOURCEPATH'

if(!$Path){
Copy-Item $SourcePath -Destination "C:\Temp" -Force
Write-Host "Rapid7 agent is not installed"
Write-Host "Installing Rapid7 agent"
Set-Location -Path "C:\Temp"
#Add Custom Token
Start-Process -Wait -FilePath 'C:\Temp\agentInstaller-x86_64.msi' -ArgumentList '/l*v insight_agent_install_log.log CUSTOMTOKEN=CUSTOMTOKEN /quiet'
Remove-Item "C:\Temp\agentInstaller-x86_64.msi" -Force
Remove-Item "C:\Temp\insight_agent_install_log.log" -Force
}
else{
	Write-Host "Rapid7 agent is already installed."
}