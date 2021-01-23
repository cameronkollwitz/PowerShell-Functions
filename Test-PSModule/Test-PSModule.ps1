Function Test-PSModule {

  [CMdletbinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$ModuleName
  )

  BEGIN {}

  PROCESS {
    If (Get-Module -Name $ModuleName) {
      Return $true
    }
    If ((Get-Module -Name $ModuleName) -ne $true) {
      Return $false
    }
  }

  END {}

}
