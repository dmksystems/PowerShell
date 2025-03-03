# UpdateAtStartup.ps1
# Ensure the script runs without loading the user profile for faster execution
# Log output to a file for troubleshooting
$LogFile = "C:\Temp\WindowsUpdateLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
 
# Create log directory if it doesn’t exist
$LogDir = "C:\Temp"
if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force
}
 
# Start logging
Start-Transcript -Path $LogFile -Append
 
try {
    # Import the PSWindowsUpdate module
    Import-Module PSWindowsUpdate -ErrorAction Stop
 
    # Register Microsoft Update service (optional, includes Office updates if installed)
    Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -Confirm:$false
 
    # Check for updates, download, and install them
    Write-Output "Checking for Windows updates..."
    $updates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot -ErrorAction Stop
 
    if ($updates) {
        Write-Output "Updates found and installed: $($updates.Count)"
    } else {
        Write-Output "No updates available at this time."
    }
} catch {
    Write-Output "Error occurred: $_"
} finally {
    Stop-Transcript
}