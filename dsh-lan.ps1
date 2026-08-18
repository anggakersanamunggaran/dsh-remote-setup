# dsh-lan.ps1 — expose DeepSeek Harness (WSL2) to your phone on the home LAN.
# DSH only binds 127.0.0.1, so this forwards 0.0.0.0:8080 -> 127.0.0.1:3080 via
# WSL2's localhost relay — the same path your PC browser already uses.
# Run from an ELEVATED PowerShell:
#   powershell -ExecutionPolicy Bypass -File C:\Users\Public\dsh-lan.ps1
$ErrorActionPreference = 'Stop'

$wslPort   = 3080
$localPort = 8080
$target    = '127.0.0.1'   # fixed target — never goes stale, unlike the WSL2 IP

# LAN IPv4 (the interface with a default gateway = your home network)
$lanIp = (Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } |
    Select-Object -First 1).IPv4Address.IPAddress
if (-not $lanIp) { throw "Could not detect the LAN IP address." }

Write-Host "LAN IP    : $lanIp"  -ForegroundColor Cyan
Write-Host "Phone URL : http://$lanIp`:$localPort" -ForegroundColor Yellow

# port forward 0.0.0.0:8080 -> 127.0.0.1:3080 (replace any stale rule)
netsh interface portproxy delete v4tov4 listenport=$localPort listenaddress=0.0.0.0 | Out-Null
netsh interface portproxy add v4tov4 listenport=$localPort listenaddress=0.0.0.0 connectport=$wslPort connectaddress=$target
Write-Host "Port forward: 0.0.0.0:$localPort -> $target`:$wslPort" -ForegroundColor Green

# firewall inbound rule (add only once)
if (-not (Get-NetFirewallRule -DisplayName "DSH remote" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "DSH remote" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $localPort | Out-Null
    Write-Host "Firewall rule 'DSH remote' added." -ForegroundColor Green
} else {
    Write-Host "Firewall rule 'DSH remote' already exists." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. On your phone open:" -ForegroundColor Cyan
Write-Host "  http://$lanIp`:$localPort" -ForegroundColor Yellow
Write-Host "  http://$env:COMPUTERNAME.local`:$localPort" -ForegroundColor Yellow
Write-Host ""
Write-Host "Undo later:" -ForegroundColor DarkGray
Write-Host "  netsh interface portproxy delete v4tov4 listenport=$localPort listenaddress=0.0.0.0" -ForegroundColor DarkGray
Write-Host "  Remove-NetFirewallRule -DisplayName 'DSH remote'" -ForegroundColor DarkGray
