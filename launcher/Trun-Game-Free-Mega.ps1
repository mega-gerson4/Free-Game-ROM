# Trun Game Free Mega - Windows 10/11 prototype
# A .BAT starts this window; PowerShell/Windows Forms draws the interface.
# Links only COPY URLs. No game is downloaded or installed.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class NoEnterFilter : IMessageFilter
{
    public bool PreFilterMessage(ref Message m)
    {
        // Suppress Enter before a focused LinkLabel or any form handles it.
        return (m.Msg == 0x100 || m.Msg == 0x104) && (int)m.WParam == 0x0D;
    }
}

public class NoEnterForm : Form
{
    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        // Enter intentionally has no effect, even when a clickable label is focused.
        if ((keyData & Keys.KeyCode) == Keys.Enter) return true;
        return base.ProcessCmdKey(ref msg, keyData);
    }
    protected override bool ProcessDialogKey(Keys keyData)
    {
        if ((keyData & Keys.KeyCode) == Keys.Enter) return true;
        return base.ProcessDialogKey(keyData);
    }
}

public static class TrunWindowDrag
{
    [DllImport("user32.dll")] private static extern bool ReleaseCapture();
    [DllImport("user32.dll")] private static extern IntPtr SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);
    public static void Begin(Form f)
    {
        ReleaseCapture();
        SendMessage(f.Handle, 0xA1, 0x2, 0);
    }
}
'@ -ReferencedAssemblies 'System.Windows.Forms','System.Drawing' -ErrorAction Stop

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
[System.Windows.Forms.Application]::AddMessageFilter([NoEnterFilter]::new())

# ---------------------------------------------------------------
# APPEARANCE - edit appearance.json to change the main colors.
# ---------------------------------------------------------------
$stylesPath = Join-Path $PSScriptRoot 'appearance.json'
$style = Get-Content -LiteralPath $stylesPath -Raw -Encoding UTF8 | ConvertFrom-Json
function Color([string]$hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}
$bg = Color $style.background
$surface = Color $style.panel
$fg = Color $style.text
$accent = Color $style.accent
$muted = Color $style.muted

# Same 19 original links and their original three sections.
$games = @(
    [pscustomobject]@{ Group='Nintendo'; Name='Nintendo Switch 1 and 2'; Url='https://nswvault.com/nintendo-switch/roms/' }
    [pscustomobject]@{ Group='Nintendo'; Name='Nintendo 64'; Url='https://romsfun.com/roms/nintendo-64/' }
    [pscustomobject]@{ Group='Nintendo'; Name='GameCube'; Url='https://romsfun.com/roms/gamecube/' }
    [pscustomobject]@{ Group='Nintendo'; Name='Game Boy Color'; Url='https://romsfun.com/roms/game-boy-color/' }
    [pscustomobject]@{ Group='Nintendo'; Name='Game Boy'; Url='https://romsfun.com/roms/game-boy/' }
    [pscustomobject]@{ Group='Nintendo'; Name='Game Boy Advance'; Url='https://romsfun.com/roms/game-boy-advance/' }
    [pscustomobject]@{ Group='Nintendo'; Name='Nintendo DS'; Url='https://romsfun.com/roms/nintendo-ds/' }
    [pscustomobject]@{ Group='Nintendo'; Name='Pokemon Mini'; Url='https://romsfun.com/roms/nintendo-pokemon-mini/' }
    [pscustomobject]@{ Group='Nintendo'; Name='Nintendo 3DS'; Url='https://romsfun.com/roms/nintendo-3ds/' }
    [pscustomobject]@{ Group='Nintendo'; Name='NES'; Url='https://romsfun.com/roms/nes/' }
    [pscustomobject]@{ Group='Sony'; Name='PS4'; Url='https://romsfun.com/roms/playstation-4/' }
    [pscustomobject]@{ Group='Sony'; Name='PS2'; Url='https://romsfun.com/roms/playstation-2/' }
    [pscustomobject]@{ Group='Sony'; Name='PS1'; Url='https://romsfun.com/roms/playstation/' }
    [pscustomobject]@{ Group='Microsoft'; Name='Xbox 360'; Url='https://romsfun.com/roms/xbox-360/' }
    [pscustomobject]@{ Group='Microsoft'; Name='Windows'; Url='https://romsfun.com/roms/windows/' }
    [pscustomobject]@{ Group='Microsoft'; Name='Windows 3.x'; Url='https://romsfun.com/roms/windows-3x/' }
    [pscustomobject]@{ Group='Microsoft'; Name='MSX'; Url='https://romsfun.com/roms/microsoft-msx/' }
    [pscustomobject]@{ Group='Microsoft'; Name='MSX 2'; Url='https://romsfun.com/roms/microsoft-msx2/' }
    [pscustomobject]@{ Group='Microsoft'; Name='Classic Xbox'; Url='https://romsfun.com/roms/xbox/' }
)

