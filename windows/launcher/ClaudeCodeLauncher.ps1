# Claude Code Launcher - Windows GUI
# This script provides a graphical interface to configure and launch Claude Code

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuration file path
$configPath = "$env:APPDATA\ClaudeCode\config.json"
$configDir = Split-Path $configPath -Parent

# Get script directory for icon
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$iconPath = Join-Path $scriptDir "claude.ico"

# Ensure config directory exists
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Default configuration
$defaultConfig = @{
    WorkingDirectory = ""
    CLAUDE_CODE_CONTINUE = $false
    ANTHROPIC_AUTH_TOKEN = ""
    ANTHROPIC_BASE_URL = ""
    ANTHROPIC_MODEL = ""
    ANTHROPIC_DEFAULT_SONNET_MODEL = ""
    ANTHROPIC_DEFAULT_OPUS_MODEL = ""
    ANTHROPIC_DEFAULT_HAIKU_MODEL = ""
    CLAUDE_CODE_USE_BEDROCK = $false
    CLAUDE_CODE_USE_VERTEX = $false
    DISABLE_PROMPT_CACHING = $false
    CLAUDE_CODE_SKIP_PERMISSIONS = $false
    HTTP_PROXY = ""
    HTTPS_PROXY = ""
}

# Load existing configuration
function Load-Config {
    if (Test-Path $configPath) {
        try {
            $loaded = Get-Content $configPath -Raw | ConvertFrom-Json
            $config = @{}
            foreach ($key in $defaultConfig.Keys) {
                if ($null -ne $loaded.$key) {
                    $config[$key] = $loaded.$key
                } else {
                    $config[$key] = $defaultConfig[$key]
                }
            }
            return $config
        } catch {
            return $defaultConfig.Clone()
        }
    }
    return $defaultConfig.Clone()
}

# Save configuration
function Save-Config($config) {
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
}

# Load current config
$config = Load-Config

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Claude Code Launcher"
$form.Size = New-Object System.Drawing.Size(600, 700)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White

# Set form icon if exists
if (Test-Path $iconPath) {
    $form.Icon = New-Object System.Drawing.Icon($iconPath)
}

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Claude Code Launcher"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 149, 0)
$titleLabel.Location = New-Object System.Drawing.Point(20, 15)
$titleLabel.Size = New-Object System.Drawing.Size(400, 40)
$form.Controls.Add($titleLabel)

# Subtitle
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Configure environment variables and options"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$subtitleLabel.ForeColor = [System.Drawing.Color]::Gray
$subtitleLabel.Location = New-Object System.Drawing.Point(22, 50)
$subtitleLabel.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($subtitleLabel)

# Create a panel for scrolling
$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point(20, 80)
$panel.Size = New-Object System.Drawing.Size(545, 480)
$panel.AutoScroll = $true
$panel.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$form.Controls.Add($panel)

$yPos = 10
$labelFont = New-Object System.Drawing.Font("Segoe UI", 9)
$textBoxFont = New-Object System.Drawing.Font("Consolas", 9)

# Helper function to create labeled textbox
function Add-TextBox($labelText, $configKey, $isPassword = $false) {
    $script:yPos = $yPos

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $labelText
    $label.Font = $labelFont
    $label.ForeColor = [System.Drawing.Color]::White
    $label.Location = New-Object System.Drawing.Point(10, $script:yPos)
    $label.Size = New-Object System.Drawing.Size(500, 20)
    $panel.Controls.Add($label)

    $script:yPos += 22

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Font = $textBoxFont
    $textBox.Location = New-Object System.Drawing.Point(10, $script:yPos)
    $textBox.Size = New-Object System.Drawing.Size(500, 25)
    $textBox.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textBox.ForeColor = [System.Drawing.Color]::White
    $textBox.BorderStyle = "FixedSingle"
    $textBox.Text = $config[$configKey]
    $textBox.Name = $configKey
    if ($isPassword) {
        $textBox.UseSystemPasswordChar = $true
    }
    $panel.Controls.Add($textBox)

    $script:yPos += 35
    return $textBox
}

