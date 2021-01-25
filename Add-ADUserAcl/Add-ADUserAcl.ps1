Function Add-ADUserAcl {

  [CmdletBinding()]
  Param(
    [Parameter(HelpMessage = 'Provide the or CN Path you would like to modify.' )]
    [string]$OUPath,
    [Parameter(HelpMessage = 'Provide the AD User name you would like to add' )]
    [string]$UserName
  )

  Begin {}

  Process {
    # Provide AD group Name here
    Try {
      Import-Module ActiveDirectory -ErrorAction Stop
      $User = Get-ADUser -Identity $UserName -ErrorAction Stop
    } Catch {
      Write-Verbose -Message "You tried to use a group that doesn't exist no changes were made exiting"
      Break
    }

    # Retrive the current ACL list for the Systm Management Container or container of your choice
    $acl = Get-Acl "ad:$($OUPath)"
    # Retrieve the SID of the Group Name and create a SID object to conain it
    $SID = New-Object System.Security.Principal.SecurityIdentifier $User.SID
    # Create an ACE object that contains the appropraite permissions
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $Sid, 'GenericAll', 'all'
    # Apply the ACE to the ACL list that was retrieved
    $ACL.AddAccessRule($ace)
    # Set the ACL on the System Management container or the container of your choice
    Set-Acl -AclObject $acl "ad:$($OUPath)"
  }

  End {}
}
