$server = "localhost"
$db = "DBATools"
$sqlScr = "C:\SQLScripts\Maintenance\Get-Database-File-Sizes.sql"

$dbSizes = Invoke-Sqlcmd -ServerInstance $server -Database $db -InputFile $sqlScr -QueryTimeout 120

$dbSizes | Out-GridView -Title "Database File Sizes"