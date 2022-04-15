# List the files in a directory and print the full path
# Get-ChildItem -Recurse -Include *.docx, *.pdf -Path .\Documents | Select-Object FullName

Get-ChildItem -Recurse -Include *.docx, *.pdf -Path .\Documents | Export-Csv `
    -Path files.csv

# Import CSV file.
$fileList = Import-Csv -Path .\files.csv # -Header FullName

# Loop through the results
foreach ($f in $fileList) {

    Get-ChildItem -Path $f.FullName

}
