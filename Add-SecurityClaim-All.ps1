$serverArray = @("VTHOSTDEVSQL01", "VTHOSTDEVSQL02", "VTHOSTDEVSQL03", "SQLCLUSTER")

foreach ($server in $serverArray)
{
    Write-Host "Adding claim to $server"
    Add-SecurityClaim -Server $server -Url "http://www.eberls.com/security/reports" -Value "Active managers with Adjusters" -Description "Name of Report on SSRS Report Server"
}