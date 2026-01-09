; Claude Code Windows Installer
; NSIS Script for creating all-in-one installer

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"

; =====================
; Installer Attributes
; =====================
Name "Claude Code"
OutFile "..\..\..\dist\ClaudeCodeSetup.exe"
InstallDir "$PROGRAMFILES64\ClaudeCode"
InstallDirRegKey HKLM "Software\ClaudeCode" "InstallDir"
RequestExecutionLevel admin
Unicode True

; Version Information
!define PRODUCT_NAME "Claude Code"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "Anthropic"
!define PRODUCT_WEB_SITE "https://claude.ai"

VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey "FileDescription" "Claude Code Installer"
VIAddVersionKey "FileVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright (c) ${PRODUCT_PUBLISHER}"

; =====================
; MUI Settings
; =====================
!define MUI_ABORTWARNING
!define MUI_ICON "..\resources\claude.ico"
!define MUI_UNICON "..\resources\claude.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\resources\welcome.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\resources\header.bmp"

; Welcome page
!insertmacro MUI_PAGE_WELCOME

; License page
!insertmacro MUI_PAGE_LICENSE "..\resources\LICENSE.txt"

; Directory page
!insertmacro MUI_PAGE_DIRECTORY

; Components page
!insertmacro MUI_PAGE_COMPONENTS

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\ClaudeCodeLauncher.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Launch Claude Code"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View README"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

; =====================
; Installer Sections
; =====================

Section "Claude Code Core" SecCore
    SectionIn RO ; Required section

    SetOutPath "$INSTDIR"

    ; Copy Node.js
    SetOutPath "$INSTDIR\nodejs"
    File /r "..\..\..\deps\nodejs\*.*"

    ; Copy Git
    SetOutPath "$INSTDIR\git"
    File /r "..\..\..\deps\git\*.*"

    ; Copy launcher files
    SetOutPath "$INSTDIR\launcher"
    File "..\..\launcher\ClaudeCodeLauncher.ps1"

    ; Copy main launcher batch
    SetOutPath "$INSTDIR"
    File "..\resources\ClaudeCodeLauncher.bat"
    File "..\resources\README.txt"

    ; Install Claude Code globally using bundled npm
    SetOutPath "$INSTDIR"
    nsExec::ExecToLog '"$INSTDIR\nodejs\npm.cmd" install -g @anthropic-ai/claude-code'

    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Write registry keys
    WriteRegStr HKLM "Software\ClaudeCode" "InstallDir" "$INSTDIR"
    WriteRegStr HKLM "Software\ClaudeCode" "Version" "${PRODUCT_VERSION}"

    ; Add to Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                     "DisplayName" "${PRODUCT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                     "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                     "DisplayIcon" "$INSTDIR\launcher\claude.ico"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                     "Publisher" "${PRODUCT_PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                     "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                     "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                      "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                      "NoRepair" 1

    ; Get installed size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode" \
                      "EstimatedSize" "$0"
SectionEnd

Section "Desktop Shortcut" SecDesktop
    CreateShortCut "$DESKTOP\Claude Code.lnk" "$INSTDIR\ClaudeCodeLauncher.bat" "" \
                   "$INSTDIR\launcher\claude.ico" 0
SectionEnd

Section "Start Menu Shortcuts" SecStartMenu
    CreateDirectory "$SMPROGRAMS\Claude Code"
    CreateShortCut "$SMPROGRAMS\Claude Code\Claude Code.lnk" "$INSTDIR\ClaudeCodeLauncher.bat" "" \
                   "$INSTDIR\launcher\claude.ico" 0
    CreateShortCut "$SMPROGRAMS\Claude Code\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Add to System PATH" SecPath
    ; Add to system PATH
    EnVar::SetHKLM
    EnVar::AddValue "PATH" "$INSTDIR\nodejs"
    EnVar::AddValue "PATH" "$INSTDIR\git\bin"

    ; Broadcast environment change
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

; =====================
; Section Descriptions
; =====================
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Core Claude Code files including Node.js, Git, and Claude Code CLI. (Required)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Create a desktop shortcut for easy access."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} "Create Start Menu shortcuts."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPath} "Add Node.js and Git to system PATH for command line access."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; =====================
; Uninstaller Section
; =====================
Section "Uninstall"
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ClaudeCode"
    DeleteRegKey HKLM "Software\ClaudeCode"

    ; Remove from PATH
    EnVar::SetHKLM
    EnVar::DeleteValue "PATH" "$INSTDIR\nodejs"
    EnVar::DeleteValue "PATH" "$INSTDIR\git\bin"

    ; Remove shortcuts
    Delete "$DESKTOP\Claude Code.lnk"
    RMDir /r "$SMPROGRAMS\Claude Code"

    ; Remove files
    RMDir /r "$INSTDIR\nodejs"
    RMDir /r "$INSTDIR\git"
    RMDir /r "$INSTDIR\launcher"
    Delete "$INSTDIR\ClaudeCodeLauncher.bat"
    Delete "$INSTDIR\README.txt"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"

    ; Broadcast environment change
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

; =====================
; Functions
; =====================
Function .onInit
    ; Check for 64-bit Windows
    ${IfNot} ${RunningX64}
        MessageBox MB_OK|MB_ICONSTOP "This installer requires 64-bit Windows."
        Abort
    ${EndIf}
FunctionEnd
