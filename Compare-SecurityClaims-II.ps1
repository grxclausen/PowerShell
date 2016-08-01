#region Process Claim Url
<#
.SYNOPSIS
   Compares Security Claims between Claims tables on Kermit
.DESCRIPTION   
    
.EXAMPLE
   ./Compare-SecurityClaims.ps1 -FromServer 'VTHOSTDEVSQL01' -ToServer 'VTHOSTDEVSQL02'
.INPUTS
   FromServer - the left hand or server comparing from
   ToServer - the right hand or server comapring to
.OUTPUTS
   SQL text to perfrom Claim URL insert.
.NOTES
	Author: Gary Clausen
	Date:   2016.6.2
#>

Function Get-Claim-UrL ()
{
	param(
		[Parameter(Position = 0, Mandatory = $true)]	[string]$FromServer,
		[Parameter(Position = 1, Mandatory = $true)]    [string]$ToServer
		)

	Write-Host "---------------------------------------------------" -ForegroundColor Yellow
	Write-Host " Claim Url " -ForegroundColor Yellow
	Write-Host "---------------------------------------------------" -ForegroundColor Yellow

	# Insert Claim Url
	$insClaimUrlSql = @"
SELECT 'EXEC sup.InsertClaimUrl ' +
            QUOTENAME(l.Url, '''') + ', ' +
            QUOTENAME(l.[Description], '''') + ', ' +
            CAST(l.IsUserClaim AS VARCHAR(5)) + ', ' +
            CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
            QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
            ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' AS InsertClaimUrlStmt
FROM $TromServer.dbo.ClaimUrl as l
LEFT JOIN $ToServer.dbo.ClaimUrl AS r ON r.Url = l.Url
WHERE r.Id IS NULL;
"@

	$stmts = Invoke-Sqlcmd2 -ServerInstance localhost -Database Kermit -Query $insClaimUrlSql -QueryTimeout 120

	if ($stmts.Count -eq 0)
	{
		Write-Host "No URL(s) need to be inserted." -ForegroundColor Magenta
	}
	else
	{
		foreach($stmt in $stmts)
		{
			Write-Host $stmt.InsertClaimUrlStmt
		}
	}

	# Update Claim Url
	$updClaimUrlSql = @"
SELECT 'EXEC sup.UpdateClaimUrl ' +
            QUOTENAME(l.Url, '''') + ', ' +
            QUOTENAME(l.Description, '''') + ', ' +
            CAST(l.IsUserClaim AS VARCHAR(5)) + ', ' +
            CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
            QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
            ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';'  AS UpdateClaimUrlStmt
FROM $FromServer.dbo.ClaimUrl as l
LEFT JOIN $ToServer.dbo.ClaimUrl as r on r.Url = l.Url
WHERE r.Id IS NOT NULL
AND (r.[Description] != l.[Description] OR r.IsUserClaim != l.IsUserClaim);
"@

	$stmts = Invoke-Sqlcmd2 -ServerInstance localhost -Database Kermit -Query $insClaimUrlSql -QueryTimeout 120

	if ($stmts.Count -eq 0)
	{
		Write-Host "No URL(s) need to be updated." -ForegroundColor Magenta
	}
	else
	{
		foreach($stmt in $stmts)
		{
			Write-Host $stmt.InsertClaimUrlStmt
		}
	}

	# Delete Claim Url
    $delClaimUrlSql = @"
SELECT 'EXEC sup.DeleteClaimUrl ' +
            QUOTENAME(l.Url, '''') + ', ' +
            QUOTENAME(l.[Description], '''') + ', ' +
            CAST(l.IsUserClaim AS VARCHAR(5)) + ', ' +
            CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
            QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
            ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';'  AS DeleteClaimUrlStmt
FROM $ToServer.dbo.ClaimUrl AS l
LEFT JOIN $FromServer.dbo.ClaimUrl AS r ON r.Url = l.Url
WHERE r.Id IS NULL;
"@
	$stmts = Invoke-Sqlcmd2 -ServerInstance localhost -Database Kermit -Query $delClaimUrlSql -QueryTimeout 120

	if ($stmts.Count -eq 0)
	{
		Write-Host "No URL(s) need to be deleted." -ForegroundColor Magenta
	}
	else
	{
		foreach($stmt in $stmts)
		{
			Write-Host $stmt.DeleteClaimUrlStmt
		}
	}
} # end function

cls
Get-Claim-UrL "SQLCLUSTER.Kermit" "VTHOSTDEVSQL03.Kermit"
#endregion