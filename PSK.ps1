function LogEvent {
    param (
        [string]$Source,
        [string]$Type,
        [string]$Message
    )

    $logFilePath = ".\PSK_All.log"
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
    $logLine = "$dateTime`::$Source`::[$Type]::$Message"

    if (-not (Test-Path $logFilePath)) {
        New-Item $logFilePath -Force
    }

    $logLine >> $logFilePath
}
function LogSystemInfo {
    
    Add-Type -AssemblyName "System.Windows.Forms"
    Add-Type -AssemblyName "System.Drawing"

   try
   {
   $Error.clear()
    $graphics = [System.Drawing.Graphics]::FromHwnd([IntPtr]::Zero) 
    $dpi = $graphics.DpiX

    $systemInfo = New-Object -TypeName PSObject -Property @{
        ScreenResolution  = (Get-WmiObject -Class Win32_DesktopMonitor -ErrorAction Stop | Select-Object -First 1 ScreenWidth, ScreenHeight) 
        DpiSetting        = $dpi
        OSEdition         = (Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop).Caption 
        PowerShellVersion = $PSVersionTable.PSVersion
        OSVersion         = (Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop).ProductType
        ExecutionPolicy   = Get-ExecutionPolicy -ErrorAction Stop
        }
    }
    catch{
        logevent -source "SYSTEMINFO" -type "ERROR" -message "Failed to capture system information $Error"
    }

    logevent -source "SYSTEMINFO" -type "INFO" -message "$systemInfo"
}
function MainUI {
    LogSystemInfo

    $Source = "MainUI"
    
    LogEvent -Source $Source -Type "INFO" -Message "MainUI function started."

    $global:PSK_UI = New-Object System.Windows.Forms.Form
    LogEvent -Source $Source -Type "INFO" -Message "Created new Form object for UI."

    $global:PSK_UI.Text = "PSK v1.0"
    $global:PSK_UI.MaximizeBox = $false
    $global:PSK_UI.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $global:PSK_UI.AutoScale = $false
    $global:PSK_UI.FormBorderStyle = "FixedDialog"
    $global:PSK_UI.StartPosition = "CenterScreen"

    Write-Host "here"
    LogEvent -Source $Source -Type "INFO" -Message "UI configured."

    $result = pinUI
    LogEvent -Source $Source -Type "INFO" -Message "pinUI function called, result: $result."

    if ($result -eq $true) {
        LogEvent -Source $Source -Type "INFO" -Message "PinUI result successful, proceeding with UI setup."

        $global:PSK_UI.MinimumSize = [System.Drawing.Size]::new(860, 500)
        $global:PSK_UI.MaximumSize = [System.Drawing.Size]::new(860, 500)

        $global:openlink = New-Object System.Windows.Forms.Button
        $global:openlink.Location = [System.Drawing.Point]::new(780, 10)
        $global:openlink.Size = [System.Drawing.Size]::new(40, 40)
        $global:openlink.Text = "🌐"
        $global:openlink.Font = [System.Drawing.Font]::new("Segoe UI emoji", 11)

        $tooltip6 = New-Object System.Windows.Forms.ToolTip
        $tooltip6.SetToolTip($global:openlink, "Open URL in Browser")
        $global:openlink.Add_Click({ openlink_action })
        LogEvent -Source $Source -Type "INFO" -Message "Open link button created."


        $licenseLabel = New-Object System.Windows.Forms.Label
        $licenseLabel.Text = "© 2025 Krishnaprasad Narayanankutty | Licensed under MIT"
        $licenseLabel.AutoSize = $true
        $licenseLabel.Location = New-Object System.Drawing.Point(2, ($global:PSK_UI.ClientSize.Height - 30))
        $licenseLabel.Anchor = "Bottom,Left"
     

        $global:togglebutton = New-Object System.Windows.Forms.Button
        $global:togglebutton.Location = [System.Drawing.Point]::new(726,10)
        $global:togglebutton.Size = [System.Drawing.Size]::new(40, 40)
        $global:togglebutton.Text = "⇄"
        $global:togglebutton.Font = [System.Drawing.Font]::new("Segoe UI emoji", 13)

        $tooltip0 = New-Object System.Windows.Forms.ToolTip
        $tooltip0.SetToolTip($global:togglebutton, "Toggle Display")

        $global:cellnumber = 1

        $global:togglebutton.Add_Click({
            switch ($global:cellnumber) {
                1 { $global:cellnumber = 2 }
                2 { $global:cellnumber = 3 }
                3 { $global:cellnumber = 1 }
                default { $global:cellnumber = 1 }
            }
            $rownumber = $global:data_grid.CurrentRow.Index
            $global:notifylabel.Text = "($($rownumber + 1)) - $($global:data_grid.Rows[$rownumber].Cells[$global:cellnumber].Value)"
            LogEvent -Source $Source -Type "INFO" -Message "Toggled cell number to $global:cellnumber."

            $global:data_grid.Columns[1].HeaderCell.Style.Font = [System.Drawing.Font]::new('Segoe UI emoji', 10, [System.Drawing.FontStyle]::Bold)
            $global:data_grid.Columns[2].HeaderCell.Style.Font = [System.Drawing.Font]::new('Segoe UI emoji', 10, [System.Drawing.FontStyle]::Bold)
            $global:data_grid.Columns[3].HeaderCell.Style.Font = [System.Drawing.Font]::new('Segoe UI emoji', 10, [System.Drawing.FontStyle]::Bold)
            $global:data_grid.Columns[$global:cellnumber].HeaderCell.Style.Font = [System.Drawing.Font]::new('Segoe UI emoji', 12, [System.Drawing.FontStyle]::Bold)

            $Global:PSK_UI.Refresh()
        })

        $global:notifylabel = New-Object System.Windows.Forms.Label
        $global:notifylabel.Size = [System.Drawing.Size]::new(700, 50)
        $global:notifylabel.Location = [System.Drawing.Point]::new(10, 5)
        $global:notifylabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $global:notifylabel.TextAlign = "MiddleCenter"
        $global:notifylabel.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 11)

        add_button
        add_manage_button
        add_copy_key_button
        add_copy_secret_button
        add_datagrid

        $global:PSK_UI.Controls.Add($global:notifylabel)
        $global:PSK_UI.Controls.Add($global:togglebutton)
        $global:PSK_UI.Controls.Add($global:openlink)
        $global:PSK_UI.Controls.Add($licenseLabel)

        LogEvent -Source $Source -Type "INFO" -Message "UI controls added to the form."

        $global:PSK_UI.ShowDialog()
        LogEvent -Source $Source -Type "INFO" -Message "UI displayed."
    }
    else {
        Write-Host "inelse"
        LogEvent -Source $Source -Type "ERROR" -Message "PinUI function failed."
    }
}

