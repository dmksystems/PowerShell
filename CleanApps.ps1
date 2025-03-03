#switches
param(
	[switch]$all,
	[switch]$apps,
	[switch]$context,
	[switch]$cloud,
	[switch]$dark,
	[switch]$task,
	[switch]$copystart,
	[switch]$help
)

if($all -or $apps -or $context -or $cloud -or $dark -or $task -or $copystart){
	$execute = $true
}
else{
	$execute = $false
}

if($help -ne $true -and $execute){
#add apps here to remove
$badApps = "*YourPhone*","*Xbox*","*Solitaire*","*Bing*","*Gaming*","*Teams*","*Zune*","*Spotify*","*ToDos*","*People*","*Skype*","*MicrosoftOfficeHub*","*clipchamp*"

#remove apps
if($apps -or $all){
	Write-Host "Removing provisioned and unprovisioned store bloat applications." -ForegroundColor Green
	foreach ($appx in $badApps){
		$app = Get-AppxPackage -AllUsers | Where-Object {$_.Name -like $appx}| Where-Object {$_.Name -ne $null}
		foreach ($a in $app){
			Write-Host "Removing package:" $a.Name -ForegroundColor Red
			$a | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 
		}
		$appP = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $appx} | Where-Object {$_.DisplayName -ne $null}
		foreach ($p in $appP){
			Write-Host "Removing provisioned package:" $p.DisplayName -ForegroundColor Red
			$p | Remove-AppxProvisionedPackage -online -ErrorAction SilentlyContinue
		}
	}
}

#configure taskbar
if($task -or $all){
#Set task alignment to left
$path = 'HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "TaskbarAl" -ErrorAction SilentlyContinue).TaskbarAl
if($key -ne 0){
	Write-Host "Moving taskbar left." -ForegroundColor Green
	Set-ItemProperty -Path $path -Name "TaskbarAl" -Value 0 | Out-Null
}

#Disable Teams Chat Taskbar Icon
$path = 'HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "TaskbarMn" -ErrorAction SilentlyContinue).TaskbarMn
if($key -ne 0){
	if($key -ne $null){
		Write-Host "Setting taskbar chat icon registry setting." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "TaskbarMn" -Value 0 | Out-Null
	}
	else{
		Write-Host "Creating taskbar chat icon registry setting." -ForegroundColor Green
		New-ItemProperty -Path $path -Name "TaskbarMn" -PropertyType DWord -Value 0 | Out-Null
	}
}
else{
	Write-Host "Chat taskbar icon is already disabled." -ForegroundColor Red
}
#Disable TaskView Button on Task Bar
$path = 'HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "ShowTaskViewButton" -ErrorAction SilentlyContinue).ShowTaskViewButton
if($key -ne 0){
	if($key -ne $null){
		Write-Host "Setting taskview icon registry setting." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "ShowTaskViewButton" -Value 0 | Out-Null
	}
	else{
		Write-Host "Creating taskview icon registry setting." -ForegroundColor Green
		New-ItemProperty -Path $path -Name "ShowTaskViewButton" -PropertyType DWord -Value 0 | Out-Null
	}
}
else{
	Write-Host "Show taskview button is already disabled" -ForegroundColor Red
}

#Disable Widgets on taskbar
$path = 'HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "TaskbarDa" -ErrorAction SilentlyContinue).TaskbarDa
if($key -ne 0){
	if($key -ne $null){
		Write-Host "Setting show widgets icon registry setting." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "TaskbarDa" -Value 0 | Out-Null
	}
	else{
		Write-Host "Creating show widgets icon registry setting." -ForegroundColor Green
		New-ItemProperty -Path $path -Name "TaskbarDa" -PropertyType DWord -Value 0 | Out-Null
	}
}
else{
	Write-Host "Show widgets button is already disabled." -ForegroundColor Red
}

#Disable Search on Taskbar
$path = 'HKCU:Software\Microsoft\Windows\CurrentVersion\Search'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -ErrorAction SilentlyContinue).SearchboxTaskbarMode
if($key -ne 0){
	if($key -ne $null){
		Write-Host "Set show search icon registry setting." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "SearchboxTaskBarMode" -Value 0 | Out-Null
	}
	else{
		Write-Host "Create show search icon registry setting." -ForegroundColor Green
		New-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -PropertyType DWord -Value 0  | Out-Null
	}
}
else{
	Write-Host "Show widgets button is already disabled." -ForegroundColor Red
}

