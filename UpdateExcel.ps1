clear
$excelProcesses = Get-Process -Name "EXCEL" -ErrorAction SilentlyContinue
if ($excelProcesses){$excelProcesses | ForEach-Object {$_.Kill()}}

Start-Transcript -Path "C:\Scripts\FileList_6AM_log.txt" 
foreach($path in Get-Content C:\scripts\FileList_6AM.txt)
{
    $date = Get-Date
    "$date Updating $path"
    $excel = New-Object -ComObject Excel.Application
    $excel.DisplayAlerts = $false
    $workbook = $excel.WorkBooks.Open($path)
    $workbook.RefreshAll()
    $excel.Calculate()
    $excel.DisplayAlerts = $false
    $workbook.SaveAs($path)

    $workbook.Close()
    $excel.Quit()
    #Release Objects

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    # Garbage collection
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    $excelProcesses = Get-Process -Name "EXCEL" -ErrorAction SilentlyContinue
    if ($excelProcesses){
    $excelProcesses | ForEach-Object {$_.Kill()}
    }
}
Stop-transcript