function openlink_action {
    $Source = "openlink_action"
    LogEvent -Source $Source -Type "INFO" -Message "openlink_action function started."
    $rownumber = $global:data_grid.CurrentRow.Index
    LogEvent -Source $Source -Type "DEBUG" -Message "Selected row: $rownumber"
    $temp_content = gc "$Global:secretfiles_path\$($rownumber + 1).secret"
    LogEvent -Source $Source -Type "DEBUG" -Message "File content retrieved for row $rownumber"
    $browser = $temp_content[3]
    $link = $temp_content[2]
    LogEvent -Source $Source -Type "DEBUG" -Message "Browser: $browser, Link: $link"

    if ($link -eq "none" -or $link -eq " ") {
        $global:notifylabel.Text = "No link provided for this record."
        $global:PSK_UI.Refresh()
        LogEvent -Source $Source -Type "WARNING" -Message "No link provided for record $rownumber"
    }
    else {
        $exe = ""
        $args = @()

        switch ($browser) {
            'Google Chrome' {
                $exe = "chrome.exe"
                $args = @($link)
            }
            '[Incognito]Google Chrome' {
                $exe = "chrome.exe"
                $args = @("--incognito", $link)
            }
            'Mozilla Firefox' {
                $exe = "firefox.exe"
                $args = @($link)
            }
            '[Incognito]Mozilla Firefox' {
                $exe = "firefox.exe"
                $args = @("-private-window", $link)
            }
            'Microsoft Edge' {
                $exe = "msedge.exe"
                $args = @($link)
            }
            '[Incognito]Microsoft Edge' {
                $exe = "msedge.exe"
                $args = @("--inprivate", $link)
            }
            'Opera' {
                $exe = "opera.exe"
                $args = @($link)
            }
            '[Incognito]Opera' {
                $exe = "opera.exe"
                $args = @("--private", $link)
            }
            'none' {
                $global:notifylabel.Text = "No browser set. Please set a browser from 🔧."
                $global:PSK_UI.Refresh()
                LogEvent -Source $Source -Type "ERROR" -Message "No browser set for record $rownumber"
                return
            }
            default {
                Write-Host "Unsupported browser selection: $browser"
                LogEvent -Source $Source -Type "ERROR" -Message "Unsupported browser selection: $browser for record $rownumber"
                return
            }
        }

        $global:notifylabel.Text = "Opening $browser for $link"
        $global:PSK_UI.Refresh()
        LogEvent -Source $Source -Type "INFO" -Message "Opening $browser with link: $link"
        Start-Sleep -Seconds 1
        Start-Process $exe -ArgumentList $args
        $global:notifylabel.Text = "Ready"
        $global:PSK_UI.Refresh()
    }
}

function pinUI {
    $Source = "pinUI"
    LogEvent -Source $Source -Type "INFO" -Message "pinUI function started."

    try {
        $global:PSK_UI.MinimumSize = [System.Drawing.Size]::new(400, 250)
        $global:PSK_UI.MaximumSize = [System.Drawing.Size]::new(400, 250)

        LogEvent -Source $Source -Type "INFO" -Message "UI size set."

        #$image = [System.Drawing.Image]::FromFile(".\imagesource\folder-password-lock-icon.png")
        $checkboximage = [System.Drawing.Image]::FromFile(".\PSK_FILES_DONOTDELETE\IMAGE_SOURCE\unlocked-icon.png")
        $image2 = [System.Drawing.Image]::FromFile(".\PSK_FILES_DONOTDELETE\IMAGE_SOURCE\padlock-icon.png")
        
        LogEvent -Source $Source -Type "INFO" -Message "Images loaded."

        $global:pictureBox = New-Object System.Windows.Forms.PictureBox
        $global:pictureBox.Image = $image
        $global:pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
        $global:pictureBox.Location = [System.Drawing.Point]::new(140, 65)
        $global:pictureBox.Size = [System.Drawing.Size]::new(100, 100)

       
        LogEvent -Source $Source -Type "INFO" -Message "PictureBoxes created."

        $global:pinlabel = New-Object System.Windows.Forms.Label
        $global:pinlabel.Size = [System.Drawing.Size]::new(380, 50)
        $global:pinlabel.Location = [System.Drawing.Point]::new(-1, 1)
        $global:pinlabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $global:pinlabel.Font = [System.Drawing.Font]::new("Segoe UI", 12)
        $global:pinlabel.TextAlign = "MiddleCenter"
        $global:pinlabel.BackColor = [System.Drawing.Color]::FromArgb(204, 229, 255)

        $global:pinbox = New-Object System.Windows.Forms.TextBox
        $global:pinbox.Location = [System.Drawing.Point]::new(140, 75)
        $global:pinbox.Size = [System.Drawing.Size]::new(120, 30)
        $global:pinbox.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
        $global:pinbox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $global:pinbox.TextAlign = "Center"
        $global:pinbox.Multiline = $false
        $global:pinbox.UseSystemPasswordChar = $true
        $global:pinbox.MaxLength = 4
        $global:pinbox.BackColor = [System.Drawing.Color]::black
        $global:pinbox.ForeColor = [System.Drawing.Color]::white

        $global:pinbox.Add_KeyPress({
            if ($_.KeyChar -notmatch '\d' -and $_.KeyChar -ne [char]8) {
                $_.Handled = $true
            }
        })

        $global:pinbox.Add_TextChanged({
            $global:pinbox.Text = ($global:pinbox.Text -replace '[^\d]', '')
            if ($global:pinbox.Text.Length -gt 4) {
                $global:pinbox.Text = $global:pinbox.Text.Substring(0, 4)
            }
            $global:pinbox.SelectionStart = $global:pinbox.Text.Length

            if ($global:pinbox.Text.Length -eq 4) {
                $global:pinbutton.Enabled = $true
                $global:PSK_UI.controls.Add($global:pictureBox2)
                $global:pinbutton.Focus()
            } else {
                $global:pinbutton.Enabled = $false
                $global:PSK_UI.controls.Remove($global:pictureBox2)
            }
        })

        $global:pinbutton = New-Object System.Windows.Forms.Button
        $global:pinbutton.Location = [System.Drawing.Point]::new(160, 140)
        $global:pinbutton.Size = [System.Drawing.Size]::new(80, 40)
        $global:pinbutton.Text = "➝"
        $global:pinbutton.Font = New-Object System.Drawing.Font("Segoe UI emoji", 20)
        $global:pinbutton.Enabled = $false
        $global:pinbuttonclicked = $false

       # $global:pinbutton.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
       # $global:pinbutton.BackColor = [System.Drawing.Color]::FromArgb(173, 216, 230)
       # $global:pinbutton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        
        $global:pinbutton.Add_Click({
            LogEvent -Source $Source -Type "INFO" -Message "PIN button clicked."
            $global:result = pinbutton_action
        })

        switch ($global:pinstatusflag) {
            "setpin" {
                $global:pinlabel.Text = "Set a 4-digit PIN"
                LogEvent -Source $Source -Type "INFO" -Message "Set PIN mode activated."
            }
            "askpin" {
                $global:pinlabel.Text = "Please enter the PIN"
                LogEvent -Source $Source -Type "INFO" -Message "Ask PIN mode activated."
            }
        }

        $global:PSK_UI.Controls.Add($global:pinlabel)
        $global:PSK_UI.Controls.Add($global:pinbox)
        $global:PSK_UI.Controls.Add($global:pinbutton)
        $global:PSK_UI.Controls.Add($global:pictureBox)

        $global:PSK_UI.ShowDialog()

        LogEvent -Source $Source -Type "INFO" -Message "pinUI function ended."

    } catch {
        LogEvent -Source $Source -Type "ERROR" -Message "Error in pinUI: $($_.Exception.Message)"
    }

    return $global:result
}

