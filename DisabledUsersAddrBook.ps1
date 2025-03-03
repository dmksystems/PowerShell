
Get-ADUser -Filter * -SearchBase "OU=Disabled Accounts,DC=contoso,DC=com" -Properties msExchHideFromAddressLists | ?{$_.msExchHideFromAddressLists -notlike 'True'} | Set-ADUser -Replace @{msExchHideFromAddressLists="TRUE"}

