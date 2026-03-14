$RepoUrl = "https://github.com/AlexKutz/win-dotfiles.git"
$DotfilesDir = Join-Path $HOME "win-dotfiles"

Write-Host "=== Настройка рабочего окружения ===" -ForegroundColor Cyan

# 1. Проверка и установка Scoop
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "`n[1/6] Установка Scoop..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "`n[1/6] Scoop уже установлен." -ForegroundColor Green
}

# Добавляем нужные бакеты (extras для утилит, nerd-fonts для шрифтов)
Write-Host "  Проверка бакетов Scoop (extras, nerd-fonts)..." -ForegroundColor DarkGray
if (!(scoop bucket list | Select-String "extras" -Quiet)) {
    scoop bucket add extras | Out-Null
}
if (!(scoop bucket list | Select-String "nerd-fonts" -Quiet)) {
    scoop bucket add nerd-fonts | Out-Null
}

# 2. Проверка и настройка Git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "`n[2/6] Установка Git..." -ForegroundColor Yellow
    scoop install git
} else {
    Write-Host "`n[2/6] Git уже установлен." -ForegroundColor Green
}

Write-Host "  Применение глобальных настроек Git..." -ForegroundColor DarkGray
git config --global user.email "kurtzalexo@gmail.com"
git config --global user.name "alexander kutson"
git config --global init.defaultBranch main
git config --global core.quotepath false
git config --global i18n.commitEncoding utf-8
git config --global i18n.logOutputEncoding utf-8

# 3. Клонирование репозитория
Write-Host "`n[3/6] Загрузка конфигурационных файлов..." -ForegroundColor Yellow
if (Test-Path $DotfilesDir) {
    Write-Host "  Папка win-dotfiles уже существует. Синхронизируем с GitHub..." -ForegroundColor DarkGray
    Set-Location $DotfilesDir
    git fetch --all | Out-Null
    git reset --hard origin/main | Out-Null
} else {
    git clone $RepoUrl $DotfilesDir
}

# 4. Установка пакетов
$packages = @("fzf", "zoxide", "neovim", "bun", "bat", "eza", "fd", "fnm", "JetBrainsMono-NF")

Write-Host "`n[4/6] Доступные пакеты для установки через Scoop:" -ForegroundColor Yellow
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

# 5. Установка модулей PowerShell
Write-Host "`n[5/6] Установка модулей PowerShell..." -ForegroundColor Yellow
if (!(Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "  Устанавливаем Terminal-Icons..." -ForegroundColor Cyan
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force
} else {
    Write-Host "  Terminal-Icons уже установлен." -ForegroundColor Green
}

# 6. Создание символических ссылок
Write-Host "`n[6/6] Настройка символических ссылок..." -ForegroundColor Yellow

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

$RepoProfilePath = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $RepoProfilePath) {
    New-Symlink -TargetFile $RepoProfilePath -LinkPath $PROFILE
} else {
    Write-Host "  Файл профиля не найден в репозитории: $RepoProfilePath" -ForegroundColor Red
}

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "Готово! Установка завершена." -ForegroundColor Green
Write-Host "ВАЖНО: Чтобы иконки Terminal-Icons отображались корректно," -ForegroundColor Magenta
Write-Host "откройте настройки Windows Terminal (Ctrl + ,) -> Профили ->" -ForegroundColor Magenta
Write-Host "Оформление и выберите шрифт 'JetBrainsMono NF' (или другой Nerd Font)." -ForegroundColor Magenta
Write-Host "После этого перезапустите терминал." -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Cyan
