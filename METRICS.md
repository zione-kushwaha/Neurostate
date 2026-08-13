# 📐 NeuroState Formal Metrics Definitions & Operationalization

> **Document Purpose**: Precise mathematical formulations, instrumentation hooks, and operational definitions for all performance, system, and user-experience metrics reported in the NeuroState evaluation.

---

## 1. Latency & Time-to-Interactive (TTI) Metrics

### 1.1 Effective Time-to-Interactive ($\text{TTI}_{\text{eff}}$)
Time-to-Interactive is defined as the elapsed duration from user gesture initiation ($t_{\text{tap}}$) until the first frame containing fully parsed, correct, interactive content is painted to the display buffer:
$$\text{TTI} = t_{\text{interactive\_frame\_presented}} - t_{\text{gesture\_dispatch}}$$

In predictive speculative architectures, total navigation requests partition into **Cache Hits** (pre-warmed speculatively) and **Cache Misses** (fallback on-demand fetching):
$$\text{TTI}_{\text{eff}} = \mathbb{P}(\text{Hit}) \cdot \text{TTI}_{\text{hit}} + (1 - \mathbb{P}(\text{Hit})) \cdot \text{TTI}_{\text{miss}}$$

### 1.2 Speculative Cache-Hit TTI ($\text{TTI}_{\text{hit}}$)
When the target route $S_{t+1}$ is already present in the bounded LRU cache $\mathcal{C}$:
$$\text{TTI}_{\text{hit}} = t_{\text{cache\_lookup}} + t_{\text{widget\_build}} + t_{\text{raster}} \approx 2.02\text{--}2.46\,\text{ms}$$
* Instrumentation: Measured using Dart `Stopwatch.elapsedMicroseconds` starting immediately at `Navigator.pushNamed` and resolving inside `WidgetsBinding.instance.addPostFrameCallback`.

### 1.3 Speculative Cache-Miss TTI ($\text{TTI}_{\text{miss}}$)
When $S_{t+1} \notin \mathcal{C}$, the runtime initiates concurrent on-demand network I/O, background isolate parsing, and widget rendering:
$$\text{TTI}_{\text{miss}} = t_{\text{net\_fetch}} + t_{\text{isolate\_parse}} + t_{\text{buffer\_transfer}} + t_{\text{widget\_build}} + t_{\text{raster}} + \delta_{\text{overhead}}$$
* Miss Penalty ($\delta_{\text{overhead}}$): The additional latency introduced by checking the cache and cancelling non-matching in-flight prefetch requests ($\delta_{\text{overhead}} \le 1.2\text{--}1.8\,\text{ms}$).

### 1.4 Component Latency Breakdown
For every navigation transition, the telemetry harness logs:
$$\text{TTI}_{\text{total}} = t_{\text{route\_dispatch}} + t_{\text{cache\_query}} + t_{\text{network\_rtt}} + t_{\text{isolate\_deser}} + t_{\text{build}} + t_{\text{raster}}$$

---

## 2. UI Thread Contention & Frame Jank Metrics

### 2.1 Frame Build Time ($t_{\text{build}}$) & Raster Time ($t_{\text{raster}}$)
Captured directly from the Flutter engine via `SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) => ...)`:
* `buildDuration`: Total CPU time spent executing `Widget.build()`, layout calculations, and RenderObject composition on the UI thread.
* `rasterDuration`: Total GPU time spent by the Impeller / Skia rasterizer executing GPU draw commands.

### 2.2 Micro-Jank Ratio ($\text{Jank}_{\%}$)
A frame is classified as *janked* if its total elapsed processing time exceeds the hardware display VSync refresh deadline:
$$\text{Janked Frame} = \mathbb{I}\left( t_{\text{build}} + t_{\text{raster}} > T_{\text{VSync}} \right)$$
where:
* $T_{\text{VSync}} = 16.67\,\text{ms}$ on 60\,Hz displays (Realme 8).
* $T_{\text{VSync}} = 11.11\,\text{ms}$ on 90\,Hz displays (Vivo V2407, Samsung Galaxy Tab S9 FE).
* $T_{\text{VSync}} = 8.33\,\text{ms}$ on 120\,Hz flagship displays.

$$\text{Jank}_{\%} = \frac{\sum_{i=1}^{N_{\text{frames}}} \mathbb{I}\left( t_{\text{build}}^{(i)} + t_{\text{raster}}^{(i)} > T_{\text{VSync}} \right)}{N_{\text{frames}}} \times 100\%$$

---

## 3. Network & Prefetching Efficiency Metrics

### 3.1 Prediction Hit Rate ($\text{HR}$)
The proportion of user route navigations correctly anticipated and pre-warmed in memory prior to route push:
$$\text{HR} = \frac{N_{\text{speculative\_hits}}}{N_{\text{total\_navigations}}} \times 100\%$$

### 3.2 Cache Precision & Wasted Byte Ratio ($\text{WBR}$)
Cache precision measures the proportion of speculatively warmed bytes that are actively accessed by the user:
$$\text{Precision} = \frac{\text{Bytes Prefetched and Navigated}}{\text{Total Bytes Prefetched}}$$
$$\text{WBR} = \frac{\text{Bytes Prefetched but Evicted Unused}}{\text{Total Bytes Prefetched}} = 1 - \text{Precision}$$

---

## 4. System Resource & Thermal Metrics

### 4.1 Resident Set Size (RSS) & Memory Leak Delta
* **Peak RSS**: Maximum resident physical memory allocated to the process during a 50-cycle benchmark, polled via `ProcessInfo.currentRss`.
* **Leak Delta ($\Delta\text{MB}$)**: Net difference in resident memory after 50 full screen push-pop cycles followed by explicit garbage collection trigger:
$$\Delta\text{RSS} = \text{RSS}_{\text{end}} - \text{RSS}_{\text{start}}$$

### 4.2 Isolate CPU Offload Efficiency
Quantifies the fraction of JSON parsing and state transformation computation moved from the UI runner thread to background worker isolates:
$$\text{Offload}_{\%} = \frac{\text{CPU Time}_{\text{Worker Isolates}}}{\text{CPU Time}_{\text{UI Thread}} + \text{CPU Time}_{\text{Worker Isolates}}} \times 100\%$$

### 4.3 Energy Consumption & Battery Drain
* Recorded over a 30-minute continuous navigation workload (500 transitions) using Android `dumpsys batterystats --charged <package_name>`.
* **Energy per 1,000 Transitions ($\mu\text{Wh}$)**: Total micro-Watt-hours consumed per 1,000 screen transitions.
* **Battery Capacity Drain ($\text{mAh}$)**: Total milliampere-hours drawn from the battery subsystem.
* **Thermal Delta ($\Delta^\circ\text{C}$)**: Temperature increase recorded via battery/SoC thermal zone sensors:
$$\Delta T = T_{\text{final}} - T_{\text{initial}}$$

---

## 5. User Perception & Quality of Experience (QoE)

### 5.1 Mean Opinion Score (MOS)
Assessed across $N=32$ human participants in a randomized, double-blind study on a 5-point Likert scale:
$$\text{MOS} = \frac{1}{N} \sum_{i=1}^N \frac{S_i + I_i + F_i}{3}$$
where $S_i$ is Perceived Smoothness (1=Stuttering, 5=Buttery smooth), $I_i$ is Perceived Instantaneity (1=Sluggish, 5=Instantaneous), and $F_i$ is Visual Fluidity (1=Frequent jank, 5=No dropped frames).
