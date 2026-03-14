
$RepoUrl = "https://github.com/AlexKutz/win-dotfiles.git"
$DotfilesDir = Join-Path $HOME "win-dotfiles"

Write-Host "=== Configuring work environment ===" -ForegroundColor Cyan

# 1. Install scoop
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "`n[1/5] Installing scoop..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "`n[1/5] Scoop is already installed." -ForegroundColor Green
}

scoop bucket add extras | Out-Null

# 2. Install git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "`n[2/5] Installing git..." -ForegroundColor Yellow
    scoop install git
} else {
    Write-Host "`n[2/5] Git already installed." -ForegroundColor Green
}

# 3. Cloning my dotfiles repo
Write-Host "`n[3/5] Loading dotfiles from github..." -ForegroundColor Yellow
if (Test-Path $DotfilesDir) {
    Write-Host "HOME/win-dotfiles already exists. Updating repo..." -ForegroundColor DarkGray
    Set-Location $DotfilesDir
    git pull
} else {
    git clone $RepoUrl $DotfilesDir
}

# 4. Packages for install
$packages = @("fzf", "zoxide", "neovim", "bun", "bat", "eza")

Write-Host "`n[4/5] Available packages for install via scoop:" -ForegroundColor Yellow
for ($i = 0; $i -lt $packages.Length; $i++) {
    Write-Host "$($i + 1). $($packages[$i])"
}

$selection = Read-Host "`nEnter packages number divided by comma (also can 'all' or 'none')"
$toInstall = @()

if ($selection -eq 'all') {
    $toInstall = $packages
} elseif ($selection -ne 'none' -and !([string]::IsNullOrWhiteSpace($selection))) {
    $indices = $selection -split ',' | ForEach-Object { $_.Trim() }
    foreach ($index in $indices) {
        $idx = [int]$index - 1
        if ($idx -ge 0 -and $idx -lt $packages.Length) {
            $toInstall += $packages[$idx]
        }
    }
}

if ($toInstall.Count -gt 0) {
    Write-Host "Installing: $($toInstall -join ', ')..." -ForegroundColor Cyan
    scoop install $toInstall
}

# 5. Creating symbolic links
Write-Host "`n[5/5] Creating symbolic links..." -ForegroundColor Yellow

function New-Symlink {
    param([string]$TargetFile, [string]$LinkPath)
    
    if ((Test-Path $LinkPath) -and !((Get-Item $LinkPath).LinkType)) {
        $bakPath = "$LinkPath.bak"
        Write-Host "  Created existing file backup: $bakPath" -ForegroundColor DarkGray
        Rename-Item -Path $LinkPath -NewName (Split-Path $bakPath -Leaf) -Force
    }

    $parentDir = Split-Path $LinkPath -Parent
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetFile -Force | Out-Null
        Write-Host "  [OK] Link created: $LinkPath -> $TargetFile" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Failed to create link $LinkPath. Windows Developer Mode or admin privileges are required." -ForegroundColor Red
    }
}

# Link for PowerShell
$RepoProfilePath = Join-Path $DotfilesDir "powershell\profile.ps1"
if (Test-Path $RepoProfilePath) {
    New-Symlink -TargetFile $RepoProfilePath -LinkPath $PROFILE
} else {
    Write-Host "  Powershell profile not found in repo: $RepoProfilePath" -ForegroundColor Red
}

# Link for neov
# $RepoNvimPath = Join-Path $DotfilesDir "nvim"
# $LocalNvimPath = Join-Path $HOME "AppData\Local\nvim"
# if (Test-Path $RepoNvimPath) {
#     New-Symlink -TargetFile $RepoNvimPath -LinkPath $LocalNvimPath
# }

Write-Host "`nAll done! Restart powerShell." -ForegroundColor Green
