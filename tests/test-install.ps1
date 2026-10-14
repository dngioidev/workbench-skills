# Smoke tests for install.ps1. Run: powershell -NoProfile -File tests/test-install.ps1
$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repo 'install.ps1'
$ps = (Get-Process -Id $PID).Path
$work = Join-Path ([IO.Path]::GetTempPath()) ('wb-test-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $work | Out-Null
$script:failures = 0

function Check([string]$Name, [bool]$Ok) {
    if ($Ok) { Write-Host "PASS $Name" } else { Write-Host "FAIL $Name"; $script:failures++ }
}

# Runs a script in a fresh non-interactive process and returns its output; exit code is in $LASTEXITCODE.
function Invoke-Ps([string[]]$Arguments) {
    & $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File @Arguments | Out-String
}

$skills = @(Get-ChildItem -LiteralPath (Join-Path $repo 'skills') -Directory | ForEach-Object { $_.Name })

function Test-AllInstalled([string]$Dir) {
    foreach ($s in $skills) {
        if (-not (Test-Path -LiteralPath (Join-Path (Join-Path $Dir $s) 'SKILL.md'))) { return $false }
    }
    return $true
}

function Test-NoneInstalled([string]$Dir) {
    foreach ($s in $skills) {
        if (Test-Path -LiteralPath (Join-Path $Dir $s)) { return $false }
    }
    return $true
}

try {
    # Project install into a path with a space, next to a foreign skill
    $proj = Join-Path $work 'my project'
    $target = Join-Path (Join-Path $proj '.claude') 'skills'
    $foreign = Join-Path $target 'foreign'
    New-Item -ItemType Directory -Path $foreign -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $foreign 'SKILL.md') -Value 'keep'

    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj) | Out-Null
    Check 'project install exits 0' ($LASTEXITCODE -eq 0)
    Check 'project install copies every skill' (Test-AllInstalled $target)
    Check 'foreign skill survives install' (Test-Path -LiteralPath (Join-Path $foreign 'SKILL.md'))

    # Re-run replaces a modified file
    $first = $skills[0]
    $installedFile = Join-Path (Join-Path $target $first) 'SKILL.md'
    $sourceFile = Join-Path (Join-Path (Join-Path $repo 'skills') $first) 'SKILL.md'
    Set-Content -LiteralPath $installedFile -Value 'tampered'
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj) | Out-Null
    Check 're-run exits 0' ($LASTEXITCODE -eq 0)
    Check 're-run restores modified file' ((Get-FileHash -LiteralPath $installedFile).Hash -eq (Get-FileHash -LiteralPath $sourceFile).Hash)

    # Uninstall
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj, '-Uninstall') | Out-Null
    Check 'uninstall exits 0' ($LASTEXITCODE -eq 0)
    Check 'uninstall removes repo skills' (Test-NoneInstalled $target)
    Check 'uninstall keeps foreign skill' (Test-Path -LiteralPath (Join-Path $foreign 'SKILL.md'))
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj, '-Uninstall') | Out-Null
    Check 'uninstall with nothing installed exits 0' ($LASTEXITCODE -eq 0)
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $work, '-Uninstall') | Out-Null
    Check 'uninstall with missing target exits 0' ($LASTEXITCODE -eq 0)

    # Global install writes under the user's home ($HOME comes from USERPROFILE on Windows, HOME elsewhere)
    $fakeHome = Join-Path $work 'home'
    New-Item -ItemType Directory -Path $fakeHome | Out-Null
    $savedProfile = $env:USERPROFILE
    $savedHome = $env:HOME
    $env:USERPROFILE = $fakeHome
    $env:HOME = $fakeHome
    Invoke-Ps @($installer, '-Scope', 'global') | Out-Null
    $globalCode = $LASTEXITCODE
    $env:USERPROFILE = $savedProfile
    $env:HOME = $savedHome
    Check 'global install exits 0' ($globalCode -eq 0)
    Check 'global install writes under home' (Test-AllInstalled (Join-Path (Join-Path $fakeHome '.claude') 'skills'))

    # Bad input
    Invoke-Ps @($installer, '-Scope', 'nowhere') | Out-Null
    Check 'invalid scope fails' ($LASTEXITCODE -eq 1)
    $missing = Join-Path $work 'nope'
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $missing) | Out-Null
    Check 'missing project path fails' ($LASTEXITCODE -eq 1)
    Check 'missing project path creates nothing' (-not (Test-Path -LiteralPath $missing))
    $out = Invoke-Ps @($installer)
    Check 'no scope without a console fails' ($LASTEXITCODE -eq 1)
    Check 'no scope message names -Scope' ($out -match 'no -Scope given')

    # Remote mode: scriptblock form, wrapper lives in $work so there is no local skills/
    $pkg = Join-Path (Join-Path $work 'pkg') 'workbench-skills-main'
    New-Item -ItemType Directory -Path $pkg -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repo 'skills') -Destination $pkg -Recurse
    $zip = Join-Path $work 'archive.zip'
    Compress-Archive -Path $pkg -DestinationPath $zip

    $sbWrapper = Join-Path $work 'run-scriptblock.ps1'
    Set-Content -LiteralPath $sbWrapper -Value @'
param($Archive, $Installer, $Target)
$env:WORKBENCH_ARCHIVE = $Archive
& ([scriptblock]::Create((Get-Content -Raw -LiteralPath $Installer))) -Scope project -Path $Target
'@
    $remote = Join-Path $work 'remote'
    New-Item -ItemType Directory -Path $remote | Out-Null
    Invoke-Ps @($sbWrapper, $zip, $installer, $remote) | Out-Null
    Check 'scriptblock remote install copies every skill' (Test-AllInstalled (Join-Path (Join-Path $remote '.claude') 'skills'))

    $broken = Join-Path $work 'broken'
    New-Item -ItemType Directory -Path $broken | Out-Null
    $out = Invoke-Ps @($sbWrapper, (Join-Path $work 'missing.zip'), $installer, $broken)
    Check 'missing archive reports download failed' ($out -match 'download failed')
    Check 'missing archive installs nothing' (Test-NoneInstalled (Join-Path (Join-Path $broken '.claude') 'skills'))

    # irm | iex form: must parse and fail cleanly when it cannot prompt
    $iexWrapper = Join-Path $work 'run-iex.ps1'
    Set-Content -LiteralPath $iexWrapper -Value @'
param($Installer)
Get-Content -Raw -LiteralPath $Installer | Invoke-Expression
'@
    $out = Invoke-Ps @($iexWrapper, $installer)
    Check 'iex form parses and asks for -Scope' ($out -match 'no -Scope given')
}
finally {
    Remove-Item -LiteralPath $work -Recurse -Force
}

if ($script:failures -gt 0) {
    Write-Host "$($script:failures) test(s) failed"
    exit 1
}
Write-Host 'All tests passed'
