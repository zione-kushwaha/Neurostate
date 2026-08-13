# 🧪 NeuroState Empirical Experiment Setup & Methodology

> **Target Venue Standard**: ACM SIGSOFT FSE / IEEE/ACM ICSE / ACM MobiSys / IEEE TSE  
> **Document Purpose**: Exhaustive specification of physical hardware, operating systems, compiler toolchains, network profile emulation, telemetry hooks, train/test dataset splits, and dataset generation parameters to ensure exact scientific reproducibility.

---

## 1. Physical Hardware Testbed Fleet (3-Tier Matrix)

All physical experiments were executed on a heterogeneous 3-tier mobile device fleet spanning entry-level 4G, modern 5G 90Hz smartphones, and flagship high-resolution 2K tablets.

| Hardware Parameter | Tier 1: Mid-Range 4G Phone | Tier 2: Modern 5G Phone | Tier 3: 6nm AMOLED Phone | Tier 4: Flagship 2K Tablet |
| :--- | :--- | :--- | :--- | :--- |
| **Manufacturer & Model** | Realme 8 (`RMX3085`) | Vivo V2407 (`V2407`) | **Infinix Note 12 Pro (`X676B`)** | Samsung Galaxy Tab S9 FE (`SM-X510`) |
| **System-on-Chip (SoC)** | MediaTek Helio G95 (`MT6785`) | MediaTek Dimensity 6300 5G (`MT6835`) | **MediaTek Helio G99 (`MT6789`)** | Samsung Exynos 1380 (`s5e8835`) |
| **Fabrication Process** | 12\,nm FinFET | 6\,nm TSMC Advanced Node | **6\,nm TSMC Advanced Node** | **5\,nm EUV Advanced Node** |
| **CPU Configuration** | 2$\times$ Cortex-A76 @ 2.05\,GHz + 6$\times$ Cortex-A55 @ 2.0\,GHz | 2$\times$ Cortex-A76 @ 2.40\,GHz + 6$\times$ Cortex-A55 @ 2.0\,GHz | **2$\times$ Cortex-A76 @ 2.20\,GHz + 6$\times$ Cortex-A55 @ 2.0\,GHz** | **4$\times$ Cortex-A78 @ 2.40\,GHz + 4$\times$ Cortex-A55 @ 2.0\,GHz** |
| **GPU Architecture** | ARM Mali-G76 MC4 | ARM Mali-G57 MC2 | **ARM Mali-G57 MC2** | **ARM Mali-G68 MP5** |
| **Total / Addressable RAM** | 6.0\,GB LPDDR4X (5,757\,MB Addressable) | 4.0\,GB LPDDR4X (3,708\,MB Addressable) | **8.0\,GB LPDDR4X (7,884\,MB Addressable)** | **6.0\,GB LPDDR4X (5,841\,MB Addressable)** |
| **Display Resolution** | $1080 \times 2400$\,px (FHD+, 480\,dpi) | $720 \times 1612$\,px (HD+, 300\,dpi) | **$1080 \times 2400$\,px (FHD+ AMOLED, 480\,dpi)** | **$1440 \times 2304$\,px (2K WQXGA, 280\,dpi)** |
| **Display Surface Pixels** | 2.59 Million Pixels / Frame | 1.16 Million Pixels / Frame | **2.59 Million Pixels / Frame** | **3.32 Million Pixels / Frame** |
| **Native Refresh / Budget**| 60.0\,Hz (16.67\,ms budget) | **90.0\,Hz (11.11\,ms budget)** | **60.0\,Hz (16.67\,ms budget)** | **90.0\,Hz (11.11\,ms budget)** |
| **Operating System** | Android 13 (API Level 33) | Android 15 (API Level 35) | **Android 12 (API Level 31, XOS)** | **Android 14 (One UI 6.1 / API 34)** |
| **Kernel Version** | Linux 4.14.186-perf+ | Linux 5.15.148-android14-11 | **Linux 5.10.66-android12-9** | Linux 6.1.75-android14-9 |

### Device Environmental Controls
1. **Thermal Stabilization**: Prior to benchmark logging, devices rested for 10 minutes at ambient room temperature ($22^\circ\text{C} \pm 1^\circ\text{C}$). SoC thermal states were verified below $35^\circ\text{C}$ via Android `thermal_zone0`.
2. **Background Process Sanitization**: All third-party background applications, auto-updates, and push notifications were terminated via `adb shell am kill-all` and `adb shell cmd statusbar disable-notifications`.
3. **Display & Power State**: Display brightness was fixed at $50\%$ manual (no auto-brightness); battery saver, adaptive battery, and high-performance gaming modes were disabled (`adb shell settings put global low_power 0`).
4. **Refresh Rate Locking**: Native refresh rates were locked via `adb shell settings put system user_refresh_rate 60` (Realme 8) and `90` (Vivo V2407, Samsung SM-X510).

