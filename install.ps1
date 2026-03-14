$RepoUrl = "https://github.com/AlexKutz/win-dotfiles.git"
$DotfilesDir = Join-Path $HOME "win-dotfiles"

Write-Host "=== Настройка рабочего окружения ===" -ForegroundColor Cyan

# 1. Проверка и установка Scoop
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "`n[1/5] Установка Scoop..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "`n[1/5] Scoop уже установлен." -ForegroundColor Green
}

if (!(scoop bucket list | Select-String "extras" -Quiet)) {
    scoop bucket add extras | Out-Null
}

# 2. Проверка и настройка Git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "`n[2/5] Установка Git..." -ForegroundColor Yellow
    scoop install git
} else {
    Write-Host "`n[2/5] Git уже установлен." -ForegroundColor Green
}

Write-Host "  Применение глобальных настроек Git..." -ForegroundColor DarkGray
git config --global user.email "kurtzalexo@gmail.com"
git config --global user.name "alexander kutson"
git config --global init.defaultBranch main
git config --global core.quotepath false
git config --global i18n.commitEncoding utf-8
git config --global i18n.logOutputEncoding utf-8

# 3. Клонирование репозитория
Write-Host "`n[3/5] Загрузка конфигурационных файлов..." -ForegroundColor Yellow
if (Test-Path $DotfilesDir) {
    Write-Host "Папка win-dotfiles уже существует. Синхронизируем с GitHub..." -ForegroundColor DarkGray
    Set-Location $DotfilesDir
    git fetch --all | Out-Null
    git reset --hard origin/main | Out-Null
} else {
    git clone $RepoUrl $DotfilesDir
}

# 4. Установка пакетов
$packages = @("fzf", "zoxide", "neovim", "bun", "bat", "eza", "terminal-icons")

Write-Host "`n[4/5] Доступные пакеты для установки через Scoop:" -ForegroundColor Yellow
for ($i = 0; $i -lt $packages.Length; $i++) {
    Write-Host "$($i + 1). $($packages[$i])"
}

$selection = Read-Host "`nВведите номера пакетов через запятую (или 'all' для всех, 'none' для пропуска)"
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
    Write-Host "Устанавливаем: $($toInstall -join ', ')..." -ForegroundColor Cyan
    scoop install $toInstall
}

# 5. Создание символических ссылок
Write-Host "`n[5/5] Настройка символических ссылок..." -ForegroundColor Yellow

function New-Symlink {
    param([string]$TargetFile, [string]$LinkPath)
    
    if ((Test-Path $LinkPath) -and !((Get-Item $LinkPath).LinkType)) {
        $bakPath = "$LinkPath.bak"
        Write-Host "  Создан бэкап существующего файла: $bakPath" -ForegroundColor DarkGray
        Rename-Item -Path $LinkPath -NewName (Split-Path $bakPath -Leaf) -Force
    }

    $parentDir = Split-Path $LinkPath -Parent
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetFile -Force | Out-Null
        Write-Host "  [OK] Ссылка создана: $LinkPath -> $TargetFile" -ForegroundColor Green
    } catch {
        Write-Host "  [ОШИБКА] Не удалось создать ссылку $LinkPath. Требуется режим разработчика Windows или права администратора." -ForegroundColor Red
    }
}

# Обновленный путь к файлу PowerShell
$RepoProfilePath = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $RepoProfilePath) {
    New-Symlink -TargetFile $RepoProfilePath -LinkPath $PROFILE
} else {
    Write-Host "  Файл профиля не найден в репозитории: $RepoProfilePath" -ForegroundColor Red
}

Write-Host "`nГотово! Перезапустите PowerShell." -ForegroundColor Green
