$ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition;

# Test for local config file
if(-not (Test-Path ($ScriptPath + '\Daemon.conf'))){
  Write-Host 'Config not found. Run Setup.ps1'
  exit
}

# Get config from local file
$Config = Get-Content ($ScriptPath + '\Daemon.conf')| ConvertFrom-Json
$Username = $Config.Username
$Password = $Config.SecurePassword | ConvertTo-SecureString
$UserCredential = New-Object System.Management.Automation.PsCredential -ArgumentList $Username,$Password
$BASE_URL = $Config.BaseURL
$SecureAPIKey = $Config.SecureAPIKey | ConvertTo-SecureString
$APIKey = (New-Object PSCredential 'foo',$SecureAPIKey).GetNetworkCredential().Password
$HEADER = @{"Authorization"="Bearer "+ $APIKey}

Function Write-Log {
  Param(
    [Parameter(Mandatory=$True,
    HelpMessage="The string to log")]
    $String
  )
  $TimeString = (Get-Date -Format s).replace("T", " ")
  ($TimeString + ' ' + $String) | Out-File -Append -Encoding Default ($ScriptPath + '\Daemon.log')
}

Function Write-Errors {
  Param(
    [Parameter(Mandatory=$True,
    HelpMessage="The error array")]
    $Errors
  )
  ForEach($e in $Errors){
    Write-Log -String ('Error ' + $e.ToString())
  }
}

function Get-UserPrincipalName {
  Param(
    [Parameter(Mandatory=$True,
    HelpMessage="The user's ObjectGuid to search")]
    $ObjectGuid,
    [Parameter(Mandatory=$False,
    HelpMessage='An array of servers to search through')]
    $SearchServers
  )
  $ErrorActionPreference = 'SilentlyContinue'
  if($SearchServers){
    ForEach($Server in $SearchServers){
      $User = Get-ADUser -Server $Server $ObjectGuid
      if($User){
        Write-Log -String ($ObjectGuid + ' upn ' + $User.UserPrincipalName)
        return $User.UserPrincipalName
      }
    }
  }
}

function Get-Config {
  $Error.Clear()
  $url = $BASE_URL + "/api/daemon/config"
  $config = (Invoke-WebRequest -Headers $HEADER -Method Get -Uri $url).Content | ConvertFrom-Json
  Write-Errors -Errors $Error
  Write-Log -String ('Retrieved config ' + ($config | ConvertTo-Json -Compress))
  return $config
}

function Get-EnrollmentRequests {
  $Error.Clear()
  $url = $BASE_URL + "/api/daemon/enrollmentRequests"
  $requests = (Invoke-WebRequest -Headers $HEADER -Method Get -Uri $url).Content | ConvertFrom-Json
  Write-Errors -Errors $Error
  return $requests
}

function Set-EnrollmentRequest {
  Param(
    [Parameter(Mandatory=$True,
    HelpMessage="The user's ObjectGuid to change")]
    $ObjectGuid
  )
  $Error.Clear()
  $url = $BASE_URL + "/api/daemon/enrollmentRequests"
  $body = '{"guid":"' + $ObjectGuid + '", "status": "enabled"}'
  $post = (Invoke-WebRequest -Headers $HEADER -Method Post -Body $body -ContentType 'application/json' -Uri $url).Content
  Write-Errors -Errors $Error
  Write-Log -String ('Set enrollmentRequest ' + $ObjectGuid)
  return $post
}

function Enable-MFA {
  Param(
    [Parameter(Mandatory=$True,
    HelpMessage="The user's UserPrincipalName to set MFA")]
    $UserPrincipalName
  )
  $Error.Clear()
  $mf= New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
  $mf.RelyingParty = "*"
  $mfa = @($mf)
  $result = Set-MsolUser -UserPrincipalName $UserPrincipalName -StrongAuthenticationRequirements $mfa
  Write-Errors -Errors $Error
  Write-Log -String ('Enabled MFA ' + $UserPrincipalName)
  return $result
}

function Get-ResetRequests {
  $Error.Clear()
  $url = $BASE_URL + "/api/daemon/resetRequests"
  $requests = (Invoke-WebRequest -Headers $HEADER -Method Get -Uri $url).Content | ConvertFrom-Json
  Write-Errors -Errors $Error
  return $requests
}

function Set-ResetRequest {
  Param(
    [Parameter(Mandatory=$True,
    HelpMessage="The user's ObjectGuid to change")]
    $ObjectGuid
  )
  $Error.Clear()
  $url = $BASE_URL + "/api/daemon/resetRequests"
  $body = '{"guid":"' + $ObjectGuid + '", "status": "complete"}'
  $post = (Invoke-WebRequest -Headers $HEADER -Method Post -Body $body -ContentType 'application/json' -Uri $url).Content
  Write-Errors -Errors $Error
  Write-Log -String ('Set resetRequest ' + $ObjectGuid)
  return $post
}


# Test API and get remaining config from API
$APIConfig = Get-Config
if(-not $APIConfig){
  Write-Host 'Failed to get config from API'
  Write-Log -String ('Failed to get config from API')
  exit
}
$PSDefaultParameterValues['Get-UserPrincipalName:SearchServers'] = $APIConfig.SearchServers;

# Test connection to MsolService
$Error.Clear()
Write-Log -String ('Connecting to MsolService')
Connect-MsolService -Credential $UserCredential
Write-Errors -Errors $Error

while($true){
  # Get requests from the API
  $EnrollmentRequests = Get-EnrollmentRequests
  $ResetRequests = Get-ResetRequests

  # Connect to Msol if there is work to do
  if((($EnrollmentRequests | measure).count -gt 0) -or (($ResetRequests | measure).count -gt 0)){
    $Error.Clear()
    Write-Log -String ('Connecting to MsolService')
    Connect-MsolService -Credential $UserCredential
    Write-Errors -Errors $Error
  }

  # Process enrollment requests
  ForEach($request in $EnrollmentRequests){
    # get user's UPN
    $upn = Get-UserPrincipalName -ObjectGuid $request.guid
    if($upn -and ($upn -ne '')){
      $AdUser = [PSCustomObject]@{
        'guid' = $request.guid;
        'status' = $request.status;
        'upn' = $upn;
      }
      # enable user's MFA
      ForEach ($MsolUser in (Get-MsolUser -UserPrincipalName $AdUser.upn)){
        $mfa = Enable-MFA -UserPrincipalName $AdUser.upn
        # update user's enrollment status
        $status = Set-EnrollmentRequest -ObjectGuid $AdUser.guid
      }
    }else{
      Write-Log -String ('Failed to get UPN for ' + $request.guid)
    }
  }

  # Process reset requests
  ForEach($request in $ResetRequests){
    # get user's UPN
    $upn = Get-UserPrincipalName -ObjectGuid $request.guid
    if($upn -and ($upn -ne '')){
      $AdUser = [PSCustomObject]@{
        'guid' = $request.guid;
        'status' = $request.status;
        'upn' = $upn;
      }
      # reset user's MFA
      ForEach ($MsolUser in (Get-MsolUser -UserPrincipalName $AdUser.upn)){
        $Error.Clear()
        $mfa = Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName $AdUser.upn
        Write-Errors -Errors $Error
        Write-Log -String ('Reset MFA ' + $AdUser.upn)
        # update user's reset status
        $status = Set-ResetRequest -ObjectGuid $AdUser.guid
      }
    }else{
      Write-Log -String ('Failed to get UPN for ' + $request.guid)
    }
  }

  # Wait a minute then go again
  Start-Sleep 60
}