# Helper function to create checkbox
function Add-CheckBox($labelText, $configKey) {
    $script:yPos = $yPos

    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Text = $labelText
    $checkBox.Font = $labelFont
    $checkBox.ForeColor = [System.Drawing.Color]::White
    $checkBox.Location = New-Object System.Drawing.Point(10, $script:yPos)
    $checkBox.Size = New-Object System.Drawing.Size(500, 25)
    $checkBox.Checked = $config[$configKey]
    $checkBox.Name = $configKey
    $checkBox.FlatStyle = "Flat"
    $panel.Controls.Add($checkBox)

    $script:yPos += 30
    return $checkBox
}

# Section: Working Directory
$sectionWorkDir = New-Object System.Windows.Forms.Label
$sectionWorkDir.Text = "Working Directory"
$sectionWorkDir.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$sectionWorkDir.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$sectionWorkDir.Location = New-Object System.Drawing.Point(10, $yPos)
$sectionWorkDir.Size = New-Object System.Drawing.Size(500, 25)
$panel.Controls.Add($sectionWorkDir)
$yPos += 30

$txtWorkDir = Add-TextBox "Working Directory (Leave empty for user profile)" "WorkingDirectory"

# Browse button for working directory
$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Browse..."
$btnBrowse.Font = $labelFont
$btnBrowse.Location = New-Object System.Drawing.Point(420, ($yPos - 30))
$btnBrowse.Size = New-Object System.Drawing.Size(90, 25)
$btnBrowse.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnBrowse.ForeColor = [System.Drawing.Color]::White
$btnBrowse.FlatStyle = "Flat"
$txtWorkDir.Size = New-Object System.Drawing.Size(400, 25)
$panel.Controls.Add($btnBrowse)

$btnBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select Working Directory"
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $txtWorkDir.Text = $folderBrowser.SelectedPath
    }
})

# Section: Launch Options
$yPos += 10
$sectionLaunchOpts = New-Object System.Windows.Forms.Label
$sectionLaunchOpts.Text = "Launch Options"
$sectionLaunchOpts.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$sectionLaunchOpts.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$sectionLaunchOpts.Location = New-Object System.Drawing.Point(10, $yPos)
$sectionLaunchOpts.Size = New-Object System.Drawing.Size(500, 25)
$panel.Controls.Add($sectionLaunchOpts)
$yPos += 30

$chkContinue = Add-CheckBox "--continue (Continue previous conversation)" "CLAUDE_CODE_CONTINUE"

# Section: API Configuration
$yPos += 10
$sectionLabel1 = New-Object System.Windows.Forms.Label
$sectionLabel1.Text = "API Configuration"
$sectionLabel1.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$sectionLabel1.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$sectionLabel1.Location = New-Object System.Drawing.Point(10, $yPos)
$sectionLabel1.Size = New-Object System.Drawing.Size(500, 25)
$panel.Controls.Add($sectionLabel1)
$yPos += 30

$txtAuthToken = Add-TextBox "ANTHROPIC_AUTH_TOKEN (Your API Key, e.g., sk-xxx)" "ANTHROPIC_AUTH_TOKEN" $true
$txtBaseUrl = Add-TextBox "ANTHROPIC_BASE_URL (Custom API endpoint, optional)" "ANTHROPIC_BASE_URL"
$txtModel = Add-TextBox "ANTHROPIC_MODEL (Default model to use)" "ANTHROPIC_MODEL"

# Section: Model Defaults
$yPos += 10
$sectionModelDefaults = New-Object System.Windows.Forms.Label
$sectionModelDefaults.Text = "Model Defaults"
$sectionModelDefaults.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$sectionModelDefaults.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$sectionModelDefaults.Location = New-Object System.Drawing.Point(10, $yPos)
$sectionModelDefaults.Size = New-Object System.Drawing.Size(500, 25)
$panel.Controls.Add($sectionModelDefaults)
$yPos += 30

