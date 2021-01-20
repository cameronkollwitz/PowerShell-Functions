Function Get-VMWareToolsStatus {
<#
  .SYNOPSIS
    This will check the status of the VMware vmtools status.
    Properties include Name, Status, UpgradeStatus and Version

  .NOTES
    ADAPTED FROM:
      FileName: Get-VMToolsStatus.ps1
      Author:   theSysadminChannel
      Version:  1.0
      Date:     2020-09-01
      Link:     https://thesysadminchannel.com/powercli-check-vmware-tools-status/

  .NOTES
    FileName: Get-VMWareToolsStatus.ps1
    Author:   Cameron Kollwitz
    Version:  1.1
    Date:     2021-01-17

  .LINK
    https://gitlab.kollwitz.cloud/PowerShell/Functions/Get-VMWareToolsStatus
#>

  [CmdletBinding()]
  Param(
    # ComputerName
    [Parameter(
      Position=0,
      ParameterSetName="NonPipeline"
    )]
    [Alias("VM", "ComputerName", "VMName")]
    [String[]]$Name,
    # InputObject
    [Parameter(
      Position=1,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true,
      ParameterSetName="Pipeline"
    )]
    [PSObject[]]$InputObject
  )

  BEGIN {
    If (-not $Global:DefaultVIServer) {
      Write-Error -Message "Unable to continue! Please connect to a vCenter Server and try again." -ErrorAction Stop
    }

    #Verifying the object is a VM
    If ($PSBoundParameters.ContainsKey("Name")) {
      $InputObject = Get-VM $Name
    }

    $i = 1
    $Count = $InputObject.Count
  }

  PROCESS {
    If (($null -eq $InputObject.VMHost) -and ($null -eq $InputObject.MemoryGB)) {
      Write-Error -Message "Invalid data type. A virtual machine object was not found" -ErrorAction Stop
    }

    ForEach ($Object in $InputObject) {
      Try {
        [PSCustomObject]@{
          Name = $Object.name
          Status = $Object.ExtensionData.Guest.ToolsStatus
          UpgradeStatus = $Object.ExtensionData.Guest.ToolsVersionStatus2
          Version = $Object.ExtensionData.Guest.ToolsVersion
        }
      } Catch {
        Write-Error $_.Exception.Message
      } Finally {
        If ($PSBoundParameters.ContainsKey("Name")) {
          $PercentComplete = ($i/$Count).ToString("P")
          Write-Progress -Activity "Processing VM: $($Object.Name)" -Status "$i/$count : $PercentComplete Complete" -PercentComplete $PercentComplete.Replace("%","")
          $i++
        } Else {
          Write-Progress -Activity "Processing VM: $($Object.Name)" -Status "Completed: $i"
          $i++
        }
      }
    }
  }

  END {}

}
