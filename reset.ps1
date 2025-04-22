function reset_PowerShell_Secret_Keeper {
    logevent -source "RESET_SCRIPT" -type "INFO" -message "Initiating reset processes."
    $source = "RESET_SCRIPT"
    try {
        $error.Clear()
        $exceptionFolders = @("SECRET_RECORDS","ENCRYPTION_KEYS")
        $subfolders = Get-ChildItem .\PSK_FILES_DONOTDELETE -Directory -ErrorAction Stop
        foreach ($folder in $subfolders) {
            logevent -source $source -type "INFO" -message "$($folder.Name) picked up."

            if ($exceptionFolders -contains $folder.Name) {
                logevent -source $source -type "INFO" -message "$($folder.Name) deleted (exception)." 
                            
            Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
            }
            else {
                        Get-ChildItem -Path $folder.FullName -File -Recurse -Force |  Move-Item -Destination . -Force
            Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
                logevent -source $source -type "INFO" -message "$($folder.Name) deleted."
            }
        }
        remove-item .\PSK_FILES_DONOTDELETE -Force -ErrorAction Stop
    }
    catch {
        logevent -source $source -type "ERROR" -message "Error during reset: `n$($_.Exception.Message)"
    }
    Remove-Variable * -ErrorAction Ignore
}

function logevent($source, $type, $message) {
    $logfilepath = ".\PSK_All.log"
    $datetime    = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
    $logline     = "$datetime`::$source`::[$type]::$message"
    if (-not (Test-Path $logfilepath)) { New-Item $logfilepath -Force | Out-Null }
    $logline >> $logfilepath
    Remove-Variable * -ErrorAction Ignore
}

reset_PowerShell_Secret_Keeper