$txtDefaultSonnet = Add-TextBox "ANTHROPIC_DEFAULT_SONNET_MODEL (e.g., claude-sonnet-4-20250514)" "ANTHROPIC_DEFAULT_SONNET_MODEL"
$txtDefaultOpus = Add-TextBox "ANTHROPIC_DEFAULT_OPUS_MODEL (e.g., claude-opus-4-20250514)" "ANTHROPIC_DEFAULT_OPUS_MODEL"
$txtDefaultHaiku = Add-TextBox "ANTHROPIC_DEFAULT_HAIKU_MODEL (e.g., claude-haiku-3-20250514)" "ANTHROPIC_DEFAULT_HAIKU_MODEL"

# Section: Provider Options
$yPos += 10
$sectionLabel2 = New-Object System.Windows.Forms.Label
$sectionLabel2.Text = "Provider Options"
$sectionLabel2.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$sectionLabel2.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$sectionLabel2.Location = New-Object System.Drawing.Point(10, $yPos)
$sectionLabel2.Size = New-Object System.Drawing.Size(500, 25)
$panel.Controls.Add($sectionLabel2)
$yPos += 30

$chkBedrock = Add-CheckBox "CLAUDE_CODE_USE_BEDROCK (Use AWS Bedrock)" "CLAUDE_CODE_USE_BEDROCK"
$chkVertex = Add-CheckBox "CLAUDE_CODE_USE_VERTEX (Use Google Vertex AI)" "CLAUDE_CODE_USE_VERTEX"
$chkDisableCache = Add-CheckBox "DISABLE_PROMPT_CACHING (Disable prompt caching)" "DISABLE_PROMPT_CACHING"

# Section: Security Options
$yPos += 10
$sectionLabel3 = New-Object System.Windows.Forms.Label
$sectionLabel3.Text = "Security Options"
$sectionLabel3.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$sectionLabel3.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
$sectionLabel3.Location = New-Object System.Drawing.Point(10, $yPos)
$sectionLabel3.Size = New-Object System.Drawing.Size(500, 25)
$panel.Controls.Add($sectionLabel3)
$yPos += 30

$chkSkipPermissions = Add-CheckBox "--dangerously-skip-permissions (Skip all permission prompts - USE WITH CAUTION!)" "CLAUDE_CODE_SKIP_PERMISSIONS"
$chkSkipPermissions.ForeColor = [System.Drawing.Color]::FromArgb(255, 180, 180)

# Section: Proxy Settings
$yPos += 10
$sectionLabel4 = New-Object System.Windows.Forms.Label
$sectionLabel4.Text = "Proxy Settings"
$sectionLabel4.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$sectionLabel4.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$sectionLabel4.Location = New-Object System.Drawing.Point(10, $yPos)
$sectionLabel4.Size = New-Object System.Drawing.Size(500, 25)
$panel.Controls.Add($sectionLabel4)
$yPos += 30

$txtHttpProxy = Add-TextBox "HTTP_PROXY (e.g., http://proxy:8080)" "HTTP_PROXY"
$txtHttpsProxy = Add-TextBox "HTTPS_PROXY (e.g., http://proxy:8080)" "HTTPS_PROXY"

# Buttons panel
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Location = New-Object System.Drawing.Point(20, 575)
$buttonPanel.Size = New-Object System.Drawing.Size(545, 70)
$buttonPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.Controls.Add($buttonPanel)

# Launch button
$btnLaunch = New-Object System.Windows.Forms.Button
$btnLaunch.Text = "Launch Claude Code"
$btnLaunch.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnLaunch.Location = New-Object System.Drawing.Point(0, 10)
$btnLaunch.Size = New-Object System.Drawing.Size(200, 45)
$btnLaunch.BackColor = [System.Drawing.Color]::FromArgb(255, 149, 0)
$btnLaunch.ForeColor = [System.Drawing.Color]::Black
$btnLaunch.FlatStyle = "Flat"
$btnLaunch.Cursor = "Hand"
$buttonPanel.Controls.Add($btnLaunch)

