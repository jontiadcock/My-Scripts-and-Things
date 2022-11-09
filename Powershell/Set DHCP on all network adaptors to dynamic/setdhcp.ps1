# Made By Jonti

# get list of adapters
$adaptersbefore = Get-NetAdapter | Select-Object "Name"

#Remove formatting and extra name information
$adaptersafter1 = $adaptersbefore -replace "Name="
$adaptersafter2 = $adaptersafter1 -replace "@{"
$adaptersafter3 = $adaptersafter2 -replace '}'

# Enable DHCP for all adapters named above
foreach ($adapter in $adaptersafter3){
netsh interface ip set address "$adapter" source=dhcp
netsh interface ip set dnsservers "$adapter" source=dhcp
}