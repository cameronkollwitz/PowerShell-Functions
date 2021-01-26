Function Compare-Folder {
  <#  #>

  [CmdletBinding()]
  Param(
    # Reference Folder
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    [string]$ReferenceFolder,
    # Difference Folder
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    [string]$DifferenceFolder,
    # Excluded File Path
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('^\\')]
    [string]$ExcludeFilePath
  )

  BEGIN {
    $ErrorActionPreference = 'Stop'
    Function Get-FileHashesInFolder {
      Param (
        [String]$Folder
      )

      $files = Get-ChildItem -Path $Folder -Recurse -File

      ForEach ($s in $files) {
        $selectObjects = @('Hash', @{ n = 'Path'; e = { $_.Path.SubString($Folder.Length) } })
        Get-FileHash $s.Fullname | Select-Object $selectObjects -ExcludeProperty Path
      }
    }
  }

  PROCESS {
    Try {
      $refHashes = Get-FileHashesInFolder -Folder $ReferenceFolder
      $destHashes = Get-FileHashesInFolder -Folder $DifferenceFolder
      If ($PSBoundParameters.ContainsKey('ExcludeFilePath')) {
        $refHashes = $refHashes.Where( { $_.Path -ne $ExcludeFilePath })
        $destHashes = $destHashes.Where( { $_.Path -ne $ExcludeFilePath })
      }

      $refHashes.Where( { $_.Path -notin $destHashes.Path }).foreach( {
          [PSCustomObject]@{
            'Path'   = $_.Path
            'Reason' = 'NotInDifferenceFolder'
          }
        })
      $destHashes.Where( { $_.Path -notin $refHashes.Path }).foreach( {
          [PSCustomObject]@{
            'Path'   = $_.Path
            'Reason' = 'NotInReferenceFolder'
          }
        })
      $refHashes.Where( { $_.Hash -notin $destHashes.Hash -and $_.Path -in $destHashes.Path }).foreach( {
          [PSCustomObject]@{
            'Path'   = $_.Path
            'Reason' = 'HashDifferent'
          }
        })
    } Catch {
      Write-Error $_.Exception.Message
    }
  }

  END {}
}
