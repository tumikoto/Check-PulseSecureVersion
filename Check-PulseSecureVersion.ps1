Param(
		[parameter(Mandatory=$true)]
		[String]$targetlistfile
)

If (!($targetlistfile)) {
	Write-Host Usage:
	Write-Host  Check-PulseSecureVersion.ps1 -RemoteHost <path to file containing list of URIs>
	Write-Host " "
	Write-Host Example:
	Write-Host  Check-PulseSecureVersion.ps1 -RemoteHost "pulsesecure_devices.txt"
	Exit
}

$targetlist = Get-Content -Path $targetlistfile

foreach ($target in $targetlist) {

  try {
    $response = Invoke-WebRequest -Method GET -Uri ($target + "/dana-na/nc/nc_gina_ver.txt") -SkipCertificateCheck -ErrorAction Stop
  } catch {
    Write-Host -Foregroundcolor Red [+] Target $target version could not be detected`, request error
    Continue
  }

  $product = $response.Content -split "`r`n" | Where {$_ -match '<PARAM NAME="ProductName'} | Select -First 1
  $Version = $response.Content -split "`r`n" | Where {$_ -match '<PARAM NAME="ProductVersion'} | Select -First 1

  if ($product -and $version) {
    $product = ($product -split '"')[3]
    $version = ($version -split '"')[3]
    Write-Host -Foregroundcolor Green [+] Target $target is $product with version $version
    Continue
  }

  Write-Host -Foregroundcolor Red [+] Target $target version could not be detected`, parsed response with no results
}
