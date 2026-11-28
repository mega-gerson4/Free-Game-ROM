param([switch]$SelfTest)
# Trun Game Free Mega 2.2 - Native Windows UI (WinForms / .NET Framework)
# Does not require Python, a web server, or a browser to display the catalog.
try {
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'BuildStatus.ps1')
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$script:root = Split-Path -Parent $PSScriptRoot
$script:dataDir = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'TrunGameFreeMega\DataSense'
[void][System.IO.Directory]::CreateDirectory($script:dataDir)
$script:historyFile = Join-Path $script:dataDir 'history.tsv'
$script:settingsFile = Join-Path $script:dataDir 'language.txt'
$script:links = @(Import-Csv -LiteralPath (Join-Path $script:root 'catalog.tsv') -Delimiter "`t" -Encoding UTF8)
if ($script:links.Count -lt 1) { throw 'Catalog is empty.' }
# Independent preflight: the installer never reports SUCCESS until this passes.
if ($SelfTest) {
  if ($script:links.Count -ne 40) { throw ('Expected 40 entries, found ' + $script:links.Count) }
  $cred=Join-Path $script:root 'credits.txt'
  if (-not (Test-Path -LiteralPath $cred)) { throw 'Credits file is missing.' }
  $imagePath=Join-Path $script:root 'assets\MEGA-Logo.png'
  $iconPath=Join-Path $script:root 'assets\MEGA-Logo.ico'
  $im=[System.Drawing.Image]::FromFile($imagePath)
  $im.Dispose()
  $ico=[System.Drawing.Icon]::new($iconPath)
  $ico.Dispose()
  Write-Output ('APP SELF-TEST OK: ' + $script:links.Count + ' entries, logo and WinForms loaded.')
  exit 0
}

$script:groups = @('All', 'Nintendo', 'Sony', 'Microsoft', 'Sega', 'Capcom', 'Commodore')
$script:activeGroup = 'All'
$script:langSetting = 'auto'
if (Test-Path -LiteralPath $script:settingsFile) {
  $candidate = [System.IO.File]::ReadAllText($script:settingsFile).Trim()
  if (@('auto','en','pt','es','fr','de','ja') -contains $candidate) { $script:langSetting = $candidate }
}
$script:wording = @{
  en = @{ search='Search consoles or links...'; copy='COPY'; open='OPEN'; history='History'; clear='Clear history'; creators='Creators'; all='All games'; copied='Copied to clipboard'; empty='No results'; language='Language'; confirm='Delete your local copy history?'; details='Copied links'; count='links' }
  pt = @{ search='Buscar consoles ou links...'; copy='COPIAR'; open='ABRIR'; history='Historico'; clear='Apagar historico'; creators='Criadores'; all='Todos'; copied='Copiado para a area de transferencia'; empty='Nenhum resultado'; language='Idioma'; confirm='Apagar seu historico local?'; details='Links copiados'; count='links' }
  es = @{ search='Buscar consolas o enlaces...'; copy='COPIAR'; open='ABRIR'; history='Historial'; clear='Borrar historial'; creators='Creadores'; all='Todos'; copied='Copiado al portapapeles'; empty='Sin resultados'; language='Idioma'; confirm='Borrar historial local?'; details='Enlaces copiados'; count='enlaces' }
  fr = @{ search='Rechercher des consoles ou liens...'; copy='COPIER'; open='OUVRIR'; history='Historique'; clear='Effacer'; creators='Createurs'; all='Tous'; copied='Copie dans le presse-papiers'; empty='Aucun resultat'; language='Langue'; confirm="Effacer l'historique local ?"; details='Liens copies'; count='liens' }
  de = @{ search='Konsolen oder Links suchen...'; copy='KOPIEREN'; open='OEFFNEN'; history='Verlauf'; clear='Verlauf loeschen'; creators='Ersteller'; all='Alle'; copied='In Zwischenablage kopiert'; empty='Keine Treffer'; language='Sprache'; confirm='Lokalen Verlauf loeschen?'; details='Kopierte Links'; count='Links' }
  ja = @{ search='Search games or links...'; copy='COPY'; open='OPEN'; history='History'; clear='Clear history'; creators='Creators'; all='All games'; copied='Copied to clipboard'; empty='No results'; language='Language'; confirm='Delete local history?'; details='Copied links'; count='links' }
}
function Get-Lang {
  if ($script:langSetting -ne 'auto') { return $script:langSetting }
  try { $v = [System.Windows.Forms.InputLanguage]::CurrentInputLanguage.Culture.TwoLetterISOLanguageName.ToLowerInvariant() }
  catch { $v = [System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName.ToLowerInvariant() }
  if (-not $script:wording.ContainsKey($v)) { return 'en' }
  return $v
}
function T([string]$key) { return $script:wording[(Get-Lang)][$key] }
function Color([string]$code) { return [System.Drawing.ColorTranslator]::FromHtml($code) }
$bg=Color '#100D14'; $surface=Color '#211721'; $card=Color '#2A1D29'; $red=Color '#F04F62'; $ink=Color '#F7F3F7'; $muted=Color '#B6A7B5'
$script:form=New-Object System.Windows.Forms.Form
$script:form.Text='Trun Game Free Mega 2.2'
$script:form.BackColor=$bg
$script:form.ForeColor=$ink
$script:form.StartPosition='CenterScreen'
$script:form.ClientSize=[System.Drawing.Size]::new(1100,720)
$script:form.MinimumSize=[System.Drawing.Size]::new(900,620)
$script:form.Font=[System.Drawing.Font]::new('Segoe UI',10)
$script:form.KeyPreview=$true
$script:form.Add_KeyDown({ param($s,$e) if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $e.SuppressKeyPress = $true } })
try { $script:form.Icon=[System.Drawing.Icon]::new((Join-Path $script:root 'assets\MEGA-Logo.ico')) } catch {}

