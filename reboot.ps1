#Staging always reboot after 15 min.
$env:SEE_MASK_NOZONECHECKS = 1
$user = Get-WmiObject Win32_Process -Filter "Name='explorer.exe'" | ForEach-Object { $_.GetOwner() } | Select-Object -Unique -Expand User
if($user -like "*testuser*"){
rundll32.exe user32.dll,LockWorkStation
Invoke-GPUpdate -Force
Start-Sleep -Seconds 900
Restart-Computer -Force
}

