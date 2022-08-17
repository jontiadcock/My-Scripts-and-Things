for(;;){
Get-Date
ping "google.com" >> "C:\temp\pingout.txt"
get-content "C:\temp\pingout.txt" -tail 14
Start-Sleep -Seconds 1200
}