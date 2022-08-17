for(;;){
Get-Date
ping "google.com" | Out-File -FileName "C:\temp\pingout.txt" -Append
get-content "C:\temp\pingout.txt" -tail 14
Start-Sleep -Seconds 1200
}