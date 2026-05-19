# CleanUnneededIntermediates.ps1
# Run from anywhere — edit $EngineRoot to match your setup
param(
    [string]$EngineRoot = "C:\Dev\UE",
    [string[]]$Keep = @("UnrealEditor", "UnrealGame")
)

$intermediatesPath = Join-Path $EngineRoot "Engine\Intermediate\Build\Win64\x64"

if (-not (Test-Path $intermediatesPath)) {
    Write-Error "Path not found: $intermediatesPath"
    exit 1
}

$targets = Get-ChildItem -Path $intermediatesPath -Directory
$toDelete = $targets | Where-Object { $_.Name -notin $Keep }

if ($toDelete.Count -eq 0) {
    Write-Host "Nothing to clean." -ForegroundColor Green
    exit 0
}

Write-Host "Will delete:" -ForegroundColor Yellow
$toDelete | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Write-Host "  $($_.Name) ($([math]::Round($size/1GB, 2)) GB)"
}

$confirm = Read-Host "`nProceed? (y/n)"
if ($confirm -ne 'y') { exit 0 }

$toDelete | Remove-Item -Recurse -Force
Write-Host "Done." -ForegroundColor Green