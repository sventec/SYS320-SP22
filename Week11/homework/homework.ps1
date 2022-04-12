# Week 11 homework
# Copy either Windows or IPTables firewall rules from the IP block list to a remote host

# Array of websites containing threat intel
$drop_urls = @("https://rules.emergingthreats.net/blockrules/emerging-botcc.rules", "https://rules.emergingthreats.net/blockrules/compromised-ips.txt")

# Loop through the URLs for the rules list
foreach ($u in $drop_urls) {
    # Extract the filename
    $temp = $u.Split("/")

    # The last element in the array plucked off is the filename
    $file_name = $temp[-1]

    if (Test-Path $file_name) {
        continue
    }
    else {
        # Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name
    }
}

# Array containing the filenames
$input_paths = @(".\compromised-ips.txt", ".\emerging-botcc.rules")

# Extract the IP addresses
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list
Select-String -Path $input_paths -Pattern $regex_drop | `
    ForEach-Object { $_.Matches } | `
    ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
    Out-File -FilePath "ips-bad.tmp"

# Check for Windows or IPTables rulesets
$rule_type = (Read-Host -Prompt "Please enter Windows or IPTables: ").ToLower()

# Get the IP addresses discovered, loop through and replace the beginning of the line with either IPTables or Windows syntax
# After the IP address, add the remaining IPTables/Windows syntax and save the results to a file.
# iptables -A INPUT -s <IP> -j DROP
# OR
# netsh advfirewall firewall add rule dir=in action=block name="Block bad ips" remoteip=<IP>

switch ( $rule_type ) {
    "iptables" {
        (Get-Content -Path ".\ips-bad.tmp") | ForEach-Object `
        { $_ -replace "^", "iptables -A INPUT -s " -replace "$", " -j DROP" } | `
            Out-File -FilePath "rules.out"

        # SCP the IPTables rules ONLY to 192.168.6.71:2222
        Set-SCPItem -ComputerName "192.168.6.71" -Port 2222 -Credential (Get-Credential reed.simon) `
            -Path "./rules.out" -Destination "/home/reed.simon/"
    }
    "windows" {
        (Get-Content -Path ".\ips-bad.tmp") | ForEach-Object `
        { $_ -replace "^", "netsh advfirewall firewall add rule dir=in action=block name='Block bad ips' remoteip=" } | `
            Out-File -FilePath "rules.out"
    }
}