# Import button
$btnImport = New-Object System.Windows.Forms.Button
$btnImport.Text = "Import"
$btnImport.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnImport.Location = New-Object System.Drawing.Point(210, 10)
$btnImport.Size = New-Object System.Drawing.Size(100, 45)
$btnImport.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnImport.ForeColor = [System.Drawing.Color]::White
$btnImport.FlatStyle = "Flat"
$btnImport.Cursor = "Hand"
$buttonPanel.Controls.Add($btnImport)

# Save button
$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = "Save"
$btnSave.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnSave.Location = New-Object System.Drawing.Point(320, 10)
$btnSave.Size = New-Object System.Drawing.Size(100, 45)
$btnSave.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnSave.ForeColor = [System.Drawing.Color]::White
$btnSave.FlatStyle = "Flat"
$btnSave.Cursor = "Hand"
$buttonPanel.Controls.Add($btnSave)

# Reset button
$btnReset = New-Object System.Windows.Forms.Button
$btnReset.Text = "Reset"
$btnReset.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnReset.Location = New-Object System.Drawing.Point(430, 10)
$btnReset.Size = New-Object System.Drawing.Size(100, 45)
$btnReset.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40)
$btnReset.ForeColor = [System.Drawing.Color]::White
$btnReset.FlatStyle = "Flat"
$btnReset.Cursor = "Hand"
$buttonPanel.Controls.Add($btnReset)

# Get all values from form
function Get-FormValues {
    $values = @{}
    foreach ($control in $panel.Controls) {
        if ($control -is [System.Windows.Forms.TextBox]) {
            $values[$control.Name] = $control.Text
        } elseif ($control -is [System.Windows.Forms.CheckBox]) {
            $values[$control.Name] = $control.Checked
        }
    }
    return $values
}

# Import button click - supports JSON files with "env" object
$btnImport.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*"
    $openFileDialog.Title = "Import Configuration"

    if ($openFileDialog.ShowDialog() -eq "OK") {
        try {
            $jsonContent = Get-Content $openFileDialog.FileName -Raw | ConvertFrom-Json

            # Check if the JSON has an "env" property
            $envData = $null
            if ($jsonContent.PSObject.Properties.Name -contains "env") {
                $envData = $jsonContent.env
            } else {
                # Assume direct format
                $envData = $jsonContent
            }

            # Map imported values to form controls
            foreach ($control in $panel.Controls) {
                if ($control -is [System.Windows.Forms.TextBox]) {
                    $key = $control.Name
                    if ($envData.PSObject.Properties.Name -contains $key) {
                        $control.Text = $envData.$key
                    }
                } elseif ($control -is [System.Windows.Forms.CheckBox]) {
                    $key = $control.Name
                    if ($envData.PSObject.Properties.Name -contains $key) {
                        $control.Checked = [bool]$envData.$key
                    }
                }
            }

            [System.Windows.Forms.MessageBox]::Show("Configuration imported successfully!", "Claude Code Launcher", "OK", "Information")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to import configuration: $_", "Error", "OK", "Error")
        }
    }
})

# Save button click
$btnSave.Add_Click({
    $values = Get-FormValues
    Save-Config $values
    [System.Windows.Forms.MessageBox]::Show("Settings saved successfully!", "Claude Code Launcher", "OK", "Information")
})

# Reset button click
$btnReset.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to reset all settings?", "Confirm Reset", "YesNo", "Warning")
    if ($result -eq "Yes") {
        foreach ($control in $panel.Controls) {
            if ($control -is [System.Windows.Forms.TextBox]) {
                $control.Text = ""
            } elseif ($control -is [System.Windows.Forms.CheckBox]) {
                $control.Checked = $false
            }
        }
    }
})

