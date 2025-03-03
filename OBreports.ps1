param (
    [parameter(mandatory)][string]$doctype, 
    [string]$startdate = (Get-Date -Day 1).ToString("MM/dd/yyyy"), 
    [string]$enddate = (Get-Date).ToString("MM/dd/yyyy"),
    [parameter(mandatory)][string]$downloadpath,
    [int]$nummonths, 
    [int]$numdays, 
    [switch]$mtd, 
    [switch]$ytd
    )

clear

if ($nummonths){
    $startdate = (Get-Date).AddMonths(-$nummonths).ToString("MM/dd/yyyy")
}

if ($numdays){
    $startdate = (Get-Date).AddDays(-$numdays).ToString("MM/dd/yyyy")
}

if ($MTD){
    $startdate = (Get-Date -Day 1).ToString("MM/dd/yyyy")
}

if($YTD){
    $startdate = (Get-Date -Month 1 -Day 1).ToString("MM/dd/yyyy")
}


$ToolsPath = "C:\Tools\Selenium\Bin"
#Get the browser Version then download the edgedriver for that verison
if(!(Test-Path "$ToolsPath" -ErrorAction SilentlyContinue)){
    New-Item -ItemType Directory -Path "$ToolsPath\selenium-manager\windows" -Force
}
#load prereqs
$browserversion = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Edge\BLBeacon").Version
$edgedriverversion = (Get-ItemProperty -Path "$ToolsPath\msedgedriver.exe" -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
#download edge driver if current edge version does not match current edge driver version
if ($browserversion -ne $edgedriverversion){
   $downloadURL = "https://msedgedriver.azureedge.net/$browserversion/edgedriver_win64.zip"
   invoke-WebRequest $downloadURL -OutFile "c:\temp\edgedriver.zip" 
   #extract driver and rename it.
   Sleep 5
   if(Test-Path -Path "C:\temp\edgedriver.zip"){
       expand-archive -LiteralPath "C:\temp\edgedriver.zip" -DestinationPath "$ToolsPath" -Force
       Remove-Item  "c:\temp\edgedriver.zip" -Force
       Sleep 5
   }
   else{
   Write-Output "edgedriver does not exist"
   }
   }
   #get selenium 4.23 if a dll doesn't exist
    $test = Test-Path -Path "C:\Tools\Selenium\Bin\WebDriver.dll"
    if(!$test){
    $downloadURL = "https://www.nuget.org/api/v2/package/Selenium.WebDriver/4.23.0"
    Invoke-WebRequest $downloadURL -OutFile "C:\temp\Selenium.zip"
    Expand-Archive -LiteralPath "C:\temp\Selenium.zip" -DestinationPath "C:\temp\Selenium" -Force
    Copy-Item -Path "C:\temp\Selenium\manager\windows\selenium-manager.exe" -Destination "$ToolsPath\selenium-manager.exe" -Force
    Copy-Item -Path "C:\temp\Selenium\manager\windows\selenium-manager.exe" -Destination "$ToolsPath\selenium-manager\windows\selenium-manager.exe" -Force
    Copy-Item -Path "C:\temp\Selenium\lib\netstandard2.0\WebDriver.dll" -Destination "$ToolsPath\WebDriver.dll" -Force
    Unblock-File -Path "$ToolsPath\WebDriver.dll"
    Remove-Item -Path "c:\temp\Selenium.zip" -Force
    Remove-Item -Path "c:\temp\Selenium" -Force -Recurse
    }
    #get newtonsoft.json
    $test = Test-Path -Path "$ToolsPath\Newtonsoft.Json.dll"
    if(!$test){
    $downloadURL = "https://www.nuget.org/api/v2/package/Newtonsoft.Json/13.0.3"
    Invoke-WebRequest $downloadURL -OutFile "C:\temp\Newtonsoft.zip"
    Expand-Archive -LiteralPath "C:\temp\Newtonsoft.zip" -DestinationPath "C:\temp\Selenium" -Force
    Copy-Item -Path "C:\temp\Selenium\lib\netstandard2.0\Newtonsoft.Json.dll" -Destination "$ToolsPath\Newtonsoft.Json.dll" -Force
    Remove-Item -Path "c:\temp\Newtonsoft.zip" -Force
    Remove-Item -Path "c:\temp\Selenium" -Force -Recurse
    Unblock-File -Path "$ToolsPath\Newtonsoft.Json.dll"
    }

#load dlls
[Reflection.Assembly]::LoadFile("$ToolsPath\NewtonSoft.Json.dll")
[Reflection.Assembly]::LoadFile("$ToolsPath\WebDriver.dll")

$trycount = 0 
while($trycount -le 4){
$filename = $doctype.Replace(" ","_")
$filename = $filename.Replace("/","_")
$filename = $filename.Replace("-","_")
$filepath = $downloadpath +"\"+$filename+".csv"
if (Test-Path $filepath){
    Remove-Item $filepath -Force
}
$trycount
try{
$service = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateDefaultService()
$service.HideCommandPromptWindow = $true
$driverpath = "$ToolsPath"
$drivername = "msedgedriver.exe"
$service.DriverServicePath = $driverpath
$service.DriverServiceExecutableName = $drivername

$options = [OpenQA.Selenium.Edge.EdgeOptions]::new()
$dldir = $downloadpath
$options.AddUserProfilePreference('download', @{'default_directory' = $dldir; 'prompt_for_download' = $false; })
$options.AcceptInsecureCertificates = $true

$driver = [OpenQA.Selenium.Edge.EdgeDriver]::new($service, $options)

$driver.Manage().Window.Maximize()
$driver.Manage().Timeouts().ImplicitWait = New-TimeSpan -Seconds 3
}
catch{
    #if any error occurs quit the driver and try again 4 times
    Write-Host "Couldn't make a webdriver"
    $driver.Quit()
    $trycount = $trycount + 1
    Sleep 10
}
try{
# Navigate to a URL
$driver.Navigate().GoToUrl("https://obweb.sactocu.org/AppNet")
$driver.Navigate().Refresh()
Sleep 2
$driver.Navigate().GoToUrl("https://obweb.sactocu.org/AppNet")
Sleep 2
}
catch{
    #if any error occurs quit the driver and try again 4 times
    Write-Host "Page wouldn't work"
    $driver.Quit()
    $trycount = $trycount + 1
    Sleep 10
}
try{
$iframe = $driver.FindElement([OpenQA.Selenium.By]::xpath("//iframe[@title='User Interaction Required']"))
if($iframe){
    $driver.SwitchTo().Frame($iframe)
    try{
    $driver.FindElement([OpenQA.Selenium.By]::xpath("//label[@for='disconnectFromOnBase')]")).Click()
    }
    catch{
    Write-Host "Button not found?"
    }
    try{
    $driver.FindElement([OpenQA.Selenium.By]::xpath('//button[contains(.,"Continue")]')).Click()
    }
    catch{
     Write-Host "Continue not found?"
    }
}
}
catch{
    #if any error occurs quit the driver and try again 4 times
    Write-Host "Page isn't showing user interaction page"
}
try{
$driver.SwitchTo().Frame("NavPanelIFrame")
$driver.FindElement([OpenQA.Selenium.By]::xpath("//input[@title='(type in document type name)']")).Click()
$driver.FindElement([OpenQA.Selenium.By]::xpath("//input[@title='(type in document type name)']")).SendKeys("$doctype")
#select by doctype name easier to input variables avoids large if/else statements
$xpath = ""
$xpath = $xpath + "//label[contains(.," + "`'" + $doctype + "`'" + ")]"
#search for the doctype
$driver.FindElement([OpenQA.Selenium.By]::xpath("$xpath")).Click()
#enter the start date
$driver.FindElement([OpenQA.Selenium.By]::xpath("//input[@class='js-fromDate']")).SendKeys("$startdate")
$driver.FindElement([OpenQA.Selenium.By]::xpath("//input[@class='js-toDate']")).SendKeys("$enddate")
#Hit the search button
$driver.FindElement([OpenQA.Selenium.By]::xpath('//button[contains(.,"Search")]')).Click()
$driver.SwitchTo().DefaultContent()
$driver.SwitchTo().Frame("frmViewer")
$driver.SwitchTo().Frame("frameDocSelect")
$driver.FindElement([OpenQA.Selenium.By]::xpath("//div[@class='docSelectContextMenuButton']")).Click()
$driver.SwitchTo().DefaultContent()
$driver.FindElement([OpenQA.Selenium.By]::xpath('//li[contains(.,"Generate CSV File")]')).Click()
$iframepath = $driver.FindElement([OpenQA.Selenium.By]::xpath("//iframe[@title='Generate CSV File']"))
$driver.SwitchTo().Frame($iframepath)
$driver.FindElement([OpenQA.Selenium.By]::xpath("//input[@name='reportName']")).SendKeys("$doctype")
#notworking
$driver.FindElement([OpenQA.Selenium.By]::xpath('//label[contains(.,"Include all documents")]')).Click()
#notworking
$driver.SwitchTo().DefaultContent()
$driver.FindElement([OpenQA.Selenium.By]::xpath('//button[contains(.,"Generate")]')).Click()

$filename = $doctype.Replace(" ","_")
$filename = $filename.Replace("/","-")
$filepath = $downloadpath +"\"+$filename+".csv"
$count = 0
while(!(Test-Path -Path $filepath) -and $count -le 30){
$count = $count + 1
Sleep 10
}
if(Test-Path -Path $filepath){
    $driver.FindElement([OpenQA.Selenium.By]::xpath('//button[contains(.,"Cancel")]')).Click()
    $filename2 = $filename.Replace("-","_")+".csv"
    Rename-Item -Path $filepath -NewName $filename2 -Force
    $trycount = 5
}
Sleep 5
#Close the driver
$driver.Quit()
}
catch{
    #if any error occurs quit the driver and try again 4 times
    $driver.Quit()
    $trycount = $trycount + 1
    Sleep 180
}
}
