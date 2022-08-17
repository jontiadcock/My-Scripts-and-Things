# This script Takes a list of all Azure AD Guest Users and records most recent login (Interactive, or non interactive)
# Created by Jonti :)

########## VARIABLES - CHANGE ME ##########

$tenantAddr = "@mytenant.onmicrosoft.com" # This is the tenant default @***.onmicrosoft.com domain
$tenantdomain = "@mytetant.com.au" # This is the tenant primary domain
$mstimeperuser = "500" # Increase number if getting error: Error occurred while executing GetAuditSignInLogs, 500 is normally pretty good but may need to be upped to 1000.
# If you have many users to audit, then 500 normally will give best results in quickest time. If you only have <50 users, then setting to 1000 will be fine.

# $Type = "guests" #or "regularusers" # this variable isnt working yet

########## VARIABLES - CHANGE ME ##########


# Start up warning
Write-Output "Run PowerShell as Administrator!
If you havent run as admin, press 'Ctrl + c' a few times to cancel, and re-launch as admin
Please click 'Yes to all' to continue, otherwise script will not work"
Start-Sleep -Milliseconds 15000

# Uninstall Azure Module and install AzureAD Preview Module
Write-Output "Uninstalling standard modules and changing to preview modules"
Uninstall-Module -Name AzureAD
Install-Module -Name AzureADPreview

# Connect to AZAD
Write-Output "Connecting to AzureAD"
Connect-AzureAD
Start-Sleep -Milliseconds 10000

# Generate List of guest users by email address and assign to $userlist variable
Write-Output "This process takes around 1-3 seconds per user and can take time to complete, there is no status updates aside from errors sometimes, please be patient and do not open CSV before completion"
$userlist = Get-AzureADUser -All $true | Select-Object -Unique "UserPrincipalName" | Select-String -pattern "#EXT#"
$userlist = $userlist -replace "@{UserPrincipalName=" -replace "}" -replace "#EXT#" -replace "$TenantAddr" -replace "$tenantdomain" -replace "_", "@"

# Check for login data for each user and export to CSV
ForEach ($singleuser in $userlist) {
$tempvalue = Get-AzureADAuditSignInLogs -Filter "UserPrincipalName eq '$singleuser'" -Top 1 | Select-Object CreatedDateTime, UserPrincipalName, userDisplayName
Start-Sleep -Milliseconds $mstimeperuser
    if ($tempvalue -eq $null){
      Write-Output "$singleuser`tNo login for over 1month" | Out-File C:\temp\AzureGuestUsers.csv -Append
      Start-Sleep -Milliseconds $mstimeperuser
      }
    else {
      Write-Output "$tempvalue" |
      ForEach-Object {$_ -Replace '@{CreatedDateTime=', 'Most recent login: '} |
      ForEach-Object {$_ -Replace '; ',', '} |
      ForEach-Object {$_ -Replace '}',' '} |
      ForEach-Object {$_ -Replace 'UserPrincipalName=', 'Email: '} |
      ForEach-Object {$_ -Replace ' UserDisplayName=', ' Name: '} |
      Out-File C:\temp\AzureGuestUsers.csv -Append
      Start-Sleep -Milliseconds $mstimeperuser
     }
Start-Sleep -Milliseconds $mstimeperuser
}

# Disconnect AzureAD
Write-Output "Disconnecting AzureAD"
Disconnect-AzureAD

# Reinstall standard AzureAD module
Write-Output "Reinstalling standard modules"
Uninstall-Module -Name AzureADPreview
Install-Module -Name AzureAD

# End script
Start-Sleep -Milliseconds 5000
Write-Output "Script Complete, file located in C:\temp\AzureGuestUsers"