$source = "\\HOSTDEV\MoveBackupFilesForTestServer"
$destination = "C:\DBBackup\"

Function Global:Copy-LF-Backup ()
{
    Param (
        [Parameter(Position=0, Mandatory=$true)]   [string]$database,
        [Parameter(Position=1, Mandatory=$true)]   [string]$source,
        [Parameter(Position=2, Mandatory=$true)]   [string]$destination
    )

    $dbSearchString = "{0}_*.bak" -F $database
    $bakFile = Get-ChildItem $source -Recurse | Where name -Like $dbSearchString

    $renBakFile = "{0}_backup_to_restore.bak" -F $database
    $bakFileLocal = $destination + $renBakFile 

    $bakFilePath = $source + '\' + $bakFile
    $bakFilePathLocal = $destination + '\' + $bakFile
    Write-Host "Found: $bakFilePath"

    try {
        $tellCopying = "Attempting to copy the backup for {0}." -F $database
        Remove-Item $bakFileLocal -Force | Out-Null
        Copy-Item $bakFilePath $destination -Force | Out-Null
        Rename-Item $bakFilePathLocal $renBakFile -Force | Out-Null
    }
    catch {
        $exType = $( $_.Exception.GetType().FullName)
        $exMsg = $( $_.Exception.Message)
        Write-Host "$exType - $exMsg"
    }
}

Copy-LF-Backup "AdjusterStatement" $source $destination

Copy-LF-Backup "ETSAPP" $source $destination

Copy-LF-Backup "Kermit" $source $destination

Copy-LF-Backup "JobsServer" $source $destination