#Disable pinning windows store to taskbar
$path = 'HKCU:SOFTWARE\Policies\Microsoft\Windows\Explorer'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "NoPinningStoreToTaskbar" -ErrorAction SilentlyContinue).NoPinningStoreToTaskbar
if($key -ne 1){
	if($key -ne $null){
		Write-Host "Disabling pinning the store app to taskbar." -ForegroundColor Green
		Write-Host "Setting NoPinningStoreToTaskbar." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "NoPinningStoreToTaskbar" -Value 1
	}
	else{
		if(Test-Path -Path $path){
			Write-Host "Disabling pinning the store app to taskbar." -ForegroundColor Green
			Write-Host "Setting NoPinningStoreToTaskbar." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "NoPinningStoreToTaskbar" -PropertyType DWord -Value 1 | Out-Null
		}
		else{
			Write-Host "Disabling pinning the store app to taskbar." -ForegroundColor Green
			Write-Host "Creating NoPinningStoreToTaskbar key." -ForegroundColor Green
			$path = 'HKCU:SOFTWARE\Policies\Microsoft\Windows\'
			New-Item -Path $path -Name 'Explorer' | Out-Null
			$path = 'HKCU:SOFTWARE\Policies\Microsoft\Windows\Explorer'
			Write-Host "Creating NoPinningStoreToTaskbar property." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "NoPinningStoreToTaskbar" -PropertyType DWord -Value 1 | Out-Null
		}
	}
}
else{
	Write-Host "NoPinningStoreToTaskbar already set to" $key"." -ForegroundColor Red
}

}
#Set Dark Mode
if($dark -or $all){
	$path = 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
	$key = $null
	$key = (Get-ItemProperty -Path $path -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue).AppsUseLightTheme
	if($key -ne 0){
		Write-Host "Enabling dark mode for Apps." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Value 0 | Out-Null
	}
	else{
		Write-Host "Dark mode is already enabled for APPS." -ForegroundColor Red
	}

	$path = 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
	$key = $null
	$key = (Get-ItemProperty -Path $path -Name "SystemUsesLightTheme" -ErrorAction SilentlyContinue).SystemUsesLightTheme
	if($key -ne 0){
		Write-Host "Enabling dark mode System Wide." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "SystemUsesLightTheme" -Value 0 | Out-Null
	}
	else{
		Write-Host "Dark mode is already enabled for SYSTEM." -ForegroundColor Red
	}
}

