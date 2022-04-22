$server = "localhost"
$db = "DBATools"
$qry = "EXEC  dbo.Get_AgentSchedules"

$jobs = Invoke-Sqlcmd -ServerInstance $server -Database $db -Query $qry -QueryTimeout 120

$jobs | Out-GridView -Title "SQL Server Agent Jobs"