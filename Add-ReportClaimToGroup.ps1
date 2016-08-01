<#
.SYNOPSIS
   Adds report permissions to Claim Group(s) on all servers.
.DESCRIPTION
   Adds report permissions to Claim Group(s) on all servers using the sup.InsertClaimToGroup stored procedure.
.PARAMETER ClaimValue
   [string] The report name to be added.
.PARAMETER ClaimGroup
   [string] The claim group to give permission to.
.EXAMPLE
   ./Add-ReportClaimToGroup -ClaimValue "NIPR Download History"  -ClaimGroup "Administrative Operations"
.NOTES
   Author: 	Gary Clausen
   Created: 2015.07.28
   Notes:   As of 7/28/2015, this script is still under development.
#>

param(
	[Parameter(Mandatory = $true)] [string]$ClaimValue
	)
cls;

cls;
$claimUrl = "http://www.eberls.com/security/reports";
$claimRights = 2;
$claimValue = "NIPR Download History";
$claimCreatedBy = 39777;
$claimCreatedOn =  Get-Date -Format "MM/dd/yyyy HH:mm";
$claimValueToSearch = "Licensing Reports";

#region Insert Claim To Group
Function InsertClaimToGroup ()
{
  Param ([Parameter(position=1,Mandatory = $true )]       [String] $server,
	       [Parameter(position=2,Mandatory = $true )]     [String] $ClaimGroup,
	       [Parameter(position=3,Mandatory = $true )]     [String] $claimUrl,
	       [Parameter(position=4,Mandatory = $true )]     [String] $claimRights,
           [Parameter(position=5,Mandatory = $true )]     [String] $claimValue,
           [Parameter(position=5,Mandatory = $true )]     [String] $claimCreatedBy,
	       [Parameter(position=6,Mandatory = $true )]     [String] $claimCreatedOn )  

    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection("Server=$server;Database=Kermit;Integrated Security=SSPI");

    $SqlConnection.Open();
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand("sup.InsertClaimToGroup", $SqlConnection);
    $SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure;

    # Claim Group
    $SqlCmd.Parameters.Add("@ClaimGroup", [System.Data.SqlDbType]::VarChar);
    $SqlCmd.Parameters["@ClaimGroup"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@ClaimGroup"].Value = $groupName;

    # Claim Url
    $SqlCmd.Parameters.Add("@ClaimUrl", [System.Data.SqlDbType]::VarChar);
    $SqlCmd.Parameters["@ClaimUrl"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@ClaimUrl"].Value = $claimUrl;

    # Claim Value
    $SqlCmd.Parameters.Add("@ClaimValue", [System.Data.SqlDbType]::VarChar);
    $SqlCmd.Parameters["@ClaimValue"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@ClaimValue"].Value = $claimValue;

    # Rights
    $SqlCmd.Parameters.Add("@Rights", [System.Data.SqlDbType]::VarChar);
    $SqlCmd.Parameters["@Rights"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@Rights"].Value = $claimRights;

    # Enabled
    $SqlCmd.Parameters.Add("@Enabled", [System.Data.SqlDbType]::Int);
    $SqlCmd.Parameters["@Enabled"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@Enabled"].Value = 1;

    # Created By
    $SqlCmd.Parameters.Add("@CreatedBy", [System.Data.SqlDbType]::BigInt);
    $SqlCmd.Parameters["@CreatedBy"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@CreatedBy"].Value = $claimCreatedBy;

    # Created On
    $SqlCmd.Parameters.Add("@CreatedOn", [System.Data.SqlDbType]::DateTime);
    $SqlCmd.Parameters["@CreatedOn"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@CreatedOn"].Value = $claimCreatedBy;

    $SqlCmd.ExecuteNonQuery();
    $SqlConnection.Close();
}
#endregion Insert Claim To Group

$groupSql = "SELECT cg.Name As GroupName " +
            "FROM dbo.ClaimToGroup AS ctg " +
            "JOIN dbo.Claim AS c ON ctg.ClaimId = c.Id " + 
            "JOIN dbo.ClaimGroup AS cg ON ctg.ClaimGroupId = cg.Id " +
            "WHERE c.Value = '" + $claimValueToSearch + "';"

Write-Host $groupSql -ForegroundColor Yellow;

$serverArray = @("VTHOSTDEVSQL01", "VTHOSTDEVSQL02", "VTHOSTDEVSQL03", "SQLCLUSTER");

foreach ($server in $serverArray)
{
    Write-Host "Processing $server" -ForegroundColor Magenta;

    $groups = sql2 -ServerInstance $server -Database "Kermit" -Query $groupSql -QueryTimeout 120 -Verbose;

    foreach ($group in $groups)
    {
        $groupName = $group.GroupName;
        Write-Host "    Found group $groupName" -ForegroundColor Green;

        InsertClaimToGroup $server $ClaimGroup $claimUrl $claimRights $claimValue $claimCreatedBy $claimCreatedOn;
    }
}