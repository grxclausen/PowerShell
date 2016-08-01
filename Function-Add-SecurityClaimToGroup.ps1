<#
.SYNOPSIS
   Adds a new Security Claim To Group entry.
.DESCRIPTION
   Executes the sup.InsertClaimToGroup stored procedure to insert a new claim in dbo.ClaimToGroup.
   The group(s) will be determined by the FolderName parameter.
.PARAMETER Server
   string
.PARAMETER FolderName
   string - This would most likely be the folder name
.PARAMETER Url
   string
.PARAMETER Value
   string - The Value column in Claim - the report/object name to give access to.
.PARAMETER Rights
   int
.PARAMETER Enabled
   boolean - User 1(true) or 0(false)
.EXAMPLE
   ./Add-SecurityClaimToGroup -Server SQLCLUSTER -Url "http://www.eberls.com/security/user/docs" -Value "MyTestReport" -Rights 2 -Enabled 1
.NOTES
	Author:  Gary Clausen
	Created: 10/22/2015 12:41
#>

Function Add-SecurityClaimToGroup()
{
	param( [Parameter(Position = 0, Mandatory = $true)] [string]$Server,
	       [Parameter(Position = 1, Mandatory = $true)] [string]$FolderName,
           [Parameter(Position = 2, Mandatory = $true)] [string]$Url,
           [Parameter(Position = 3, Mandatory = $true)] [string]$Value,
           [Parameter(Position = 4, Mandatory = $true)] [int]$Rights,
		   [Parameter(Position = 5, Mandatory = $true)] [int]$Enabled
    )
	
	# Get the list of ClaimGroupNames to give access to the value (report).
	
	$groupSql = "SELECT cg.Name AS ClaimGroupName "
	$groupSql += "FROM dbo.Claim AS c "
	$groupSql += "LEFT JOIN dbo.ClaimToGroup AS ctg ON c.Id = ctg.ClaimId "
	$groupSql += "LEFT JOIN dbo.ClaimGroup AS cg ON ctg.ClaimGroupId = cg.Id "
	$groupSql += "WHERE ( Value = '$FolderName' )"

	$groups = sql2 -ServerInstance $Server -Database Kermit -Query $groupSql -QueryTimeout 120

	foreach ($group in $groups)
	{
		
		$createdBy = 39777
	    $createdOn = Get-Date
	    $sqlCmdString = "sup.InsertClaimToGroup"
	    $sqlCmdTimeout = 60
		
		$connString = "Data Source=$Server;Initial Catalog=Kermit;Integrated Security=SSPI;"
	    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
	    $sqlConnection.ConnectionString = $connString
		
		$sqlCmd = New-Object System.Data.SqlClient.SqlCommand
	    $sqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
	    $sqlCmd.CommandText = $sqlCmdString
	    $sqlCmd.CommandTimeout = $sqlCmdTimeout
	    $sqlCmd.Connection = $sqlConnection
		
		$sqlCmd.Parameters.Add("@ClaimGroup",[System.Data.SqlDbType]::VarChar) | Out-Null
	    $sqlCmd.Parameters['@ClaimGroup'].Direction = [System.Data.ParameterDirection]::Input
	    $sqlCmd.Parameters['@ClaimGroup'].Value = $group.ClaimGroupName
		
		$sqlCmd.Parameters.Add("@ClaimUrl",[System.Data.SqlDbType]::VarChar) | Out-Null
	    $sqlCmd.Parameters['@ClaimUrl'].Direction = [System.Data.ParameterDirection]::Input
	    $sqlCmd.Parameters['@ClaimUrl'].Value = $Url
		
		$sqlCmd.Parameters.Add("@Value",[System.Data.SqlDbType]::VarChar) | Out-Null
	    $sqlCmd.Parameters['@Value'].Direction = [System.Data.ParameterDirection]::Input
	    $sqlCmd.Parameters['@Value'].Value = $Value
		
		$sqlCmd.Parameters.Add("@Rights",[System.Data.SqlDbType]::Int) | Out-Null
	    $sqlCmd.Parameters['@Rights'].Direction = [System.Data.ParameterDirection]::Input
	    $sqlCmd.Parameters['@Rights'].Value = $Rights
		
		$sqlCmd.Parameters.Add("@Enabled",[System.Data.SqlDbType]::Int) | Out-Null
	    $sqlCmd.Parameters['@Enabled'].Direction = [System.Data.ParameterDirection]::Input
	    $sqlCmd.Parameters['@Enabled'].Value = $Enabled
		
		$sqlCmd.Parameters.Add("@CreatedBy",[System.Data.SqlDbType]::Int) | Out-Null
	    $sqlCmd.Parameters['@CreatedBy'].Direction = [System.Data.ParameterDirection]::Input
	    $sqlCmd.Parameters['@CreatedBy'].Value = $createdBy

	    $sqlCmd.Parameters.Add("@CreatedOn",[System.Data.SqlDbType]::DateTime) | Out-Null
	    $sqlCmd.Parameters['@CreatedOn'].Direction = [System.Data.ParameterDirection]::Input
	    $sqlCmd.Parameters['@CreatedOn'].Value = $createdOn
		
		try {
	        $sqlConnection.Open()
	        $sqlCmd.ExecuteNonQuery() | Out-Null

	        Write-Host "The Claim Group $Group now has access to $Value." -ForegroundColor Green
	    }
	    catch {
	        $exType = $( $_.Exception.GetType().FullName)
	        $exMsg = $( $_.Exception.Message)
	        Write-Host "A problem occurred copying the backup: $exType $exMsg" -ForegroundColor Red 
	    }
	    finally {
	        $sqlConnection.Close()
	    }
	}
}