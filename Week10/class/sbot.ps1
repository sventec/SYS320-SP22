# Send an email using Powershell

$toSend = @('test1@example.com', 'test2@example.com', 'mytest@othersite.net')

# Message body
$msg = "Hello"

while ($true) {

    foreach ($email in $toSend) {

        # Send the email
        Write-Host "Send-MailMessage -From 'my.email@champlain.edu' -To $email -Subject 'Test'`
        -Body $msg -SmtpServer X.X.X.X"
        
        # Pause for 1 second
        Start-Sleep 1

    }
}
