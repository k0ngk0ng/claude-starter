; Claude Code Windows Installer
; NSIS Script for creating all-in-one installer

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"
!include "WinMessages.nsh"

; =====================
; Installer Attributes
; =====================
Name "Claude Code"
OutFile "..\..\..\dist\ClaudeCodeSetup.exe"
InstallDir "$PROGRAMFILES64\ClaudeCode"
InstallDirRegKey HKLM "Software\ClaudeCode" "InstallDir"
RequestExecutionLevel admin
Unicode True

; Version Information - can be overridden by /DPRODUCT_VERSION=x.x.x
!define PRODUCT_NAME "Claude Code"
!ifndef PRODUCT_VERSION
    !define PRODUCT_VERSION "1.0.0"
!endif
!define PRODUCT_PUBLISHER "Anthropic"
!define PRODUCT_WEB_SITE "https://claude.ai"

; Extract version numbers for VIProductVersion (needs x.x.x.x format)
!searchparse ${PRODUCT_VERSION} "v" VERSION_CLEAN
!ifndef VERSION_CLEAN
    !define VERSION_CLEAN ${PRODUCT_VERSION}
!endif

VIProductVersion "${VERSION_CLEAN}.0.0.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey "FileDescription" "Claude Code Installer ${PRODUCT_VERSION}"
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
!define MUI_FINISHPAGE_RUN "wscript.exe"
!define MUI_FINISHPAGE_RUN_PARAMETERS '"$INSTDIR\ClaudeCodeLauncher.vbs"'
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

    ; Copy 7za.exe first for extraction
    File "..\resources\7za.exe"

    ; Copy 7z archives
    File "..\..\..\deps\nodejs.7z"
    File "..\..\..\deps\git.7z"

    ; Extract Node.js using 7z
    DetailPrint "Extracting Node.js..."
    nsExec::ExecToLog '"$INSTDIR\7za.exe" x -o"$INSTDIR\nodejs" -y "$INSTDIR\nodejs.7z"'
    Delete "$INSTDIR\nodejs.7z"

    ; Extract Git using 7z
    DetailPrint "Extracting Git..."
    nsExec::ExecToLog '"$INSTDIR\7za.exe" x -o"$INSTDIR\git" -y "$INSTDIR\git.7z"'
    Delete "$INSTDIR\git.7z"

    ; Delete 7za.exe after extraction
    Delete "$INSTDIR\7za.exe"

    ; Copy launcher files
    SetOutPath "$INSTDIR\launcher"
    File "..\..\launcher\ClaudeCodeLauncher.ps1"
    File "..\resources\claude.ico"

    ; Copy main launcher (VBS for hidden window)
    SetOutPath "$INSTDIR"
    File "..\resources\ClaudeCodeLauncher.vbs"
    File "..\resources\README.txt"

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
    CreateShortCut "$DESKTOP\Claude Code.lnk" "wscript.exe" '"$INSTDIR\ClaudeCodeLauncher.vbs"' \
                   "$INSTDIR\launcher\claude.ico" 0
SectionEnd

Section "Start Menu Shortcuts" SecStartMenu
    CreateDirectory "$SMPROGRAMS\Claude Code"
    CreateShortCut "$SMPROGRAMS\Claude Code\Claude Code.lnk" "wscript.exe" '"$INSTDIR\ClaudeCodeLauncher.vbs"' \
                   "$INSTDIR\launcher\claude.ico" 0
    CreateShortCut "$SMPROGRAMS\Claude Code\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Add to System PATH" SecPath
    ; Read current PATH
    ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"

    ; Add Node.js to PATH if not already present
    StrCpy $1 "$INSTDIR\nodejs"
    ${If} $0 != ""
        StrCpy $0 "$0;$1"
    ${Else}
        StrCpy $0 "$1"
    ${EndIf}

    ; Add Git to PATH
    StrCpy $0 "$0;$INSTDIR\git\bin"

    ; Write updated PATH
    WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" "$0"

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

    ; Remove shortcuts
    Delete "$DESKTOP\Claude Code.lnk"
    RMDir /r "$SMPROGRAMS\Claude Code"

    ; Remove files
    RMDir /r "$INSTDIR\nodejs"
    RMDir /r "$INSTDIR\git"
    RMDir /r "$INSTDIR\launcher"
    Delete "$INSTDIR\ClaudeCodeLauncher.vbs"
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