# Explicit grid layout: prevents the sidebar and header from overlapping the cards.
# Docking the old panels directly on Form caused the list to render UNDER the sidebar
# and the toolbar, which hid console names and search fields on Windows 11.
$rootLayout=New-Object System.Windows.Forms.TableLayoutPanel
$rootLayout.Dock='Fill'; $rootLayout.Margin=[System.Windows.Forms.Padding]::new(0)
$rootLayout.Padding=[System.Windows.Forms.Padding]::new(0)
$rootLayout.ColumnCount=2; $rootLayout.RowCount=1
[void]$rootLayout.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new([System.Windows.Forms.SizeType]::Absolute,205))
[void]$rootLayout.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new([System.Windows.Forms.SizeType]::Percent,100))
[void]$rootLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Percent,100))
$script:form.Controls.Add($rootLayout)

$sidebar=New-Object System.Windows.Forms.Panel
$sidebar.Dock='Fill'; $sidebar.Margin=[System.Windows.Forms.Padding]::new(0)
$sidebar.BackColor=$surface
$rootLayout.Controls.Add($sidebar,0,0)
$groupHead=New-Object System.Windows.Forms.Label
$groupHead.Text='LIBRARY'; $groupHead.ForeColor=$red; $groupHead.Font=[System.Drawing.Font]::new('Segoe UI',10,[System.Drawing.FontStyle]::Bold)
$groupHead.Location=[System.Drawing.Point]::new(22,24); $groupHead.AutoSize=$true; $sidebar.Controls.Add($groupHead)
$script:navButtons=@()
for($i=0;$i -lt $script:groups.Count;$i++) {
  $group=$script:groups[$i]
  $b=New-Object System.Windows.Forms.Button
  $b.Tag=$group; $b.Text=$group; $b.FlatStyle='Flat'; $b.FlatAppearance.BorderSize=0
  $b.TextAlign='MiddleLeft'; $b.Location=[System.Drawing.Point]::new(12,(58+$i*48))
  $b.Size=[System.Drawing.Size]::new(186,42)
  $b.Font=[System.Drawing.Font]::new('Segoe UI',10,[System.Drawing.FontStyle]::Bold)
  $b.ForeColor=$ink; $b.BackColor=$surface
  $b.Add_Click({ param($s,$e) $script:activeGroup=[string]$s.Tag; Refresh-List })
  $sidebar.Controls.Add($b); $script:navButtons+= $b
}
$creatorsBtn=New-Object System.Windows.Forms.Button
$creatorsBtn.Text='CREATORS'; $creatorsBtn.FlatStyle='Flat'; $creatorsBtn.FlatAppearance.BorderColor=$red
$creatorsBtn.ForeColor=$ink; $creatorsBtn.BackColor=$surface
$creatorsBtn.Location=[System.Drawing.Point]::new(17,422); $creatorsBtn.Size=[System.Drawing.Size]::new(171,43)
$sidebar.Controls.Add($creatorsBtn)
$script:status=New-Object System.Windows.Forms.Label
$script:status.AutoEllipsis=$true; $script:status.Text='Loading...'; $script:status.Dock='Bottom'; $script:status.Height=48
$script:status.ForeColor=$muted; $script:status.Padding=[System.Windows.Forms.Padding]::new(20,12,10,5)
$sidebar.Controls.Add($script:status)

