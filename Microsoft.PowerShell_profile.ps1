# 引入 ps-read-line
Import-Module PSReadLine
# 引入 posh-git
Import-Module posh-git
# 引入 Z
Import-Module Z
# 引入 PSFzf
Import-Module PSFzf

Import-Module (Get-Command 'gsudoModule.psd1').Source

Set-alias 'sudo' 'gsudo'

Invoke-Expression (&starship init powershell)
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin.omp.json" | Invoke-Expression
oh-my-posh init pwsh --config "C:\Users\Administrator\Documents\PowerShell\my_catppuccin.omp.json" | Invoke-Expression
# 设置预测文本来源为历史记录
Set-PSReadLineOption -PredictionSource History
# # 每次回溯输入历史，光标定位于输入内容末尾
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# # 设置 Tab 为菜单补全和 Intellisense
Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+p" -Function HistorySearchBackward # 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function HistorySearchForward # 设置向下键为前向搜索历史纪录

# eza
function Get-DirectoryContent
{
  eza --classify --color-scale --icons=always --group-directories-first --time-style iso @args
}
Remove-Alias -Name ls
New-Alias -Name ls -Value Get-DirectoryContent
function Get-DetailedDirectoryContent
{
  Get-DirectoryContent --long @args
}
New-Alias -Name ll -Value Get-DetailedDirectoryContent
function Get-GitIgnoredDirectoryContent
{
  Get-DirectoryContent --git-ignore --git --git-repos @args
}
New-Alias -Name lsg -Value Get-GitIgnoredDirectoryContent
function Get-DetialedGitIgnoredDirectoryContent
{
  Get-GitIgnoredDirectoryContent --long @args
}
New-Alias -Name llg -Value Get-DetialedGitIgnoredDirectoryContent

# psfzf
Set-PsFzfOption -PSReadLineChordProvider ‘Ctrl+f’ -PSReadLineChordReverseHistory ‘Ctrl+r’
# fzf
$Env:FZF_DEFAULT_COMMAND = 'fd --hidden --follow 
-E ".git"  
-E "node_modules" 
-E ".cache" '
$Env:FZF_DEFAULT_OPTS = '--height 90% 
--layout=reverse 
--bind=alt-j:down,alt-k:up,alt-i:toggle+down 
--border 
--preview "bat --color=always --style=numbers --line-range=:500 {}" 
--color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
$Env:CMAKE_GENERATOR='MinGW Makefiles'

Set-PSReadlineKeyHandler -Chord "Ctrl+f" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cd "$(fzf)\.."')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
Set-PSReadlineKeyHandler -Chord "Ctrl+e" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('$fzfAndVim = fzf ; cd $fzfAndVim\.. ; nvim ($fzfAndVim -split "\\" | tail -1)')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadlineKeyHandler -Chord "Ctrl+o" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('explorer .')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadlineKeyHandler -Chord "Ctrl+g" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('lazygit')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

function ya
{
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
  {
    Set-Location -Path $cwd
  }
  Remove-Item -Path $tmp
}

# Import the module
Import-Module Catppuccin

# Set a flavor for easy access
$Flavor = $Catppuccin['Mocha']

# Print a summary of the flavor's colors
# Returns Null, calls Write-Host internally.
# $Flavor.Table()

# Print blocks of the flavor's colors
# Returns a string
# Write-Host $Flavor.Blocks()

$Colors = @{
  # Largely based on the Code Editor style guide
  # Emphasis, ListPrediction and ListPredictionSelected are inspired by the Catppuccin fzf theme
	
  # Powershell colours
  ContinuationPrompt     = $Flavor.Teal.Foreground()
  Emphasis               = $Flavor.Red.Foreground()
  Selection              = $Flavor.Surface0.Background()
	
  # PSReadLine prediction colours
  InlinePrediction       = $Flavor.Overlay0.Foreground()
  ListPrediction         = $Flavor.Mauve.Foreground()
  ListPredictionSelected = $Flavor.Surface0.Background()

  # Syntax highlighting
  Command                = $Flavor.Blue.Foreground()
  Comment                = $Flavor.Overlay0.Foreground()
  Default                = $Flavor.Text.Foreground()
  Error                  = $Flavor.Red.Foreground()
  Keyword                = $Flavor.Mauve.Foreground()
  Member                 = $Flavor.Rosewater.Foreground()
  Number                 = $Flavor.Peach.Foreground()
  Operator               = $Flavor.Sky.Foreground()
  Parameter              = $Flavor.Pink.Foreground()
  String                 = $Flavor.Green.Foreground()
  Type                   = $Flavor.Yellow.Foreground()
  Variable               = $Flavor.Lavender.Foreground()
}

# Set the colours
Set-PSReadLineOption -Colors $Colors

# The following colors are used by PowerShell's formatting
# Again PS 7.2+ only
$PSStyle.Formatting.Debug = $Flavor.Sky.Foreground()
$PSStyle.Formatting.Error = $Flavor.Red.Foreground()
$PSStyle.Formatting.ErrorAccent = $Flavor.Blue.Foreground()
$PSStyle.Formatting.FormatAccent = $Flavor.Teal.Foreground()
$PSStyle.Formatting.TableHeader = $Flavor.Rosewater.Foreground()
$PSStyle.Formatting.Verbose = $Flavor.Yellow.Foreground()
$PSStyle.Formatting.Warning = $Flavor.Peach.Foreground()

