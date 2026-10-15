# Claude Code 作業完成通知腳本（Stop hook 用）
# 模式由 %USERPROFILE%\.claude\notify-mode.txt 決定，可用 claude-notify-mode.ps1 切換：
#   voice : 語音播報（目前預設）
#   beep  : 單純提示音
#   off   : 靜音
# 也可用環境變數 CLAUDE_NOTIFY_MODE 覆寫（優先於設定檔）。

param(
    [string]$Message = "Claude 作業已完成"
)

$ErrorActionPreference = "SilentlyContinue"

# Stop hook 會把 JSON 餵進 stdin，這裡讀掉即可，避免管線卡住
try { [void][Console]::In.ReadToEnd() } catch {}

$modeFile = Join-Path $env:USERPROFILE ".claude\notify-mode.txt"
$mode = "voice"  # 找不到設定時的預設值

if ($env:CLAUDE_NOTIFY_MODE) {
    $mode = $env:CLAUDE_NOTIFY_MODE
}
elseif (Test-Path $modeFile) {
    $fromFile = (Get-Content $modeFile -Raw -ErrorAction SilentlyContinue)
    if ($fromFile) { $mode = $fromFile.Trim() }
}

switch ($mode.ToLower()) {
    "off" {
        # 靜音
    }
    "voice" {
        try {
            Add-Type -AssemblyName System.Speech
            $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $synth.Rate = 0
            $synth.Speak($Message)
            $synth.Dispose()
        }
        catch {
            # 語音失敗就退回提示音
            [Console]::Beep(880, 200)
        }
    }
    default {
        # beep：兩短音，比系統音效更明顯
        try {
            [Console]::Beep(880, 150)
            Start-Sleep -Milliseconds 80
            [Console]::Beep(1175, 200)
        }
        catch {
            [System.Media.SystemSounds]::Asterisk.Play()
        }
    }
}

exit 0
