Function Reset-DellTPMOwner {
#BEGINFUNCTION
  <#
  .SYNOPSIS
    Reset TPM Ownership on Device

  .DESCRIPTION
    Used to reset the TPM Ownership of a device using Microsoft APIs

  .EXAMPLE
    Reset-DellTPMOwner
  #>

  # Determine where to do the logging
  $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
  #$logPath = $tsenv.Value("LogPath")
  $logPath = "${ENV:SystemRoot}\Logs\Software"
  $logFile = "$logPath\$($myInvocation.MyCommand).log"

  # Start logging
  Start-Transcript $logFile
  Write-Output "Logging to $logFile"

  Write-Output "The TPM must be cleared before it can be used to help secure the computer."
  Write-Output "Clearing the TPM cancels the TPM ownership and resets it to factory defaults."

  Write-Output "Quering Win32_TPM WMI object..."
  $oTPM = Get-WmiObject -Class "Win32_Tpm" -Namespace "ROOT\CIMV2\Security\MicrosoftTpm"

  Write-Output "Clearing TPM ownership....."
  $tmp = $oTPM.SetPhysicalPresenceRequest(5)
  If ($tmp.ReturnValue -eq 0) {
    Write-Output "Successfully cleared the TPM chip. A reboot is required."
    $TSenv.Value("NeedRebootTpmClear") = "YES"
    Exit 0
  }
  Else {
    Write-Warning "Failed to clear TPM ownership. Exiting..."
    Stop-Transcript
    Exit 0
  }
#ENDFUNCTION
}
