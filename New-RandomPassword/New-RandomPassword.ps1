#Requires -Version 2.0

Function New-RandomPassword {
<#
  .SYNOPSIS
    Generates a complex password of the specified length and text encoding.

  .DESCRIPTION
    Generates a random password using only common ASCII code numbers.  The
    password will be four characters in length at a minimum so that it may
    contain at least one of each of the following character types: uppercase,
    lowercase, number and password-legal non-alphanumerics.  To make the
    output play nice, the following characters are excluded from the
    output password string: extended ASCII, spaces, #, ", `, ', /, 0, O.
    Also, the function prevents any two identical characters in a row.
    The output should be compatible with any code page or culture when
    an appropriate encoding is chosen.  Because of how certain characters
    are excluded, the randomness of the password is slightly lower, hence,
    the length may need to be increased to achieve a particular entropy.

  .PARAMETER Length
    Length of password to be generated.  Minimum is 4.  Default is 15.
    Complexity requirements force a minimum length of 4 characters.
    Maximum is 2,147,483,647 characters.

  .PARAMETER Encoding
    The encoding of the output string. Must be one of these:
      * ASCII
      * UTF8
      * UNICODE
      * UTF16
      * UTF16-LE
      * UTF32
      * UTF16-BE

    The default is UTF16-LE.  Note that UNICODE, UTF16 and UTF16-LE are
    identical on Windows and in this script.  Because of how characters
    are generated, ASCII and UTF8 are identical here too. 'LE' stands for
    Little Endian, and 'BE' stands for Big Endian.

  .EXAMPLE
    New-RandomPassword -Length 25

    Returns a 25-character UTF16-LE string.  Note that if you will save the
    output to a file, beware of unexpected Byte Order Mark (BOM) bytes and
    newline bytes added by cmdlets like Out-File and Set-Content.
#>

  [CmdletBinding()][OutputType([System.String])]
  Param (
    [Int32][ValidateRange(4, 2147483647)] $Length = 15,
    [String][ValidateSet('ASCII', 'UTF8', 'UNICODE', 'UTF16', 'UTF16-LE', 'UTF32', 'UTF16-BE')] $Encoding = 'UTF16-LE'
  )

  #Password must be at least 4 characters long in order to satisfy complexity requirements.
  #Use the .NET crypto random number generator, not the weaker System.Random class with Get-Random:
  $RngProv = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
  [byte[]] $onebyte = @(255)
  [Int32] $x = 0
  [Int32] $prior = 0    #Used to avoid repeated chars.

  #In case the $length is enormous, use a typed list:
  $GenericList = [System.Collections.Generic.List``1]
  $GenericList = $GenericList.MakeGenericType( @('System.Byte') )
  $password = New-Object -TypeName $GenericList -ArgumentList $length

  Do {
    $password.clear()

    $hasupper = $false    #Has uppercase letter character flag.
    $haslower = $false    #Has lowercase letter character flag.
    $hasnumber = $false   #Has number character flag.
    $hasnonalpha = $false #Has non-alphanumeric character flag.
    $isstrong = $false    #Assume password is not complex until tested otherwise.

    For ($i = $length; $i -gt 0; $i--) {
      While ($true) {
        #Generate a random US-ASCII code point number.
        $RngProv.GetNonZeroBytes( $onebyte )
        [Int32] $x = $onebyte[0]

        # Even though it reduces randomness, eliminate problem characters to preserve sanity while debugging.
        # Also, do not allow two identical chars in a row.  If you're worried about the loss of entropy,
        # increase the length of the password or comment out the undesired line(s) below:
        if ($x -eq $prior) { continue } #Eliminates two repeated chars in a row; they seem too frequent... :-\
        If ($x -eq 32) { continue }     #Eliminates the space character; causes problems for other scripts/tools.
        If ($x -eq 34) { continue }     #Eliminates double-quote; causes problems for other scripts/tools.
        If ($x -eq 39) { continue }     #Eliminates single-quote; causes problems for other scripts/tools.
        If ($x -eq 47) { continue }     #Eliminates the forward slash; causes problems for net.exe.
        If ($x -eq 96) { continue }     #Eliminates the backtick; causes problems for PowerShell.
        If ($x -eq 48) { continue }     #Eliminates zero; causes problems for humans who see capital O.
        If ($x -eq 79) { continue }     #Eliminates capital O; causes problems for humans who see zero.

        if ($x -ge 32 -and $x -le 126) { $prior = $x ; break }  #It's a keeper!
      }

      $password.Add($x)

      If ($x -ge 65 -And $x -le 90) { $hasupper = $true }   #Non-USA users may wish to customize the code point numbers by hand,
      If ($x -ge 97 -And $x -le 122) { $haslower = $true }   #which is why we don't use functions like IsLower() or IsUpper() here.
      If ($x -ge 48 -And $x -le 57) { $hasnumber = $true }
      If (($x -ge 32 -And $x -le 47) -Or ($x -ge 58 -And $x -le 64) -Or ($x -ge 91 -And $x -le 96) -Or ($x -ge 123 -And $x -le 126)) { $hasnonalpha = $true }
      If ($hasupper -And $haslower -And $hasnumber -And $hasnonalpha) { $isstrong = $true }
    }
  } While ($isstrong -eq $false)

  #$RngProv.Dispose() #Not compatible with PowerShell 2.0.

  #Output as a string with the desired encoding:
  Switch -Regex ( $Encoding.ToUpper().Trim() ) {
    'ASCII'
    { ([System.Text.Encoding]::ASCII).GetString($password) ; continue }
    'UTF8'
    { ([System.Text.Encoding]::UTF8).GetString($password) ; continue }
    'UNICODE|UTF16-LE|^UTF16$' {
      $password = [System.Text.AsciiEncoding]::Convert([System.Text.Encoding]::ASCII, [System.Text.Encoding]::Unicode, $password )
      ([System.Text.Encoding]::Unicode).GetString($password)
      continue
    }
    'UTF32' {
      $password = [System.Text.AsciiEncoding]::Convert([System.Text.Encoding]::ASCII, [System.Text.Encoding]::UTF32, $password )
      ([System.Text.Encoding]::UTF32).GetString($password)
      continue
    }
    '^UTF16-BE$' {
      $password = [System.Text.AsciiEncoding]::Convert([System.Text.Encoding]::ASCII, [System.Text.Encoding]::BigEndianUnicode, $password )
      ([System.Text.Encoding]::BigEndianUnicode).GetString($password)
      continue
    }
    default {
      #UTF16-LE Unicode
      $password = [System.Text.AsciiEncoding]::Convert([System.Text.Encoding]::ASCII, [System.Text.Encoding]::Unicode, $password )
      ([System.Text.Encoding]::Unicode).GetString($password)
      continue
    }
  }

}

# Run the function
#New-RandomPassword -Length $Length -Encoding $Encoding
