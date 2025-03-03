# Copy the start.bin file into all existing profiles, to overwrite all the crap MS is including in the default Start Menu
# Won't prevent users from unpinning these items or pinning new items, only handles initial cleanup
# RUN THIS FROM THE PROFILE YOU WANT TO COPY
echo ""
echo "Clean up new and existing Start Menus"
$DefaultPath = "C:\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
$Source = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start.bin"
$Destination = 'C:\Users\*\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState'
Get-ChildItem $Destination | ForEach-Object {Copy-Item -Path $Source -Destination $_ -Force}
Copy-Item -path $Source -Destination $DefaultPath -Force