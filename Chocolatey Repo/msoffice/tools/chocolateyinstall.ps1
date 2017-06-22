$packageName = msoffice
$fileType = "exe"
$fileLocation = "\\finance\files\Software Distribution\Office 2013 w SP1\setup.exe"
$silentArgs = "/verysilent"

Install-ChocolateyPackage $packageName $fileType $silentArgs $fileLocation

