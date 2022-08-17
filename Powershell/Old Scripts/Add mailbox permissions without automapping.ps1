Connect-ExchangeOnline
Add-MailboxPermission -Identity "user to be accessed" -User "user that requires access" -AccessRights FullAccess -AutoMapping $false
Get-MailboxPermission -Identity "Verify user to be accessed permissions"