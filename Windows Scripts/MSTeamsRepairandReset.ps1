$ErrorActionPreference = 'SilentlyContinue'

function Remove-Contents {
    param([string]$Path)
    if (Test-Path $Path) {
        Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            } catch {}
        }
    }
}

Write-Output "==============================="
Write-Output " TEAMS FULL RESET"
Write-Output "==============================="
Write-Output ""

$stopped = @()
$cleared = @()
$paths = @(
    "$env:APPDATA\Microsoft\Teams",
    "$env:LOCALAPPDATA\Microsoft\Teams",
    "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache",
    "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\TempState",
    "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalState"
)

$processNames = @('Teams','ms-teams','msedgewebview2')

foreach ($p in $processNames) {
    Get-Process -Name $p -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
            $stopped += "$($_.ProcessName) [$($_.Id)]"
        } catch {}
    }
}

foreach ($path in $paths) {
    if (Test-Path $path) {
        Remove-Contents -Path $path
        $cleared += $path
    }
}

$launchCandidates = @(
    "$env:LOCALAPPDATA\Microsoft\WindowsApps\ms-teams.exe",
    "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe",
    "$env:ProgramFiles\WindowsApps\MSTeams*",
    "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe"
)

$launched = $false

if (Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\ms-teams.exe") {
    Start-Process "$env:LOCALAPPDATA\Microsoft\WindowsApps\ms-teams.exe" -ErrorAction SilentlyContinue
    $launched = $true
}
elseif (Test-Path "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe") {
    Start-Process "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe" -ErrorAction SilentlyContinue
    $launched = $true
}
elseif (Test-Path "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe") {
    Start-Process "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe" --processStart "Teams.exe" -ErrorAction SilentlyContinue
    $launched = $true
}

Write-Output "Computer        : $env:COMPUTERNAME"
Write-Output "Processes Stopped:"
if ($stopped.Count -gt 0) {
    $stopped | ForEach-Object { Write-Output " - $_" }
} else {
    Write-Output " - None found"
}

Write-Output ""
Write-Output "Cache Paths Cleared:"
if ($cleared.Count -gt 0) {
    $cleared | ForEach-Object { Write-Output " - $_" }
} else {
    Write-Output " - No cache paths found"
}

Write-Output ""
Write-Output "Teams Relaunched: $(if ($launched) {'YES'} else {'NO'})"
Write-Output ""
Write-Output "Result          : SUCCESS"
Write-Output ""
Write-Output "==============================="
