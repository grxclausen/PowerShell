##################################################################
# Date: 2/14/2022
# Name: GetIndexStats.ps1
# Purpose: Returns index fragmentation maintenance statements
##################################################################
$server = "localhost"
$db = "WideWorldImporters"
$sqlScr = "C:\SQLScripts\Maintenance\Get-Index-Fragmentation.sql"

$indexStats = Invoke-Sqlcmd -ServerInstance $server -Database $db -QueryTimeout 120 -InputFile $sqlScr

Clear-Host

Write-Host "Number of indexes to be rebuilt/reorganized: " ($indexStats).Count -ForegroundColor Green

foreach ( $row in $indexStats ) {
    Write-Host($row.index_maint_stmt)
}