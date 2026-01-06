# 🖥 Codex Now - Launch OpenAI Codex CLI instantly without confirmation
# PowerShell script to launch Codex in current directory

# Configuration file for last directory
$LastDirFile = "$env:USERPROFILE\.codex-now-last-dir"

# If user provided an argument, use it
if ($args.Count -gt 0) {
    $TargetDir = $args[0]
}
# Otherwise try to read last directory
elseif (Test-Path $LastDirFile) {
    $TargetDir = Get-Content $LastDirFile
}
# Fall back to user home directory
else {
    $TargetDir = $env:USERPROFILE
}

# Check if directory exists
if (-not (Test-Path $TargetDir -PathType Container)) {
    Write-Host "❌ Error: Directory '$TargetDir' does not exist" -ForegroundColor Red
    exit 1
}

# Change to target directory
Set-Location $TargetDir

Write-Host "🖥 Launching Codex in '$TargetDir'..." -ForegroundColor Green

# Find codex command
$CodexPath = $null

# Try to find command directly
$CodexCommand = Get-Command codex -ErrorAction SilentlyContinue
if ($CodexCommand) {
    $CodexPath = $CodexCommand.Source
}
else {
    # Try common installation locations
    $PossiblePaths = @(
        "$env:APPDATA\npm\codex.cmd",
        "$env:ProgramFiles\nodejs\codex.cmd",
        "$env:LOCALAPPDATA\npm\codex.cmd"
    )

    foreach ($path in $PossiblePaths) {
        if (Test-Path $path) {
            $CodexPath = $path
            break
        }
    }
}

if (-not $CodexPath) {
    Write-Host "❌ Error: Codex CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Please make sure Codex CLI is installed" -ForegroundColor Yellow
    Write-Host "💡 Tip: Try running 'npm install -g @openai/codex'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📝 Common installation paths:" -ForegroundColor Cyan
    Write-Host "   - $env:APPDATA\npm\codex.cmd"
    Write-Host "   - $env:ProgramFiles\nodejs\codex.cmd"
    Write-Host "   - $env:LOCALAPPDATA\npm\codex.cmd"
    exit 1
}

Write-Host "✅ Found Codex: $CodexPath" -ForegroundColor Green

# Save current directory for next use
$TargetDir | Out-File -FilePath $LastDirFile -Encoding utf8

# Verify Codex path for security
if ($CodexPath -match "codex(\.exe|\.cmd|\.ps1)?$") {
    Write-Host "🔒 Security check passed, launching Codex..." -ForegroundColor Green
    & $CodexPath --yolo
} else {
    Write-Host "❌ Security check failed: Invalid Codex path detected" -ForegroundColor Red
    Write-Host "🔍 Current path: $CodexPath" -ForegroundColor Yellow
    Write-Host "⚠️  Refusing to execute this path for security reasons" -ForegroundColor Yellow
    exit 1
}
