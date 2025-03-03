#DNSFilter Install

$dns =  Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.DisplayName -ne $null} | ?{$_.Displayname -like "*DNS*"}
if(!$dns){
	Invoke-WebRequest -Uri "https://download.dnsfilter.com/User_Agent/Windows/DNSFilter_Agent_Setup.msi" -OutFile "C:\Temp\DNSFilter_Agent_Setup.msi"
	#make sure to get YOUR NKEY
	Start-Process -Wait -FilePath "C:\Temp\DNSFilter_Agent_Setup.msi" -ArgumentList '/quiet /norestart NKEY="NKEY HERE"'
	Remove-Item "C:\Temp\DNSFilter_Agent_Setup.msi" -Force
}
else{
	Write-Host "Already Installed"
}