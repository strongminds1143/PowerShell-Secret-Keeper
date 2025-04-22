# PowerShell Secret Keeper - PSK

An offline password manager built using PowerShell with a clean UI interface. Ideal for users who prefer simple credential storage without relying on cloud services.

---

## Author

**Krishnaprasad Narayanankutty**  
GitHub: [@strongminds1143](https://github.com/strongminds1143/)

## Version

1.0

## Overview

PSKv1.0 is a UI-based PowerShell script that serves as an offline password manager. It allows users to securely store, manage, and retrieve credentials. Credentials are encrypted using a custom key—partially derived from user input and partially randomly generated—for enhanced security. The tool is optimized for Windows systems.

---

## Story Behind This Project

This project began as a personal challenge to create a secure, offline password vault using PowerShell. I wanted something lightweight, customizable, and easy to maintain without depending on any cloud service. You can read the full background and journey here:  
[**PowerShell Secret Keeper – Behind the Build**](https://powershellsecretkeeper.wordpress.com)

---

## Features

- Store credentials securely with Name, Key, Secret, and optional URL + browser.
- Toggle display bar data: Name, Key, or URL.
- One-click copy to clipboard for Key or Secret.
- Launch saved URLs using your preferred browser in normal/incognito mode.
- Add/Edit/Delete credentials.
- Logs errors in `PSK_All.log`.
- PIN-protected access with encryption.
- Runs completely offline.

---

## Requirements

- PowerShell 5.1 or later (Windows)
- PowerShell Editions: Desktop and Server
- Font: Segoe UI (includes Segoe UI Emoji)

---

## Installation

1. Download the repo as a `.zip` file.
2. Extract to a folder with script execution permissions.
3. Run `CONFIG.bat` to initialize folders and organize files.
4. Launch with `START.bat`.
5. (Optional) Create a desktop shortcut for `START.bat`.

---

## Configuration

- All configuration values are stored in the `.psd1` file.

---

## How to Use

### First Run

- Run `START.bat`.
- Set a 4-digit PIN on first launch.
- Enter the main dashboard.
- Click "+" to add a credential.
  - Required: Name, Key, Secret
  - Optional: URL, Browser
- Use the action buttons:
  - **Copy Key** / **Copy Secret** to clipboard
  - **Open Browser** to open the stored URL
  - **Manage** to edit/delete entries
- Close app using the window "X" button.

### Subsequent Runs

- Enter your 4-digit PIN to access.
- Wrong PIN will close the app automatically.

---

## Common Troubleshooting

- Make sure the downloaded `.zip` files aren't blocked by Windows.
- If UI appears distorted, adjust the scaling values from PSD1 config file.

---

## Reset the Application

- Run `RESET.bat` to clear all saved credentials and reset PSK.
- **Warning:** This action is permanent and cannot be undone.

---

## Must Know

- Forgotten PINs cannot be recovered.
- Backup `encryptfiles` and `secret` folders, in case you forgot the pin.
- A small command window will remain open due to how the script is launched (this is normal and can be minimized).

---

## To-Do / Roadmap

- Package PSK for cross-platform support (Mac/Linux).
- Add URL validation.
- Support for PowerShell 7.x series.


---

## Output

- All logs are written to `PSK_All.log`.

---

## Logging

- Errors, actions, and runtime events are logged automatically.

---

## Error Handling

- PIN mismatch closes app.
- Credential errors prompt UI alerts.

---

## Security

- Partial user-key + random key encryption.
- All data stored locally and securely.

---

## Known Issues

- Limited to Windows only for now.

---

## License

MIT License

