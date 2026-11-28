# Native WinForms status dialog used for installation and fatal errors.
# The Read More action opens an independent details window. No web browser.
function Show-BuildResult {
    param(
        [ValidateSet('Success','Fatal')][string]$Status,
        [string]$Summary,
        [string]$Details = ''
    )
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $dark = [System.Drawing.ColorTranslator]::FromHtml('#181119')
        $panel = [System.Drawing.ColorTranslator]::FromHtml('#261A26')
        $bright = [System.Drawing.ColorTranslator]::FromHtml('#F0495C')
        $light = [System.Drawing.ColorTranslator]::FromHtml('#F8F3F7')
        $subtle = [System.Drawing.ColorTranslator]::FromHtml('#BCADBA')
        $success = ($Status -eq 'Success')
        $heading = if ($success) { 'BUILD SUCCESS' } else { 'BUILD FATAL ERROR' }
        $dlg = New-Object System.Windows.Forms.Form
        $dlg.Text = 'Trun Game Free Mega 2.2 - ' + $heading
        $dlg.BackColor = $dark; $dlg.ForeColor = $light
        $dlg.FormBorderStyle = 'FixedDialog'; $dlg.MaximizeBox = $false
        $dlg.MinimizeBox = $false; $dlg.StartPosition = 'CenterScreen'
        $dlg.ClientSize = [System.Drawing.Size]::new(520,246)
        $dlg.Font = [System.Drawing.Font]::new('Segoe UI',10)
        $h = New-Object System.Windows.Forms.Label
        $h.Text = $heading; $h.Font = [System.Drawing.Font]::new('Segoe UI',20,[System.Drawing.FontStyle]::Bold)
        $h.ForeColor = if($success){ $light } else { $bright }
        $h.Location = [System.Drawing.Point]::new(25,24)
        $h.Size = [System.Drawing.Size]::new(465,43)
        $dlg.Controls.Add($h)
        $summaryLabel = New-Object System.Windows.Forms.Label
        $summaryLabel.Text = $Summary
        $summaryLabel.ForeColor = $subtle
        $summaryLabel.Location = [System.Drawing.Point]::new(27,78)
        $summaryLabel.Size = [System.Drawing.Size]::new(464,80)
        $summaryLabel.AutoEllipsis = $true
        $dlg.Controls.Add($summaryLabel)
        $detailsButton = New-Object System.Windows.Forms.Button
        $detailsButton.Text = 'Read More'
        $detailsButton.Location = [System.Drawing.Point]::new(27,179)
        $detailsButton.Size = [System.Drawing.Size]::new(139,43)
        $detailsButton.FlatStyle = 'Flat'; $detailsButton.FlatAppearance.BorderColor = $bright
        $detailsButton.ForeColor = $light; $detailsButton.BackColor = $panel
        $detailsButton.Add_Click(({
            $detailWindow = New-Object System.Windows.Forms.Form
            $detailWindow.Text = 'Trun Game Free Mega - Build Details'
            $detailWindow.BackColor = $dark; $detailWindow.ForeColor = $light
            $detailWindow.StartPosition = 'CenterParent'
            $detailWindow.ClientSize = [System.Drawing.Size]::new(750,470)
            $detailWindow.MinimumSize = [System.Drawing.Size]::new(520,340)
            $detailWindow.Font = [System.Drawing.Font]::new('Segoe UI',10)
            $text = New-Object System.Windows.Forms.TextBox
            $text.Multiline = $true; $text.ReadOnly = $true
            $text.ScrollBars = 'Both'; $text.WordWrap = $false
            $text.Dock = 'Fill'; $text.BackColor = $panel; $text.ForeColor = $light
            $text.Font = [System.Drawing.Font]::new('Consolas',10)
            $text.Text = $heading + "`r`n`r`n" + $Summary + "`r`n`r`n" + $Details
            $buttons = New-Object System.Windows.Forms.Panel
            $buttons.Dock = 'Bottom'; $buttons.Height = 54
            $copyButton = New-Object System.Windows.Forms.Button
            $copyButton.Text = 'Copy Details'; $copyButton.Size = [System.Drawing.Size]::new(135,35)
            $copyButton.Location = [System.Drawing.Point]::new(12,10)
            $copyButton.Add_Click(({ [System.Windows.Forms.Clipboard]::SetText($text.Text) }).GetNewClosure())
            $buttons.Controls.Add($copyButton)
            $detailWindow.Controls.Add($text); $detailWindow.Controls.Add($buttons)
            [void]$detailWindow.ShowDialog($dlg)
            $detailWindow.Dispose()
        }).GetNewClosure())
        $dlg.Controls.Add($detailsButton)
        $closeButton = New-Object System.Windows.Forms.Button
        $closeButton.Text = 'Close'; $closeButton.Size = [System.Drawing.Size]::new(119,43)
        $closeButton.Location = [System.Drawing.Point]::new(368,179)
        $closeButton.BackColor = $bright; $closeButton.ForeColor = $light
        $closeButton.FlatStyle = 'Flat'; $closeButton.FlatAppearance.BorderSize = 0
        $closeButton.Add_Click(({ $dlg.Close() }).GetNewClosure())
        $dlg.Controls.Add($closeButton)
        [void]$dlg.ShowDialog(); $dlg.Dispose()
    } catch {
        # Keep the original build result even if the status UI cannot initialize.
        Write-Host ('[STATUS UI ERROR] ' + $_.Exception.Message)
        Write-Host ($Status + ': ' + $Summary)
        Write-Host $Details
    }
}