$mainLayout=New-Object System.Windows.Forms.TableLayoutPanel
$mainLayout.Dock='Fill'; $mainLayout.Margin=[System.Windows.Forms.Padding]::new(0)
$mainLayout.Padding=[System.Windows.Forms.Padding]::new(0)
$mainLayout.ColumnCount=1; $mainLayout.RowCount=4
[void]$mainLayout.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new([System.Windows.Forms.SizeType]::Percent,100))
[void]$mainLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute,126))
[void]$mainLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute,72))
[void]$mainLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute,30))
[void]$mainLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Percent,100))
$rootLayout.Controls.Add($mainLayout,1,0)

$header=New-Object System.Windows.Forms.Panel
$header.Dock='Fill'; $header.Margin=[System.Windows.Forms.Padding]::new(0); $header.BackColor=$surface
$mainLayout.Controls.Add($header,0,0)
$redBar=New-Object System.Windows.Forms.Panel
$redBar.Dock='Bottom'; $redBar.Height=3; $redBar.BackColor=$red
$header.Controls.Add($redBar)
$logo=New-Object System.Windows.Forms.PictureBox
$logo.Size=[System.Drawing.Size]::new(80,80); $logo.Location=[System.Drawing.Point]::new(24,20)
$logo.SizeMode='Zoom'
try { $logo.Image=[System.Drawing.Image]::FromFile((Join-Path $script:root 'assets\MEGA-Logo.png')) } catch {}
$header.Controls.Add($logo)
$title=New-Object System.Windows.Forms.Label
$title.Text='TRUN GAME FREE MEGA'; $title.ForeColor=$ink; $title.Font=[System.Drawing.Font]::new('Segoe UI',23,[System.Drawing.FontStyle]::Bold)
$title.Location=[System.Drawing.Point]::new(128,24); $title.AutoSize=$true; $header.Controls.Add($title)
$subtitle=New-Object System.Windows.Forms.Label
$subtitle.Text='RED EDITION   /   2.2   /   NATIVE APP'; $subtitle.ForeColor=$red; $subtitle.Font=[System.Drawing.Font]::new('Segoe UI',10,[System.Drawing.FontStyle]::Bold)
$subtitle.Location=[System.Drawing.Point]::new(132,79); $subtitle.AutoSize=$true; $header.Controls.Add($subtitle)

