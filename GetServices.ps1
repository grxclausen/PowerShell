$svcs = Get-Service -Name "*sql*" | Where-Object {$_.Status -eq "Stopped"}

$svcs | Format-Table

foreach ($row in $svcs) {
    Write-Host $row.Name

    if ( $row.Name -eq "SQLServerReportingServices" ) {
        Start-Service -Name "SQLServerReportingServices" 
    } 
}