#Remove 7-Zip and Reinstall. 
#set env variable to allow network execute
$env:SEE_MASK_NOZONECHECKS = 1

$FilePath = 'Path to file'
#uninstall old versions
$Path = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.DisplayName -ne $null} | ?{($_.DisplayName -like "*7zip*") -or ($_.DisplayName -like "*7-zip*") -or ($_.DisplayName -like "*7 Zip*")} 

foreach($p in $path){
	$uninst = $p.UninstallString
	if($uninst -ne $null){
		if($uninst -like "MsiExec*"){
			$uninst = $uninst.Replace('MsiExec.exe ','')
			$uninst = $uninst.Replace('/I','/X')
			$uninst += ' /quiet /norestart'
			Write-Host "Uninstalling:" $p.DisplayName"..."
			Start-Process -Wait msiexec.exe -ArgumentList $uninst -ErrorAction Continue
		}
	}
}

Write-Host "Check Uninstall Strings Again..."
$Path = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.DisplayName -ne $null} | ?{($_.DisplayName -like "*7zip*") -or ($_.DisplayName -like "*7-zip*") -or ($_.DisplayName -like "*7 Zip*")}
#Do .exe uninstalls second
foreach($p in $path){
	$uninst = $p.UninstallString
	if($uninst -ne $null){
		if($uninst -notlike "MsiExec*"){
			$1,$2,$arguments = $uninst.Split('"',3)
			$1 = '"'
			$exestr = $1 += $2 += '"'
			Write-Host "Uninstalling from EXE:" $p.Displayname
			$arguments += '/S'
			Write-Host $exestr $arguments
			if($arguments -ne $null){
				Start-Process -Wait $exestr -ArgumentList $arguments -ErrorAction Continue
			}
		}
	}
}
Write-Host "Installing 7-zip 21.07 64bit"
Start-Process -Wait -FilePath $FilePath -ArgumentList '/quiet /norestart'