if($cloud -or $all){
#Disable Windows Cloud Content Garbage
$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\CloudContent'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "DisableCloudOptimizedContent" -ErrorAction SilentlyContinue).DisableCloudOptimizedContent
if($key -ne 1){
	if($key -ne $null){
		Write-Host "Disabling Cloud based consumer content" -ForegroundColor Green
		Write-Host "Setting DisableCloudOptimizedContent." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "DisableCloudOptimizedContent" -Value 1
	}
	else{
		if(Test-Path -Path $path){
			Write-Host "Disabling Cloud based consumer content" -ForegroundColor Green
			Write-Host "Setting DisableCloudOptimizedContent." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "DisableCloudOptimizedContent" -PropertyType DWord -Value 1 | Out-Null
		}
		else{
			Write-Host "Disabling Cloud based consumer content" -ForegroundColor Green
			Write-Host "Creating CloudContent key." -ForegroundColor Green
			$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\'
			New-Item -Path $path -Name 'CloudContent' | Out-Null
			$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\CloudContent'
			Write-Host "Creating DisableCloudOptimizedContent property." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "DisableCloudOptimizedContent" -PropertyType DWord -Value 1 | Out-Null
		}
	}
}
else{
	Write-Host "DisableCloudOptimizedContent already set to" $key"." -ForegroundColor Red
}

$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\CloudContent'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "DisableConsumerAccountStateContent" -ErrorAction SilentlyContinue).DisableConsumerAccountStateContent
if($key -ne 1){
	if($key){
		Write-Host "Setting DisableConsumerAccountStateContent." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "DisableConsumerAccountStateContent" -Value 1 | Out-Null
	}
	else{
		if(Test-Path -Path $path){
			Write-Host "Creating DisableConsumerAccountStateContent property." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "DisableConsumerAccountStateContent" -PropertyType DWord -Value 1 | Out-Null
		}
		else{
			Write-Host "Creating CloudContent key." -ForegroundColor Green
			$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\'
			New-Item -Path $path -Name 'CloudContent' | Out-Null
			$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\CloudContent'
			Write-Host "Creating DisableConsumerAccountStateContent property." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "DisableConsumerAccountStateContent" -PropertyType DWord -Value 1 | Out-Null
		}
	}
}
else{
	Write-Host "DisableConsumerAccountStateContent already set to" $key"." -ForegroundColor Red
}

$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\CloudContent'
$key = $null
$key = (Get-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue).DisableWindowsConsumerFeatures
if($key -ne 1){
	if($key){
		Write-Host "Setting DisableWindowsConsumerFeatures." -ForegroundColor Green
		Set-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -Value 1 | Out-Null
	}
	else{
		if(Test-Path -Path $path){
			Write-Host "Creating DisableWindowsConsumerFeatures property." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 | Out-Null
		}
		else{
			Write-Host "Creating CloudContent key." -ForegroundColor Green
			$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\'
			New-Item -Path $path -Name 'CloudContent' | Out-Null
			$path = 'HKLM:SOFTWARE\Policies\Microsoft\Windows\CloudContent'
			Write-Host "Creating DisableWindowsConsumerFeatures property." -ForegroundColor Green
			New-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 | Out-Null
		}
	}
	
}
else{
	Write-Host "DisableWindowsConsumerFeatures already set to" $key"." -ForegroundColor Red
}


}

#Restore Classic Context Menus
if($context -or $all){
	$path = 'HKCU:Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
	$test = Test-Path -Path $path 
	if($test -ne $true){
	Write-Host "Restoring classic context menus." -ForegroundColor Green
	$path = 'HKCU:Software\Classes\CLSID'
	New-Item -Path $path -Name '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' | Out-Null
	$path = 'HKCU:Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' 
	New-Item -Path $path -Name 'InprocServer32' | Out-Null
	$path = 'HKCU:Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
	Set-ItemProperty -Path $path -Name '(Default)' -Value $null
	}
	else{
		Write-Host "System context menus have already been set to classic mode" -ForegroundColor Red
		Write-Host "To revert this change delete the key at path: HKCU:Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -ForegroundColor Green
	}
}

if($copystart){
	Write-Host "Copying start layout to C:\Users\default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.json" -ForegroundColor Green
	Remove-Item -Path "C:\Users\default\AppData\Local\Microsoft\Windows\Shell\*.*"
	Export-StartLayout -Path "C:\Users\default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml"
	Export-StartLayout -Path "C:\Users\default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.json"
}
}
#Help Menu
if($help -or ($execute -ne $true)){
	Write-Host "Use -all to configure windows with all the settings in this script." -ForegroundColor Green
	Write-Host "Use -apps to remove bloatware apps." -ForegroundColor Green
	Write-Host "Use -cloud to disable windows cloud stuff." -ForegroundColor Green
	Write-Host "Use -context to restore old style context menus." -ForegroundColor Green
	Write-Host "Use -dark to set windows to dark mode." -ForegroundColor Green
	Write-Host "Use -task to configure task bar." -ForegroundColor Green
	Write-Host "Use -copystart to copy start meny layout to default profile." -ForegroundColor Green
	Write-Host "Use -help to display this menu." -ForegroundColor Green
	Write-Host "This script requires a reboot to be fully implemented." -ForegroundColor Green
}