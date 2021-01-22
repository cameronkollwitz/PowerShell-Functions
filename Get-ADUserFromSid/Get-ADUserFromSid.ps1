Function Get-ADUserFromSid {
<#
  .SYNOPSIS
    Converts a SID to NTAccount

  .DESCRIPTION
    Long description here....

  .EXAMPLE
    GoGo-ConvertSIDtoNTAccount -SID 'S-1-5-21-0000000000-1000000000-200000000-30000'

  .INPUTS
    SID

  .OUTPUTS

  .NOTES
    None

  .COMPONENT
    None

  .ROLE
    Systems Administration

  .FUNCTIONALITY
    Convert SID to NTAccount
#>

  [CmdletBinding()]
  Param (
    [ValidateNotNull()]
    $SID
  )

  # Main Script
  Try {
    # Create SecurityIdentifier Object for the SID
    $objSID = New-Object System.Security.Principal.SecurityIdentifier ("$SID")
    # Translate the SID into NTAccount
    $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
    # Return the NTAccount
    Write-Host -Object $objUser.Value
  } Catch {
    $errMsg = $_.Exception.Message
    Write-Host -Object $errMsg
  }

}
