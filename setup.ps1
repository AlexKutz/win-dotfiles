# ====================================================================
# Настройка окружения PowerShell 7
# ====================================================================

# 🔴 ВАЖНО: Замените эту ссылку на RAW URL вашего файла профиля на GitHub
$ProfileRawUrl = "https://raw.githubusercontent.com/alexkutz/win-dotfiles/main/powershell/Microsoft.PowerShell_profile.ps1"

# Список доступных пакетов (можете добавлять свои)
$AvailablePackages = @(
    "zoxide",
    "fzf",
    "starship",
    "bat",
    "neovim",
    "git"
)

Write-Host "=== Автоматическая настройка PowerShell 7 ===" -ForegroundColor Cyan

# --- Шаг 1: Интерактивный выбор пакетов ---
Write-Host "`nДоступные пакеты Scoop для установки:" -ForegroundColor Yellow
for ($i = 0; $i -lt $AvailablePackages.Count; $i++) {
    Write-Host "[$($i + 1)] $($AvailablePackages[$i])"
}
Write-Host "[A] Установить все"
Write-Host "[N] Пропустить установку пакетов"

$Selection = Read-Host "`nВведите номера пакетов через запятую (например: 1,2,4), 'A' или 'N'"

$PackagesToInstall = @()
if ($Selection -match '(?i)^A$') {
    $PackagesToInstall = $AvailablePackages
} elseif ($Selection -notmatch '(?i)^N$' -and -not [string]::IsNullOrWhiteSpace($Selection)) {
    # Разбиваем введенную строку по запятым и убираем пробелы
    $Indexes = $Selection -split ',' | ForEach-Object { $_.Trim() }
    foreach ($Index in $Indexes) {
        if ([int]::TryParse($Index, [ref]$null) -and $Index -ge 1 -and $Index -le $AvailablePackages.Count) {
            $PackagesToInstall += $AvailablePackages[$Index - 1]
        }
    }
}

# --- Шаг 2: Проверка и установка Scoop ---
if ($PackagesToInstall.Count -gt 0) {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "`n[!] Scoop не найден. Начинаем установку..." -ForegroundColor Yellow
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    } else {
        Write-Host "`n[v] Scoop уже установлен. Обновляем базы данных..." -ForegroundColor Green
        scoop update
    }

    # --- Шаг 3: Установка выбранных пакетов ---
    Write-Host "`nУстановка пакетов: $($PackagesToInstall -join ', ')" -ForegroundColor Cyan
    foreach ($pkg in $PackagesToInstall) {
        Write-Host "Устанавливаем $pkg..." -ForegroundColor Gray
        scoop install $pkg
    }
} else {
    Write-Host "`nУстановка пакетов пропущена." -ForegroundColor DarkGray
}

# --- Шаг 4: Загрузка профиля PowerShell 7 ---
Write-Host "`nНастройка профиля PowerShell..." -ForegroundColor Yellow
$ProfileDir = Split-Path -Parent $PROFILE

# Создаем папку PowerShell в Документах, если её нет
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

try {
    # Скачиваем профиль с GitHub
    Invoke-WebRequest -Uri $ProfileRawUrl -OutFile $PROFILE -UseBasicParsing
    Write-Host "[v] Ваш профиль успешно загружен и сохранен в: $PROFILE" -ForegroundColor Green
} catch {
    Write-Host "[X] Ошибка при скачивании профиля. Проверьте правильность URL: $ProfileRawUrl" -ForegroundColor Red
}

Write-Host "`n=== Настройка завершена! Пожалуйста, перезапустите PowerShell. ===" -ForegroundColor Cyan