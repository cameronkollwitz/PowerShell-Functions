Function Invoke-MSIntunePolicySync {

  [CmdletBinding()]
  Param ()

  #$Devices = (Get-IntuneManagedDevice -Filter "contains(operatingsystem,'Windows')")
  $Devices = (Get-IntuneManagedDevice -Top '500' -Filter "contains(operatingsystem,'Windows')")
  $IntuneModule = (Get-Module -Name 'Microsoft.Graph.Intune' -ListAvailable)

  If (!$IntuneModule) {
    Write-Host -Object 'Microsoft.Graph.Intune Powershell module not installed...' -ForegroundColor Red
    Write-Host -Object "Install by running 'Install-Module Microsoft.Graph.Intune' from an elevated PowerShell prompt" -ForegroundColor Yellow
    Write-Host -Object "Script can't continue..." -ForegroundColor Red
    Write-Host
    Exit
  }

  ####################################################
  # Importing the SDK Module
  Import-Module -Name Microsoft.Graph.Intune

  If (!(Connect-MSGraph)) {
    Connect-MSGraph -AdminConsent
  }

  ####################################################

  #### Insert your script here

  #### Gets all devices running Windows
  ForEach ($Device in $Devices) {
    Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId "$Device.Id"
    Write-Host -Object "Sending Sync Request to Device with ID $($Device.Id)" -ForegroundColor Yellow
  }

  #endregion
}
