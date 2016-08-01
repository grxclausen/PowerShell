<#
.SYNOPSIS
   Returns currently running queries for troubleshooting.
.DESCRIPTION   
   Runs a T-SQL script that outputs currently running queries, 
   Start Time, SPID, Database, Executing SQL Status, Command, Wait Type, Wait Time,
   Wait Resource, and Last Wait Type. 
.EXAMPLE
   ./Get-RunningQueries.ps1 -Server 'SQLCLUSTER'
.INPUTS
   Server
.OUTPUTS
   Currently running queries.
.NOTES
	Author: Gary Clausen
	Date:   6/6/2016
#>

Function Get-RunningQueries ()
{
	param(
		[Parameter(Position = 0, Mandatory = $true)]	[string]$Server
		)

	$sql = @"
SELECT r.start_time [Start Time],session_ID [SPID]
	,DB_NAME(database_id) [Database]
	,SUBSTRING(t.text,(r.statement_start_offset/2) + 1
	,CASE WHEN statement_end_offset = -1 OR statement_end_offset = 0 
          THEN (DATALENGTH(t.Text) - r.statement_start_offset/2) + 1 
     ELSE (r.statement_end_offset-r.statement_start_offset) / 2 + 1
     END) [Executing SQL]
     ,Status
     ,command AS Command
     ,wait_type AS [Wait Type]
     ,wait_time AS [Wait Time]
     ,wait_resource AS [Wait Resource]
     ,last_wait_type AS [Last Wait Type]
FROM sys.dm_exec_requests r
OUTER APPLY sys.dm_exec_sql_text(sql_handle) t
WHERE ( session_id != @@SPID ) -- don't show this query
AND ( session_id > 50 ) -- don't show system queries
ORDER BY r.start_time;
"@

	$runningQueries = sql2 -Server $Server -Database 'master' -Query $sql

	$runningQueries #| Out-GridView
}

Get-RunningQueries -Server 'SQLCLUSTER'