function pinbutton_action {
    $Source = "pinbutton_action"
    LogEvent -Source $Source -Type "INFO" -Message "pinbutton_action started."

    $initialpin = $global:pinbox.Text
    $global:pinbox.Text = ""
    $global:pinbuttonclicked = $true

    try {
        switch ($global:pinstatusflag) {
            "setpin" {
                LogEvent -Source $Source -Type "INFO" -Message "Setting PIN."
                $pinbytes = getpinbytes -pin $initialpin
                $randomBytes = New-Object byte[] 28
                [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($randomBytes)
                $base64key = [Convert]::ToBase64String($randomBytes)
                $base64key | Set-Content $global:encryptionkeypath
                $global:keybytes = $pinbytes + $randomBytes

                $encrypt_text = "This is a random text"
                $securestring_text = ConvertTo-SecureString -String $encrypt_text -AsPlainText -Force
                $encrypted_string = ConvertFrom-SecureString -SecureString $securestring_text -Key $global:keybytes
                $encrypted_string | Set-Content $global:entry_gate_path
                $result = $true
                LogEvent -Source $Source -Type "INFO" -Message "PIN set and encryption successful."

                $global:PSK_UI.Controls.Clear()
                $global:PSK_UI.Close()
            }
            "askpin" {
                LogEvent -Source $Source -Type "INFO" -Message "Asking for PIN verification."
                $pinbytes = getpinbytes -pin $initialpin
                $base64_key = gc $global:encryptionkeypath
                $encryptionkey_bytes = [convert]::FromBase64String($base64_key)
                $global:keybytes = $pinbytes + $encryptionkey_bytes
                try {
                    $Error.Clear()
                    $entrygatebase64 = gc $global:entry_gate_path
                    $null = ConvertTo-SecureString -String $entrygatebase64 -Key $global:keybytes -ErrorAction Stop
                    LogEvent -Source $Source -Type "INFO" -Message "PIN verification successful."
                    $global:pinlabel.BackColor = [System.Drawing.Color]::FromArgb(204, 255, 204)
                    $global:pinlabel.Text = "Authentication Successful"
                    $global:pinbutton.Visible = $false
                    $global:pinbox.Visible = $false
                    $global:pictureBox.Image = $checkboximage
                    $global:PSK_UI.Refresh()
                    Start-Sleep -Milliseconds 500
                    getfilenumber
                    $global:PSK_UI.Controls.Clear()
                    $global:PSK_UI.Close()
                    $result = $true
                    $exitflag = $true
                }
                catch {
                    LogEvent -Source $Source -Type "ERROR" -Message "Authentication failed. Error: $($_.Exception.Message)"
                    $global:pictureBox.Image = $image2
                    $global:pinbutton.Visible = $false
                    $global:pinbox.Visible = $false
                    $global:pinlabel.BackColor = [System.Drawing.Color]::FromArgb(255, 204, 204)
                    $global:pinlabel.Text = "Authentication Failed. Exiting.."
                    $global:PSK_UI.Refresh()
                    Start-Sleep -Seconds 1
                    $global:PSK_UI.Controls.Clear()
                    $global:PSK_UI.Close()
                    $result = $false
                }
            }
        }
    } catch {
        LogEvent -Source $Source -Type "ERROR" -Message "Error in pinbutton_action: $($_.Exception.Message)"
    }

    LogEvent -Source $Source -Type "INFO" -Message "pinbutton_action ended."
    return $result
}

function add_manage_button
{
    $Source = "add_manage_button"
    LogEvent -Source $Source -Type "INFO" -Message "Adding manage button to the UI."

    $global:manage_button = New-Object System.Windows.Forms.Button
    $global:manage_button.Location = [System.Drawing.Point]::new(780, 60)
    $global:manage_button.Size = [System.Drawing.Size]::new(40,40)
    $global:manage_button.Text = "🔧"
    $global:manage_button.Font = [System.Drawing.Font]::new("Segoe UI Emoji", 12)
    $global:manage_button.add_click({manage_button_action})

    $tooltip1 = New-Object System.Windows.Forms.ToolTip
    $tooltip1.SetToolTip($global:manage_button, "Manage")
    
    $global:PSK_UI.controls.Add($global:manage_button)

    LogEvent -Source $Source -Type "INFO" -Message "Manage button added to UI."
}

function manage_button_action
{
    $Source = "manage_button_action"
    LogEvent -Source $Source -Type "INFO" -Message "Manage button clicked. Clearing current UI and resizing."

    $global:PSK_UI.Controls.Clear()
    $global:PSK_UI.MinimumSize = [System.Drawing.Size]::new(490,350)
    $global:PSK_UI.MaximumSize = [System.Drawing.Size]::new(490,350)

    LogEvent -Source $Source -Type "INFO" -Message "Calling add/edit UI function."
    add_edit_UI

    LogEvent -Source $Source -Type "INFO" -Message "Removing submit button from UI."
    $global:PSK_UI.Controls.Remove($global:submit_button)

    $currentrow = $global:data_grid.CurrentRow.Index
    LogEvent -Source $Source -Type "INFO" -Message "Selected row: $currentrow"

    $temp_file_raw = gc "$global:secretfiles_path\$($currentrow+1).secret"
    $secret_line = $temp_file_raw[4]
    $linkline = $temp_file_raw[2]
    $browserline = $temp_file_raw[3]
        $keyline = $temp_file_raw[1]
    $nameline = $temp_file_raw[0]

    $temp_secret = ConvertTo-SecureString -String $secret_line -Key $global:keybytes
    $clipboarddata = getplainpin -pin $temp_secret

    LogEvent -Source $Source -Type "INFO" -Message "Loading data into textboxes."
    $global:tb_name.Text = $nameline
    $global:tb_name.Enabled = $false
    $global:tb_key.Text = $keyline
    $global:tb_key.Enabled = $false
    $global:tb_secret.Text = $clipboarddata
    $global:tb_secret.Enabled = $false
    $global:tb_link.Text = $linkline
    $global:tb_link.Enabled = $false
    $global:dropdown.SelectedItem = $browserline
    $global:dropdown.Enabled = $false

    # Create Delete Button
    $global:delete_button = New-Object System.Windows.Forms.Button
    $global:delete_button.Location = [System.Drawing.Point]::new(380,20)
    $global:delete_button.Text = "❌"
    $global:delete_button.Size = [System.Drawing.Size]::new(80,50)
    $global:delete_button.Font = [System.Drawing.Font]::new('segoe UI emoji',10)
    $global:delete_button.Visible = $false
    $global:delete_button.add_click({
        $currentRowFile = $global:data_grid.CurrentRow.Index + 1
        $purgefilepath = "$global:secretfiles_path\$currentRowFile.secret"
        LogEvent -Source $Source -Type "INFO" -Message "Deleting file: $purgefilepath"
        Remove-Item $purgefilepath -Force 
        getfilenumber
        bringback_mainUI
    })

    # Create Edit Button
    $global:edit_button = New-Object System.Windows.Forms.Button
    $global:edit_button.Location = [System.Drawing.Point]::new(380,115)
    $global:edit_button.Text = "✏️"
    $global:edit_button.Size = [System.Drawing.Size]::new(80,50)
    $global:edit_button.Font = [System.Drawing.Font]::new('segoe UI emoji',12)
    $global:edit_button.add_click({
        LogEvent -Source $Source -Type "INFO" -Message "Editing file. Enabling fields and showing submit button."
        
        $global:delete_button.Visible = $true
        $global:edit_button.Visible = $false
        $global:editflag = $true

        $global:tb_name.Enabled = $true
        $global:tb_key.Enabled = $true
        $global:tb_link.Enabled = $true
        $global:dropdown.Enabled = $true
        $global:tb_secret.Enabled = $true

        LogEvent -Source $Source -Type "INFO" -Message "Re-adding submit button to UI."
        $global:PSK_UI.Controls.Remove($global:edit_button)
        $global:PSK_UI.Controls.Add($global:submit_button)
        $global:PSK_UI.Refresh()
    })

    # Add Edit and Delete Buttons to UI
    LogEvent -Source $Source -Type "INFO" -Message "Adding edit and delete buttons to UI."
    $global:PSK_UI.controls.Add($global:edit_button)
    $global:PSK_UI.controls.Add($global:delete_button)
}

function add_edit_UI {
    $source = "add_edit_UI"
    LogEvent -Source $source -Type "INFO" -Message "Editing file. Enabling fields and showing submit button."

    $label_name = New-Object System.Windows.Forms.Label
    $label_name.Text = "👤"
    $label_name.Location = [System.Drawing.Point]::new(10,28)
    $label_name.Size = [System.Drawing.Size]::new(40,40)
    $label_name.Font = [System.Drawing.Font]::new('segoe UI emoji',12)

    $global:tb_name = New-Object System.Windows.Forms.TextBox
    $global:tb_name.Location = [System.Drawing.Point]::new(50,25)
    $global:tb_name.Size = [System.Drawing.Size]::new(300,50)
    $global:tb_name.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $global:placeholdername = "Name"
    $global:tb_name.Text = $global:placeholdername
    $global:tb_name.ForeColor = [System.Drawing.Color]::Gray
    $global:tb_name.Add_enter({
        if ($global:tb_name.Text -eq $global:placeholdername) {
            $global:tb_name.Text = ""
            $global:tb_name.ForeColor = [System.Drawing.Color]::Black
            $global:tb_name.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_name.Add_leave({
        if ($global:tb_name.Text -eq "") {
            $global:tb_name.Text = $global:placeholdername
            $global:tb_name.ForeColor = [System.Drawing.Color]::Gray
            $global:tb_name.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_name.Multiline = $false
    $global:tb_name.MaxLength = 50
    LogEvent -Source $source -Type "INFO" -Message "Name field initialized."

    $label_key = New-Object System.Windows.Forms.Label
    $label_key.Location = [System.Drawing.Point]::new(10,78)
    $label_key.Size = [System.Drawing.Size]::new(40,40)
    $label_key.Text = "🗝️"
    $label_key.Font = [System.Drawing.Font]::new('segoe UI emoji',12)

    $global:tb_key = New-Object System.Windows.Forms.TextBox
    $global:tb_key.Location = [System.Drawing.Point]::new(50,75)
    $global:tb_key.Size = [System.Drawing.Size]::new(300,50)
    $global:tb_key.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $global:placeholderkey = "Key"
    $global:tb_key.Text = $global:placeholderkey
    $global:tb_key.ForeColor = [System.Drawing.Color]::Gray
    $global:tb_key.Add_enter({
        if ($global:tb_key.Text -eq $global:placeholderkey) {
            $global:tb_key.Text = ""
            $global:tb_key.ForeColor = [System.Drawing.Color]::Black
            $global:tb_key.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_key.Add_leave({
        if ($global:tb_key.Text -eq "") {
            $global:tb_key.Text = $global:placeholderkey
            $global:tb_key.ForeColor = [System.Drawing.Color]::Gray
            $global:tb_key.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_key.Multiline = $false
    $global:tb_key.MaxLength = 500
    LogEvent -Source $source -Type "INFO" -Message "Key field initialized."

    $label_secret = New-Object System.Windows.Forms.Label
    $label_secret.Location = [System.Drawing.Point]::new(10,128)
    $label_secret.Size = [System.Drawing.Size]::new(40,40)
    $label_secret.Text = "🔒"
    $label_secret.Font = [System.Drawing.Font]::new('segoe UI emoji',12)

    $global:tb_secret = New-Object System.Windows.Forms.TextBox
    $global:tb_secret.Location = [System.Drawing.Point]::new(50,125)
    $global:tb_secret.Size = [System.Drawing.Size]::new(300,50)
    $global:tb_secret.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $global:placeholdersecret = "Secret"
    $global:tb_secret.Text = $global:placeholdersecret
    $global:tb_secret.ForeColor = [System.Drawing.Color]::Gray
    $global:tb_secret.Add_enter({
        if ($global:tb_secret.Text -eq $global:placeholdersecret) {
            $global:tb_secret.Text = ""
            $global:tb_secret.ForeColor = [System.Drawing.Color]::Black
            $global:tb_secret.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_secret.Add_leave({
        if ($global:tb_secret.Text -eq "") {
            $global:tb_secret.Text = $global:placeholdersecret
            $global:tb_secret.ForeColor = [System.Drawing.Color]::Gray
            $global:tb_secret.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_secret.UseSystemPasswordChar = $true
    $global:tb_secret.Multiline = $false
    LogEvent -Source $source -Type "INFO" -Message "Secret field initialized."

    $global:submit_button = New-Object System.Windows.Forms.Button
    $global:submit_button.Location = [System.Drawing.Point]::new(380,115)
    $global:submit_button.Text = "✔️"
    $global:submit_button.Size = [System.Drawing.Size]::new(80,50)
    $global:submit_button.Font = [System.Drawing.Font]::new('segoe UI emoji',12)
    $global:submit_button.add_click({submit_button_action})
    LogEvent -Source $source -Type "INFO" -Message "Submit button created."

    $back_button = New-Object System.Windows.Forms.Button
    $back_button.Location = [System.Drawing.Point]::new(380,215)
    $back_button.Size = [System.Drawing.Size]::new(80,50)
    $back_button.Font = [System.Drawing.Font]::new('segoe UI emoji',19)
    $back_button.Text = "←"
    $back_button.add_click({bringback_mainUI})
    LogEvent -Source $source -Type "INFO" -Message "Back button created."

    $label_link = New-Object System.Windows.Forms.Label
    $label_link.Location = [System.Drawing.Point]::new(10,175)
    $label_link.Size = [System.Drawing.Size]::new(40,40)
    $label_link.Text = "🔗"
    $label_link.Font = [System.Drawing.Font]::new('segoe UI emoji',12)

    $global:tb_link = New-Object System.Windows.Forms.TextBox
    $global:tb_link.Location = [System.Drawing.Point]::new(50,175)
    $global:tb_link.Size = [System.Drawing.Size]::new(300,50)
    $global:tb_link.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $global:placeholderlink = "URL"
    $global:tb_link.Text = $global:placeholderlink
    $global:tb_link.ForeColor = [System.Drawing.Color]::Gray
    $global:tb_link.Add_enter({
        if ($global:tb_link.Text -eq $global:placeholderlink) {
            $global:tb_link.Text = ""
            $global:tb_link.ForeColor = [System.Drawing.Color]::Black
            $global:tb_link.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_link.Add_leave({
        if ($global:tb_link.Text -eq "") {
            $global:tb_link.Text = $global:placeholderlink
            $global:tb_link.ForeColor = [System.Drawing.Color]::Gray
            $global:tb_link.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $global:PSK_UI.Refresh()
        }
    })
    $global:tb_link.Multiline = $false
    LogEvent -Source $source -Type "INFO" -Message "URL field initialized."

    $label_dropdown = New-Object System.Windows.Forms.Label
    $label_dropdown.Location = [System.Drawing.Point]::new(10,230)
    $label_dropdown.Size = [System.Drawing.Size]::new(40,40)
    $label_dropdown.Text = "🌍"
    $label_dropdown.Font = [System.Drawing.Font]::new('segoe UI emoji',12)

    $global:dropdown = New-Object System.Windows.Forms.ComboBox
    $global:dropdown.Size = [System.Drawing.Size]::new(300,50)
    $global:dropdown.Location = [System.Drawing.Point]::new(50,230)
    $global:dropdown.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $global:dropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $availablebrowsers = getinstalledbrowsers 
    $global:dropdown.Items.AddRange($availablebrowsers)
    $global:dropdown.SelectedIndex = 0
    LogEvent -Source $source -Type "INFO" -Message "Dropdown populated with available browsers."

    $global:PSK_UI.Controls.Add($global:dropdown)
    $global:PSK_UI.Controls.Add($label_name)
    $global:PSK_UI.controls.add($global:tb_name)
    $global:PSK_UI.Controls.Add($label_key)
    $global:PSK_UI.controls.add($global:tb_key)
    $global:PSK_UI.Controls.Add($label_secret)
    $global:PSK_UI.controls.add($global:tb_secret)
    $global:PSK_UI.Controls.Add($label_link)
    $global:PSK_UI.Controls.Add($label_dropdown)
    $global:PSK_UI.controls.add($global:tb_link)
    $global:PSK_UI.controls.add($global:submit_button)
    $global:PSK_UI.controls.add($back_button)

    LogEvent -Source $source -Type "INFO" -Message "All UI controls added to main form."
}


function getinstalledbrowsers {
    $source = "getinstalledbrowsers"

    $browsers = @(
        @{ Name = 'Google Chrome'; Path = 'C:\Program Files\Google\Chrome\Application\chrome.exe' },
        @{ Name = 'Mozilla Firefox'; Path = 'C:\Program Files\Mozilla Firefox\firefox.exe' },
        @{ Name = 'Microsoft Edge'; Path = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' },
        @{ Name = 'Opera'; Path = 'C:\Program Files\Opera\opera.exe' }
    )
    $availablebrowsers = @("None")
    foreach ($browser in $browsers) {
        if (Test-Path $browser.Path) {
            $availablebrowsers += $browser.name
            $availablebrowsers += "[Incognito]$($browser.name)"
            LogEvent -Source $source -Type "INFO" -Message "$($browser.Name) found at $($browser.Path)."
        }
        elseif (-not (Test-Path $browser.Path)) {
            LogEvent -Source $source -Type "WARNING" -Message "$($browser.Name) not found at $($browser.Path)."
        }
    }
    LogEvent -Source $source -Type "INFO" -Message "Checked and returned list of installed browsers."
    return $availablebrowsers
}


function add_copy_key_button
{
    $source = "add_copy_key_button"
    $global:copy_key_button = New-Object System.Windows.Forms.Button
    $global:copy_key_button.Location = [System.Drawing.Point]::new(726,105)
    $global:copy_key_button.Size = [System.Drawing.Size]::new(40,310)
    $global:copy_key_button.Text = "🔑"
    $font = New-Object System.Drawing.Font("Segoe UI Emoji", 11)
    $global:copy_key_button.Font = $font 
    $tooltip2 = New-Object System.Windows.Forms.ToolTip
    $tooltip2.SetToolTip($global:copy_key_button, "Copy Key to Clipboard")
    $global:copy_key_button.add_click({copy_key_action})
    $global:PSK_UI.Controls.Add($copy_key_button)
    LogEvent -Source $source -Type "INFO" -Message "Copy key button added to UI."
}

function copy_key_action
{
    $source = "copy_key_action"
    Write-Host "copied key"
    $currentrownumber = ($global:data_grid.CurrentRow).Index + 1
    LogEvent -Source $source -Type "INFO" -Message "Copied key from row $currentrownumber"
    copy_secret_action -currentrow $currentrownumber -type "Key"
}



function add_copy_secret_button
{
    $source = "add_copy_secret_button"
    $global:copy_secret_button = New-Object System.Windows.Forms.Button
    $global:copy_secret_button.Location = [System.Drawing.Point]::new(780,105)
    $global:copy_secret_button.Size = [System.Drawing.Size]::new(40,310)
    $global:copy_secret_button.Text = "🔒"
    $font = New-Object System.Drawing.Font("Segoe UI Emoji", 12)
    $global:copy_secret_button.Font = $font 
    $tooltip3 = New-Object System.Windows.Forms.ToolTip
    $tooltip3.SetToolTip($global:copy_secret_button, "Copy Secret to Clipboard")
    $global:copy_secret_button.add_click(
    {
        $currentrownumber = ($global:data_grid.CurrentRow).Index + 1
        copy_secret_action -currentrow $currentrownumber -type "Secret"
    })
    $global:PSK_UI.Controls.Add($copy_secret_button)
    LogEvent -Source $source -Type "INFO" -Message "Copy secret button added to UI."
}

function copy_secret_action($currentrow,$type)
{
    $source = "copy_secret_action"
    Write-Host "copied secret $currentrow"
    $temp_file_raw = gc "$global:secretfiles_path\$currentrow.secret"
    if($type -eq "secret")
    {
        $secret_line = $temp_file_raw[4]
        $temp_secret = ConvertTo-SecureString -String $secret_line -Key $global:keybytes
        $clipboarddata = getplainpin -pin $temp_secret
        Write-Host $temp_secret, $clipboarddata
    }
    if($type -eq "key")
    {
        $clipboarddata = $temp_file_raw[1]
    }
    Set-Clipboard  -Value $clipboarddata
    $global:notifylabel.BackColor = [System.Drawing.Color]::FromArgb(204,229,255)
    $global:notifylabel.Text = "$type is copied to clipboard !"
    $global:PSK_UI.Refresh()
    LogEvent -Source $source -Type "INFO" -Message "$type copied to clipboard for row $currentrow."
}


function add_button
{
    $source = "add_button"
    $global:add_button = New-Object System.Windows.Forms.Button
    $global:add_button.Size = [System.Drawing.Size]::new(40,40)
    $global:add_button.Location = [System.Drawing.Point]::new(726,60)
    $global:add_button.Text = "➕"
    $global:add_button.Font = [System.Drawing.Font]::new("Segoe UI Emoji", 11)
    $tooltip4 = New-Object System.Windows.Forms.ToolTip
    $tooltip4.SetToolTip($global:add_button, "Add")
    $global:PSK_UI.Controls.Add($add_button)
    $global:add_button.add_click({add_button_action})
    LogEvent -Source $source -Type "INFO" -Message "Add button created and added to UI."
}

function add_button_action
{
    $source = "add_button_action"
    Write-Host "clicked"
    $global:PSK_UI.Controls.Clear()
    $global:PSK_UI.MinimumSize = [System.Drawing.Size]::new(490,350)
    $global:PSK_UI.MaximumSize = [System.Drawing.Size]::new(490,350)
    add_edit_UI
    LogEvent -Source $source -Type "INFO" -Message "Add button clicked, UI cleared and resized."
}

function submit_button_action
{
    $source = "submit_button_action"
    $psk_name = $global:tb_name.Text
    $psk_key = $global:tb_key.Text
    $psk_secret = $global:tb_secret.Text
    $psk_link = $global:tb_link.Text
    $psk_browser = $global:dropdown.SelectedItem
    
    if($psk_name -and $psk_key -and $psk_secret -and $psk_name -ne " " -and $psk_key -ne " " -and $psk_secret -ne " " -and $psk_name -ne "Name" -and $psk_key -ne "Key" -and $psk_secret -ne "Secret" )
    {
        Write-Host "data is there"
        if($psk_link -eq "" -or $psk_link -eq " " -or $psk_link -eq $null -or $psk_link -eq 'URL')
        {
            $psk_link = "None"
        }
        Write-Host $psk_name,$psk_key $psk_secret,$psk_link,$psk_browser
        $temp_var = @($psk_name,$psk_key,$psk_link,$psk_browser)
        $temp_varsecure = ConvertTo-SecureString -String $psk_secret -AsPlainText -Force
        $encoded_secret = ConvertFrom-SecureString -SecureString $temp_varsecure -Key $Global:keybytes
        $temp_var += $encoded_secret
        $temp_filename = getfilenumber
        Write-Host $temp_var,$temp_filename
        Write-Host $global:editflag
        if($global:editflag)
        {
            Write-Host $global:data_grid.CurrentRow.Index
            set-content "$Global:secretfiles_path\$($global:data_grid.CurrentRow.Index +1).secret" -Value $temp_var -Force
        }
        else
        {
            set-content "$Global:secretfiles_path\$temp_filename.secret" -Value $temp_var -Force
        }
        $global:editflag = $false
        Write-Host $global:editflag
        bringback_mainUI
        LogEvent -Source $source -Type "INFO" -Message "Secret data submitted and saved successfully."
    }
    else
    {
        Write-Host "empty"
        $global:tb_secret.BackColor = [System.Drawing.Color]::FromArgb(255, 204, 204)
        $global:tb_name.BackColor = [System.Drawing.Color]::FromArgb(255, 204, 204)
        $global:tb_key.BackColor = [System.Drawing.Color]::FromArgb(255, 204, 204)
        $errorlabel.Size = [System.Drawing.Size]::new(300,50)
        $global:PSK_UI.controls.Add($errorlabel)
        $global:PSK_UI.Refresh()
        LogEvent -Source $source -Type "WARNING" -Message "Required fields are empty."
    }
}

function bringback_mainUI
{
    $source = "bringback_mainUI"
    $global:PSK_UI.Text = "PowerShell Secret Keeper v1.0"
    $global:PSK_UI.MaximizeBox = $false
    $global:PSK_UI.AutoScaleMode = "none"
    $global:PSK_UI.AutoScale = $false
        $global:PSK_UI.MinimumSize = [System.Drawing.Size]::new(860, 500)
        $global:PSK_UI.MaximumSize = [System.Drawing.Size]::new(860, 500)
    add_datagrid
    $global:editflag = $false
    $global:PSK_UI.Controls.Clear()
    $global:PSK_UI.Controls.Add($global:togglebutton)
    $global:PSK_UI.controls.Add($global:manage_button)
    $global:PSK_UI.Controls.Add($global:openlink)
    $Global:PSK_UI.Controls.Add($global:data_grid)
    $global:PSK_UI.Controls.Add($global:add_button)
    $global:PSK_UI.Controls.Add($global:copy_secret_button)
    $global:PSK_UI.Controls.Add($global:copy_key_button)
    $global:PSK_UI.controls.Add($global:notifylabel)
       $global:PSK_UI.Controls.Add($licenseLabel)
    $global:PSK_UI.controls.Add($global:panel)
    $global:PSK_UI.Refresh()
    LogEvent -Source $source -Type "INFO" -Message "Main UI returned to display after action."
}

function add_datagrid
{
    $source = "add_datagrid"
    $global:data_grid = New-Object System.Windows.Forms.DataGridView
    $global:data_grid.RowHeadersVisible = $false
    $global:data_grid.ColumnHeadersHeight = 50
    $global:data_grid.ReadOnly = $true
    $global:data_grid.AllowUserToResizeColumns = $false
    $global:data_grid.AllowUserToResizeRows = $false
    $global:data_grid.ColumnHeadersHeightSizeMode = "DisableResizing"
    $global:data_grid.ColumnCount = 4
    $global:data_grid.AllowUserToAddRows = $false
    $global:data_grid.SelectionMode = "fullrowselect"
    $global:data_grid.MultiSelect = $false
    $global:data_grid.RowTemplate.Height = 40
    $global:data_grid.Location = [System.Drawing.Point]::new(10,62)
    $global:data_grid.Size = [System.Drawing.Size]::new(700,350)
    $global:data_grid.AllowUserToOrderColumns = $false
    $global:data_grid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(0, 76, 153)
    $global:data_grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White
    $global:data_grid.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $global:data_grid.Columns[1].HeaderCell.Style.Font = [System.Drawing.Font]::new('Segoe UI emoji',12,[System.Drawing.FontStyle]::Bold)
    $global:data_grid.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(240, 248, 255)
    $global:data_grid.DefaultCellStyle.ForeColor = [System.Drawing.Color]::Black
    $global:data_grid.DefaultCellStyle.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $global:data_grid.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
    $global:data_grid.CellBorderStyle = [System.Windows.Forms.DataGridViewCellBorderStyle]::Single
    $global:data_grid.GridColor = [System.Drawing.Color]::FromArgb(169, 169, 169)

    $col_serialnumber = $global:data_grid.Columns[0]
    $col_serialnumber.Width = 50
    $col_serialnumber.HeaderText = "#"
    $col_serialnumber.ValueType = [int]

    $col_name = $global:data_grid.Columns[1]
    $col_name.Width = 230
    $col_name.HeaderText = "Name"
    $col_name.SortMode = 'notsortable'

    $col_key = $global:data_grid.Columns[2]
    $col_key.Width = 235
    $col_key.HeaderText = "Key"
    $col_key.SortMode = 'notsortable'

    $col_link = $global:data_grid.Columns[3]
    $col_link.Width = 150
    $col_link.HeaderText = "URL"
    $col_link.SortMode = 'notsortable'

    $avalable_secrets = Get-ChildItem $global:secretfiles_path
    if ($avalable_secrets.count -eq 0)
    {
        $global:manage_button.Enabled = $false
        $global:copy_key_button.Enabled = $false
        $global:copy_secret_button.Enabled = $false
        $global:togglebutton.Enabled = $false
        $global:openlink.Enabled = $false
        $global:notifylabel.Text = "Please add a credential to start"
        $global:notifylabel.BackColor = [System.Drawing.Color]::FromArgb(204, 229, 255)
        $Global:PSK_UI.Refresh()
        LogEvent -Source $source -Type "INFO" -Message "No available secrets, UI updated accordingly."
    }
    else
    {
        $global:manage_button.Enabled = $true
        $global:copy_key_button.Enabled = $true
        $global:copy_secret_button.Enabled = $true
        $global:togglebutton.Enabled = $true
        $global:openlink.Enabled = $true
        $global:data_grid.rows.Clear()
        foreach($file in $avalable_secrets)
        {
            [int]$filenumber = $file.basename
            $temp_content = gc $file.fullname
            $firstline = $temp_content[0]
            $secondline = $temp_content[1]
            $linkline = $temp_content[2]
            $global:data_grid.rows.Add($filenumber,$firstline,$secondline,$linkline)
        }
        $global:notifylabel.BackColor = [System.Drawing.Color]::FromArgb(204, 229, 255)
        $global:notifylabel.Text = "(1) - " + $global:data_grid.rows[0].Cells[$global:cellnumber].Value
        $Global:PSK_UI.Refresh()
        $global:data_grid.add_selectionchanged(
        {
            $global:notifylabel.BackColor = [System.Drawing.Color]::FromArgb(204, 229, 255)
            $rownumber = $global:data_grid.CurrentRow.Index
            $global:notifylabel.Text = "($($rownumber +1 )) - $($global:data_grid.rows[$rownumber].Cells[$global:cellnumber].Value)"
            $Global:PSK_UI.Refresh()
        })
        LogEvent -Source $source -Type "INFO" -Message "Secrets loaded into data grid successfully."
    }
    $global:data_grid.Sort($global:data_grid.Columns[0], 'Ascending')
    $Global:PSK_UI.Controls.Add($data_grid)
    $Global:PSK_UI.Refresh()
}

function getfilenumber
{
    $source = "getfilenumber"
    $files = Get-ChildItem $global:secretfiles_path | Sort-Object Name 

    if($files.count -eq 0 )
    {
        LogEvent -Source $source -Type "INFO" -Message "No files found, returning 1 as file number."
        return 1
    }
    else
    {
        LogEvent -Source $source -Type "INFO" -Message "Files exist, renaming files."
        $counter = 1
        foreach($file in $files)
        {
            Rename-Item $file.fullname "$counter.temp" 
            $counter++
        }
        $files = Get-ChildItem $global:secretfiles_path | Sort-Object Name 
        $counter = 1
        foreach($file in $files)
        {
            Write-Host "$global:secretfiles_path\$counter.temp"
            Write-Host "$global:secretfiles_path\$counter.secret" 
            Rename-Item $file.fullname "$counter.secret" 
            $counter++
        }
        LogEvent -Source $source -Type "INFO" -Message "Renaming completed, returning next file number."
        return $files.count + 1
    }
}

function getplainpin($pin)
{
    $source = "getplainpin"
    LogEvent -Source $source -Type "INFO" -Message "Converting secure string to plain text."
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pin))
}

function getpinbytes($pin)
{
    $source = "getpinbytes"
    LogEvent -Source $source -Type "INFO" -Message "Converting pin to byte array."
    return [System.Text.Encoding]::UTF8.GetBytes($pin)
}

function start_script
{
    $source = "start_script"
    LogEvent -Source $source -Type "INFO" -Message "Initializing script and setting paths."
    $global:encryptionkeypath = ".\PSK_FILES_DONOTDELETE\ENCRYPTION_KEYS\encryption_partial_key.key"
    $global:entry_gate_path =  ".\PSK_FILES_DONOTDELETE\ENCRYPTION_KEYS\entry_gate.key"
    $global:secretfiles_path = ".\PSK_FILES_DONOTDELETE\SECRET_RECORDS"
    
    Add-Type -AssemblyName 'System.Windows.Forms'
    
    Add-Type -TypeDefinition '
    public class DPIAware
    {
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern bool SetProcessDPIAware();
    }
    '

    [System.Windows.Forms.Application]::EnableVisualStyles()
    [void] [DPIAware]::SetProcessDPIAware()

    if(Test-Path $global:encryptionkeypath)
    {
        LogEvent -Source $source -Type "INFO" -Message "Encryption key found, setting pin status to 'askpin'."
        $global:pinstatusflag = "askpin"
    }
    else
    {
        LogEvent -Source $source -Type "INFO" -Message "Encryption key not found, setting pin status to 'setpin'."
        $global:pinstatusflag = "setpin"
    }

    mainUI
}

start_script

