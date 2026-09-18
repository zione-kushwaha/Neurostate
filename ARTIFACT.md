# 📦 NeuroState Research Artifact & Reproducibility Guide

> **Artifact Evaluation Package**: This document provides end-to-end instructions for the Artifact Evaluation Committee (AEC) to inspect, execute, and verify all empirical findings reported in the **NeuroState** manuscript.

---

## 🏆 Target Artifact Badges

- ✅ **Artifacts Available**: All application codebases, custom JSI engines, micro-benchmarks, raw device traces, and analysis scripts are publicly accessible in the repository.
- ✅ **Artifacts Evaluated – Functional**: The complete experimental pipeline runs without manual interventions, executing automated headless tests and generating all statistical metrics.
- ✅ **Artifacts Evaluated – Reusable**: Benchmark harnesses and analysis pipelines are modularized, documented, and packaged for extensibility to other mobile frameworks and hardware devices.

---

## 🖥️ System Requirements & Environment Setup

### 1. Host Machine
- **Operating System**: Windows 10/11, macOS 12+, or Ubuntu 20.04/22.04 LTS.
- **Python**: Python 3.10, 3.11, or 3.12 (with `scipy`, `numpy`, `pandas`, `statsmodels`, `matplotlib`, `pypdf`).
- **LaTeX Engine**: `tectonic` (recommended for zero-config compilation) or `pdflatex` / `latexmk`.

### 2. Mobile Runtimes (Optional for Live Device Benchmarks)
- **Flutter SDK**: Flutter 3.24.x (Dart SDK 3.5.x).
- **Node.js & React Native**: Node.js 18+ and React Native 0.74 (Hermes engine).
- **Android SDK**: Platform Tools (ADB enabled) for live on-device telemetry collection.

---

## ⚡ Quick Start: 1-Command Verification

To run the complete verification suite, generate all 12 LaTeX tables, generate all 10 figures, and recompile the manuscripts:

### On Windows (PowerShell):
```powershell
./run_reproduce.ps1
```

### On Linux / macOS (Bash):
```bash
python benchmarks/scripts/run_headless_synthetic.py
python benchmarks/scripts/generate_all_reports.py
cd paper && tectonic conference_main.tex && tectonic main.tex
```

---

## 📊 Mapping Artifact Outputs to Paper Claims

| Paper Table / Figure | Description | Generating Script / Source File | Output File |
| :--- | :--- | :--- | :--- |
| **Table I / II** | Cross-Runtime Comparison (Flutter vs. React Native) | `benchmarks/scripts/generate_all_reports.py` | `benchmarks/reports/table_cross_runtime_comparison.tex` |
| **Table III** | Predictive Model Hierarchy vs. Controls | `benchmarks/scripts/run_headless_synthetic.py` | `benchmarks/reports/table_model_comparison.tex` |
| **Table IV** | Equalized Fair Baselines Comparison | `benchmarks/scripts/generate_all_reports.py` | `benchmarks/reports/table_fair_baselines.tex` |
| **Table V / Fig. 2** | 5-Way Factorial Component Ablation | `benchmarks/scripts/run_headless_synthetic.py` | `benchmarks/reports/table_ablation_study.tex`, `ablation_breakdown.png` |
| **Table VI / Fig. 3** | Cross-Network Latency Masking (5G/4G/3G/Wi-Fi) | `benchmarks/scripts/generate_all_reports.py` | `benchmarks/reports/table_network_emulation.tex`, `network_latency_comparison.png` |
| **Table VII / Fig. 4**| Zero-Copy Typed Buffer vs. Deep Copy | `benchmarks/scripts/generate_all_reports.py` | `benchmarks/reports/table_zero_copy_isolate.tex`, `isolate_zerocopy_overhead.png` |
| **Table VIII** | Multi-Persona Behavioral Workload (A, B, C, D) | `benchmarks/scripts/run_headless_synthetic.py` | `benchmarks/reports/table_persona_workload.tex`, `persona_radar_chart.png` |
| **Table IX** | 5D Contextual Bandit Telemetry Ablation | `benchmarks/scripts/run_headless_synthetic.py` | `benchmarks/reports/table_bandit_sensitivity.tex`, `bandit_5d_sensitivity.png` |
| **Table X** | Subsystem Energy Decomposition (30-min) | `benchmarks/scripts/generate_all_reports.py` | `benchmarks/reports/table_energy_breakdown.tex`, `energy_component_breakdown.png` |
| **Table XI** | Counterbalanced Human Subject Study ($N=32$) | `benchmarks/scripts/generate_all_reports.py` | `benchmarks/reports/qoe_human_study.png` |
| **Table XII** | Linear Mixed-Effects ANOVA ($N=400$ runs) | `benchmarks/scripts/run_anova_analysis.py` | `benchmarks/reports/inferential_anova.tex` |

---

## 📂 Repository Layout

```
neurostate/
├── app1/                      # Provider standard & optimized reference application
├── app2/                      # Riverpod reference application
├── app3/                      # BLoC reference application
├── app4/                      # NeuroState speculative runtime reference application
├── rn_app/                    # React Native (Hermes + C++ JSI) reference application
├── benchmarks/
│   ├── scripts/               # Headless benchmarks, live runners & report generators
│   ├── reports/               # Auto-generated LaTeX tables (.tex) and plots (.png)
│   └── telemetry/             # Raw on-device CSV/JSON traces across 4 devices
├── paper/
│   ├── conference_main.tex    # 10-page Double-Blind Review conference manuscript
│   ├── main.tex               # Full 17-page Flagship Journal manuscript (IEEEtran)
│   ├── references.bib         # Expanded 60+ reference database
│   ├── conference_main.pdf    # Compiled conference submission PDF
│   └── main.pdf               # Compiled journal submission PDF
├── REPRODUCE.md               # Quick reproduction instructions
└── ARTIFACT.md                # This artifact evaluation specification
```

---

## 🔒 Double-Blind Review Compliance

For conference artifact submission, all author and institutional identifiers have been removed:
- Anonymized artifact sandbox URL: `https://anonymous.4open.science/r/Neurostate-AEC`
- Anonymized protocol identifier: `IRB-exempt Protocol #2026-ENG-042`
