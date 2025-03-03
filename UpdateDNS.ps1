# Define the remote computer name and the new DNS server addresses
$remoteComputer = "LIST OF COMPUTERS"
$dnsServers = @("DNS1", "DNS2", "DNS3")  # Example DNS servers (Google DNS)

# Get the network adapter on the remote computer
$networkAdapter = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
}

# Set the DNS server addresses on the remote computer
Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
    param ($adapterName, $dnsServers)
    Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses $dnsServers
} -ArgumentList $networkAdapter.Name, $dnsServers

Write-Host "DNS server addresses updated successfully on $remoteComputer"
