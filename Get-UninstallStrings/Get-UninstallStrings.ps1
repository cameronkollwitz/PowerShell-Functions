Function Get-UninstallStrings {
<#
  .SYNOPSIS
  .DESCRIPTION
  .EXAMPLE
  .OUTPUTS
  .NOTES
    None
  .COMPONENT
    None
  .ROLE
    Systems Administration
  .FUNCTIONALITY
#>

Try {
  $ColRegUinst = @()
  (Get-Item -Path 'HKLM:\software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall').GetSubKeyNames() |
  ForEach-Object {
    If ($null -ne (Get-Item -Path "HKLM:\software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$_").GetValue("DisplayName")) {
      $ObjRegUinst = New-Object System.Object
      $ObjRegUinst | Add-Member -Type NoteProperty -Name Publisher -Value (Get-Item -Path "HKLM:\software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$_").GetValue("Publisher")
      $ObjRegUinst | Add-Member -Type NoteProperty -Name Name -Value (Get-Item -Path "HKLM:\software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$_").GetValue("DisplayName")
      $ObjRegUinst | Add-Member -Type NoteProperty -Name Uninstall -Value (Get-Item -Path "HKLM:\software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$_").GetValue("UninstallString")
      $ColRegUinst += $ObjRegUinst
    }
  }
  $ColRegUinst #| Out-GridView
} Catch { Out-Null }

}
