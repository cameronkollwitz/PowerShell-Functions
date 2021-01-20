Function Get-CMTaskSequenceStatus {
<#
  .SYNOPSIS
    Evaluates if there is currently a Task Sequence running on the device.
#>

  Try {
    $TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment
  } Catch {}
  If ($NULL -eq $TSEnv) {
    Return $False
  } Else {
    Try {
      $SMSTSType = $TSEnv.Value('_SMSTSType')
    } Catch {}
    If ($NULL -eq $SMSTSType) {
      Return $False
    } Else {
      Return $True
    }
  }
}
