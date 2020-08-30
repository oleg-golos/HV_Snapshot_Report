# Define HTML style
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

# Exclustion tag
$excl = "ExcludeFromReport"

# Minimum snapshot age to report
$MinSnapAge = (get-date).adddays(-2)
# Import Invoke-Parallel function
. .\Invoke-Parallel.ps1


# Get HV accounts from specified OUs
$HVS = @()
$HVS = Get-ADComputer -SearchBase "OU=Servers_1,DC=domain,DC=com" -Filter * -Properties lastlogondate
$HVS +=Get-ADComputer -SearchBase "OU=Servers_2,DC=domain,DC=com" -Filter * -Properties lastlogondate
$HVS = $HVS  | ? {$_.Name -like "*HV*"} | ? {$_.lastlogondate -gt (get-date).adddays(-30)}

# Get list of snapshots
$result = $HVS | invoke-parallel  {invoke-command $_.Name {get-vm | get-vmsnapshot}} | select VMName,Name,ComputerName,SnapshotType,CreationTime,ParentSnapshotName

# Filter out fresh snapshots
$result = $result | ? {($_.CreationTime -lt $MinSnapAge)}

# Filter out excluded snapshots. Comment to disable
$result = $result | ? {($_.Name -notmatch $excl)}

# Convert result to HTML
$message = $result | sort CreationTime -Descending | ConvertTo-Html -Head $style | Out-String

# Send email
Send-MailMessage -Body $message -BodyAsHtml  -From "it@domain.com" -To "it@domain.com" -SmtpServer server.domain.com -Subject "HV Snapshot Report" -Encoding ([Text.Encoding]::GetEncoding("koi8-r"))