# Connect-ExchangeOnline
$username = 'Adam.Bond@netballwa.com.au' #Enter email you wish to check permissions for here
get-mailbox -resultsize unlimited -ErrorAction silentlycontinue | % {Get-MailboxPermission $_.alias -ErrorAction silentlycontinue -user $username}