# Get a list of running processes: name, id, path
# Then, save the output to a CSV
# -----------------------------------------------
# Get-Process | Select-Object -Property Name, Id, Path | Export-Csv -Path `
#     "D:\school-files\SYS320-SP22\Week09\homework\processes.csv"

# Assign output filename to a variable
$outputName = "D:\school-files\SYS320-SP22\Week09\homework\out.csv"

# System Services and Properties
# ------------------------------
# Get-Service | Get-Member  # Get-Member is used to determine all available properties for a cmdlet
# Get-Service | Select-Object -Property Status, Name, DisplayName, BinaryPathName | Export-Csv -Path $outputName

# Get a list of running services
# ------------------------------
Get-Service | Where-Object { $_.Status -eq "Running" } | Export-Csv -Path $outputName

# Check to see if the output file exists
# --------------------------------------
if (Test-Path $outputName) {
    Write-Host -BackgroundColor "Green" -ForegroundColor "White" "Services file was created!"
}
else {
    Write-Host -BackgroundColor "Red" -ForegroundColor "White" "Services file was not created!"
}
