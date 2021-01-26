Function Invoke-MWMTraceRoute {
  <#
  .SYNOPSIS
    Perform a Traceroute on a host using PowerShell.

  .DESCRIPTION
    Utilize the .NET Framework to implement a "Mid-Wage-Man's Traceroute" using PowerShell.

  .LINK
    https://stackoverflow.com/questions/32434882/is-there-a-powershell-equivalent-tracert-that-works-in-version-2

  .NOTES
    Created By:   Cameron Kollwitz <cameron@kollwitz.us>
    Date:         2021-01-25
    File:         Invoke-MWMTraceRoute.ps1
#>

  [CmdletBinding()]
  Param(
    # Hostname to trace
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Destination,
    # Maximume Time-To-Live (TTL)
    [Parameter(Mandatory = $false)]
    [int]$MaxTTL = 16,
    # Fragmentation
    [Parameter(Mandatory = $false)]
    [bool]$Fragmentation = $false,
    # Verbose Output (Default: True)
    [Parameter(Mandatory = $false)]
    [bool]$VerboseOutput = $true,
    # Default timeout of 5000 seconds.
    [Parameter(Mandatory = $false)]
    [int]$Timeout = 5000
  )

  BEGIN {
    $ping = New-Object System.Net.NetworkInformation.Ping
    $success = [System.Net.NetworkInformation.IPStatus]::Success
    $results = @()
  }

  PROCESS {
    If ($VerboseOutput) {
      Write-Host -Object "Tracing to $Destination"
    }

    # Main Loop
    For ($i = 1; $i -le $MaxTTL; $i++) {
      $popt = New-Object System.Net.NetworkInformation.PingOptions($i, $Fragmentation)
      $reply = $ping.Send($Destination, $Timeout, [System.Text.Encoding]::Default.GetBytes('MESSAGE'), $popt)
      $addr = $reply.Address

      Try {
        $dns = [System.Net.Dns]::GetHostByAddress($addr)
      } Catch {
        $dns = '-'
      }

      $name = $dns.HostName

      $obj = New-Object -TypeName PSObject
      $obj | Add-Member -MemberType NoteProperty -Name hop -Value $i
      $obj | Add-Member -MemberType NoteProperty -Name address -Value $addr
      $obj | Add-Member -MemberType NoteProperty -Name dns_name -Value $name
      $obj | Add-Member -MemberType NoteProperty -Name latency -Value $reply.RoundTripTime

      If ($VerboseOutput) { Write-Host "Hop: $i`t= $addr`t($name)" }
      $results += $obj

      If ($reply.Status -eq $success) { break }
    }
  }

  END {
    Return $results
  }
}
