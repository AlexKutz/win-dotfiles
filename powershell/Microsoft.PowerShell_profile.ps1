Import-Module -Name Terminal-Icons

# Set utf-8 for input/output 
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Set utf-8 for all commands 
$OutputEncoding = [System.Text.Encoding]::UTF8

Invoke-Expression (& { (zoxide init powershell | Out-String) })

$env:FZF_DEFAULT_COMMAND = 'fd --type f --strip-cwd-prefix --hidden --exclude .git'

function fzf-open {
    param(
        [Parameter(Mandatory=$false)]
        [string]$Editor
    )

    # Запускаем fzf и сохраняем выбор
    $selection = fzf --height 40% --reverse --border

    # Проверяем, что файл был выбран (не нажали Esc)
    if ($selection) {
        if ($Editor) {
            # Если указана программа (например, nvim), запускаем её с файлом
            # & -- это оператор вызова в PowerShell
            & $Editor $selection
        } else {
            # Если программа не указана, открываем стандартным средством Windows
            Start-Process $selection
        }
    }
}

Set-Alias fo fzf-open

fnm env --use-on-cd --version-file-strategy=recursive --shell powershell | Out-String | Invoke-Expression

Set-Alias g git
Set-Alias ll Get-ChildItem

function snip {
    & "C:\Users\alex\Scripts\Snippets\Get-Snippet.ps1"
}

function obsidianPush {
    $vaultPath = "C:\Users\alex\github\ObsidianNotes"

    if (Test-Path $vaultPath) {
        $currentPath = Get-Location
        Set-Location $vaultPath
        
        Write-Host "🚀 Синхронизация Obsidian в $vaultPath..." -ForegroundColor Cyan
        
        git add .
        git commit -m "update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git push
        
        Set-Location $currentPath
        Write-Host "✅ Готово!" -ForegroundColor Green
    } else {
        Write-Host "❌ Ошибка: Путь $vaultPath не найден!" -ForegroundColor Red
    }
}
