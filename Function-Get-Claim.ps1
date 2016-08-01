#region Process Claim
<#
.SYNOPSIS
   Compares Security Claims between Claims tables on Kermit
.DESCRIPTION   
   This function compares Claims between servers and suggests insert, update, and deletes
   and generates the statements.
.EXAMPLE
   ./Get-Claim.ps1 -FromServer 'VTHOSTDEVSQL01' -ToServer 'VTHOSTDEVSQL02'
.INPUTS
   FromServer - the left hand or server comparing from
   ToServer - the right hand or server comapring to
.OUTPUTS
   SQL text to perfrom Claim insert, update, or delete.
.NOTES
	Author: Gary Clausen
	Date:   6/10/2016
#>


Function Get-Claim ()
{
	param(
		[Parameter(Position = 0, Mandatory = $true)]	[string]$FromServer,
		[Parameter(Position = 1, Mandatory = $true)]    [string]$ToServer
		)
		
	
	Write-Host "---------------------------------------------------" -ForegroundColor Yellow
	Write-Host " Claim " -ForegroundColor Yellow
	Write-Host "---------------------------------------------------" -ForegroundColor Yellow
	
	# Insert Claim
	$insClaimSql = @"
SELECT *
FROM
( SELECT 'EXEC sup.InsertClaim ' +
            CASE WHEN lClaimUrl.Url IS NOT NULL THEN QUOTENAME(lClaimUrl.Url, '''') + ', ' ELSE 'NULL, ' END +
            CASE WHEN l.[Value] IS NOT NULL THEN QUOTENAME(CAST(l.[Value] AS VARCHAR(100)), '''') + ', ' ELSE 'NULL, ' END +
            CASE WHEN l.[Description] IS NOT NULL THEN QUOTENAME(CAST(l.[Description] AS VARCHAR(512)), '''') + ', ' ELSE 'NULL, ' END +
            CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
            QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
            ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' AS InsertClaimStmt
FROM $FromServer.dbo.Claim AS l
JOIN $FromServer.dbo.ClaimUrl AS lClaimUrl ON lClaimUrl.Id = l.ClaimUrlId
LEFT JOIN $ToServer.dbo.ClaimUrl AS rClaimUrl ON rClaimUrl.Url = lClaimUrl.Url
LEFT JOIN $ToServer.dbo.Claim AS r ON rClaimUrl.Id = r.ClaimUrlId 
      AND ( (r.Value IS NULL AND l.Value IS NULL) OR r.Value = l.Value )
WHERE ( r.Id IS NULL ) ) AS x
ORDER BY InsertClaimStmt;
"@

	$stmts = sql2 -ServerInstance "VTHOSTDEVSQL02" -Database Kermit -Query $insClaimSql -QueryTimeout 120

	if ($stmts.Count -eq 0)
	{
		Write-Host "No Claim(s) need to be inserted." -ForegroundColor Magenta
	}
	else
	{
		foreach($stmt in $stmts)
		{
			Write-Host $stmt.InsertClaimStmt
		}
	}
	
	# Update Claim
	$updClaimSql = @"
SELECT *
FROM ( SELECT 'EXEC sup.UpdateClaim ' +
                  CASE WHEN lClaimUrl.Url IS NOT NULL THEN QUOTENAME(lClaimUrl.Url, '''') + ', ' ELSE 'NULL, ' END +
                  CASE WHEN l.[Value] IS NOT NULL THEN QUOTENAME(CAST(l.[Value] AS VARCHAR(100)), '''') + ', ' ELSE 'NULL, ' END +
                 CASE WHEN l.[Description] IS NOT NULL THEN CONVERT(VARCHAR(512), '''' + l.[Description] + '''' + ', ') ELSE 'null, ' END +
                 CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
                 QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
                 ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
                 ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' AS UpdateClaimStmt
        FROM $FromServer.dbo.Claim AS l
        JOIN $FromServer.dbo.ClaimUrl AS lClaimUrl ON lClaimUrl.Id = l.ClaimUrlId
        LEFT JOIN $ToServer.dbo.ClaimUrl AS rClaimUrl ON rClaimUrl.Url = lClaimUrl.Url
        LEFT JOIN $ToServer.dbo.Claim AS r ON rClaimUrl.Id = r.ClaimUrlId 
            AND ((r.Value IS NULL AND l.Value IS NULL) OR r.Value = l.Value)
        WHERE r.Id IS NOT NULL
        AND (r.[Description] != l.[Description]
        OR ((r.[Value] IS NULL AND l.[Value] IS NOT NULL) OR (r.[Value] IS NOT NULL AND l.[Value] IS NULL) OR r.[Value] != l.[Value])) ) AS x
ORDER BY UpdateClaimStmt;	
"@

		$stmts = sql2 -ServerInstance "VTHOSTDEVSQL02" -Database Kermit -Query $updClaimSql -QueryTimeout 120

		if ($stmts.Count -eq 0)
		{
			Write-Host "No Claim(s) need to be updated." -ForegroundColor Magenta
		}
		else
		{
			foreach($stmt in $stmts)
			{
			Write-Host $stmt.UpdateClaimStmt -ForegroundColor Green
		}
	}
	
	# Delete Claim
	$delClaimSql = @"
SELECT *
FROM ( SELECT 'EXEC sup.DeleteClaim ' +
                  ISNULL(QUOTENAME(lClaimUrl.Url, ''''), ' NULL') + ', ' +
                  ISNULL(QUOTENAME(l.[Value], ''''), ' NULL') + ', ' +
                  ISNULL(QUOTENAME(l.[Description], ''''),  ' NULL') + ', ' +
                 QUOTENAME(CAST(l.CreatedBy AS VARCHAR(10)), '''') + ';'  AS DeleteClaimStmt
        FROM $ToServer.dbo.Claim AS l
        JOIN $ToServer.dbo.ClaimUrl AS lClaimUrl ON lClaimUrl.Id = l.ClaimUrlId
        LEFT JOIN $FromServer.dbo.ClaimUrl AS rClaimUrl ON rClaimUrl.Url = lClaimUrl.Url
        LEFT JOIN $FromServer.dbo.Claim AS r ON rClaimUrl.Id = r.ClaimUrlId 
            AND ((r.Value IS NULL AND l.Value IS NULL) OR r.Value = l.Value)
        WHERE r.Id IS NULL ) AS x
        ORDER BY DeleteClaimStmt;   
"@

		$stmts = sql2 -ServerInstance "VTHOSTDEVSQL02" -Database Kermit -Query $delClaimSql -QueryTimeout 120

		if ($stmts.Count -eq 0)
		{
			Write-Host "No Claim(s) need to be deleted." -ForegroundColor Magenta
		}
		else
		{
			foreach($stmt in $stmts)
			{
			Write-Host $stmt.DeleteClaimStmt -ForegroundColor Green
		}
	}
}

cls
Get-Claim "VTHOSTDEVSQL03.Kermit" "SQLCLUSTER.Kermit"
#endregion