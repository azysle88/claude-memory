# 切換 Claude Code 作業完成通知模式
# 用法：
#   .\claude-notify-mode.ps1 beep    # 單純提示音
#   .\claude-notify-mode.ps1 voice   # 語音播報
#   .\claude-notify-mode.ps1 off     # 靜音
#   .\claude-notify-mode.ps1         # 顯示目前模式
#   .\claude-notify-mode.ps1 test    # 用目前模式播一次

param(
    [ValidateSet("beep", "voice", "off", "status", "test", "")]
    [string]$Mode = "status"
)

$modeFile = Join-Path $env:USERPROFILE ".claude\notify-mode.txt"

function Get-CurrentMode {
    if (Test-Path $modeFile) {
        $v = (Get-Content $modeFile -Raw).Trim()
        if ($v) { return $v }
    }
    return "voice (預設，尚未建立設定檔)"
}

switch ($Mode) {
    "status" {
        Write-Host "目前通知模式：$(Get-CurrentMode)"
        Write-Host "設定檔：$modeFile"
    }
    "test" {
        & (Join-Path $PSScriptRoot "claude-notify.ps1")
        Write-Host "已用目前模式（$(Get-CurrentMode)）播放一次"
    }
    default {
        $dir = Split-Path $modeFile
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        # 以不帶 BOM 的 UTF-8 寫入純 ASCII 內容
        [IO.File]::WriteAllText($modeFile, $Mode, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "通知模式已切換為：$Mode"
    }
}
