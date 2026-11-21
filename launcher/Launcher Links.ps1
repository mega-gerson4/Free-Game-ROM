# Portable shortcut launcher - stored in %LOCALAPPDATA% by Installer Links.
# Handles moved project folders with a user-initiated, visible repair dialog.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$installFolder=$PSScriptRoot
$configPath=Join-Path $installFolder 'config.json'

function Test-Project([string]$Folder) {
    if ([string]::IsNullOrWhiteSpace($Folder)) { return $false }
    foreach ($name in @('Trun-Game-Free-Mega.bat','Trun-Game-Free-Mega.ps1','Abrir-sem-janela-preta.vbs')) {
        if (-not (Test-Path -LiteralPath (Join-Path $Folder $name) -PathType Leaf)) { return $false }
    }
    return $true
}
function Get-Config {
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return $null }
    try { return (Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json) }
    catch { return $null }
}
function Set-Config([object]$Config, [string]$Folder) {
    $Config.ProjectFolder=$Folder
    $Config.InstalledAt=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $serialized=$Config | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($configPath,$serialized,(New-Object System.Text.UTF8Encoding($false)))
}
function Update-Shortcuts([object]$Config, [string]$Folder) {
    $desktop=[Environment]::GetFolderPath('DesktopDirectory')
    $paths=@((Join-Path $desktop 'Trun Game Free Mega.lnk'),(Join-Path $Folder 'Trun Game Free Mega 1.0.lnk'))
    if ($null -ne $Config.ShortcutPaths) {
        foreach ($existing in @($Config.ShortcutPaths)) {
            # Update old paths only when the link still exists (avoid recreating files in moved-away folders).
            if (Test-Path -LiteralPath ([string]$existing) -PathType Leaf) { $paths += [string]$existing }
        }
    }
    $legacyDesktop=Join-Path $desktop 'Trun Game Free Mega 1.0.lnk'
    if (Test-Path -LiteralPath $legacyDesktop -PathType Leaf) { $paths += $legacyDesktop }
    $paths=@($paths | Select-Object -Unique)

    $customIcon=Join-Path $Folder 'MEGA-Logo.ico'
    $stableIcon=Join-Path $installFolder 'MEGA-Logo.ico'
    if (Test-Path -LiteralPath $customIcon -PathType Leaf) { Copy-Item -LiteralPath $customIcon -Destination $stableIcon -Force }
    $shell=New-Object -ComObject WScript.Shell
    $wscript=Join-Path $env:WINDIR 'System32\wscript.exe'
    $vbs=Join-Path $installFolder 'Abrir Launcher.vbs'
    foreach ($linkPath in $paths) {
        $link=$shell.CreateShortcut($linkPath)
        $link.TargetPath=$wscript
        $link.Arguments='"' + $vbs + '"'
        $link.WorkingDirectory=$installFolder
        $link.IconLocation=$stableIcon + ',0'
        $link.Description='Trun Game Free Mega - atalho pessoal com reparacao de caminho'
        $link.Save()
    }
    $Config.ShortcutPaths=@($paths)
}
function Start-Game([string]$Folder) {
    $scriptToRun=Join-Path $Folder 'Abrir-sem-janela-preta.vbs'
    Start-Process -FilePath (Join-Path $env:WINDIR 'System32\wscript.exe') -ArgumentList ('"' + $scriptToRun + '"') -WorkingDirectory $Folder
}

try {
    $config=Get-Config
    $folder=if ($null -ne $config) { [string]$config.ProjectFolder } else { '' }
    if (Test-Project $folder) {
        Start-Game $folder
        exit 0
    }

    # The shortcut remains valid because this launcher is in LocalAppData, not in the moved project.
    $form=New-Object System.Windows.Forms.Form
    $form.Text='Trun Game Free Mega - Repository not found'
    $form.StartPosition='CenterScreen'
    $form.FormBorderStyle='FixedDialog'
    $form.MaximizeBox=$false
    $form.MinimizeBox=$false
    $form.ClientSize=New-Object System.Drawing.Size(520,225)
    $form.Font=New-Object System.Drawing.Font('Segoe UI',10)

    $heading=New-Object System.Windows.Forms.Label
    $heading.AutoSize=$false
    $heading.Location=New-Object System.Drawing.Point(20,18)
    $heading.Size=New-Object System.Drawing.Size(480,40)
    $heading.Text='Diretorio nao reconhecido - Repositorio nao encontrado'
    $heading.Font=New-Object System.Drawing.Font('Segoe UI',11,[System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($heading)

    $description=New-Object System.Windows.Forms.Label
    $description.Location=New-Object System.Drawing.Point(20,68)
    $description.Size=New-Object System.Drawing.Size(480,72)
    $description.Text='A pasta do projeto foi movida ou nao esta mais disponivel. Clique em Reparar problema, selecione a pasta atual do Trun Game Free Mega e o atalho sera atualizado.'
    $form.Controls.Add($description)

    $repair=New-Object System.Windows.Forms.Button
    $repair.Text='Reparar problema'
    $repair.Location=New-Object System.Drawing.Point(20,166)
    $repair.Size=New-Object System.Drawing.Size(170,35)
    $form.Controls.Add($repair)

    $cancel=New-Object System.Windows.Forms.Button
    $cancel.Text='Cancelar'
    $cancel.Location=New-Object System.Drawing.Point(380,166)
    $cancel.Size=New-Object System.Drawing.Size(120,35)
    $cancel.Add_Click({$form.Close()})
    $form.Controls.Add($cancel)

    $script:launchAfterRepair=$false
    $script:repairedFolder=''
    $repair.Add_Click({
        $picker=New-Object System.Windows.Forms.FolderBrowserDialog
        $picker.Description='Selecione a pasta que contem Trun-Game-Free-Mega.bat'
        $picker.ShowNewFolderButton=$false
        try {
            if ($picker.ShowDialog($form) -ne [System.Windows.Forms.DialogResult]::OK) { return }
            $selected=[string]$picker.SelectedPath
            if (-not (Test-Project $selected)) {
                [System.Windows.Forms.MessageBox]::Show($form,'Essa pasta nao contem todos os arquivos principais. Selecione a pasta do projeto, nao uma subpasta.','Pasta invalida','OK','Warning') | Out-Null
                return
            }
            $updated=if ($null -ne $config) { $config } else { [pscustomobject]@{ProjectFolder='';ShortcutPaths=@();InstalledAt='';Version='1.1'} }
            Update-Shortcuts $updated $selected
            Set-Config $updated $selected
            $script:repairedFolder=$selected
            $script:launchAfterRepair=$true
            [System.Windows.Forms.MessageBox]::Show($form,'Reparo concluido! O atalho existente foi atualizado para a nova pasta.','Trun Game Free Mega','OK','Information') | Out-Null
            $form.Close()
        } catch {
            [System.Windows.Forms.MessageBox]::Show($form,('Nao foi possivel reparar: ' + $_.Exception.Message),'Erro de reparacao','OK','Error') | Out-Null
        } finally { $picker.Dispose() }
    })
    [void]$form.ShowDialog()
    $form.Dispose()
    if ($script:launchAfterRepair -and (Test-Project $script:repairedFolder)) {
        Start-Game $script:repairedFolder
    }
} catch {
    [System.Windows.Forms.MessageBox]::Show(('O inicializador encontrou um erro: '+$_.Exception.Message),'Trun Game Free Mega','OK','Error') | Out-Null
}