---

## 2. Software Runtime & Toolchain Environment

* **Flutter Framework**: Flutter 3.24.3 (Channel Stable, engine revision `e672b006cb`)
* **Dart VM / SDK**: Dart 3.5.3 / Dart SDK 3.12.x (`dart_runner` in AOT Profile mode)
* **Compilation Mode**: **AOT Profile Mode** (`flutter run --profile --no-dds --dart-define=DART_VM_PROFILE=true`)
* **Android SDK**: Build-Tools 34.0.0 / 35.0.0, NDK 26.1.10909125, Gradle 8.4
* **Host Benchmarking Machine**: Windows 11 Pro 64-bit / Linux Ubuntu 22.04 LTS, Python 3.10+, NumPy 1.26+, SciPy 1.13+, Matplotlib 3.8+

---

## 3. Standardized 5-Screen Mobile Application Topology

All evaluated architectures share identical UI layouts, widget hierarchies, typography (Inter / Roboto), and assets, differing solely in their state resolution pipeline:

1. **Feed Screen (`FeedScreen`)**: Paginated infinite list of research articles with dynamic category filters, thumbnail rendering, and real-time scroll velocity estimation.
2. **Explore Screen (`ExploreScreen`)**: 6 distinct topic clusters (Machine Learning, Systems, Mobile, Security, Networks, HCI) with horizontal carousel widgets.
3. **Bookmarks Screen (`BookmarksScreen`)**: Persisted local reading list exercising cross-screen state mutation and version-vectored optimistic cache writes.
4. **Detail Screen (`DetailScreen`)**: Rich Markdown renderer displaying full structured article content ($10$\,KB to $50$\,KB) with microsecond Time-to-Interactive measurement hooks.
5. **Telemetry Lab Screen (`TelemetryLabScreen`)**: Headless and interactive test runner displaying real-time VSync frame latency HUD, memory RSS counters, and batch automated execution.

---

## 4. Multi-Tiered Network Latency Emulation Matrix

To simulate realistic mobile environments, network I/O requests were routed through an adaptive network latency throttler with the following profile matrix:

| Network Profile | Simulated RTT ($\mu \pm \sigma$) | Downlink Bandwidth | Packet Loss | Target Mobile Scenario |
| :--- | :---: | :---: | :---: | :--- |
| **5G Ultra-Wideband** | $15\text{ ms} \pm 5\text{ ms}$ | $150\text{ Mbps}$ | $0.0\%$ | High-density urban mmWave / Sub-6 |
| **4G LTE Standard** | $80\text{ ms} \pm 20\text{ ms}$ | $25\text{ Mbps}$ | $0.2\%$ | Standard outdoor cellular data |
| **3G Legacy / Rural** | $350\text{ ms} \pm 100\text{ ms}$ | $2\text{ Mbps}$ | $1.5\%$ | Weak coverage, transit tunnels |
| **Congested Edge Wi-Fi** | $600\text{ ms} \pm 250\text{ ms}$ | $5\text{ Mbps}$ | $4.0\%$ | Public venue / airport Wi-Fi |

---

## 5. Dataset Generation, Schema & Train/Test Split

The evaluation dataset consists of **10,000 structured research articles** ($23.65$\,MB total uncompressed JSON payload; mean $2.36$\,KB/article) generated with a deterministic pseudo-random seed (`seed=0xDEADBEEF`).

### Train / Test Split Protocol
* **Session-Level Disjoint Split**: $80\%$ of user navigation sessions ($N=800$ sessions) for offline prior estimation / model training, and $20\%$ disjoint sessions ($N=200$ sessions) strictly held out for testing.
* **Leakage Prevention**: No user session in the test set contributes transition counts or context feedback to the training set.
* **Cold-Start Evaluation**: Step $t=1\dots 10$ traces evaluated with zero user history, bootstrapping solely from the static routing Directed Acyclic Graph (DAG).

### JSON Schema per Item
```json
{
  "id": "art_0009842",
  "title": "Predictive State Prefetching in Declarative Mobile Engines",
  "category": "Systems",
  "author": "Dr. A. Turing",
  "published_at": "2026-08-15T10:30:00Z",
  "read_time_minutes": 8,
  "summary": "This paper investigates client-side speculative execution...",
  "body_markdown": "# Abstract\nSpeculative prefetching eliminates UI thread contention...",
  "tags": ["Flutter", "Dart Isolates", "Performance", "State Management"],
  "metrics": {
    "citations": 142,
    "downloads": 3890,
    "rating": 4.92
  },
  "version": 1
}
```

The dataset is hosted on a local low-latency mock HTTP/2 server (`benchmarks/scripts/mock_server.py`) supporting gzip compression ($3.8\times$ network compression) and paginated queries (`GET /api/feed?page=1&limit=20`).