$toolbar=New-Object System.Windows.Forms.TableLayoutPanel
$toolbar.Dock='Fill'; $toolbar.Margin=[System.Windows.Forms.Padding]::new(0)
$toolbar.Padding=[System.Windows.Forms.Padding]::new(16,13,18,11)
$toolbar.BackColor=$bg; $toolbar.ColumnCount=3; $toolbar.RowCount=1
[void]$toolbar.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new([System.Windows.Forms.SizeType]::Percent,100))
[void]$toolbar.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new([System.Windows.Forms.SizeType]::Absolute,152))
[void]$toolbar.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new([System.Windows.Forms.SizeType]::Absolute,120))
[void]$toolbar.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Percent,100))
$mainLayout.Controls.Add($toolbar,0,1)
$script:search=New-Object System.Windows.Forms.TextBox
$script:search.Dock='Fill'; $script:search.Margin=[System.Windows.Forms.Padding]::new(5,7,12,5)
$script:search.BackColor=$card; $script:search.ForeColor=$ink
$script:search.BorderStyle='FixedSingle'; $script:search.Font=[System.Drawing.Font]::new('Segoe UI',12)
$toolbar.Controls.Add($script:search,0,0)
$script:search.Add_TextChanged({ Refresh-List })
$language=New-Object System.Windows.Forms.ComboBox
$language.DropDownStyle='DropDownList'; $language.Dock='Fill'
$language.Margin=[System.Windows.Forms.Padding]::new(4,6,10,5)
$language.BackColor=$card; $language.ForeColor=$ink
@('Auto','English','Portugues','Espanol','Francais','Deutsch','Japanese') | ForEach-Object { [void]$language.Items.Add($_) }
$script:codes=@('auto','en','pt','es','fr','de','ja')
$language.SelectedIndex=[Array]::IndexOf($script:codes,$script:langSetting)
$language.Add_SelectedIndexChanged({
 if ($language.SelectedIndex -lt 0) { return }
 $script:langSetting=$script:codes[$language.SelectedIndex]
 [System.IO.File]::WriteAllText($script:settingsFile,$script:langSetting)
 Refresh-List
})
$toolbar.Controls.Add($language,1,0)
$historyBtn=New-Object System.Windows.Forms.Button
$historyBtn.Text='HISTORY'; $historyBtn.Dock='Fill'
$historyBtn.Margin=[System.Windows.Forms.Padding]::new(4,4,3,5)
$historyBtn.BackColor=$red; $historyBtn.ForeColor=$ink; $historyBtn.FlatStyle='Flat'; $historyBtn.FlatAppearance.BorderSize=0
$toolbar.Controls.Add($historyBtn,2,0)
$script:counter=New-Object System.Windows.Forms.Label
$script:counter.Dock='Fill'; $script:counter.Margin=[System.Windows.Forms.Padding]::new(0)
$script:counter.ForeColor=$muted; $script:counter.Padding=[System.Windows.Forms.Padding]::new(23,4,0,0)
$mainLayout.Controls.Add($script:counter,0,2)
$script:list=New-Object System.Windows.Forms.FlowLayoutPanel
$script:list.Dock='Fill'; $script:list.Margin=[System.Windows.Forms.Padding]::new(0)
$script:list.FlowDirection='TopDown'; $script:list.WrapContents=$false
$script:list.AutoScroll=$true; $script:list.Padding=[System.Windows.Forms.Padding]::new(15,3,8,8)
$script:list.BackColor=$bg
$mainLayout.Controls.Add($script:list,0,3)
$script:notify=New-Object System.Windows.Forms.NotifyIcon
$script:notify.Icon=$script:form.Icon
$script:notify.Text='Trun Game Free Mega'
$script:notify.Visible=$true
function Show-History {
  $dlg=New-Object System.Windows.Forms.Form
  $dlg.Text='DataSense - '+(T 'details');$dlg.BackColor=$bg;$dlg.ForeColor=$ink
  $dlg.ClientSize=[System.Drawing.Size]::new(640,455);$dlg.StartPosition='CenterParent'
  $box=New-Object System.Windows.Forms.ListBox
  $box.Dock='Fill'; $box.BackColor=$surface;$box.ForeColor=$ink
  $box.Font=[System.Drawing.Font]::new('Consolas',10)
  if(Test-Path -LiteralPath $script:historyFile) {
    $lines=[System.IO.File]::ReadAllLines($script:historyFile)
    foreach($line in @($lines | Select-Object -Last 300)) { [void]$box.Items.Add($line) }
  }
  $buttons=New-Object System.Windows.Forms.Panel;$buttons.Dock='Bottom';$buttons.Height=56;$buttons.BackColor=$bg
  $clear=New-Object System.Windows.Forms.Button;$clear.Text=(T 'clear');$clear.Width=158;$clear.Height=36
  $clear.Location=[System.Drawing.Point]::new(12,10);$clear.ForeColor=$ink;$clear.BackColor=$red
  $clear.FlatStyle='Flat';$clear.FlatAppearance.BorderSize=0
  $clear.Add_Click({
    $r=[System.Windows.Forms.MessageBox]::Show((T 'confirm'),'DataSense','YesNo','Question')
    if($r -eq [System.Windows.Forms.DialogResult]::Yes) {
      if(Test-Path -LiteralPath $script:historyFile){Remove-Item -LiteralPath $script:historyFile -Force}
      $box.Items.Clear();$script:status.Text='DataSense: history cleared'
    }
  })
  $buttons.Controls.Add($clear);$dlg.Controls.Add($box);$dlg.Controls.Add($buttons)
  [void]$dlg.ShowDialog($script:form);$dlg.Dispose()
}
$historyBtn.Add_Click({ Show-History });$script:notify.Add_BalloonTipClicked({ Show-History })
$creatorsBtn.Add_Click({
  $names=[System.IO.File]::ReadAllText((Join-Path $script:root 'credits.txt'))
  [void][System.Windows.Forms.MessageBox]::Show($names,'Trun Game Free Mega - Creators','OK','Information')
})
function Save-Copy([string]$name,[string]$url) {
  try {
    [System.Windows.Forms.Clipboard]::SetText($url)
    $line=[DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss')+"`t"+$name+"`t"+$url+"`r`n"
    [System.IO.File]::AppendAllText($script:historyFile,$line,(New-Object System.Text.UTF8Encoding($false)))
    $script:status.Text=(T 'copied')
    $script:notify.BalloonTipTitle='Trun Game Free Mega'
    $script:notify.BalloonTipText=(T 'copied')+': '+$name
    $script:notify.ShowBalloonTip(1800)
  } catch {
    Show-BuildResult -Status Fatal -Summary ('Clipboard or DataSense failure: ' + $_.Exception.Message) -Details ($_ | Out-String)
  }
}
function Refresh-List {
  if($null -eq $script:list) { return }
  $script:list.SuspendLayout(); $script:list.Controls.Clear()
  foreach($nav in $script:navButtons) {
    $nav.BackColor= if([string]$nav.Tag -eq $script:activeGroup){$red}else{$surface}
    if([string]$nav.Tag -eq 'All') { $nav.Text=(T 'all') }
  }
  $historyBtn.Text=(T 'history').ToUpperInvariant();$script:search.AccessibleDescription=(T 'search')
  $word=$script:search.Text.Trim().ToLowerInvariant()
  $matched=@($script:links | Where-Object {
    ($script:activeGroup -eq 'All' -or $_.Group -eq $script:activeGroup) -and
    ($word -eq '' -or $_.Name.ToLowerInvariant().Contains($word) -or $_.URL.ToLowerInvariant().Contains($word) -or $_.Group.ToLowerInvariant().Contains($word))
  })
  $script:counter.Text=($matched.Count.ToString()+' / '+$script:links.Count+' '+(T 'count'))
  $width=[Math]::Max(500,$script:list.ClientSize.Width - 39)
  foreach($item in $matched) {
    $p=New-Object System.Windows.Forms.Panel
    $p.Size=[System.Drawing.Size]::new($width,84)
    $p.BackColor=$surface
    $p.Margin=[System.Windows.Forms.Padding]::new(4,3,3,7)
    $tag=New-Object System.Windows.Forms.Label
    $tag.Text=$item.Group.ToUpperInvariant(); $tag.ForeColor=$red
    $tag.Font=[System.Drawing.Font]::new('Segoe UI',8,[System.Drawing.FontStyle]::Bold)
    $tag.Location=[System.Drawing.Point]::new(15,7); $tag.Size=[System.Drawing.Size]::new(($width-250),17)
    $p.Controls.Add($tag)
    $label=New-Object System.Windows.Forms.Label
    $label.Text=$item.Name; $label.ForeColor=$ink; $label.AutoEllipsis=$true
    $label.Font=[System.Drawing.Font]::new('Segoe UI',11,[System.Drawing.FontStyle]::Bold)
    $label.Location=[System.Drawing.Point]::new(15,26); $label.Size=[System.Drawing.Size]::new(($width-250),25)
    $p.Controls.Add($label)
    $address=New-Object System.Windows.Forms.Label
    $address.Text=$item.URL; $address.ForeColor=$muted; $address.AutoEllipsis=$true
    $address.Font=[System.Drawing.Font]::new('Segoe UI',8)
    $address.Location=[System.Drawing.Point]::new(15,56); $address.Size=[System.Drawing.Size]::new(($width-250),18)
    $p.Controls.Add($address)
    $copy=New-Object System.Windows.Forms.Button
    $copy.Text=(T 'copy'); $copy.Tag=$item; $copy.Size=[System.Drawing.Size]::new(94,38)
    $copy.Location=[System.Drawing.Point]::new(($width-211),23)
    $copy.ForeColor=$ink; $copy.BackColor=$red; $copy.FlatStyle='Flat'; $copy.FlatAppearance.BorderSize=0
    $copy.Add_Click({param($s,$e) Save-Copy $s.Tag.Name $s.Tag.URL})
    $p.Controls.Add($copy)
    $open=New-Object System.Windows.Forms.Button
    $open.Text=(T 'open'); $open.Tag=$item.URL; $open.Size=[System.Drawing.Size]::new(86,38)
    $open.Location=[System.Drawing.Point]::new(($width-107),23)
    $open.ForeColor=$ink; $open.BackColor=$card; $open.FlatStyle='Flat'; $open.FlatAppearance.BorderSize=0
    $open.Add_Click({param($s,$e) try { Start-Process -FilePath ([string]$s.Tag) } catch { Show-BuildResult -Status Fatal -Summary ('Could not open link: ' + $_.Exception.Message) -Details ($_ | Out-String) }})
    $p.Controls.Add($open); [void]$script:list.Controls.Add($p)
  }
  if($matched.Count -eq 0) { $script:counter.Text=(T 'empty') }
  $script:list.ResumeLayout()
}
$script:form.Add_ResizeEnd({ Refresh-List })
$script:list.Add_SizeChanged({
  $w=[Math]::Max(500,$script:list.ClientSize.Width - 39)
  foreach($p in $script:list.Controls) {
    if($p -isnot [System.Windows.Forms.Panel]) { continue }
    $p.Width=$w
    foreach($c in $p.Controls) {
      if($c -is [System.Windows.Forms.Label]) {
        $c.Width= $w-250
      } elseif($c -is [System.Windows.Forms.Button]) {
        if($c.Tag -is [string]) { $c.Left=$w-107 }
        else { $c.Left=$w-211 }
      }
    }
  }
})
$script:form.Add_InputLanguageChanged({ if($script:langSetting -eq 'auto'){Refresh-List} })
$script:form.Add_FormClosed({ $script:notify.Visible=$false;$script:notify.Dispose();if($logo.Image){$logo.Image.Dispose()} })
$script:form.Add_Shown({ Refresh-List; $script:status.Text='BUILD SUCCESS - Ready' })
Refresh-List
[void]$script:form.ShowDialog()
 } catch {
  $details = ($_ | Out-String)
  try {
    $logDir=Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'TrunGameFreeMega\DataSense'
    [void][System.IO.Directory]::CreateDirectory($logDir)
    [System.IO.File]::AppendAllText((Join-Path $logDir 'error.log'), "[$([DateTime]::Now.ToString('s'))] $details`r`n")
  } catch { }
  if ($SelfTest) {
    Write-Output ('APP SELF-TEST FATAL ERROR: ' + $details)
    exit 2
  }
  if (-not (Get-Command Show-BuildResult -ErrorAction SilentlyContinue)) {
    try { . (Join-Path $PSScriptRoot 'BuildStatus.ps1') } catch { }
  }
  if (Get-Command Show-BuildResult -ErrorAction SilentlyContinue) {
    Show-BuildResult -Status Fatal -Summary ('App failed to start: ' + $_.Exception.Message) -Details $details
  } else {
    try {
      Add-Type -AssemblyName System.Windows.Forms
      [void][System.Windows.Forms.MessageBox]::Show(('BUILD FATAL ERROR' + "`r`n" + $_.Exception.Message), 'Trun Game Free Mega', 'OK', 'Error')
    } catch { }
  }
  exit 2
}
