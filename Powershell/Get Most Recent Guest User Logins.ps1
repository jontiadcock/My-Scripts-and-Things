# This script Takes a list of all Azure AD Guest Users and records most recent login (Interactive, or non interactive)
# Created by Jonti :)


# $Type = "guests" #or "regularusers" # this variable isnt setup yet


# Start up warning
Write-Output "Run PowerShell as Administrator!"
$Admin = read-host -p "'Did you run as admin? (Y/N)'"
if ($Admin -eq "Y") {
    Write-Output "Starting script..."

    # ask for script parameters details
    $TenantAddr = read-host -p 'Enter the Tenat full address of the Azure tenancy, example: @mytenant.onmicrosoft.com (include @)'
    $tenantdomain = read-host -p 'Enter the primary domain of the tenant, example: @mydomain.com.au (include @)'
    $pathforcsv = read-host -p "Enter the path to the csv file you want to save the results to, example: 'C:\Users\john.doe\results.csv'"
    $mstimeperuser = "1000" # Increase number if getting error: Error occurred while executing GetAuditSignInLogs, 650 is normally pretty good but may need to be upped to 1000 if getting errors.
    # If you have many users to audit, then 1000 normally will give best results in quickest time. If you only have <50 users, then setting to 1000 will be fine.

    # Uninstall Azure Module and install AzureAD Preview Module
    Write-Output "Please click 'Yes to all' to continue, otherwise script will not work"
    Write-Output "Uninstalling standard modules and changing to preview modules"
    Uninstall-Module -Name AzureAD | out-null
    Install-Module -Name AzureADPreview | out-null

    # Connect to AZAD
    Write-Output "Connecting to AzureAD"
    Connect-AzureAD | Out-Null
    Start-Sleep -Milliseconds 5000

    # Generate List of guest users by email address and assign to $userlist variable
    $userlist = Get-AzureADUser -All $true | Select-Object -Unique "UserPrincipalName" | Select-String -pattern "#EXT#"
    $userlist = $userlist -replace "@{UserPrincipalName=" -replace "}" -replace "#EXT#" -replace "$TenantAddr" -replace "$tenantdomain" -replace "_", "@"

    # Create CSV file and write headers
    Write-Output "Creating CSV file"
    Write-Output "Ignore" | Out-File -FilePath $pathforcsv

    # Check for login data for each user and export to CSV
    Write-Output "Getting and Writing Data, this process takes around 1-3 seconds per user and can take time to complete, there is no status updates aside from errors sometimes, please be patient and do not open CSV before completion"
    ForEach ($singleuser in $userlist) {
    $tempuservalue = Get-AzureADAuditSignInLogs -Filter "UserPrincipalName eq '$singleuser'" -Top 1 | Select-Object CreatedDateTime, UserPrincipalName, userDisplayName
    Start-Sleep -Milliseconds $mstimeperuser
        if ($null -eq $tempuservalue){
          Write-Output "$singleuser`tNo login for over 1month" | Out-File -FilePath "$pathforcsv" -append
          Start-Sleep -Milliseconds $mstimeperuser
          }
        else {
          Write-Output "$tempuservalue" |
          ForEach-Object {$_ -Replace '@{CreatedDateTime=', 'Most recent login: '} |
          ForEach-Object {$_ -Replace '; ',', '} |
          ForEach-Object {$_ -Replace '}',' '} |
          ForEach-Object {$_ -Replace 'UserPrincipalName=', 'Email: '} |
          ForEach-Object {$_ -Replace ' UserDisplayName=', ' Name: '} |
          Out-File -FilePath "$pathforcsv" -append
          Start-Sleep -Milliseconds $mstimeperuser
        }
    Start-Sleep -Milliseconds $mstimeperuser
    }

    # Disconnect AzureAD
    Write-Output "Disconnecting AzureAD"
    Disconnect-AzureAD

    # Shut down azuread module
    Write-Output "Shutting down AzureAD Preview module"
    Remove-Module -Name AzureADPreview
    Remove-Module -Name PowerShellGet | out-null

    # Reinstall standard AzureAD module
    Write-Output "Reinstalling standard modules"
    Uninstall-Module -Name AzureADPreview | out-null
    Install-Module -Name AzureAD | out-null

    # End script
    Start-Sleep -Milliseconds 5000
    Write-Output "Script Complete, file located in '$pathforcsv'"
    Start-Sleep -Milliseconds 5000
    exit
  }
    # End script if user did not run as admin
    else {
    Write-Output "Exiting script... Run as admin next time"
    exit
    }