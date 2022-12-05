$path = "C:\Users\GCDESKTOP21\OneDrive\Pictures\Mom's Birthday\"
$files = Get-ChildItem -Path $path #-Exclude "*.mov"
$ctr = 100

foreach ($file in $files) {
    #Write-Host($file.FullName)

    $ctr += 1

    $FullNewName = $path + "Moms-Birthday_" + $ctr + ".jpg"
    Write-Host($FullNewName)

    Rename-Item -Path $file.FullName -NewName $fullNewName
}