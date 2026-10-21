<#
.SYNOPSIS
    Windows equivalent of GNU Stow + Startup registration for dotfiles.
    Creates native Windows junctions/symlinks from $HOME into this dotfiles clone
    (zero cross-OS WSL links) and optionally registers WezTerm to launch at logon.

.EXAMPLE
    .\setup-windows.ps1
    .\setup-windows.ps1 -SkipStartupTask
    .\setup-windows.ps1 -UnregisterStartupTask
#>
[CmdletBinding()]
param(
    [switch]$SkipStartupTask,
    [switch]$UnregisterStartupTask
)

$ErrorActionPreference = 'Stop'
$DotfilesRoot = $PSScriptRoot
$TaskName = 'Dotfiles-WezTerm-Workspace'

function Set-DotfileLink {
    param(
        [Parameter(Mandatory)][string]$LinkPath,
        [Parameter(Mandatory)][string]$TargetPath,
        [Parameter(Mandatory)][ValidateSet('Junction', 'FileLink')][string]$Kind
    )

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        Write-Warning "Target does not exist, skipping: $TargetPath"
        return
    }

    $ParentDir = Split-Path -Parent $LinkPath
    if (-not (Test-Path -LiteralPath $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $LinkPath) {
        $existing = Get-Item -LiteralPath $LinkPath -Force
        if ($existing.LinkType) {
            $currentTarget = ($existing.Target | Select-Object -First 1)
            if ($currentTarget -and ((Resolve-Path -LiteralPath $currentTarget -ErrorAction SilentlyContinue).Path -eq (Resolve-Path -LiteralPath $TargetPath).Path)) {
                Write-Host "[OK] Already linked: $LinkPath -> $TargetPath" -ForegroundColor Green
                return
            }
            Remove-Item -LiteralPath $LinkPath -Force
        } else {
            $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            $backupPath = "$LinkPath.backup-$timestamp"
            Write-Host "[BACKUP] Moving existing $LinkPath -> $backupPath" -ForegroundColor Yellow
            Move-Item -LiteralPath $LinkPath -Destination $backupPath -Force
        }
    }

    if ($Kind -eq 'Junction') {
        New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
        Write-Host "[LINKED] (Junction) $LinkPath -> $TargetPath" -ForegroundColor Cyan
    } else {
        try {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
            Write-Host "[LINKED] (SymbolicLink) $LinkPath -> $TargetPath" -ForegroundColor Cyan
        } catch {
            New-Item -ItemType HardLink -Path $LinkPath -Target $TargetPath | Out-Null
            Write-Host "[LINKED] (HardLink) $LinkPath -> $TargetPath" -ForegroundColor Cyan
        }
    }
}

Write-Host "=== Linking Windows Dotfiles from $DotfilesRoot ===" -ForegroundColor Magenta

# 1. Directory Junctions (No Admin privileges required)
Set-DotfileLink -LinkPath "$HOME\.config\wezterm" `
                -TargetPath (Join-Path $DotfilesRoot 'wezterm\.config\wezterm') `
                -Kind 'Junction'

Set-DotfileLink -LinkPath "$env:LOCALAPPDATA\nvim" `
                -TargetPath (Join-Path $DotfilesRoot 'nvim\.config\nvim') `
                -Kind 'Junction'

Set-DotfileLink -LinkPath "$HOME\.copilot\skills" `
                -TargetPath (Join-Path $DotfilesRoot 'copilot\.copilot\skills') `
                -Kind 'Junction'

# 2. File Links
Set-DotfileLink -LinkPath "$HOME\.tmux.conf" `
                -TargetPath (Join-Path $DotfilesRoot 'tmux\.tmux.conf') `
                -Kind 'FileLink'

Set-DotfileLink -LinkPath "$HOME\.gitconfig" `
                -TargetPath (Join-Path $DotfilesRoot 'git\.gitconfig') `
                -Kind 'FileLink'

Set-DotfileLink -LinkPath "$HOME\.copilot\mcp-config.json" `
                -TargetPath (Join-Path $DotfilesRoot 'copilot\.copilot\mcp-config.json') `
                -Kind 'FileLink'

# 3. Startup Task (Task Scheduler OnLogon -> WezTerm Workspace)
if ($UnregisterStartupTask) {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "[REMOVED] Scheduled Task '$TaskName'" -ForegroundColor Yellow
    } else {
        Write-Host "[INFO] Scheduled Task '$TaskName' is not registered." -ForegroundColor Gray
    }
    return
}

if (-not $SkipStartupTask) {
    $WezTermGui = 'C:\Program Files\WezTerm\wezterm-gui.exe'
    if (-not (Test-Path -LiteralPath $WezTermGui)) {
        $cmd = Get-Command wezterm-gui.exe -ErrorAction SilentlyContinue
        if ($cmd) { $WezTermGui = $cmd.Source }
    }

    if (Test-Path -LiteralPath $WezTermGui) {
        $Action = New-ScheduledTaskAction -Execute $WezTermGui -WorkingDirectory $HOME
        $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
                                                 -DontStopIfGoingOnBatteries `
                                                 -ExecutionTimeLimit ([TimeSpan]::Zero)
        Register-ScheduledTask -TaskName $TaskName `
                               -Action $Action `
                               -Trigger $Trigger `
                               -Settings $Settings `
                               -Description 'Launches WezTerm multi-OS development workspace defined in dotfiles/wezterm/.config/wezterm/workspaces.json' `
                               -Force | Out-Null
        Write-Host "[TASK] Registered logon task '$TaskName' -> $WezTermGui" -ForegroundColor Green
    } else {
        Write-Warning "wezterm-gui.exe not found; skipped logon task registration."
    }
}

Write-Host "=== Setup Complete ===" -ForegroundColor Magenta
