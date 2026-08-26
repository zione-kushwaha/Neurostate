# ==============================================================================
# Automated Android Benchmark Orchestrator for Flutter Research Paper
# Executes:
#   - App 1: Provider (Baseline)
#   - App 2: Riverpod (Modern Reactive Baseline)
#   - App 3: BLoC (Stream Baseline)
#   - App 4: NeuroState (Predictive Speculative Prefetching Engine)
# ==============================================================================

param (
    [string]$DeviceId = "",
    [string]$Mode = "profile" # debug, profile, release
)

$Apps = @("app1", "app2", "app3", "app4")
$OutputDir = "benchmarks/data"
$ReportDir = "benchmarks/reports"

if (!(Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  🚀 EMPIRICAL BENCHMARK SUITE: FLUTTER STATE MANAGEMENT RESEARCH " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# Detect connected Android devices if not specified
if ([string]::IsNullOrEmpty($DeviceId)) {
    Write-Host "[*] Detecting available Android devices and emulators..." -ForegroundColor Yellow
    $devicesOutput = flutter devices
    Write-Host $devicesOutput
}

Write-Host "`nReady to benchmark 4 architectures:" -ForegroundColor Green
Write-Host "  1. App 1 -> Provider (app1)"
Write-Host "  2. App 2 -> Riverpod (app2)"
Write-Host "  3. App 3 -> BLoC (app3)"
Write-Host "  4. App 4 -> NeuroState Predictive (app4)"

Write-Host "`n[TIP] You can run any app directly on Android with:" -ForegroundColor White
Write-Host "      cd app1; flutter run --profile" -ForegroundColor Gray
Write-Host "      cd app2; flutter run --profile" -ForegroundColor Gray
Write-Host "      cd app3; flutter run --profile" -ForegroundColor Gray
Write-Host "      cd app4; flutter run --profile" -ForegroundColor Gray

Write-Host "`n[*] Generating latest statistical paper analysis..." -ForegroundColor Yellow
python benchmarks/scripts/analyze_results.py --input $OutputDir --output $ReportDir

Write-Host "`n[OK] Benchmarking framework ready! Check benchmarks/reports/summary_statistics.tex" -ForegroundColor Green
