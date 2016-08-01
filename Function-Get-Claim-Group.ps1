#region Process Claim Group
<#
.SYNOPSIS
   Compares Security Claim Groups between Claims tables on Kermit
.DESCRIPTION   
   This function compares Claims between servers and suggests insert, update, and deletes
   and generates the statements.
.EXAMPLE
   ./Get-Claim-Group.ps1 -FromServer 'VTHOSTDEVSQL01' -ToServer 'VTHOSTDEVSQL02'
.INPUTS
   FromServer - the left hand or server comparing from
   ToServer - the right hand or server comapring to
.OUTPUTS
   SQL text to perfrom Claim Group  insert, update, or delete.
.NOTES
	Author: Gary Clausen
	Date:   6/10/2016
#>

Function Get-Claim-Group ()
{
	param(
		[Parameter(Position = 0, Mandatory = $true)]	[string]$FromServer,
		[Parameter(Position = 1, Mandatory = $true)]    [string]$ToServer
		)
		
	Write-Host "---------------------------------------------------" -ForegroundColor Yellow
	Write-Host " Claim Group " -ForegroundColor Yellow
	Write-Host "---------------------------------------------------" -ForegroundColor Yellow
	
	# Insert Claim Group
	$insClaimGroupSql = @"
SELECT 'EXEC sup.InsertClaimGroup ' +
         QUOTENAME(l.[Name], '''') + ', ' +
         CAST(l.IsDisplayedForApproval AS VARCHAR(10)) + ', ' +
         CAST(l.IsAdjusterRecordRequiredOnApproval AS VARCHAR(5)) + ', ' +
         CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
         QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
         ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ';' AS InsertClaimGroupStmt
FROM $FromServer.dbo.ClaimGroup AS l
LEFT JOIN $ToServer.dbo.ClaimGroup AS r ON r.Name = l.Name
WHERE r.Id IS NULL;
"@

	$stmts = sql2 -ServerInstance "VTHOSTDEVSQL02" -Database Kermit -Query $insClaimGroupSql -QueryTimeout 120

	if ($stmts.Count -eq 0)
	{
		Write-Host "No Group(s) need to be inserted." -ForegroundColor Magenta
	}
	else
	{
		foreach($stmt in $stmts)
		{
			Write-Host $stmt.InsertClaimGroupStmt -ForegroundColor Green
		}
	}
	
	# Update Claim Group
	$updClaimGroupSql = @"
SELECT 'EXEC sup.UpdateClaimGroup ' +
        QUOTENAME(l.Name, '''') + ', ' +
        CAST(l.IsDisplayedForApproval AS VARCHAR(5)) + ', ' +
        CAST(l.IsAdjusterRecordRequiredOnApproval AS VARCHAR(5)) + ', ' +
        CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
        QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
        ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
        ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' AS UpdateClaimGroupStmt
FROM $FromServer.dbo.ClaimGroup AS l
LEFT JOIN $ToServer.dbo.ClaimGroup AS r ON r.Name = l.Name
WHERE r.Id IS NOT NULL
AND ( r.[Name] != l.[Name] OR r.IsDisplayedForApproval != l.IsDisplayedForApproval OR r.IsAdjusterRecordRequiredOnApproval != l.IsAdjusterRecordRequiredOnApproval );	
"@

	$stmts = sql2 -ServerInstance "VTHOSTDEVSQL02" -Database Kermit -Query $updClaimGroupSql -QueryTimeout 120

	if ($stmts.Count -eq 0)
	{
		Write-Host "No Group(s) need to be updated." -ForegroundColor Magenta
	}
	else
	{
		foreach($stmt in $stmts)
		{
			Write-Host $stmt.UpdateClaimGroupStmt -ForegroundColor Green
		}
	}
	
	# Delete Claim Group
	$delClaimGroupSql = @"
SELECT 'EXEC sup.DeleteClaimGroup ' +
        QUOTENAME(l.[Name], '''') + ', ' +
        CAST(l.IsDisplayedForApproval AS VARCHAR(5)) + ', ' +
        CAST(l.IsAdjusterRecordRequiredOnApproval AS VARCHAR(5)) + ', ' +
        CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
        QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
        ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
        ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' AS DeleteClaimGroupStmt
FROM $ToServer.dbo.ClaimGroup AS l
LEFT JOIN $FromServer.dbo.ClaimGroup AS r ON r.Name = l.Name
WHERE r.Id IS NULL;
"@
	$stmts = sql2 -ServerInstance "VTHOSTDEVSQL02" -Database Kermit -Query $delClaimGroupSql -QueryTimeout 120

	if ($stmts.Count -eq 0)
	{
		Write-Host "No Group(s) need to be deleted." -ForegroundColor Magenta
	}
	else
	{
		foreach($stmt in $stmts)
		{
			Write-Host $stmt.DeleteClaimGroupStmt -ForegroundColor Green
		}
	}
}	
cls
Get-Claim-Group "VTHOSTDEVSQL03.Kermit" "SQLCLUSTER.Kermit"
#endregion