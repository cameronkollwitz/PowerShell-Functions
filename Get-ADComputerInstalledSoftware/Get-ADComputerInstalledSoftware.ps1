Function Get-ADComputerInstalledSoftware {
  <#
    .SYNOPSIS
      Get-ADComputerInstalledSoftware retrieves a list of installed software

    .DESCRIPTION
      Get-ADComputerInstalledSoftware opens up the specified (remote) registry and scours it for installed software. When found it returns a list of the software and its version.

    .PARAMETER ComputerName
      The computer from which you want to get a list of installed software. Defaults to the local host.

    .EXAMPLE
      Get-ADComputerInstalledSoftware -ComputerName DC1

      This will return a list of software from DC1. Like:

      Name      Version     Computer  UninstallCommand
      ----      -------     --------  ----------------
      7-Zip      9.20.00.0  DC1       MsiExec.exe /I{23170F69-40C1-2702-0920-000001000000}
      Opera      12.16      DC1       "C:\Program Files (x86)\Opera\Opera.exe" /uninstall

    .EXAMPLE
      Import-Module ActiveDirectory
      Get-ADComputer -Filter 'Name -Like "DC*"' | Get-ADComputerInstalledSoftware

      This will get a list of installed software on every AD computer that matches the AD filter (So all computers with names starting with DC)

    .INPUTS
      [string[]]Computername

    .OUTPUTS
      PSObject with properties: Name,Version,Computer,UninstallCommand

    .NOTES
      Author: Anthony Howell

      To add directories, add to the LMkeys (LocalMachine)

    .LINK
      [Microsoft.Win32.RegistryHive]
      [Microsoft.Win32.RegistryKey]
  #>

  #region
  Param(
    [Alias('Computer', 'ComputerName', 'HostName')]
    [Parameter(
      ValueFromPipeline = $True,
      ValueFromPipelineByPropertyName = $true,
      Position = 1
    )]
    [string]$Name = $env:COMPUTERNAME
  )

  Begin {
    $lmKeys = 'Software\Microsoft\Windows\CurrentVersion\Uninstall', 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    $lmReg = [Microsoft.Win32.RegistryHive]::LocalMachine
    $cuKeys = 'Software\Microsoft\Windows\CurrentVersion\Uninstall'
    $cuReg = [Microsoft.Win32.RegistryHive]::CurrentUser
  }
  Process {
    if (!(Test-Connection -ComputerName $Name -Count 1 -Quiet)) {
      Write-Error -Message "Unable to contact $Name. Please verify its network connectivity and try again." -Category ObjectNotFound -TargetObject $Computer
      Break
    }
    $masterKeys = @()
    $remoteCURegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($cuReg, $computer)
    $remoteLMRegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($lmReg, $computer)
    ForEach ($key in $lmKeys) {
      $regKey = $remoteLMRegKey.OpenSubkey($key)
      ForEach ($subName in $regKey.GetSubkeyNames()) {
        ForEach ($sub in $regKey.OpenSubkey($subName)) {
          $masterKeys += (New-Object PSObject -Property @{
              'ComputerName'     = $Name
              'Name'             = $sub.getvalue('displayname')
              'SystemComponent'  = $sub.getvalue('systemcomponent')
              'ParentKeyName'    = $sub.getvalue('parentkeyname')
              'Version'          = $sub.getvalue('DisplayVersion')
              'UninstallCommand' = $sub.getvalue('UninstallString')
              'InstallDate'      = $sub.getvalue('InstallDate')
              'RegPath'          = $sub.ToString()
            })
        }
      }
    }
    ForEach ($key in $cuKeys) {
      $regKey = $remoteCURegKey.OpenSubkey($key)
      if ($regKey -ne $null) {
        ForEach ($subName in $regKey.getsubkeynames()) {
          ForEach ($sub in $regKey.opensubkey($subName)) {
            $masterKeys += (New-Object PSObject -Property @{
                'ComputerName'     = $Name
                'Name'             = $sub.getvalue('displayname')
                'SystemComponent'  = $sub.getvalue('systemcomponent')
                'ParentKeyName'    = $sub.getvalue('parentkeyname')
                'Version'          = $sub.getvalue('DisplayVersion')
                'UninstallCommand' = $sub.getvalue('UninstallString')
                'InstallDate'      = $sub.getvalue('InstallDate')
                'RegPath'          = $sub.ToString()
              })
          }
        }
      }
    }
    $woFilter = { $null -ne $_.name -AND $_.SystemComponent -ne '1' -AND $null -eq $_.ParentKeyName }
    $props = 'Name', 'Version', 'ComputerName', 'Installdate', 'UninstallCommand', 'RegPath'
    $masterKeys = ($masterKeys | Where-Object $woFilter | Select-Object $props | Sort-Object Name)
    $masterKeys
  }
  End {
    Out-Null
  }
  #endregion
}
