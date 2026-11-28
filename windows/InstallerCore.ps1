param([ValidateSet('Install','Repair')][string]$Mode = 'Install')
$ErrorActionPreference = 'Stop'
$source = Split-Path -Parent $PSScriptRoot
$base = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'TrunGameFreeMega'
$app = Join-Path $base 'App'
$stage = Join-Path $base ('_stage_' + [Guid]::NewGuid().ToString('N'))
$old = Join-Path $base '_previous_app'
$logFolder = Join-Path $base 'DataSense'
$stageActivated = $false
$oldMoved = $false
$shortcutSaved = $false
$trace = New-Object 'System.Collections.Generic.List[string]'
function Trace([string]$msg) { [void]$trace.Add($msg); Write-Host $msg }
function Test-PsSyntax([string]$file) {
    $tokens = $null; $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors)
    if ($errors -and $errors.Count -gt 0) {
        throw ('PowerShell syntax error in ' + (Split-Path $file -Leaf) + ': ' + $errors[0].Message)
    }
}
function Hide-AuxiliaryFiles([string]$folder) {
    # Hide only known project assets, not arbitrary user files.
    $names = @('windows','linux','macos','assets','.github','catalog.tsv','catalog-original.txt',
       'credits.txt','Installer Windows.bat','Repair Windows.bat','Installer Linux.sh','Repair Linux.sh',
       'Installer macOS.command','Repair macOS.command','PREVIEW-LINUX.png',
       'README-EN.txt','README-PTBR.txt','TEST-RESULTS.txt','WINDOWS-LAYOUT-FIX.txt','.hidden')
    foreach ($name in $names) {
        $p = Join-Path $folder $name
        if (Test-Path -LiteralPath $p) {
            try {
                $attrib = [System.IO.File]::GetAttributes($p)
                [System.IO.File]::SetAttributes($p, ($attrib -bor [System.IO.FileAttributes]::Hidden))
            } catch {
                throw ('Could not hide required support item: ' + $name + '. ' + $_.Exception.Message)
            }
        }
    }
}
try {
    if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'BuildStatus.ps1') -PathType Leaf)) {
        throw 'Missing status dialog component (windows\BuildStatus.ps1).'
    }
    . (Join-Path $PSScriptRoot 'BuildStatus.ps1')
    Trace ('[CHECK] Mode: ' + $Mode)
    Trace ('[CHECK] Project folder: ' + $source)
    $files = @('catalog.tsv','catalog-original.txt','credits.txt','assets\MEGA-Logo.ico',
      'assets\MEGA-Logo.png','windows\TrunGameFreeMega.ps1','windows\Launcher.vbs','windows\BuildStatus.ps1')
    foreach ($f in $files) {
        $from = Join-Path $source $f
        if (-not (Test-Path -LiteralPath $from -PathType Leaf)) { throw ('Required file not found: ' + $f) }
    }
    $data = @(Import-Csv -LiteralPath (Join-Path $source 'catalog.tsv') -Delimiter "`t" -Encoding UTF8)
    if ($data.Count -ne 40) { throw ('Unexpected catalog size: ' + $data.Count + ' (expected 40)') }
    foreach ($entry in $data) {
        $uri = $null
        if (-not [Uri]::TryCreate([string]$entry.URL, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
            throw ('Invalid catalog URL: ' + $entry.URL)
        }
    }
    Test-PsSyntax (Join-Path $source 'windows\TrunGameFreeMega.ps1')
    Test-PsSyntax (Join-Path $source 'windows\BuildStatus.ps1')
    [void][System.IO.Directory]::CreateDirectory($base)
    [void][System.IO.Directory]::CreateDirectory($logFolder)
    foreach ($f in $files) {
        $destination = Join-Path $stage $f
        [void][System.IO.Directory]::CreateDirectory((Split-Path -Parent $destination))
        Copy-Item -LiteralPath (Join-Path $source $f) -Destination $destination -Force
    }
    Trace '[CHECK] Staging complete.'
    # Preflight in a fresh PowerShell process ensures app dependencies load before reporting success.
    $psExe = Join-Path $PSHOME 'powershell.exe'
    $testOutput = @(& $psExe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File (Join-Path $stage 'windows\TrunGameFreeMega.ps1') -SelfTest 2>&1 | Out-String)
    $testCode = $LASTEXITCODE
    if ($testCode -ne 0) {
        throw ('Application preflight failed (exit ' + $testCode + '): ' + ($testOutput -join "`r`n"))
    }
    Trace ('[CHECK] Windows application self-test: PASS. ' + ($testOutput -join ' ').Trim())
    if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Recurse -Force }
    if (Test-Path -LiteralPath $app) { Move-Item -LiteralPath $app -Destination $old; $oldMoved = $true }
    Move-Item -LiteralPath $stage -Destination $app
    $stageActivated = $true
    Trace '[FILES] Application files installed in LocalAppData.'
    $lnk = Join-Path $source 'Trun Game Free Mega.lnk'
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($lnk)
    $shortcut.TargetPath = Join-Path $env:SystemRoot 'System32\wscript.exe'
    $shortcut.Arguments = '"' + (Join-Path $app 'windows\Launcher.vbs') + '"'
    $shortcut.WorkingDirectory = $app
    $shortcut.IconLocation = (Join-Path $app 'assets\MEGA-Logo.ico') + ',0'
    $shortcut.Description = 'Trun Game Free Mega 2.2 - Native Red Edition'
    $shortcut.Save()
    $shortcutSaved = $true
    if (-not (Test-Path -LiteralPath $lnk -PathType Leaf)) { throw 'Shortcut verification failed.' }
    $confirm = $wsh.CreateShortcut($lnk)
    if ($confirm.Arguments -notlike '*TrunGameFreeMega*') { throw 'Shortcut target verification failed.' }
    Trace ('[SHORTCUT] Created INSIDE PROJECT FOLDER: ' + $lnk)
    # Remove ONLY an old shortcut created by this project in previous releases.
    $desktop = [Environment]::GetFolderPath('DesktopDirectory')
    if ($desktop) {
        $desktopLink = Join-Path $desktop 'Trun Game Free Mega.lnk'
        if (Test-Path -LiteralPath $desktopLink) {
            try {
                $prior = $wsh.CreateShortcut($desktopLink)
                if (($prior.Arguments -like '*TrunGameFreeMega*') -and ($prior.TargetPath -like '*wscript.exe')) {
                    Remove-Item -LiteralPath $desktopLink -Force
                    Trace '[CLEANUP] Old project desktop shortcut removed.'
                }
            } catch { Trace ('[WARNING] Desktop cleanup skipped: ' + $_.Exception.Message) }
        }
    }
    Hide-AuxiliaryFiles $source
    Trace '[HIDDEN] Project support files hidden (launcher icon remains visible).'
    Trace '[DATA] DataSense preserved: no history was cleared.'
    Trace '[BUILD SUCCESS] The project shortcut was verified.'
    $log = ($trace -join "`r`n")
    [System.IO.File]::AppendAllText((Join-Path $logFolder 'install.log'), ("`r`n" + [DateTime]::Now.ToString('s') + "`r`n" + $log + "`r`n"))
    if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Recurse -Force }
    if ($env:TRUN_INSTALL_NONINTERACTIVE -ne '1') { Show-BuildResult -Status Success -Summary 'The app was verified and its launcher was created inside the project folder. No Desktop shortcut was created.' -Details $log }
    exit 0
} catch {
    $reason = ($_ | Out-String)
    Trace ('[BUILD FATAL ERROR] ' + $_.Exception.Message)
    if ($stageActivated -and $oldMoved) {
        try { Remove-Item -LiteralPath $app -Recurse -Force; Move-Item -LiteralPath $old -Destination $app; Trace '[ROLLBACK] Previous application version restored.' }
        catch { Trace ('[ROLLBACK ERROR] ' + $_.Exception.Message) }
    } elseif ($oldMoved -and -not $stageActivated) {
        try { Move-Item -LiteralPath $old -Destination $app } catch { }
    } elseif ($stageActivated -and -not $oldMoved) {
        try { Remove-Item -LiteralPath $app -Recurse -Force } catch { }
    }
    if ($shortcutSaved -and -not $oldMoved) {
        try { Remove-Item -LiteralPath (Join-Path $source 'Trun Game Free Mega.lnk') -Force -ErrorAction SilentlyContinue } catch { }
    }
    if (Test-Path -LiteralPath $stage) {
        try { Remove-Item -LiteralPath $stage -Recurse -Force } catch { }
    }
    $report = $reason + "`r`n" + ($trace -join "`r`n")
    try {
        [void][System.IO.Directory]::CreateDirectory($logFolder)
        [System.IO.File]::AppendAllText((Join-Path $logFolder 'install-errors.log'), ("`r`n" + [DateTime]::Now.ToString('s') + "`r`n" + $report + "`r`n"))
    } catch { }
    if (-not (Get-Command Show-BuildResult -ErrorAction SilentlyContinue)) {
        try { . (Join-Path $PSScriptRoot 'BuildStatus.ps1') } catch { }
    }
    if (($env:TRUN_INSTALL_NONINTERACTIVE -ne '1') -and (Get-Command Show-BuildResult -ErrorAction SilentlyContinue)) {
        Show-BuildResult -Status Fatal -Summary $_.Exception.Message -Details $report
    }
    exit 1
}
