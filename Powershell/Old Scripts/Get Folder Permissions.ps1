$path = "C:\temp\" #path to check permissions
$outpath = "C:\temp\Permissions.csv" # CSV Output path
dir -Recurse $path | where { $_.PsIsContainer } | % { $path1 = $_.fullname; Get-Acl $_.Fullname | % { $_.access | Add-Member -MemberType NoteProperty '.\Application Data' -Value $path1 -passthru }} | Export-csv $outpath