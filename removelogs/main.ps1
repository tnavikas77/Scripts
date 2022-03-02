# Invoke variables from the config file in the main script scope
. C:\scripts\removelogs\config.ps1

# Delete files in log folders
$Logs = (Get-ChildItem $LogFolder | `
    ?{$_.LastWriteTime -lt (Get-Date).AddDays($LogRetentionDays)})
$Logs | Remove-Item