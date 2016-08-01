$serverArray = @("VTHOSTDEVSQL01", "VTHOSTDEVSQL02", "VTHOSTDEVSQL03", "SQLCLUSTER")

cls

foreach($server in $serverArray)
{
    Write-Host "Adding claim to group rows for $server"
    Add-SecurityClaimToGroup -Server $server -FolderName "Deployment Reports" -Url "http://www.eberls.com/security/reports" -Value "Active managers with Adjusters" -Rights 2 -Enabled 1
}