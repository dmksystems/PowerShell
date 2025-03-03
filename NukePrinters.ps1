$printers = Get-Printer
ForEach ($printer in $printers){
	if( $printer.Name -notlike "Black*" -and $printer.Name -notlike "Microsoft*"){
		Remove-Printer -InputObject $printer
	}
}
Get-WmiObject -Class Win32_printer | where($_.Network -eq "True") | foreach(%_.delete()}

