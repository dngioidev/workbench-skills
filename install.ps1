<#
.SYNOPSIS
    Install workbench skills for Claude Code.
.DESCRIPTION
    Copies every skill in skills/ into ~/.claude/skills (global) or <project>/.claude/skills
    (project). Re-run to update; use -Uninstall to remove. When not run from a clone, downloads
    the repo archive from GitHub.
.EXAMPLE
    ./install.ps1 -Scope project -Path D:\my-app
.EXAMPLE
    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/dngioidev/workbench-skills/main/install.ps1))) -Scope global
#>
[CmdletBinding()]
param(
    [string]$Scope,
    [string]$Path,
    [string]$Ref = 'main',
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$Repo = 'dngioidev/workbench-skills'
# Only set an exit code when run as a file; under `irm | iex`, exit would close the user's console.
$RunAsFile = $MyInvocation.MyCommand.CommandType -eq 'ExternalScript'
$LocalSkills = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'skills' } else { $null }

function Test-Interactive {
    if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) { return $false }
    $nonInteractive = [Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-noni*' }
    return -not $nonInteractive
}

function Resolve-Scope([string]$Value, [string]$ProjectPath) {
    if ($Value) { return $Value }
    if (-not (Test-Interactive)) {
        throw "no -Scope given and no console to ask. Re-run with: & ([scriptblock]::Create((irm https://raw.githubusercontent.com/$Repo/main/install.ps1))) -Scope global"
    }
    $here = if ($ProjectPath) { $ProjectPath } else { (Get-Location).Path }
    Write-Host 'Install workbench skills to:'
    Write-Host '  [1] Global  (~/.claude/skills)'
    Write-Host "  [2] Project ($here/.claude/skills)"
    switch (Read-Host 'Choice [1/2]') {
        '1' { return 'global' }
        '2' { return 'project' }
        default { throw 'invalid choice (expected 1 or 2)' }
    }
}

function Resolve-Target([string]$ScopeValue, [string]$ProjectPath) {
    switch ($ScopeValue) {
        'global' { return Join-Path (Join-Path $HOME '.claude') 'skills' }
        'project' {
            if (-not $ProjectPath) { $ProjectPath = (Get-Location).Path }
            if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
                throw "project path does not exist: $ProjectPath"
            }
            $root = (Resolve-Path -LiteralPath $ProjectPath).ProviderPath
            return Join-Path (Join-Path $root '.claude') 'skills'
        }
        default { throw "invalid scope: '$ScopeValue' (expected global or project)" }
    }
}

function Get-RemoteSkills([string]$GitRef, [string]$Temp) {
    $archive = if ($env:WORKBENCH_ARCHIVE) { $env:WORKBENCH_ARCHIVE } else { "https://github.com/$Repo/archive/$GitRef.zip" }
    $zip = Join-Path $Temp 'src.zip'
    Write-Host "Downloading $archive"
    try {
        if (Test-Path -LiteralPath $archive -PathType Leaf) {
            Copy-Item -LiteralPath $archive -Destination $zip
        } else {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $archive -OutFile $zip -UseBasicParsing
        }
    } catch {
        throw "download failed: $archive ($($_.Exception.Message))"
    }
    try {
        Expand-Archive -LiteralPath $zip -DestinationPath $Temp -Force
    } catch {
        throw "could not extract archive: $($_.Exception.Message)"
    }
    foreach ($dir in Get-ChildItem -LiteralPath $Temp -Directory) {
        $candidate = Join-Path $dir.FullName 'skills'
        if (Test-Path -LiteralPath $candidate -PathType Container) { return $candidate }
    }
    throw 'archive has no skills/ directory'
}

function Invoke-Main {
    $scopeValue = Resolve-Scope $Scope $Path
    $target = Resolve-Target $scopeValue $Path
    $temp = $null
    try {
        if ($LocalSkills -and (Test-Path -LiteralPath $LocalSkills -PathType Container)) {
            $source = $LocalSkills
        } else {
            $temp = Join-Path ([IO.Path]::GetTempPath()) ('workbench-skills-' + [guid]::NewGuid())
            New-Item -ItemType Directory -Path $temp | Out-Null
            $source = Get-RemoteSkills $Ref $temp
        }

        $skills = @(Get-ChildItem -LiteralPath $source -Directory |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') })
        if ($skills.Count -eq 0) { throw "no skills found in $source" }

        if ($Uninstall) {
            $removed = 0
            foreach ($skill in $skills) {
                $dest = Join-Path $target $skill.Name
                if (Test-Path -LiteralPath $dest) {
                    Remove-Item -LiteralPath $dest -Recurse -Force
                    Write-Host "  removed $($skill.Name)"
                    $removed++
                }
            }
            Write-Host "Removed $removed skill(s) from $target"
        } else {
            try {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
            } catch {
                throw "cannot create target: $target"
            }
            foreach ($skill in $skills) {
                $dest = Join-Path $target $skill.Name
                if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
                Copy-Item -LiteralPath $skill.FullName -Destination $dest -Recurse
                Write-Host "  installed $($skill.Name)"
            }
            Write-Host "Installed $($skills.Count) skill(s) to $target"
            if ($scopeValue -eq 'project') {
                Write-Host 'Tip: commit .claude/skills/ to share these skills with your team.'
            }
        }
    } finally {
        if ($temp -and (Test-Path -LiteralPath $temp)) { Remove-Item -LiteralPath $temp -Recurse -Force }
    }
}

$failed = $false
try {
    Invoke-Main
} catch {
    Write-Host "error: $($_.Exception.Message)" -ForegroundColor Red
    $failed = $true
}
if ($failed -and $RunAsFile) { exit 1 }
