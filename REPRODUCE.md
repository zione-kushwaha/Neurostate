# 🔁 NeuroState One-Click Reproducibility Guide

> **Artifact Badging Target**: ACM / IEEE Artifacts Evaluated -- Functional & Reusable  
> **Repository**: [https://github.com/zione-kushwaha/Neurostate](https://github.com/zione-kushwaha/Neurostate)  
> **Target Platforms**: Android (ARM64), Flutter 3.24.x, Dart 3.5.x  reproduce all empirical benchmarks, statistical models, LaTeX tables, and high-resolution figures reported in the paper.

---

## 1. Prerequisites & Environment Setup

### System Requirements
* **Dart SDK**: 3.5+ / 3.12+ (`dart --version`)
* **Python**: 3.10+ with `numpy`, `scipy`, `matplotlib`, `pandas`, `statsmodels`
* **Flutter**: 3.24+ (Optional, only for compiling live Android binaries)

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
python benchmarks/scripts/analyze_top_tier_results.py

# On Linux / macOS:
python3 benchmarks/scripts/analyze_top_tier_results.py
```

---

## 3. Step-by-Step Experimental Suite Execution

### Step 3.1: Run Headless Benchmark Harness
Simulates 50 iterations across 4 predictive models, 5-way factorial ablations, 4 network profiles, 4 user personas, and 4 state architectures:

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
  - `table_ablation_study.tex` (5-way factorial ablation)
  - `table_network_emulation.tex` (Cross-network resilience)
  - `table_persona_workload.tex` (Multi-persona behavioral workload)
  - `table_cross_device_perf.tex` (3-tier hardware fleet generalizability)
  - `table_zero_copy_isolate.tex` (Zero-copy serialization latency)
  - `table_energy_profiling.tex` (Battery and energy drain)
  - `table_qoe_metrics.tex` (Double-blind human QoE)
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
  - `cold_start_convergence.png`
  - `qoe_human_study.png`

---

## 4. Live Android Hardware Benchmarking (Optional)

To execute live benchmarks on connected physical Android devices (e.g., Realme 8, Vivo V2407, or Samsung Galaxy Tab S9 FE SM-X510):

1. Connect device via USB with ADB debugging enabled:
   ```bash
   adb devices
   ```
2. Launch the mock HTTP/2 backend server:
   ```bash
   python benchmarks/scripts/mock_server.py &
   ```
3. Run automated live test script:
   ```bash
   python benchmarks/scripts/run_live_samsung_benchmarks.py
   ```

---

## 5. Artifact Directory Structure

```
e:/flutter paper/
├── app1/                  # Baseline 1: Provider Implementation
├── app2/                  # Baseline 2: Riverpod Implementation
├── app3/                  # Baseline 3: BLoC Implementation
├── app4/                  # Proposed: NeuroState Implementation
├── benchmarks/
│   ├── data/              # Raw & aggregated JSON telemetry logs
│   ├── reports/           # Generated LaTeX tables & PNG figures
│   └── scripts/           # Dart & Python benchmark/analysis code
├── paper/
│   ├── main.tex           # IEEEtran Paper Source Code
│   ├── references.bib     # BibTeX Reference Database
│   └── main.pdf           # Compiled Publication PDF
├── EXPERIMENT_SETUP.md    # Hardware/Software/Network Specifications
├── METRICS.md             # Formal Mathematical Metrics Formulations
├── REPRODUCE.md           # Reproduction Instructions (This File)
└── README.md              # Project Overview & Architecture Guide
```
