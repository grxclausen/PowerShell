# Get-Service | Where-Object {$_.Status -eq 'Stopped'} | Out-GridView

Clear-Host

function Set-Services {
<#
.SYNOPSIS
    Checkes to see if a service is running. Most of these are for Microsoft
    SQL Server related services. Can easily be adapted for other services.

.DESCRIPTION
    See synopsis.

.PARAMETER ServiceName
    The actual service name.

.PARAMETER Name
    The name that will be printed on screen

.EXAMPLE
     'Server1', 'Server2' | Get-MrAutoStoppedService

.EXAMPLE
     ./CheckServices.ps1

.INPUTS
    None

.OUTPUTS
    Status of each service.

.NOTES
    Author:  Gary Clausen
#>
    param (
        [Parameter(Mandatory)] [string]$ServiceName,
        [Parameter(Mandatory)] [string]$Name
    )

    $svc = Get-Service | Where-Object { $_.Name -eq $ServiceName }

    $status = $svc.Status
    #Write-Host $status

    if ( $status -eq "Stopped" ) {
        Start-Service -Name $ServiceName
        Write-Host $Name "successfully started" -ForegroundColor Green 
    }
    elseif ( $status -eq "Running" ) {
        Write-Host $Name "is already running" -ForegroundColor Magenta
    }
    else {
        Write-Host $Name " is in an unknown state" -ForegroundColor Red
    }
}
# End Function

# Entry point of script
# These must be in this order

Set-Services -ServiceName "MSSQLLaunchpad"  -Name "SQL Server Launchpad"

Set-Services -ServiceName "MSSQLSERVER" -Name "SQL Server Database Engine"

Set-Services -ServiceName "SQLSERVERAGENT" -Name "SQL Server Agent"

# These could be optional
Set-Services -ServiceName "MSSQLServerOLAPService" -Name "SQL Server Analysis Services"
Set-Services -ServiceName "SSASTELEMETRY" -Name "SQL Server Analysis Services CEIP" 

# These usually aren't a problem
Set-Services -ServiceName "SQLTELEMETRY" -Name "SQL Server CEIP service"

# SSIS
Set-Services -ServiceName "MsDtsServer150" -Name "SQL Server Integration Services 15.0"

Set-Services -ServiceName "SSISTELEMETRY150" -Name "SQL Server Integration Services CEIP service 15.0"

Set-Services -ServiceName "SSISScaleOutMaster150" -Name "Scale Out Master for SQL Server Integration Services Scale Out"
Set-Services -ServiceName "SSISScaleOutWorker150" -Name "Scale Out Worker for SQL Server Integration Services Scale Out"

Set-Services -ServiceName "SQLServerReportingServices" -Name "SQL Server Reporting Services"

Set-Services -ServiceName "SQLWriter" -Name "SQL Server VSS Writer"

#=============================================
# For PostgreSQL
Set-Services -ServiceName "PEMHTTPD" -Name "PEM HTTPD"
Set-Services -ServiceName "pgbouncer" -Name "pgbouncer"
Set-Services -ServiceName "postgresql-x64-14" -Name "PostgreSQL v14"
Set-Services -ServiceName "pgagent-pg14" -Name "PostgreSQL Scheduling Agent"
