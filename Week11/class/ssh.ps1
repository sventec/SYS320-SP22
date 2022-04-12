Clear-Host

$ip_addr = "192.168.1.179"

# Login to a remote SSH server
# New-SSHSession -ComputerName $ip_addr -Credential (Get-Credential reed)
# Find new session ID with Get-SSHSession

<#
while ($true) {

    # Add prompt to run commands
    $the_cmd = Read-Host -Prompt "Please enter a command"

    # Run command on remote SSH server
    (Invoke-SSHCommand -index 0 $the_cmd).Output

}
#>

# Download file from remote
Get-SCPItem -ComputerName $ip_addr -Credential (Get-Credential reed) `
    -Path "/home/reed/test.txt" -Destination "./" -PathType "File"

# Push file to remote
# Set-SCPItem -ComputerName $ip_addr -Credential (Get-Credential reed) `
#     -Path "./test2.txt" -Destination "/home/reed/test2.txt"

# Close SSH session opened previously
# Remove-SSHSession -SessionId 0
