# Connect-ExchangeOnline
$username = 'usernamehere' #Enter email you wish to check permissions for here
get-mailbox -resultsize unlimited -ErrorAction silentlycontinue | 
%{Get-MailboxFolderPermission "$($_.alias):\calendar" -ErrorAction silentlycontinue -User $username}