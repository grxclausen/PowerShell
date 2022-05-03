$installedModules = Get-InstalledModule

foreach ($module in $installedModules) {

    $moduleName = $module.Name

    if ( $moduleName -like "OCI*" ) {
        Write-Host($moduleName)

        Uninstall-Module -Name $moduleName
    }
}