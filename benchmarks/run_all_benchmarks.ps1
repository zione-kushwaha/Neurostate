# Master benchmark execution script
param (
    [string]$Target = "android",
    [string]$Mode = "profile"
)

& powershell -File benchmarks/run_android_benchmarks.ps1 -Mode $Mode
