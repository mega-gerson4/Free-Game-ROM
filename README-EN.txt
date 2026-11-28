TRUN GAME FREE MEGA 2.2 - NATIVE RED EDITION
=================================================

WINDOWS 10/11
1. Extract the complete ZIP into its own folder.
2. Run "Installer Windows.bat".
3. A "BUILD SUCCESS" dialog appears only after application preflight,
   file staging and shortcut verification pass.
4. The "Trun Game Free Mega" shortcut is INSIDE THE PROJECT FOLDER,
   not on the Desktop.
5. Double-click it to open the native WinForms interface. No Python or browser.

Auxiliary project files (including installers) are marked hidden in Windows.
Explorer > View > Show > Hidden items reveals them. The shortcut remains visible.
Only recognized older project shortcuts may be removed from the Desktop.

If installation or startup fails, the UI shows "BUILD FATAL ERROR" with the
reason. Click "Read More" to open a separate window with diagnostic details.
Logs and previous copy history live at %LOCALAPPDATA%\TrunGameFreeMega\DataSense.
The repair installer preserves this history.

The shortcut points to the local installed copy, so moving the downloaded folder
later will not invalidate it. Each computer must run its own installer.

LINUX
Run sh "Installer Linux.sh" with Tcl/Tk (wish) installed.
The "Trun Game Free Mega.desktop" launcher is created INSIDE this folder,
plus an entry in the application menu; no Desktop shortcut is created.
The .hidden manifest hides support items in compatible Linux file managers.

MACOS
Run "Installer macOS.command" on a Mac with Apple's Swift toolchain.
It builds a real SwiftUI "Trun Game Free Mega.app" INSIDE this folder,
not a browser-based page or Desktop shortcut. This package contains source,
not a prebuilt/notarized app. Read More opens the build log in TextEdit.

VALIDATION NOTE
Linux installer and status dialogs tested. Windows runtime and native macOS
build still require testing on those operating systems. Never treat success
as a guarantee that every subsequent runtime action will work.

External game websites are not controlled by this project. Only download
material you are legally entitled to access.
