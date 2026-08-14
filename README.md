# 🧠 NeuroState: Resource-Aware Predictive Prefetching & State Preparation for Flutter Applications

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24.3-02569B?logo=flutter)](https://flutter.dev)
[![Dart SDK](https://img.shields.io/badge/Dart-3.5.3-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Artifact Evaluation](https://img.shields.io/badge/Artifact-Functional%20%26%20Reusable-green.svg)](file:///e:/flutter%20paper/REPRODUCE.md)
[![Preprint](https://img.shields.io/badge/Preprint-Under%20Peer%20Review-orange.svg)](file:///e:/flutter%20paper/paper/main.pdf)

> **Official Research Artifact Repository** for the paper:  
> *"NeuroState: Resource-Aware Predictive Prefetching and Background State Preparation for Flutter Applications"*  
> **Author**: Jeevan Kumar Kushwaha  
> **Affiliation**: Department of Electronics and Computer Engineering, Institute of Engineering (IOE), Tribhuvan University  
> **Contact**: `er.jeevankushwaha@gmail.com`

---

## 📌 Overview

Declarative mobile frameworks (e.g., Google Flutter) define UI as pure functional mappings of state ($\text{UI} = f(\text{State})$). However, mainstream state management patterns (**Provider**, **Riverpod**, and **BLoC**) operate predominantly on a **reactive paradigm**: data fetching, network I/O, and JSON deserialization start only *after* an explicit user interaction occurs.

On resource-constrained mobile hardware with single-threaded event loops, this post-hoc execution induces two major bottlenecks:
1. **Transition Delays (TTI Stalls)**: Users see loading spinners for $115$--$135$\,ms while network I/O and deserialization execute.
2. **Main Thread Contention & Jank**: Parsing multi-megabyte payloads on the UI thread starves the rasterizer, missing VSync deadlines ($16.67$\,ms at 60\,Hz; $11.11$\,ms at 90\,Hz).

**NeuroState** introduces an augmentative speculative runtime layer that:
* Forecasts navigation trajectories using a **Contextual Multi-Armed Bandit (LinUCB)** with dynamic thresholding $\tau(t) = f(\text{Battery}, \text{NetworkRTT}, \text{RAM}, \text{Velocity})$.
* Offloads parsing to **background Dart worker isolates** passing byte buffers via zero-copy `TransferableTypedData`.
* Governs cache entries with a **hybrid version tuple coherency protocol** ($V(e) = \langle v_c, v_s, t \rangle$) with Last-Write-Wins (LWW) conflict resolution.

---

## 🏛️ System Architecture

```
                                  ┌─────────────────────────────────────────────────────────┐
                                  │                 User Interaction Stream                 │
                                  │  (Scroll Velocity, Screen Transitions, Route Dwell)     │
                                  └────────────────────────────┬────────────────────────────┘
                                                               │
                                                               ▼
                                              ┌─────────────────────────────────┐
                                              │   LinUCB Contextual Bandit      │
                                              │   - Context: Battery, RTT, RAM  │
                                              │   - Dynamic Threshold tau(t)    │
                                              └────────────────┬────────────────┘
                                                               │ (Trigger if P(Route) >= tau(t))
                                                               ▼
        ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
        │                              Multi-Threaded Isolate Pool                                    │
        │  - Asynchronous HTTP/2 Payload Retrieval                                                    │
        │  - Background Isolate Deserialization                                                       │
        │  - Zero-Copy Buffer Passing (TransferableTypedData)                                         │
        │  - Version-Vectored Coherency Cache (LRU, Capacity K=50)                                    │
        └──────────────────────────────────────────────┬──────────────────────────────────────────────┘
                                                       │
                                                       ▼
                                ┌──────────────────────────────────────────────┐
                                │ Declarative UI Tree (Instant Activation)     │
                                │ Speculative Hit TTI: 6.20ms (0-Jank Render)  │
                                └──────────────────────────────────────────────┘
```

---

## 📊 Key Empirical Findings

Physical benchmarking across a **4-tier device fleet** (Realme 8, Vivo V2407, Infinix Note 12 Pro, Samsung Galaxy Tab S9 FE 2K), 4 network profiles, 4 user personas, and a double-blind human study ($N=32$) demonstrates:

| Performance Dimension | Standard Reactive Baseline | NeuroState Speculative Engine | Empirical Improvement |
| :--- | :---: | :---: | :---: |
| **Speculative Hit Activation TTI** | $124.8\text{--}135.0$\,ms | $\mathbf{6.20\text{--}6.85\text{ ms}}$ | $\mathbf{19.7\times\text{--}20.1\times\text{ Speedup}}$ |
| **Effective Whole-Session TTI** | $124.8$\,ms | $\mathbf{19.98\text{ ms}}$ | $\mathbf{6.4\times\text{--}12.9\times\text{ Speedup}}$ |
| **Frame Jank Rate (>16.67ms)** | $8.9\%$ | $\mathbf{1.1\%}$ | $\mathbf{87.6\%\text{ Jank Reduction}}$ |
| **Mean Frame Build Time** | $16.76$\,ms | $\mathbf{9.85\text{ ms}}$ | $\mathbf{41.2\%\text{ Faster Build}}$ |
| **30-Min Continuous Battery Drain** | $48.6 \pm 2.4$\,mAh | $\mathbf{31.8 \pm 1.6\text{ mAh}}$ | $\mathbf{34.6\%\text{ Energy Savings}}$ |
| **Contextual Bandit Hit Rate** | $21.8\%$ (Random) | $\mathbf{88.4\%}$ | $\mathbf{8.2\%\text{ Wasted Byte Ratio}}$ |
| **Human Quality of Experience (MOS)** | $2.84 / 5.0$ | $\mathbf{4.42 \pm 0.28 / 5.0}$ | $\mathbf{p < 0.001\text{ (Wilcoxon)}}$ |

---

## 📱 Physical Hardware Testbed (4-Tier Fleet)

| Testbed Tier | Model | System-on-Chip (SoC) | Display & Refresh Rate | RAM | Android OS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tier 1: Mid-Range Phone** | Realme 8 (`RMX3085`) | MediaTek Helio G95 (12nm) | $1080 \times 2400$ @ 60Hz | 6.0 GB | Android 13 (API 33) |
| **Tier 2: Modern 5G Phone** | Vivo V2407 (`V2407`) | MediaTek Dimensity 6300 (6nm) | $720 \times 1612$ @ 90Hz | 4.0 GB | Android 15 (API 35) |
| **Tier 3: AMOLED Phone** | Infinix Note 12 Pro (`X676B`) | MediaTek Helio G99 (6nm) | $1080 \times 2400$ @ 60Hz | 8.0 GB | Android 12 (API 31, XOS) |
| **Tier 4: Flagship 2K Tablet** | Samsung Galaxy Tab S9 FE (`SM-X510`) | Samsung Exynos 1380 (5nm EUV) | $1440 \times 2304$ 2K @ 90Hz | 6.0 GB | Android 14 (One UI 6.1) |

---

## 📂 Repository Structure

```
├── app1/                      # Provider Reactive Implementation (Baseline)
├── app2/                      # Riverpod Reactive Implementation (Baseline)
├── app3/                      # BLoC Reactive Implementation (Baseline)
├── app4/                      # NeuroState Speculative Prefetching Engine
├── benchmarks/
│   ├── data/                  # Raw empirical datasets (JSON format)
│   │   ├── top_tier_benchmark_results.json
│   │   └── infinix_x676b_benchmark_results.json
│   ├── reports/               # Auto-generated LaTeX tables and 300 DPI figures
│   └── scripts/               # Benchmarking harnesses & telemetry analyzers
│       ├── top_tier_benchmark_suite.dart
│       ├── analyze_top_tier_results.py
│       ├── run_live_infinix_benchmarks.py
│       └── generate_infinix_reports.py
├── paper/
│   ├── main.tex               # Complete publication LaTeX source
│   ├── references.bib         # BibTeX bibliography
│   └── main.pdf               # Compiled 11-page publication PDF
├── EXPERIMENT_SETUP.md        # Exhaustive hardware, OS, and toolchain specification
├── METRICS.md                 # Mathematical formulations for all operational metrics
├── REPRODUCE.md               # 1-Click step-by-step reproduction guide
└── README.md
```

---

## 🔁 1-Click Reproducibility

### Prerequisites
* Dart SDK $\ge 3.5.0$ / Flutter $\ge 3.24.0$
* Python $\ge 3.10$ with `numpy`, `matplotlib`, `scipy`
* `tectonic` or `pdflatex` (for LaTeX paper compilation)

### Run Benchmark Pipeline
```bash
# 1. Execute full benchmark suite across all conditions (50 cycles/condition)
dart benchmarks/scripts/top_tier_benchmark_suite.dart 50

# 2. Process empirical dataset, fit Linear Mixed-Effects Model, generate tables & charts
python benchmarks/scripts/analyze_top_tier_results.py

# 3. Compile publication PDF
cd paper
tectonic main.tex
```

---

## 📖 Citation

If you use NeuroState in your research, please cite our technical report:

```bibtex
@article{kushwaha2026neurostate,
  title={NeuroState: Resource-Aware Predictive Prefetching and Background State Preparation for Flutter Applications},
  author={Kushwaha, Jeevan Kumar},
  journal={arXiv preprint / Research Technical Report},
  year={2026},
  publisher={Tribhuvan University, Institute of Engineering (IOE)},
  url={https://github.com/zione-kushwaha/Neurostate}
}
```

---

## 📄 License
This research codebase and evaluation artifacts are distributed under the **MIT License**. See [LICENSE](LICENSE) for details.
