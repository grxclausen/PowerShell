$leftServer = "VTHOSTDEVSQL03"
$rightServer = "SQLCLUSTER"
$Database = "Kermit"

$qry = "
SELECT fc.FeatureId
	,f.Name AS FeatureName
    ,fc.ClaimId
	,c.Value
	,cu.Url
      ,fc.CreatedBy
      ,fc.CreatedOn
      ,fc.ChangedBy
      ,fc.ChangedOn
FROM dbo.FeatureClaim AS fc
JOIN dbo.Feature AS f ON fc.FeatureId = f.Id
JOIN dbo.Claim AS c ON fc.ClaimId = c.Id
JOIN dbo.ClaimUrl AS cu ON c.ClaimUrlId = cu.Id "


cls
$leftData = sql2 -ServerInstance $leftServer -Database $Database -Query $qry -QueryTimeout 60
$rightData = sql2 -ServerInstance $rightServer -Database $Database -Query $qry -QueryTimeout 60

Compare-Object -ReferenceObject $leftData -DifferenceObject $rightData -Property Name, FeatureId, Value, Url -PassThru | Format-Table -AutoSize #| Sort-Object Name | Select-Object FeatureId, FeatureName, ClaimId, Value, Url