$script:lastCopy = $null
$script:detailWindow = $null
$main = [NoEnterForm]::new()
$main.Text = 'Trun Game Free Mega'
$main.StartPosition = 'CenterScreen'
$main.Size = [System.Drawing.Size]::new([int]$style.width,[int]$style.height)
$main.MinimumSize = [System.Drawing.Size]::new(650,430)
$main.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$main.BackColor = $bg
$main.ForeColor = $fg
$main.ShowInTaskbar = $true
$main.KeyPreview = $true
$main.Add_KeyDown({ param($s,$e) if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) { $e.Handled=$true; $e.SuppressKeyPress=$true } })

$layout = [System.Windows.Forms.TableLayoutPanel]::new()
$layout.Dock = 'Fill'
$layout.ColumnCount = 1
$layout.RowCount = 3
$layout.ColumnStyles.Add([System.Windows.Forms.ColumnStyle]::new([System.Windows.Forms.SizeType]::Percent,100)) | Out-Null
$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute,104)) | Out-Null
$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Percent,100)) | Out-Null
$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute,70)) | Out-Null
$layout.Margin = [System.Windows.Forms.Padding]::new(0)
$layout.Padding = [System.Windows.Forms.Padding]::new(0)
$main.Controls.Add($layout)

# Custom header: draggable, with no standard title-bar buttons.
$header = [System.Windows.Forms.Panel]::new()
$header.Dock = 'Fill'
$header.Height = 104
$header.BackColor = $surface
$layout.Controls.Add($header,0,0)
$header.Add_MouseDown({ param($s,$e) if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) { [TrunWindowDrag]::Begin($main) } })

$title = [System.Windows.Forms.Label]::new()
$title.AutoSize=$false
$title.Location=[System.Drawing.Point]::new(24,18)
$title.Size=[System.Drawing.Size]::new(790,35)
$title.Font=[System.Drawing.Font]::new('Segoe UI',19,[System.Drawing.FontStyle]::Bold)
$title.ForeColor=$fg
$title.Text='TRUN GAME FREE MEGA'
$header.Controls.Add($title)
$title.Add_MouseDown({ param($s,$e) if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) { [TrunWindowDrag]::Begin($main) } })

$subtitle=[System.Windows.Forms.Label]::new()
$subtitle.Location=[System.Drawing.Point]::new(26,60)
$subtitle.AutoSize=$false
$subtitle.Size=[System.Drawing.Size]::new(800,28)
$subtitle.ForeColor=$muted
$subtitle.Font=[System.Drawing.Font]::new('Segoe UI',10)
$subtitle.Text='Click a game link to COPY it. Press Enter: nothing. Alt+F4: close.'
$header.Controls.Add($subtitle)
$subtitle.Add_MouseDown({ param($s,$e) if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) { [TrunWindowDrag]::Begin($main) } })

$footer = [System.Windows.Forms.Panel]::new()
$footer.Dock='Fill'
$footer.Height=70
$footer.BackColor=$surface
$layout.Controls.Add($footer,0,2)

$status = [System.Windows.Forms.Label]::new()
$status.Location=[System.Drawing.Point]::new(24,13)
$status.Size=[System.Drawing.Size]::new(740,22)
$status.ForeColor=$fg
$status.Font=[System.Drawing.Font]::new('Segoe UI',10)
$status.Text='Ready. No link has been copied yet.'
$footer.Controls.Add($status)

$openLast = [System.Windows.Forms.LinkLabel]::new()
$openLast.Location=[System.Drawing.Point]::new(24,40)
$openLast.Size=[System.Drawing.Size]::new(170,23)
$openLast.Text='View last notification'
$openLast.LinkColor=$accent
$openLast.ActiveLinkColor=$accent
$openLast.Visible=$false
$footer.Controls.Add($openLast)

