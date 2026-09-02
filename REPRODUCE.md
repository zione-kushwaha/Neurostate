# 🔁 NeuroState One-Click Reproducibility Guide

> **Artifact Badging Target**: ACM / IEEE Artifacts Evaluated -- Functional & Reusable  
> **Repository**: [https://github.com/zione-kushwaha/Neurostate](https://github.com/zione-kushwaha/Neurostate)  
> **Target Platforms**: Android (ARM64), Google Flutter 3.24.x, React Native 0.74.x (Hermes / C++ JSI)

This document provides exact, end-to-end instructions to reproduce all empirical benchmarks, cross-runtime evaluations, statistical models, LaTeX tables, and high-resolution figures reported in the paper.

---

## 1. Prerequisites & Environment Setup

### System Requirements
* **Dart SDK**: 3.5+ / Flutter 3.24+ (`dart --version`, `flutter --version`)
* **Node.js**: 20+ / 22+ (`node -v`)
* **Java**: JDK 17 / JDK 21 (`java -version`)
* **Android SDK**: API Level 31 to 35 with ADB (`adb devices`)
* **Python**: 3.10+ with `numpy`, `scipy`, `matplotlib`, `pandas`, `statsmodels`

### Python Dependency Installation
```bash
python -m pip install --upgrade pip
pip install numpy scipy matplotlib pandas statsmodels
```

---

## 2. Quick Reproduction (Single Command)

To execute the entire empirical suite, run statistical mixed-effects modeling, and generate all LaTeX tables and figures:

```bash
# On Windows (PowerShell):
dart benchmarks/scripts/top_tier_benchmark_suite.dart 50
python benchmarks/scripts/analyze_top_tier_results.py

# On Linux / macOS:
dart benchmarks/scripts/top_tier_benchmark_suite.dart 50
python3 benchmarks/scripts/analyze_top_tier_results.py
```

---

## 3. Step-by-Step Experimental Suite Execution

### Step 3.1: Run Headless Benchmark Harness
Simulates 50 iterations across 4 predictive models, 5-way factorial ablations, 4 network profiles, 4 user personas, 4-tier hardware fleet, cross-runtime comparisons (Flutter vs React Native), and systems hardening stress tests:

```bash
dart benchmarks/scripts/top_tier_benchmark_suite.dart 50
```
*Output*: Generates `benchmarks/data/top_tier_benchmark_results.json`.

### Step 3.2: Generate Statistical Analysis & Publication Artifacts
Parses raw telemetry logs, executes Linear Mixed-Effects Models, ANOVA, and Tukey HSD post-hoc tests, and renders high-DPI charts:

```bash
python benchmarks/scripts/analyze_top_tier_results.py
```
*Output Artifacts*:
* **LaTeX Table Snippets** in `benchmarks/reports/`:
  - `table_model_comparison.tex` (Predictive intent models)
  - `table_fair_baselines.tex` (Standard vs. Optimized Isolates+Cache)
  - `table_ablation_study.tex` (5-way factorial ablation)
  - `table_network_emulation.tex` (Cross-network resilience)
  - `table_persona_workload.tex` (Multi-persona behavioral workload)
  - `table_cross_device_perf.tex` (4-tier hardware fleet generalizability)
  - `table_cross_runtime_comparison.tex` (Flutter Dart AOT vs React Native Hermes/JSI)
  - `table_zero_copy_isolate.tex` (Zero-copy serialization latency across runtimes)
  - `table_energy_profiling.tex` (Battery and energy drain)
  - `table_systems_hardening.tex` (Concurrency pressure, mutation bursts, concept drift, DCG)
  - `inferential_anova.tex` (Mixed-effects & ANOVA statistics)
* **High-Resolution Figures (300 DPI)** in `benchmarks/reports/`:
  - `architecture_system_overview.png`
  - `ablation_breakdown.png`
  - `network_latency_comparison.png`
  - `wbr_accuracy_tradeoff.png`
  - `isolate_zerocopy_overhead.png`
  - `persona_radar_chart.png`
  - `continuous_battery_30min.png`
  - `cross_device_comparison.png`
  - `concept_drift_adaptation.png`
  - `concurrent_speculation_pressure.png`
  - `qoe_human_study.png`

---

## 4. Live Android Hardware Benchmarking (Optional)

To execute live benchmarks on connected physical Android devices (e.g., Realme 8, Vivo V2407, Infinix Note 12 Pro, or Samsung Galaxy Tab S9 FE SM-X510):

1. **Verify Connected ADB Device**:
   ```bash
   adb devices
   ```
2. **Run Live Flutter Telemetry**:
   ```bash
   python benchmarks/scripts/run_live_samsung_benchmarks.py
   python benchmarks/scripts/run_live_infinix_benchmarks.py
   ```
3. **Run Live React Native Telemetry**:
   ```bash
   python benchmarks/scripts/run_live_react_native_adb_benchmark.py
   ```

---

## 5. Artifact Directory Structure

```
├── app1/                      # Provider Reactive Implementation (Baseline)
├── app2/                      # Riverpod Reactive Implementation (Baseline)
├── app3/                      # BLoC Reactive Implementation (Baseline)
├── app4/                      # NeuroState Speculative Prefetching Engine (Flutter)
├── rn_app/                    # NeuroState Cross-Runtime Implementation (React Native)
├── benchmarks/
│   ├── data/                  # Raw empirical datasets (JSON format)
│   │   ├── top_tier_benchmark_results.json
│   │   └── react_native_live_adb_benchmark_results.json
│   ├── reports/               # Auto-generated LaTeX tables and 300 DPI figures
│   └── scripts/               # Benchmarking harnesses & telemetry analyzers
├── paper/
│   ├── main.tex               # Complete publication LaTeX source
│   ├── references.bib         # BibTeX bibliography
│   └── main.pdf               # Compiled publication PDF
├── EXPERIMENT_SETUP.md        # Exhaustive hardware, OS, and toolchain specification
├── METRICS.md                 # Mathematical formulations for all operational metrics
├── REPRODUCE.md               # 1-Click step-by-step reproduction guide
└── README.md
```
