$ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition;

function Has-Choco {
  $ErrorActionPreference = 'SilentlyContinue'
  if(Get-Command choco){
    return $true
  }
  return $false
}

function Has-Nssm {
  $ErrorActionPreference = 'SilentlyContinue'
  if(Get-Command nssm){
    return $true
  }
  return $false
}

function Has-AD {
  $ErrorActionPreference = 'SilentlyContinue'
  if(Get-Module -ListAvailable -Name ActiveDirectory){
    return $true
  }
  return $false
}

function Has-MSOnline {
  $ErrorActionPreference = 'SilentlyContinue'
  if(Get-Module -ListAvailable -Name MSOnline){
    return $true
  }
  return $false
}

Function Is-Admin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal $identity
  $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Function Test-Write {
  $ErrorActionPreference = 'SilentlyContinue'
  $Now = [Int](New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds
  $File = $ScriptPath + '\' + $now + '.txt'
  "Test" | Out-File -Encoding Default $File
  if(Test-Path $File){
    Remove-Item $File
    return $true
  }
  return $false
}

Function Has-ssmfadaemon {
  $ErrorActionPreference = 'SilentlyContinue'
  if(Get-Service ssmfadaemon){
    return $true
  }
  return $false
}

# Check for admin rights
if(-not (Is-Admin)){
  throw 'Run as administrator'
}

# Make sure msonline is installed
if(-not (Has-MSOnline)){
  Write-Host 'Installing MSOnline'
  Install-Module MSOnline
}

# Make sure activedirectory is installed
if(-not (Has-AD)){
  Write-Host 'Installing RSAT-AD-PowerShell'
  Add-WindowsFeature -Name 'RSAT-AD-PowerShell' -IncludeAllSubFeature
}

Write-Host 'You are currently running as '(whoami)'. If you plan to install the daemon as a service, you should be running as the service account.'
$Continue = Read-Host 'Do you wish to continue? (y/n)'
if($Continue -ne 'y'){
  exit
}

$Username = Read-Host 'Enter Office 365 admin username'
$SecurePassword = Read-Host -AsSecureString 'Enter Office 365 admin password' | ConvertFrom-SecureString
$SecureAPIKey = Read-Host -AsSecureString 'Enter API Key from API cli' | ConvertFrom-SecureString
$BaseURL = Read-Host 'Enter Base URL from API cli'
$Config = [PSCustomObject]@{
  'Username' = $Username;
  'SecurePassword' = $SecurePassword;
  'SecureAPIKey' = $SecureAPIKey;
  'BaseURL' = $BaseURL;
}
$Config = $Config | ConvertTo-Json
if(Test-Write){
  $Config | Out-File -Encoding Default ($ScriptPath + '\Daemon.conf')
}else{
  $Config
  Write-Host 'Your config is dispayed above. Please create '$ScriptPath'\Daemon.conf with the above config.'
}

$SetupService = Read-Host 'Do you want to install Self-Service MFA Daemon as a service using chocolatey and nssm? (y/n)'
if($SetupService -eq 'y'){
  if(-not (Has-ssmfadaemon)){
    if(-not (Has-Choco)){
      Write-Host 'Installing Choco'
      Set-ExecutionPolicy Bypass -Scope Process -Force
      iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
      if(-not (Has-Choco)){
        Write-Host 'Close and reopen powershell and start Setup.ps1 again'
        exit
      }
    }
    if(-not (Has-Nssm)){
      Write-Host 'Installing Nssm'
      choco install nssm
      if(-not (Has-Nssm)){
        Write-Host 'Close and reopen powershell and start Setup.ps1 again'
        exit
      }
    }

    $Username = Read-Host 'Enter service account username'
    $SecurePassword = Read-Host -AsSecureString 'Enter service account password'
    $Password = (New-Object PSCredential 'foo',$SecurePassword).GetNetworkCredential().Password

    nssm install ssmfadaemon (Get-Command powershell).Source ('-ExecutionPolicy Bypass -NoProfile -File ' + $ScriptPath + '\Daemon.ps1')
    nssm set ssmfadaemon AppDirectory ($ScriptPath)
    nssm set ssmfadaemon DisplayName 'Self-Service MFA Daemon'
    nssm set ssmfadaemon ObjectName ($Username) ($Password)
    Write-Host 'You may start the service when ready'
    services.msc
  }
}
