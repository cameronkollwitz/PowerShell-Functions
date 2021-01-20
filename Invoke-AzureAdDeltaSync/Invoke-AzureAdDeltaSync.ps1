Function Invoke-AzureAdDeltaSync {
<#
  .SYNOPSIS
    Remotely invoke a Delta Sync with an Azure Active Directory Connect server.

  .DESCRIPTION
    A PowerShell Function to invoke a Delta Sync with an Azure Active Directory Connect server remotely.

  .EXAMPLE
    Invoke-AzureAdDeltaSync -ComputerName 'aad01.mydomain.com'

  .EXAMPLE
    Invoke-AzureAdDeltaSync -Credential $Credential

  .FUNCTIONALITY
    Remotely invoke a Delta Sync with an Azure Active Directory Connect server.

  .INPUTS
    ComputerName
    Credential

  .OUTPUTS
    Windows PowerShell credential request
    Enter your credentials.
    User: mydomainadminuser@mydomain.com
    Password for user mydomainadminuser@mydomain.com: ****************

    PSComputerName              RunspaceId                           Result
    --------------              ----------                           ------
    AAD01.mydomain.com          XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX Success

  .ROLE
    Systems Administration

  .NOTES
    Author:   Cameron Kollwitz <cameron@kollwitz.us>
    Date:     2021/01/12
#>

  #region PARAMETERS
  Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    $ComputerName,
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]$Credential,
    [Parameter(Mandatory=$false)]
    $AADDeltaSyncSession = (New-PSSession -ComputerName $ComputerName -Credential $Credential)
  )
  #endregion PARAMETERS

  #region PROCESS
  Try {
    Invoke-Command -Session $AADDeltaSyncSession -ScriptBlock { Import-Module -Name 'ADSync' }
    Invoke-Command -Session $AADDeltaSyncSession -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }
  }

  Catch {
    Write-Output "Error: $_"
    Return 1
  }

  Finally {
    Remove-PSSession $AADDeltaSyncSession
  }
  #endregion PROCESS
}
