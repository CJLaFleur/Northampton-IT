$packageName = 'ar'
$fileType = 'exe'
$fileLocation = "\\finance\files\Software Distribution\Adobe11Standard\AdbeRdr11000_en_US.exe"
$silentArgs = '/verysilent'

Install-ChocolateyPackage $packageName $fileType $silentArgs $fileLocation

