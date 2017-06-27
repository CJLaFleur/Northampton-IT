$packageName = "laserfiche"
$fileType = "exe"
$fileLocation = "\\hyper-laser\LFSoftware\Laserfiche Rio 10.1.1.254\en\Client\Setup.exe"
$silentArgs = "/NoUI", "/iacceptlicenseagreement"

Install-ChocolateyPackage $packageName $fileType $silentArgs $fileLocation

