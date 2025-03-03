$disabled = Get-ADUser -Filter * -SearchBase "OU=Disabled Accounts,DC=contoso,DC=com" -Properties memberof,msExchHideFromAddressLists
Write-Host "Disable Accounts"
foreach ($d in $disabled){
	$c = $d.Name
	if ($d.Enabled -eq 'True'){
		Write-Host Disabling account: $c
		Disable-ADAccount -Identity $d
	}
	$groups = $d.memberof
	foreach($g in $groups){
		Write-Host Removing $c from $g
		Remove-ADPrincipalGroupMembership -Identity $d -MemberOf $g -Confirm:$false
	}
	Write-Host "Clear $c's Attributes"
	Set-ADUser -Identity $d -Clear description,physicalDeliveryOfficeName,telephoneNumber,mail,title,manager,company,department,info
	if ($d.msExchHideFromAddressLists -notlike 'True'){
		Write-Host "Hide" $c "From Address List"
		Set-ADUser -Identity $d -Replace @{msExchHideFromAddressLists="TRUE"}
	}
}

