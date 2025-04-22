function config_PowerShell_Secret_Keeper
{
    #create required folders
    #Encrypt_check
    #Secret_files
    $path1 = ".\PSK_FILES_DONOTDELETE\ENCRYPTION_KEYS"
    $path2 = ".\PSK_FILES_DONOTDELETE\SECRET_RECORDS"
    $path3 = ".\PSK_FILES_DONOTDELETE\PS1_SCRIPTS"
    $path4 = ".\PSK_FILES_DONOTDELETE\IMAGE_SOURCE"
    $path5 = ".\PSK_FILES_DONOTDELETE\LICENSE"
    
    

    $source = "CONFIG_SCRIPT"
    
    $pathlist = @($path1,$path2,$path3,$path4,$path5) #I want it to loop through each

    foreach($path in $pathlist)
    {
        if(Test-Path $path)
        {
             logevent -source $source -type "WARNING" -message "This path $path already exists. It could be that reset was not executed properly.`nIf you have manually created this, please ignore.`n Please check the PSK_ALL.log under 'CONFIG_SCRIPT' and execute reset.ps1 script again if required."
                     
        }
        else
        {
            try
            {
                $Error.clear()
                New-Item $path -ItemType Directory -Force  -ErrorAction Stop
                logevent -source $source -type "INFO" -message "Path $path is created successfully"
            }
            catch
            {
                logevent -source $source -type "ERROR" -message "Failed to create the required path $path. Please manually create the folder and try start.bat. If still issue please try reset.ps1 again.`n $Error"
            }

        }
    
    }

    #just for scripts, we will move into a folder
    Move-Item *.PS1 -Destination $path3

    #just for images, we will move into a folder
    Move-Item *.png -Destination $path4

    

    Move-Item LICENSE -Destination $path5
    
    #cleanup
    Remove-Variable * -ErrorAction Ignore

}
function logevent($source,$type,$message)
{
    #default log path
    $logfilepath = ".\PSK_All.log"

    #resetlog
    $datetime = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"

    $logline = "$datetime`::$source`::[$type]::$message"

    if(-not( Test-Path $logfilepath))
    {
        #create a new log file
        New-Item $logfilepath -Force
    }
    $logline >> $logfilepath

    Remove-Variable * -ErrorAction Ignore
}
config_PowerShell_Secret_Keeper