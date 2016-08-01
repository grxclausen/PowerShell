<#
.SYNOPSIS
   Adds a new Security Claim.
.DESCRIPTION
   Executes the sup.InsertClaim stored procedure to insert a new claim in dbo.Claim.
.PARAMETER Server
   string
.PARAMETER Url
   string - Will translate in to the UrlId in Claim.
.PARAMETER Value
   string - The Value column in Claim - the report/object name to be inserted.
.PARAMETER Description
   string - The Desctiption column in Claim.
.EXAMPLE
   ./Add-SecurityClaim -Server SQLCLUSTER -Url "http://www.eberls.com/security/user/docs" -Value "MyTestReport" -Description "Name of SSRS Report on Server"
.NOTES
	Author:  Gary Clausen
	Created: 10/21/2015 16:40
#>


param( [Parameter(Position = 0, Mandatory = $true)] [string]$Server,
       [Parameter(Position = 1, Mandatory = $true)] [string]$Url,
       [Parameter(Position = 2, Mandatory = $true)] [string]$Value,
       [Parameter(Position = 1, Mandatory = $true)] [string]$Description
)

$createdBy = 39777
$createdOn = Get-Date
$sqlCmdString = "sup.InsertClaim"
$sqlCmdTimeout = 60

$connString = "Data Source=$Server;Initial Catalog=Kermit;Integrated Security=SSPI;"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = $connString

$sqlCmd = New-Object System.Data.SqlClient.SqlCommand
$sqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
$sqlCmd.CommandText = $sqlCmdString
$sqlCmd.CommandTimeout = $sqlCmdTimeout
$sqlCmd.Connection = $sqlConnection


$sqlCmd.Parameters.Add("@ClaimUrl",[System.Data.SqlDbType]::VarChar) | Out-Null
$sqlCmd.Parameters['@ClaimUrl'].Direction = [System.Data.ParameterDirection]::Input
$sqlCmd.Parameters['@ClaimUrl'].Value = $Url


$sqlCmd.Parameters.Add("@Value",[System.Data.SqlDbType]::VarChar) | Out-Null
$sqlCmd.Parameters['@Value'].Direction = [System.Data.ParameterDirection]::Input
$sqlCmd.Parameters['@Value'].Value = $Value

$sqlCmd.Parameters.Add("@Description",[System.Data.SqlDbType]::VarChar) | Out-Null
$sqlCmd.Parameters['@Description'].Direction = [System.Data.ParameterDirection]::Input
$sqlCmd.Parameters['@Description'].Value = $Description

$sqlCmd.Parameters.Add("@CreatedBy",[System.Data.SqlDbType]::Int) | Out-Null
$sqlCmd.Parameters['@CreatedBy'].Direction = [System.Data.ParameterDirection]::Input
$sqlCmd.Parameters['@CreatedBy'].Value = $createdBy

$sqlCmd.Parameters.Add("@CreatedOn",[System.Data.SqlDbType]::DateTime) | Out-Null
$sqlCmd.Parameters['@CreatedOn'].Direction = [System.Data.ParameterDirection]::Input
$sqlCmd.Parameters['@CreatedOn'].Value = $createdOn

try {
    $sqlConnection.Open()
    $sqlCmd.ExecuteNonQuery() | Out-Null

    Write-Host "The Security Claim for $Value was inserted." -ForegroundColor Green
}
catch {
    $exType = $( $_.Exception.GetType().FullName)
    $exMsg = $( $_.Exception.Message)
    Write-Host "A problem occurred copying the backup: $exType $exMsg" -ForegroundColor Red 
}
finally {
    $sqlConnection.Close()
}
 