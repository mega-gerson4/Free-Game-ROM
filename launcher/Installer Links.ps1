# Installer Links - installs/updates shortcuts for current Windows user.
# Does NOT need elevation and does NOT add scheduled tasks or autorun entries.
$ErrorActionPreference = 'Stop'

function Step([string]$Label) { Write-Host ("[INSTALLER] " + $Label) -ForegroundColor Cyan }
function Test-Project([string]$Folder) {
    $needed = @('Trun-Game-Free-Mega.bat','Trun-Game-Free-Mega.ps1','Abrir-sem-janela-preta.vbs','MEGA-Logo.ico')
    foreach ($name in $needed) {
        if (-not (Test-Path -LiteralPath (Join-Path $Folder $name) -PathType Leaf)) { return $false }
    }
    return $true
}

try {
    $project = $PSScriptRoot
    Step "Verificando os arquivos do projeto em: $project"
    if (-not (Test-Project $project)) { throw 'Arquivos principais do projeto nao encontrados. Extraia o ZIP completo.' }

    $installFolder = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'TrunGameFreeMega'
    Step "Criando inicializador local em: $installFolder"
    [void](New-Item -Path $installFolder -ItemType Directory -Force)

    $files = @(
        @{From='Launcher Links.ps1';To='Launcher Links.ps1'},
        @{From='Abrir Launcher.vbs';To='Abrir Launcher.vbs'},
        @{From='MEGA-Logo.ico';To='MEGA-Logo.ico'}
    )
    foreach ($file in $files) {
        $from=Join-Path $project $file.From
        if (-not (Test-Path -LiteralPath $from -PathType Leaf)) { throw "Arquivo do instalador nao encontrado: $from" }
        $to=Join-Path $installFolder $file.To
        Step "Copiando $($file.From) para a pasta do usuario"
        Copy-Item -LiteralPath $from -Destination $to -Force
    }

    $desktop = [Environment]::GetFolderPath('DesktopDirectory')
    if ([string]::IsNullOrWhiteSpace($desktop) -or -not (Test-Path -LiteralPath $desktop -PathType Container)) {
        throw 'A area de trabalho deste usuario nao foi encontrada.'
    }

    $shortcuts = @(
        (Join-Path $desktop 'Trun Game Free Mega.lnk'),
        (Join-Path $project 'Trun Game Free Mega 1.0.lnk')
    )
    $shortcutName = 'Trun Game Free Mega 1.0.lnk'
    $oldOnDesktop = Join-Path $desktop $shortcutName
    if (Test-Path -LiteralPath $oldOnDesktop -PathType Leaf) { $shortcuts += $oldOnDesktop }

    $configPath = Join-Path $installFolder 'config.json'
    Step 'Gravando o diretorio deste computador (usuario/disco detectados automaticamente)'
    $config = [ordered]@{
        ProjectFolder=$project
        ShortcutPaths=@($shortcuts)
        InstalledAt=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Version='1.1'
    } | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($configPath,$config,(New-Object System.Text.UTF8Encoding($false)))

    $shell = New-Object -ComObject WScript.Shell
    $wscript = Join-Path $env:WINDIR 'System32\wscript.exe'
    $launcherVbs = Join-Path $installFolder 'Abrir Launcher.vbs'
    $icon = Join-Path $installFolder 'MEGA-Logo.ico'
    foreach ($shortcutPath in $shortcuts) {
        Step "Gerando ou atualizando atalho: $shortcutPath"
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $wscript
        $shortcut.Arguments = '"' + $launcherVbs + '"'
        $shortcut.WorkingDirectory = $installFolder
        $shortcut.IconLocation = $icon + ',0'
        $shortcut.Description = 'Trun Game Free Mega - atalho pessoal com reparacao de caminho'
        $shortcut.Save()
    }

    Step 'Configurando o Installer Links para ficar oculto depois da instalacao'
    foreach ($name in @('Installer Links.bat','Installer Links.ps1','Launcher Links.ps1','Abrir Launcher.vbs')) {
        $sourceFile=Join-Path $project $name
        if (Test-Path -LiteralPath $sourceFile -PathType Leaf) {
            try {
                $item=Get-Item -LiteralPath $sourceFile -Force
                $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::Hidden
            } catch { Write-Host "Aviso: nao foi possivel ocultar $name" -ForegroundColor Yellow }
        }
    }
    Write-Host ''
    Write-Host 'SUCESSO: Seu atalho foi atualizado sem remover o projeto!' -ForegroundColor Green
    Write-Host "Local de instalacao: $installFolder"
    Write-Host 'Se voce mover a pasta depois, abra o atalho e clique em Reparar problema.'
    exit 0
} catch {
    Write-Host ('ERRO: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