$content = [System.Windows.Forms.Panel]::new()
$content.Dock='Fill'
$content.AutoScroll=$true
$content.BackColor=$bg
$layout.Controls.Add($content,0,1)

# System tray balloon/Windows notification; clicking it opens the small completion window.
$tray = [System.Windows.Forms.NotifyIcon]::new()
$tray.Icon = [System.Drawing.SystemIcons]::Information
$tray.Text = 'Trun Game Free Mega'
$tray.Visible = $true

function Show-CompletionWindow {
    if ($null -eq $script:lastCopy) { return }
    if ($null -ne $script:detailWindow -and -not $script:detailWindow.IsDisposed) {
        $script:detailWindow.Activate()
        return
    }

    $popup = [NoEnterForm]::new()
    $popup.Text='Trun Mega - Notification complete'
    $popup.StartPosition='CenterScreen'
    $popup.FormBorderStyle='None'
    $popup.BackColor=$surface
    $popup.ForeColor=$fg
    $popup.Size=[System.Drawing.Size]::new(510,220)
    $popup.ShowInTaskbar=$true
    $popup.TopMost=$true

    $popupTitle=[System.Windows.Forms.Label]::new()
    $popupTitle.Location=[System.Drawing.Point]::new(20,19)
    $popupTitle.Size=[System.Drawing.Size]::new(460,40)
    $popupTitle.Font=[System.Drawing.Font]::new('Segoe UI',14,[System.Drawing.FontStyle]::Bold)
    $popupTitle.Text='Notification completed!'
    $popup.Controls.Add($popupTitle)
    $popupTitle.Tag=$popup
    $popupTitle.Add_MouseDown({ param($sender,$e) if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) { [TrunWindowDrag]::Begin($sender.Tag) } })

    $popupText=[System.Windows.Forms.Label]::new()
    $popupText.Location=[System.Drawing.Point]::new(22,70)
    $popupText.Size=[System.Drawing.Size]::new(460,49)
    $popupText.Text='The selected link was copied to your clipboard.'
    $popupText.ForeColor=$muted
    $popup.Controls.Add($popupText)

    $details = [System.Windows.Forms.LinkLabel]::new()
    $details.Location=[System.Drawing.Point]::new(23,142)
    $details.Size=[System.Drawing.Size]::new(130,27)
    $details.Text='Details'
    $details.LinkColor=$accent
    $popup.Controls.Add($details)

    $close = [System.Windows.Forms.LinkLabel]::new()
    $close.Location=[System.Drawing.Point]::new(401,142)
    $close.Size=[System.Drawing.Size]::new(65,27)
    $close.Text='Close'
    $close.LinkColor=$accent
    $close.Tag=$popup
    $close.Add_LinkClicked({ param($sender,$e) $sender.Tag.Close() })
    $popup.Controls.Add($close)

    $info = [System.Windows.Forms.TextBox]::new()
    $info.Location=[System.Drawing.Point]::new(21,191)
    $info.Size=[System.Drawing.Size]::new(464,145)
    $info.Multiline=$true
    $info.ReadOnly=$true
    $info.WordWrap=$true
    $info.ScrollBars='Vertical'
    $info.BackColor=$bg
    $info.ForeColor=$fg
    $info.BorderStyle='FixedSingle'
    $info.Text="Action: Copy link to clipboard`r`nGame: $($script:lastCopy.Name)`r`nURL: $($script:lastCopy.Url)`r`nCompleted: $($script:lastCopy.Time)`r`nResult: Success"
    $info.Visible=$false
    $popup.Controls.Add($info)

    $details.Tag=[pscustomobject]@{ Window=$popup; Info=$info }
    $details.Add_LinkClicked({
        param($sender,$e)
        $window=$sender.Tag.Window
        $box=$sender.Tag.Info
        if ($box.Visible) {
            $box.Visible=$false
            $window.Height=220
        } else {
            $window.Height=365
            $box.Visible=$true
        }
    })
    $script:detailWindow = $popup
    $popup.Add_FormClosed({ $script:detailWindow=$null })
    $popup.Show()
    $popup.Activate()
}

