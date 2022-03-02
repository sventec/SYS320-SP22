#!/usr/bin/env python3
import os
import sys
from getpass import getpass

import paramiko

# Define results flie name
RESULTS_FILENAME = "results.txt"

# Check to see if results file already exists
if os.path.exists(RESULTS_FILENAME):
    if (
        input(
            "\nWARNING: The file "
            + RESULTS_FILENAME
            + " already exists. Press Y to overwrite it, or any other key to quit."
        ).lower()
        == "y"
    ):
        os.remove(RESULTS_FILENAME)
    else:
        print("\nExiting...")
        sys.exit()

# Create the password prompt
thePass = getpass(prompt="Please enter your SSH password: ")

# Host information
host = "ubserv.fx.local"
port = 22
username = "reed"
password = thePass

try:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, username, password)

except paramiko.AuthenticationException:
    print("Authentication failed.")
    sys.exit()

sftp = ssh.open_sftp()

# Upload the fs.py script
sftp.put("./fs.py", "/tmp/fs.py")

# Run the fs.py script on the remote system
stdin, stdout, stderr = ssh.exec_command("python3 /tmp/fs.py -d /usr/bin")

# Get results from stdout
lines = stdout.readlines()

# Save results to local file
with open(RESULTS_FILENAME, "w") as f:
    f.writelines(lines)

# Close SSH connection
ssh.close()
