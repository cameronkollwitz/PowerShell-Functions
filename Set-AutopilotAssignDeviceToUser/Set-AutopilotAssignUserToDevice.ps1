Function Set-AutopilotAssignDeviceToUser() {
<#
  .SYNOPSIS
    Assigns an user to a Windows Autopilot device.

  .DESCRIPTION
    The Set-AutopilotAssignDeviceToUser cmdlet assign the specified user and sets a Display Name to show on the Windows Autopilot device.

  .PARAMETER AutopilotDeviceID
    The Windows Autopilot Device ID (Mandatory).

  .PARAMETER userPrincipalName
    The User Principal Name (UPN) (Mandatory)

  .PARAMETER displayName
    The name to display during Windows Autopilot enrollment (mandatory).

  .EXAMPLE
    Assign an user and a name to display during enrollment to a Windows Autopilot device.

    Set-AutopilotAssignDeviceToUser -AutopilotDeviceID $AutopilotDeviceID -userPrincipalName $userPrincipalName -DisplayName "John Doe"
#>

  [CmdletBinding()]
  Param (
    # Autopilot Device ID (GUID)
    [Parameter(
      Mandatory = $true
      )]
    [String[]]
    $AutopilotDeviceID,
    # User Principal Name (Email)
    [Parameter(
      Mandatory = $true
      )]
    [String[]]
    $UserPrincipalName,
    # Display Name
    [Parameter(
      Mandatory = $true
      )]
    [String[]]
    $displayName
  )

  BEGIN {
    # Reminder: This section will only run ONCE!
    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeviceIdentities"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$AutopilotDeviceID/AssignUserToDevice"
    $json = @"
{
    "userPrincipalName":"$userPrincipalName",
    "addressableUserName":"$displayName"
}
"@
  }

  PROCESS {

    Try {
      Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $json -ContentType "application/json"
    } Catch {
      # Display the error that made the oopsie
      $ex = $_.Exception
      $errorResponse = $ex.Response.GetResponseStream()
      $reader = New-Object System.IO.StreamReader($errorResponse)
      $reader.BaseStream.Position = 0
      $reader.DiscardBufferedData()
      $responseBody = $reader.ReadToEnd();

      Write-Host "Response content:`n$responseBody" -f Red
      Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

      Break
    }

  }

  END {
    # Reminder: This section will only run ONCE!
  }

}