function Copy-GameLink($game) {
    try {
        [System.Windows.Forms.Clipboard]::SetText([string]$game.Url)
    } catch {
        [System.Windows.Forms.MessageBox]::Show('Could not copy the URL. Please try again.','Trun Mega') | Out-Null
        return
    }
    $script:lastCopy = [pscustomobject]@{
        Name=$game.Name
        Url=$game.Url
        Time=(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }
    $status.Text='Copied: '+ $game.Name + '  -  The link is in your clipboard.'
    $openLast.Visible=$true
    # Windows handles where and how this notification appears.
    $tray.ShowBalloonTip(6000,'Trun Game Free Mega','Application executed. Link copied to clipboard! Click this notification to open the result.',[System.Windows.Forms.ToolTipIcon]::Info)
}

$tray.Add_BalloonTipClicked({ Show-CompletionWindow })
$openLast.Add_LinkClicked({ Show-CompletionWindow })

$y=18
$currentGroup=''
foreach ($game in $games) {
    if ($game.Group -ne $currentGroup) {
        $currentGroup=$game.Group
        $section=[System.Windows.Forms.Label]::new()
        $section.Location=[System.Drawing.Point]::new(24,$y)
        $section.Size=[System.Drawing.Size]::new(795,34)
        $section.Text='= ' + $currentGroup.ToUpperInvariant() + ' ='
        $section.Font=[System.Drawing.Font]::new('Segoe UI',13,[System.Drawing.FontStyle]::Bold)
        $section.ForeColor=$accent
        $content.Controls.Add($section)
        $y+=42
    }
    $link=[System.Windows.Forms.LinkLabel]::new()
    $link.AutoSize=$false
    $link.Location=[System.Drawing.Point]::new(34,$y)
    $link.Size=[System.Drawing.Size]::new(820,29)
    $link.Font=[System.Drawing.Font]::new('Segoe UI',10)
    $link.Text='Games for ' + $game.Name + ' - Link: ' + $game.Url
    $link.LinkColor=$fg
    $link.ActiveLinkColor=$accent
    $link.VisitedLinkColor=$fg
    $link.Tag=$game
    $link.Add_LinkClicked({ param($sender,$args) Copy-GameLink $sender.Tag })
    $content.Controls.Add($link)
    $y+=36
}

# Preserve the original creators and final message (not clickable).
$credits = @('Ruros','MEGA GERSON','Gerson Speed Minecraft','Dash X','Game Fun Mega','Night Friends','Jan Jan Boy','BunJun Fun LKJ','JJNS','No Game','Yafek JKS','Makerzin','Animazin','Club OBC','Club 2017 Neus','Club Mega ++')
$creatorTitle=[System.Windows.Forms.Label]::new()
$creatorTitle.Location=[System.Drawing.Point]::new(24,$y)
$creatorTitle.Size=[System.Drawing.Size]::new(790,36)
$creatorTitle.Text='= CREATED BY ='
$creatorTitle.Font=[System.Drawing.Font]::new('Segoe UI',13,[System.Drawing.FontStyle]::Bold)
$creatorTitle.ForeColor=$accent
$content.Controls.Add($creatorTitle)
$y+=40
foreach($creator in $credits) {
    $credit=[System.Windows.Forms.Label]::new()
    $credit.Location=[System.Drawing.Point]::new(34,$y)
    $credit.Size=[System.Drawing.Size]::new(770,25)
    $credit.Font=[System.Drawing.Font]::new('Segoe UI',10)
    $credit.ForeColor=$fg
    $credit.Text=[char]0x2022 + ' ' + $creator
    $content.Controls.Add($credit)
    $y+=27
}
$thanks=[System.Windows.Forms.Label]::new()
$thanks.Location=[System.Drawing.Point]::new(24,($y+12))
$thanks.Size=[System.Drawing.Size]::new(820,60)
$thanks.Font=[System.Drawing.Font]::new('Segoe UI',10,[System.Drawing.FontStyle]::Italic)
$thanks.ForeColor=$muted
$thanks.Text='Thanks for reading this far and for supporting us with this project!'
$content.Controls.Add($thanks)
$content.AutoScrollMinSize=[System.Drawing.Size]::new(0,($y+90))

$main.Add_FormClosed({
    if ($null -ne $script:detailWindow -and -not $script:detailWindow.IsDisposed) { $script:detailWindow.Close() }
    $tray.Visible=$false
    $tray.Dispose()
})
[System.Windows.Forms.Application]::Run($main)
