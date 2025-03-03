#Reboot the Servers
#Script needs to run with domain admin powershell
#Function to Test SQL Connections
function Test-SqlConnection {
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [pscredential]$Credential
    )

    $ErrorActionPreference = 'Stop'

    try {
        $userName = $Credential.UserName
        $password = $Credential.GetNetworkCredential().Password
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userName,$password
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
		Write-Host "Testing Sql-Connection..."
        $sqlConnection.Open()
        ## This will run if the Open() method does not throw an exception
        $true
    } catch {
		Write-Host "SQL not up..."
        $false
    } finally {
        ## Close the connection when we're done
        $sqlConnection.Close()
    }
}
#Use this function only after rebooting a server
function Test-Ping{
	param(
		[Parameter(Mandatory)]
        [string]$ServerName
	)
	$p = Test-Connection -ComputerName $ServerName -Quiet -Count 1 -ErrorAction SilentlyContinue
	while($p){
		Write-Host "Waiting for $ServerName to reboot..."
		Start-Sleep 5
		$p = Test-Connection -ComputerName $ServerName -Quiet -Count 1 -ErrorAction SilentlyContinue
	}
	while(!$p){
		Write-Host "Server $ServerName is offline..."
		Start-Sleep 5
		$p = Test-Connection -ComputerName $ServerName -Quiet -Count 1 -ErrorAction SilentlyContinue
	}
	if($p){
		Write-Host "Server $ServerName is online..."
		$true
	}
	else{
		$false
	}
}
#use this function to test a service
function Test-Service{
	param(
		[Parameter(Mandatory)]
		[string]$ServiceName,
		
		[Parameter(Mandatory)]
		[string]$ServerName	
	)
	$svc = Get-Service $ServiceName -ComputerName $ServerName
	Write-Host "Checking..."$svc.DisplayName 
	$count = 0
	while($svc.Status -notlike "*Running*" -and ($count -ne 60)){
		Write-Host "Waiting for:" $svc.DisplayName 
		Start-Sleep 10
		$svc = Get-Service $ServiceName -ComputerName $ServerName
		$count = $count + 1
	}
	Write-Host $svc.DisplayName "is running..."
	if($count -eq 60){
		Write-Host "Operation Timed out after ten minutes..." -ForegroundColor Red
		$false
	}
	else{
		$true
	}
}

$cred = (Get-Credential -Message "Enter the SQL server credentials.")

#Restart Server
Restart-Computer -ComputerName "is-sql01.contoso.org" -Force -Wait -For PowerShell -Timeout 2400 -Delay 2

#Test for connection drop then connection return
#$ping = Test-Ping -ServerName "is-sql01.contoso.org"

#Test that SQL connection is up
	$sql = Test-SqlConnection -ServerName "is-sql01.contoso.org" -DatabaseName "desktopcentral" -Credential $cred
	while(!$sql){
		Write-Host "Waiting for the SQL services..."
		Start-Sleep 10
		$sql = Test-SqlConnection -ServerName "is-sql01.contoso.org" -DatabaseName "desktopcentral" -Credential $cred
	}
	if($sql){
		Write-Host "Server is back up..."
	}
	else{
		Write-Host "Something went wrong..." -ForegroundColor Red
	}
#Test that sql server got moved to HA backup
Write-Host "Testing backup server connection..."

	$sql = Test-SqlConnection -ServerName "is-sql02.contoso.org" -DatabaseName "onbase" -Credential $cred
	$count = 0
	while(!$sql -and $count -ne 60){
		Write-Host "Waiting for the SQL services..."
		Start-Sleep 10
		$sql = Test-SqlConnection -ServerName "is-sql02.contoso.org" -DatabaseName "onbase" -Credential $cred
		$count = $count + 1
	}
	if($sql){
		Write-Host "Server backup is online and SQL connection successful..."
	}
	else{
		Write-Host "Operation timed out after ten minutes..." -ForegroundColor Red
	}
Write-Host "Databases have moved to backup."
Write-Host "Wait three minutes..."
Start-Sleep 180
#Reboot Backup SQL server and cause failover to primary
Write-Host "Rebooting is-sql02.contoso.org..."
Restart-Computer -ComputerName "is-sql02.contoso.org" -Force

Write-Host "Check if DBs moved back to primary..."
#Check that the sql primary server is back online
	$sql = Test-SqlConnection -ServerName "is-sql01.contoso.org" -DatabaseName "onbase" -Credential $cred
	$count = 0
	while(!$sql -and ($count -ne 60)){
		Write-Host "Waiting for the SQL services on..."
		Start-Sleep 10
		$sql = Test-SqlConnection -ServerName "is-sql01.contoso.org" -DatabaseName "onbase" -Credential $cred
		$count = $count + 1	
	}
	if($sql){
		Write-Host "Server backups have been restored..."
	}
	else{
		Write-Host "Operation timed out after ten minutes..." -ForegroundColor Red
	}
