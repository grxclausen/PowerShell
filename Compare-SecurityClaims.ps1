$fromServer = 'SQLCLUSTER.Kermit'
$toServer = 'VTHOSTDEVSQL03.Kermit'

Write-Host "---------------------------------------------------" -ForegroundColor Yellow
Write-Host " Claim Url " -ForegroundColor Yellow
Write-Host "---------------------------------------------------" -ForegroundColor Yellow

#region Insert Claim Url
$insClaimUrlSql = @"
SELECT 'EXEC sup.InsertClaimUrl ' +
            QUOTENAME(l.Url, '''') + ', ' +
            QUOTENAME(l.[Description], '''') + ', ' +
            CAST(l.IsUserClaim AS VARCHAR(5)) + ', ' +
            CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
            QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
            ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' +
            '  --  ' + '$fromServer' + ' ---> ' + '$toServer   ' +
            ( SELECT '    ' + up.LastName
              FROM dbo.UserPersonal as up
              WHERE up.UserId = ISNULL( l.ChangedBy, l.CreatedBy ) ) +
            '     ClaimUrl.Id( ' + CAST(l.Id AS VARCHAR(10)) + ' vs ' + CASE WHEN r.Id IS NOT NULL THEN CAST(r.Id AS VARCHAR(10)) ELSE 'NULL'  END + ' ) ' AS InsertClaimUrlStmt
FROM $fromServer.dbo.ClaimUrl as l
LEFT JOIN $toServer.dbo.ClaimUrl AS r ON r.Url = l.Url
WHERE r.Id IS NULL;
"@

$stmts = sql2 -ServerInstance localhost -Database Kermit -Query $insClaimUrlSql -QueryTimeout 120

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
#endregion

#region Update Claim Url
$updClaimUrlSql = @"
SELECT 'EXEC sup.UpdateClaimUrl ' +
            QUOTENAME(l.Url, '''') + ', ' +
            QUOTENAME(l.Description, '''') + ', ' +
            CAST(l.IsUserClaim AS VARCHAR(5)) + ', ' +
            CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
            QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
            ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' +
            + '  --  ' + '$fromServer' + ' ---> ' + '$toServer   ' +
            ( SELECT '    ' + up.LastName
              FROM dbo.UserPersonal as up
              WHERE up.UserId = ISNULL( l.ChangedBy, l.CreatedBy ) ) +
            '     ClaimUrl.Id( ' + CAST(l.Id AS VARCHAR(15)) + ' vs ' +  CASE WHEN r.Id IS NOT NULL THEN CAST(r.Id AS VARCHAR(15)) ELSE 'NULL' END + ' ) ' AS UpdateClaimUrlStmt
FROM $fromServer.dbo.ClaimUrl as l
LEFT JOIN $toServer.dbo.ClaimUrl as r on r.Url = l.Url
WHERE r.Id IS NOT NULL
AND (r.[Description] != l.[Description] OR r.IsUserClaim != l.IsUserClaim);
"@

$stmts = sql2 -ServerInstance localhost -Database Kermit -Query $updClaimUrlSql -QueryTimeout 120

if ($stmts.Count -eq 0)
{
    Write-Host "No URL(s) need to be updated." -ForegroundColor Magenta
}
else
{
    foreach($stmt in $stmts)
    {
        Write-Host $stmt.UpdateClaimUrlStmt
    }
}

#endregion

#region Delete Claim Url
$delClaimUrlSql = @"
SELECT 'EXEC sup.DeleteClaimUrl ' +
            QUOTENAME(l.Url, '''') + ', ' +
            QUOTENAME(l.[Description], '''') + ', ' +
            CAST(l.IsUserClaim AS VARCHAR(5)) + ', ' +
            CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
            QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
            ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' + 
           '  --  ' + '$fromServer' + ' ---> ' + '$toServer   ' +
                  ( SELECT '    ' + up.LastName
                    FROM UserPersonal AS up
                    WHERE up.UserId = ISNULL( l.ChangedBy, l.CreatedBy )) +
                        '     ClaimUrl.Id( ' + CAST(l.Id AS VARCHAR(10)) + ' vs ' + CASE WHEN r.Id IS NOT NULL THEN CAST(r.Id AS VARCHAR(10)) ELSE 'NULL' END + ' ) ' AS DeleteClaimUrlStmt
FROM $toServer.dbo.ClaimUrl AS l
LEFT JOIN $fromServer.dbo.ClaimUrl AS r ON r.Url = l.Url
WHERE r.Id IS NULL;
"@

$stmts = sql2 -ServerInstance localhost -Database Kermit -Query $delClaimUrlSql -QueryTimeout 120

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

#endregion

Write-Host "---------------------------------------------------" -ForegroundColor Yellow
Write-Host " Claim " -ForegroundColor Yellow
Write-Host "---------------------------------------------------" -ForegroundColor Yellow
#region Insert Claim
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
            ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' + 
            '  --  ' + '$fromServer' + ' ---> ' + '$toServer   ' +
            ( SELECT '    ' + up.LastName
              FROM dbo.UserPersonal AS up
              WHERE up.UserId = ISNULL( l.ChangedBy, l.CreatedBy ) ) +
            '     Claim.Id( ' + CAST(l.Id AS VARCHAR(10)) + ' vs ' + CASE WHEN r.Id IS NOT NULL THEN CAST(r.Id AS VARCHAR(10)) ELSE 'NULL'  END + ' ) ' AS InsertClaimStmt
FROM $fromServer.dbo.Claim AS l
JOIN $fromServer.dbo.ClaimUrl AS lClaimUrl ON lClaimUrl.Id = l.ClaimUrlId
LEFT JOIN $toServer.dbo.ClaimUrl AS rClaimUrl ON rClaimUrl.Url = lClaimUrl.Url
LEFT JOIN $toServer.dbo.Claim AS r ON rClaimUrl.Id = r.ClaimUrlId 
      AND ( (r.Value IS NULL AND l.Value IS NULL) OR r.Value = l.Value )
WHERE ( r.Id IS NULL ) ) AS x
ORDER BY InsertClaimStmt;
"@

$stmts = sql2 -ServerInstance localhost -Database Kermit -Query $insClaimSql -QueryTimeout 120

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
#endregion

#region Update Claim
$updClaimSql = @"
SELECT *
FROM ( SELECT 'EXEC sup.UpdateClaim ' +
                  CASE WHEN lClaimUrl.Url IS NOT NULL THEN QUOTENAME(lClaimUrl.Url, '''') + ', ' ELSE 'NULL, ' END +
                  CASE WHEN l.[Value] IS NOT NULL THEN QUOTENAME(CAST(l.[Value] AS VARCHAR(100)), '''') + ', ' ELSE 'NULL, ' END +
                  '/* ' + CASE WHEN r.[Value] IS NOT NULL THEN CONVERT(VARCHAR(100), '''' + r.[Value] + '''') ELSE 'NULL ' END + ' */  ' + 
                 CASE WHEN l.[Description] IS NOT NULL THEN CONVERT(VARCHAR(512), '''' + l.[Description] + '''' + ', ') ELSE 'null, ' END +
                  '/* ' + CASE WHEN r.[Description] IS NOT NULL THEN CONVERT(VARCHAR(512), '''' + r.[Description] + '''') ELSE 'NULL ' END + ' */  ' + 
                 CAST(l.CreatedBy AS VARCHAR(10)) + ', ' +
                 QUOTENAME(CONVERT(VARCHAR(25), l.CreatedOn, 120), '''') + ', ' +
                 ISNULL(CAST(l.ChangedBy AS VARCHAR(10)), ' NULL') + ', ' +
                 ISNULL(QUOTENAME(CONVERT(VARCHAR(25), l.ChangedOn, 120), ''''), ' NULL') + ';' + 
                  '  --  ' + '$fromServer' + ' ---> ' + '$toServer   ' +
                  ( SELECT '    ' + up.LastName
                    FROM dbo.UserPersonal AS up
                    WHERE up.UserId = ISNULL( l.ChangedBy, l.CreatedBy ) ) +
                  '     Claim.Id( ' + CAST(l.Id AS VARCHAR(10)) + ' vs ' + CASE WHEN r.Id IS NOT NULL THEN CAST(r.Id AS VARCHAR(10)) ELSE 'NULL' END + ' ) ' AS UpdateClaimStmt
        FROM $fromServer.dbo.Claim AS l
        JOIN $fromServer.dbo.ClaimUrl AS lClaimUrl ON lClaimUrl.Id = l.ClaimUrlId
        LEFT JOIN $toServer.dbo.ClaimUrl AS rClaimUrl ON rClaimUrl.Url = lClaimUrl.Url
        LEFT JOIN $toServer.dbo.Claim AS r ON rClaimUrl.Id = r.ClaimUrlId 
            AND ((r.Value IS NULL AND l.Value IS NULL) OR r.Value = l.Value)
        WHERE r.Id IS NOT NULL
        AND (r.[Description] != l.[Description]
        OR ((r.[Value] IS NULL AND l.[Value] IS NOT NULL) OR (r.[Value] IS NOT NULL AND l.[Value] IS NULL) OR r.[Value] != l.[Value])) ) AS x
ORDER BY UpdateClaimStmt;
"@

$stmts = sql2 -ServerInstance localhost -Database Kermit -Query $updClaimSql -QueryTimeout 120

if ($stmts.Count -eq 0)
{
    Write-Host "No Claim(s) need to be updated." -ForegroundColor Magenta
}
else
{
    foreach($stmt in $stmts)
    {
        Write-Host $stmt.UpdateClaimStmt
    }
}
#endregion

#region
$delClaimSql = @"
SELECT *
FROM ( SELECT 'EXEC sup.DeleteClaim ' +
                  ISNULL(QUOTENAME(lClaimUrl.Url, ''''), ' NULL') + ', ' +
                  ISNULL(QUOTENAME(l.[Value], ''''), ' NULL') + ', ' +
                  ISNULL(QUOTENAME(l.[Description], ''''),  ' NULL') + ', ' +
                 QUOTENAME(CAST(l.CreatedBy AS VARCHAR(10)), '''') + ';' + 
                  '  --  ' + '$fromServer' + ' ---> ' + '$toServer   ' +
                  ( SELECT '    ' + up.LastName
                    FROM UserPersonal AS up
                    WHERE up.UserId = ISNULL(l.ChangedBy, l.CreatedBy) ) +
                        '     Claim.Id( ' + CAST(l.Id AS VARCHAR(10)) + ' vs ' + CASE WHEN r.Id IS NOT NULL THEN CAST(r.Id AS VARCHAR(10)) ELSE 'NULL' END + ' ) ' AS DeleteClaimStmt
        FROM $toServer.dbo.Claim AS l
        JOIN $toServer.dbo.ClaimUrl AS lClaimUrl ON lClaimUrl.Id = l.ClaimUrlId
        LEFT JOIN $fromServer.dbo.ClaimUrl AS rClaimUrl ON rClaimUrl.Url = lClaimUrl.Url
        LEFT JOIN $fromServer.dbo.Claim AS r ON rClaimUrl.Id = r.ClaimUrlId 
            AND ((r.Value IS NULL AND l.Value IS NULL) OR r.Value = l.Value)
        WHERE r.Id IS NULL ) AS x
        ORDER BY DeleteClaimStmt;   
"@
$stmts = sql2 -ServerInstance localhost -Database Kermit -Query $delClaimSql -QueryTimeout 120

if ($stmts.Count -eq 0)
{
    Write-Host "No Claim(s) need to be deleted." -ForegroundColor Magenta
}
else
{
    foreach($stmt in $stmts)
    {
        Write-Host $stmt.DeleteClaimStmt
    }
}
#endregion