Function Register-PSRepositoryFix {
  <#
    Workaround caused by a bug relating to accessing HTTPS endpoints
  #>

  [CmdletBinding()]
  Param (
    # PowerShell Module Name
    [Parameter(Mandatory = $true)]
    [String]
    $Name,
    # Source Location
    [Parameter(Mandatory = $true)]
    [Uri]
    $SourceLocation,
    # Gallery Installation Policy
    [ValidateSet('Trusted', 'Untrusted')]
    $InstallationPolicy = 'Trusted'
  )

  BEGIN {
    $ErrorActionPreference = 'Stop'
  }

  PROCESS {
    Try {
      Write-Verbose 'Trying to register via ​Register-PSRepository'
      Register-PSRepository -Name $Name -SourceLocation $SourceLocation -InstallationPolicy $InstallationPolicy
      Write-Verbose 'Registered via Register-PSRepository'
    } Catch {
      Write-Verbose 'Register-PSRepository failed, registering via workaround'

      # Adding PSRepository directly to file
      Register-PSRepository -Name $Name -SourceLocation $env:TEMP -InstallationPolicy $InstallationPolicy
      $PSRepositoriesXmlPath = "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\PowerShellGet\PSRepositories.xml"
      $repos = Import-Clixml -Path $PSRepositoriesXmlPath
      $repos[$Name].SourceLocation = $SourceLocation.AbsoluteUri
      $repos[$Name].PublishLocation = (New-Object -TypeName Uri -ArgumentList $SourceLocation, 'package/').AbsoluteUri
      $repos[$Name].ScriptSourceLocation = ''
      $repos[$Name].ScriptPublishLocation = ''
      $repos | Export-Clixml -Path $PSRepositoriesXmlPath
    }
  }

  END {
    # Reloading PSRepository list
    Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted
    Write-Verbose -Message "PowerShell Repository Registered via Workaround!"
  }
}