Write-Host "Databases have moved back to primary."
Write-Host "Rebooting Desktop Central Server...."
Restart-Computer -ComputerName "is-sql01.contoso.org" -Force -Wait -For PowerShell -Timeout 2400 -Delay 2
#Special Cases
#Domain Controllers
Write-Host "Rebooting dct01..."
Restart-Computer -ComputerName "is-dct01.contoso.org" -Force -Wait -For PowerShell -Timeout 2400 -Delay 2
#$ping = Test-Ping -ServerName "is-dct01.contoso.org"
Test-Service -ServiceName "*NTDS*" -ServerName "is-dct01.contoso.org"
Write-Host "Waiting 60 seconds can never be too safe..."
Start-Sleep 60
#Restart other domain controllers now that dct01 has restarted
Write-Host "Restarting other domain controllers..."
Restart-Computer -ComputerName "is-dct02.contoso.org","rv-is-dct03.contoso.org" -Force

#Restart Intranet Server
Write-Host "Restarting intranet server..."
Restart-Computer -ComputerName "is-int01.contoso.org" -Force -Wait -For PowerShell -Timeout 2400 -Delay 2
	Test-Service -ServiceName 'MSSQL$SQLEXPRESS' -ServerName "is-int01.contoso.org"
	Write-Host "Wait two minutes..."
	Start-Sleep 120
	#Restart IIS Services
	Write-Host "Restarting IIS service..."
	Invoke-Command -ComputerName "is-int01.contoso.org" -ScriptBlock {iisreset}
	Start-Sleep 15
	Test-Service -ServiceName "*W3SVC*" -ServerName "is-int01.contoso.org"
	Write-Host "Intranet server is ready..."
#card wizard never works 
Write-Host "Restarting Card Wizard..."
Restart-Computer -ComputerName "is-cwiz02.contoso.org" -Force -Wait -For PowerShell -Timeout 2400 -Delay 2
	#fix card wizard services
	Test-Service -ServiceName 'MSSQL$SQLEXPRESS' -ServerName "is-cwiz02.contoso.org"
	Test-Service -ServiceName "*HsmServer*" -ServerName "is-cwiz02.contoso.org"
	Test-Service -ServiceName "*DCG_BusinessService*" -ServerName "is-cwiz02.contoso.org"
	Test-Service -ServiceName "*DCG_ApplicationService*" -ServerName "is-cwiz02.contoso.org"
	Write-Host "Restart HSM Service..."
	$hsm = Get-Service "*HsmServer*" -ComputerName "is-cwiz02.contoso.org"
	$hsm | Restart-Service -Force
	Start-Sleep 15
	Test-Service -ServiceName "*HsmServer*" -ServerName "is-cwiz02.contoso.org"
	Write-Host "Restarting Business Service..."
	$bs = Get-Service "*DCG_BusinessService*" -ComputerName "is-cwiz02.contoso.org"
	$bs | Restart-Service -Force
	Start-Sleep 15
	Test-Service -ServiceName "*DCG_BusinessService*" -ServerName "is-cwiz02.contoso.org"
	#Restart IIS Services
	Write-Host "Restarting IIS service..."
	Invoke-Command -ComputerName "is-cwiz02.contoso.org" -ScriptBlock {iisreset}
	Start-Sleep 15
	Test-Service -ServiceName "*W3SVC*" -ServerName "is-cwiz02.contoso.org"
	Write-Host "Card wizard server ready..."

#Reboot Servers without special needs 
$servers = "Onbase.contoso.org","is-cfm01.contoso.org","is-est01.contoso.org","is-ss01.contoso.org","is-adm01.contoso.org","Scriptrunner.contoso.org","IS-REP01.contoso.org","is-av01.contoso.org","is-bck01.contoso.org","is-fsv02.contoso.org","is-hmail.contoso.org","is-proxy1.contoso.org","is-prt01.contoso.org","is-siem.contoso.org","is-tch01.contoso.org","win7-acrobat.contoso.org","rv-is-proxy1.contoso.org","is-sym01.contoso.org","is-pnt01.contoso.org","is-vul01.contoso.org","is-wp01.contoso.org","is-duo01.contoso.org","boardroom.contoso.org","is-asset01.contoso.org"

Write-Host "Rebooting dependent servers..."
foreach($s in $servers){
	Write-Host "Restarting $s"
	Restart-Computer -ComputerName $s -Force
	Write-Host "Waiting 30 seconds to offset boot times..."
	Start-Sleep 30
}
Write-Host "Servers have been rebooted..."



