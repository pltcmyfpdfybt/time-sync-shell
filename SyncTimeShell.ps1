/****************************************************************/
/*                                                              */
/*               Project - TimeSyncShell.ps1                    */
/*                                                              */
/*                                                              */
/*               Create  : 19 August 2019 11:56:29              */
/*             Update  : 12 September 2024 11:49:59             */
/*                                                              */
/****************************************************************/

$tmp = Get-Content -LiteralPath '**append path to file with win instance list'
$tdlist = new-object 'System.Collections.Generic.List[string]'

Function getTimeAll() {
  for($i=0; $i -lt $tmp.Count; $i++){
    $computer = $tmp[$i] 
    #$IsConnect = Test-Connection $computer -Quiet -Count 1
    #$H = get-date -Format 'HH'
    #$M = get-date -Format 'mm'
    #$S = get-date -Format 'ss'
    #Write-Host($computer)
    #if($IsConnect -eq $true){
    $Error.Clear()
    #Get-Date -DisplayHint Time
    $tt = Get-WMIObject win32_operatingsystem -computerName $computer | select csname, @{LABEL=’LocalDateTime’; EXPRESSION={$_.ConverttoDateTime($_.LocalDateTime)}} -ErrorAction SilentlyContinue
    $tt | select csname, LocalDateTime
    $ErrorActionPreference = 'SilentlyContinue'
    #Clear-Variable -Name rw
    If($Error -ne $null)  {
      $Error.Clear()
       Write-Host($computer + "  error")
    }
   #}
  }
}
Function syncTimeComputer($computer)  {
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c "REG ADD HKCU\Console /v CodePage /t REG_DWORD /d 65001 /f" }
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c 'REG ADD HKCU\Console /v FaceName /t REG_SZ /d "Lucida Console" /f' }
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c "w32tm /resync" }
    Write-Host("Time:")
    Get-WMIObject win32_operatingsystem -computerName $computer | select @{LABEL=’LocalDateTime’; EXPRESSION={$_.ConverttoDateTime($_.LocalDateTime)}} -ErrorAction SilentlyContinue
}
Function restartService($computer)  {
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c "REG ADD HKCU\Console /v CodePage /t REG_DWORD /d 65001 /f" }
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c 'REG ADD HKCU\Console /v FaceName /t REG_SZ /d "Lucida Console" /f' }
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c "net stop w32time" }
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c "net start w32time" }
}
Function getTimeComputer($computer) {
 Get-WMIObject win32_operatingsystem -computerName $computer | select @{LABEL=’LocalDateTime’; EXPRESSION={$_.ConverttoDateTime($_.LocalDateTime)}} -ErrorAction SilentlyContinue
}
Function syncTimeAll()  {
    for($i=0; $i -lt $tmp.Count; $i++){
      $computer = $tmp[$i] 
      #$IsConnect = Test-Connection $computer -Quiet -Count 1
      #$H = get-date -Format 'HH'
      #$M = get-date -Format 'mm'
      #$S = get-date -Format 'ss'
      #Write-Host($computer)
      #if($IsConnect -eq $true){
      $Error.Clear()
      #Get-Date -DisplayHint Time
      Write-Host($computer + "  sync started")
      Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c "w32tm /resync" } -ErrorAction SilentlyContinue
      $ErrorActionPreference = 'SilentlyContinue'
      #Clear-Variable -Name rw
      If($Error -ne $null){
        $Error.Clear()
        Write-Host($computer + "  error")
      }
   #}
 }
}
Function gpUpdate() {
  for($i=0; $i -lt $tmp.Count; $i++){
    $computer = $tmp[$i] 
    $Error.Clear()
    Invoke-Command -ComputerName $computer -ScriptBlock {cmd /s /c "gpupdate /force" }
    $ErrorActionPreference = 'SilentlyContinue'
    #Clear-Variable -Name rw
    If($Error -ne $null){
      $Error.Clear()
       Write-Host($computer + "  error")
    }
  }
 }

$FR = Read-Host "TimeSyncShell`n1) get time from all`n2) sync time on one`n3) restart time service`n4) get time frome one`n5) sync time on all`n6) gpupdate /force`n"
switch ( $FR )  {
  1 
  { 
    Write-Host "get time from all"
    getTimeAll
  }
  2 
  {
    Write-Host "sync time on one"
    $sto = Read-Host "Write name of computer or server"
    syncTimeComputer($sto)
  }
  3 
  {
    Write-Host "restart time service"
    $sto = Read-Host "Write name of computer or server"
    restartService($sto)
  }
  4
  {
    Write-Host "get time from one"
    $sto = Read-Host "Write name of computer or server"
    getTimeComputer($sto)
  }
  5 
  {
    Write-Host "sync time on all"
    syncTimeAll
  }
  6 
  {
    Write-Host "gpupdate /force"
    gpUpdate
  }
  default 
  {
    Write-Host "Wrong choice, try again" -ForegroundColor Red
    Exit
  }
}     