# Launch button click
$btnLaunch.Add_Click({
    # Save current settings
    $values = Get-FormValues
    Save-Config $values

    # Get installation directory (launcher is in $INSTDIR\launcher)
    $installDir = Split-Path -Parent $PSScriptRoot
    if (-not (Test-Path "$installDir\nodejs")) {
        # Fallback: maybe running from source
        $installDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    }

    # Build environment variables
    $envVars = @()

    if ($values.ANTHROPIC_AUTH_TOKEN) {
        $envVars += "set ANTHROPIC_AUTH_TOKEN=$($values.ANTHROPIC_AUTH_TOKEN)"
    }
    if ($values.ANTHROPIC_BASE_URL) {
        $envVars += "set ANTHROPIC_BASE_URL=$($values.ANTHROPIC_BASE_URL)"
    }
    if ($values.ANTHROPIC_MODEL) {
        $envVars += "set ANTHROPIC_MODEL=$($values.ANTHROPIC_MODEL)"
    }
    if ($values.ANTHROPIC_DEFAULT_SONNET_MODEL) {
        $envVars += "set ANTHROPIC_DEFAULT_SONNET_MODEL=$($values.ANTHROPIC_DEFAULT_SONNET_MODEL)"
    }
    if ($values.ANTHROPIC_DEFAULT_OPUS_MODEL) {
        $envVars += "set ANTHROPIC_DEFAULT_OPUS_MODEL=$($values.ANTHROPIC_DEFAULT_OPUS_MODEL)"
    }
    if ($values.ANTHROPIC_DEFAULT_HAIKU_MODEL) {
        $envVars += "set ANTHROPIC_DEFAULT_HAIKU_MODEL=$($values.ANTHROPIC_DEFAULT_HAIKU_MODEL)"
    }
    if ($values.CLAUDE_CODE_USE_BEDROCK) {
        $envVars += "set CLAUDE_CODE_USE_BEDROCK=1"
    }
    if ($values.CLAUDE_CODE_USE_VERTEX) {
        $envVars += "set CLAUDE_CODE_USE_VERTEX=1"
    }
    if ($values.DISABLE_PROMPT_CACHING) {
        $envVars += "set DISABLE_PROMPT_CACHING=1"
    }
    if ($values.HTTP_PROXY) {
        $envVars += "set HTTP_PROXY=$($values.HTTP_PROXY)"
    }
    if ($values.HTTPS_PROXY) {
        $envVars += "set HTTPS_PROXY=$($values.HTTPS_PROXY)"
    }

    # Build claude command
    $claudeArgs = ""
    if ($values.CLAUDE_CODE_CONTINUE) {
        $claudeArgs += " --continue"
    }
    if ($values.CLAUDE_CODE_SKIP_PERMISSIONS) {
        $claudeArgs += " --dangerously-skip-permissions"
    }

    # Working directory
    $workDir = $values.WorkingDirectory
    if (-not $workDir -or -not (Test-Path $workDir)) {
        $workDir = [Environment]::GetFolderPath("UserProfile")
    }

    # Create launch script
    $launchScript = @"
@echo off
title Claude Code
cd /d "$workDir"

REM Set PATH to include bundled tools
set PATH=$installDir\nodejs;$installDir\git\bin;$installDir\git\usr\bin;%PATH%

REM Set environment variables
$($envVars -join "`n")

REM Launch Claude Code
echo.
echo ========================================
echo   Claude Code Launcher
echo ========================================
echo.
echo Install Directory: $installDir
echo Working Directory: $workDir
echo.

REM Check if claude.cmd exists
if exist "$installDir\nodejs\claude.cmd" (
    echo Starting Claude Code...
    "$installDir\nodejs\claude.cmd"$claudeArgs
) else (
    echo ERROR: claude.cmd not found at $installDir\nodejs\claude.cmd
    echo.
    echo Trying npx fallback...
    npx @anthropic-ai/claude-code$claudeArgs
)

pause
"@

    $tempScript = "$env:TEMP\launch_claude.bat"
    $launchScript | Set-Content $tempScript -Encoding ASCII

    # Hide the launcher and start Claude
    $form.WindowState = "Minimized"
    Start-Process "cmd.exe" -ArgumentList "/c `"$tempScript`"" -Wait
    $form.WindowState = "Normal"
})

# Show the form
[void]$form.ShowDialog()
