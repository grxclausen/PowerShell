<#
.SYNOPSIS
   Adds report Claim Value to all servers.
.DESCRIPTION
   Adds report Claim Value to all servers using the sup.InsertClaim stored procedure.
.PARAMETER Claim Value
   [string] The report name to be added.
.EXAMPLE
   ./Add-ReportClaim -ClaimValue "NIPR Download History"
.NOTES
   Author: 	Gary Clausen
   Created: 2015.07.28
#>

param(
	[Parameter(Mandatory = $true)] [string]$ClaimValue
	)
cls;

$serverArray = @("VTHOSTDEVSQL01", "VTHOSTDEVSQL02", "VTHOSTDEVSQL03", "SQLCLUSTER");

foreach ($server in $serverArray)
{ 
    $loopServer = $server;
    Write-Host "Adding claim to: $loopServer";

    $claimUrl = "http://www.eberls.com/security/reports";
    $value = $ClaimValue;
    $description = "Name of Report on SSRS Report Server";
    $createdBy = 39777;
    $createdOn = Get-Date -Format "MM/dd/yyyy HH:mm";

    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection("Server=$loopServer;Database=Kermit;Integrated Security=SSPI");

    $SqlConnection.Open();
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand("sup.InsertClaim", $SqlConnection);
    $SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure;

    $SqlCmd.Parameters.Add("@ClaimUrl", [System.Data.SqlDbType]::VarChar);
    $SqlCmd.Parameters["@ClaimUrl"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@ClaimUrl"].Value = $claimUrl;

    $SqlCmd.Parameters.Add("@Value", [System.Data.SqlDbType]::VarChar);
    $SqlCmd.Parameters["@Value"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@Value"].Value = $value;

    $SqlCmd.Parameters.Add("@Description", [System.Data.SqlDbType]::VarChar);
    $SqlCmd.Parameters["@Description"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@Description"].Value = $description;

    $SqlCmd.Parameters.Add("@CreatedBy", [System.Data.SqlDbType]::BigInt);
    $SqlCmd.Parameters["@CreatedBy"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@CreatedBy"].Value = $createdBy;

    $SqlCmd.Parameters.Add("@CreatedOn", [System.Data.SqlDbType]::DateTime);
    $SqlCmd.Parameters["@CreatedOn"].Direction = [system.data.ParameterDirection]::Input
    $SqlCmd.Parameters["@CreatedOn"].Value = $createdOn;

    $SqlCmd.ExecuteNonQuery();
    $SqlConnection.Close();
}
