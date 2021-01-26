function Get-MoreCowbell {
  [CmdletBinding()]
  Param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [Switch]$Introduction,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [Int]$Repeat = 10,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]$CowbellUrl = 'http://emmanuelprot.free.fr/Drums%20kit%20Manu/Cowbell.wav',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]$IntroUrl = 'http://www.innervation.com/crap/Cowbell.wav'
  )

  BEGIN {
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
  }

  PROCESS {
    Try {
      $sound = New-Object System.Media.SoundPlayer
      #$CowBellLoc = "$($env:TEMP)\Cowbell.wav"
      $CowBellLoc = "$PSScriptRoot\Cowbell.wav"
      if (-not (Test-Path -Path $CowBellLoc -PathType Leaf)) {
        Invoke-WebRequest -Uri $CowbellUrl -OutFile $CowBellLoc
      }
      if ($Introduction.IsPresent) {
        $IntroLoc = "$($env:TEMP)\CowbellIntro.wav"
        if (-not (Test-Path -Path $IntroLoc -PathType Leaf)) {
          Invoke-WebRequest -Uri $IntroUrl -OutFile $IntroLoc
        }
        $sound.SoundLocation = $IntroLoc
        $sound.Play()
        Start-Sleep 2
      }
      $sound.SoundLocation = $CowBellLoc
      for ($i = 0; $i -lt $Repeat; $i++) {
        $sound.Play();
        Start-Sleep -Milliseconds 500
      }
    } Catch {
      Write-Error $_.Exception.Message
    }
  }

  END {}

}
