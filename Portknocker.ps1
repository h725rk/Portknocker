<#
.SYNOPSIS
Mein TTest
.DESCRIPTION
  This Script is for sending TCP- and UDP-packages over severals Ports.
  I use it for knockd for Linux, because there are only old Windows-clients for portknocking in the internet.
.PARAMETER <Parameter_Name>
    - Servername: Name or IP of the Server, where you sending the packages
    - Portnumber: Ports and Protocols
.INPUTS
  None
.OUTPUTS
   None
.NOTES
  Version:        1.0
  Author:         h725rk
  Creation Date:  08.11.2024
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\Portknocker.ps1
  .\Portknocker.ps1 -Servername 111.111.111.111
  .\Portknocker.ps1 -Servername myserver.domain.com
  .\Portknocker.ps1 -Ports 396:UDP,2390:TCP,2341:UDP
  .\Portknocker.ps1 -Servername 111.111.111.111 -Ports 396:UDP,2390:TCP,2341:UDP
  .\Portknocker.ps1 -Servername myserver.domain.com -Ports 396:UDP,2390:TCP,2341:UDP
#>

# Start-Parameter
param(
    [string]$Servername = $null,
    [array]$Portnumbers = $null
)

# Check, if Servername is null
function Check-Servername($Server){
    if($Server -eq $null -or $Server -eq ""){
        $Server = Read-Host "Which Server do you want to open a Port"
    }else{
        Write-Host -ForegroundColor Yellow "Information: Server is not null - Server: $Server"
    }
    
    return $Server
}

#Check, if Ports are null
function Check-Ports($Ports) {
    if($Ports -eq $null -or $Ports -eq ""){
        Write-Host "Syntax for Ports"
        Write-Host "You have to separate the Ports and Protocols with Comma"
        Write-Host "e.g. 2850:UDP,6026:TCP,14962:UDP,..."
        $Ports = Read-Host "Which Ports and Protocols do you want to send"
    }else{
        Write-Host -ForegroundColor Yellow "Information: Ports are not null - Ports: $Ports"
    }

    return $Ports
}

# Send UDP Packet
function Send-TCP($Server, $Port){
    try{
        $TCPClient = New-Object System.Net.Sockets.TcpClient -ErrorAction Stop  -ErrorVariable ErrorSendTCP
        $TCPClient.BeginConnect($Server, $Port, $null, $null) | Out-Null
        $TCPClient.Close() | Out-Null
        # On success, send 0
        return 0
    }catch{
        # On failure, send 1
        Write-Error -Message $ErrorSendTCP -Category ConnectionError
        return 1
    }
    
}

# Send UDP Packet
function Send-UDP($Server, $Port){
    try{
        $UDPClient = New-Object System.Net.Sockets.UdpClient -ErrorAction Stop -ErrorVariable ErrorSendUDP
        $UDPClient.Connect($Server, $Port) | Out-Null
        $UDPClient.Send([byte[]](0), 1) | Out-Null
        $UDPClient.Close()| Out-Null
        # On success, send 0
        return 0
    }catch{
        # On failure, send 1
        Write-Error -Message $ErrorSendUDP -Category ConnectionError
        return 1
    }
}

# Checking Servername and Ports
$Server = Check-Servername -Server $Servername
$Ports = Check-Ports -Ports $Portnumbers

# Process all Port separate
foreach($Port in $Ports){

    # Spliting comma-seperate Ports
    $PortsplitComma = $Port.Split(",")
    # Spliting Port and Protocol
    $PortsplitColon = $PortsplitComma.Split(":")
    # Port and Protocol as Variable
    $Portnumber = $PortsplitColon[0]
    $Protocol = $PortsplitColon[1]

    Write-Host "Sending Package to Port $Portnumber with Protocol $Protocol"

    # Checking which Protocol is using
    if($Protocol -eq "TCP"){
        $SendPackage = Send-TCP -Server $Server -Port $Portnumber
    }elseif($Protocol -eq "UDP"){
        $SendPackage = Send-UDP -Server $Server -Port $Portnumber
    }else {
        Write-Error -Message "Error: Protocol is not TCP or UDP`nExit Script"
        EXIT
    }
    
    # Check, is Package send
    if($SendPackage -eq 0){
        Write-Host -ForegroundColor Green "Success: Sending Package to Port $Portnumber with Protocol $Protocol"
    }elseif($SendPackage -eq 1){
        Write-Host -ForegroundColor Red "Error: Problems with sending Package to Port $Portnumber with Protocol $Protocol"
    }else{
        Write-Error -Message "Error: Returnvalue of SendPackage is not 0 or 1 - SendPackage: $SendPackage"
    }

    # Wait a Second
    Start-Sleep -Seconds 1
}