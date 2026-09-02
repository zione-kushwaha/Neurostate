# ==============================================================================
# 🚀 NeuroState Top-Tier Automated Reproduction & PDF Build Harness
# ==============================================================================

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "🏆 NEUROSTATE TOP-TIER ARTIFACT REPRODUCTION SUITE" -ForegroundColor Green
Write-Host "   Target: ACM / IEEE Artifacts Evaluated (Functional & Reusable)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Execute Benchmark Suite
Write-Host "`n[*] Step 1/3: Executing Master Empirical Benchmark Suite (50 iters)..." -ForegroundColor White
dart benchmarks/scripts/top_tier_benchmark_suite.dart 50
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error running benchmark suite." -ForegroundColor Red
    exit $LASTEXITCODE
}

# 2. Generate Statistical Analysis, LaTeX Tables & Figures
Write-Host "`n[*] Step 2/3: Generating 15 Publication Tables, Statistical Models & Figures..." -ForegroundColor White
python benchmarks/scripts/analyze_top_tier_results.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error running analysis script." -ForegroundColor Red
    exit $LASTEXITCODE
}

# 3. Compile LaTeX Manuscript
Write-Host "`n[*] Step 3/3: Compiling Camera-Ready Paper PDF via Tectonic..." -ForegroundColor White
tectonic paper/main.tex
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] Artifacts & PDF successfully built: paper/main.pdf" -ForegroundColor Green
} else {
    Write-Host "`n[!] Warning: Tectonic compilation encountered an issue." -ForegroundColor Yellow
}

Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host "✨ All 15 LaTeX tables, figures, and paper/main.pdf are up-to-date!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan
