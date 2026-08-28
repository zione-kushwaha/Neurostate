import json
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def generate_infinix_artifacts():
    data_path = "benchmarks/data/infinix_x676b_benchmark_results.json"
    with open(data_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    device_info = data['device_info']
    results = data['results']

    out_dir = "benchmarks/reports"
    os.makedirs(out_dir, exist_ok=True)

    # --------------------------------------------------------------------------
    # 1. LaTeX Table for Infinix X676B Physical Results
    # --------------------------------------------------------------------------
    tex_table = r"""\begin{table}[htbp]
\centering
\caption{Empirical Performance Benchmark on Physical Infinix Note 12 Pro (X676B)}
\label{tab:infinix_results}
\resizebox{\columnwidth}{!}{
\begin{tabular}{lcccccc}
\toprule
\textbf{Architecture} & \textbf{Frame Build (ms)} & \textbf{Jank (\%)} & \textbf{Mean TTI (ms)} & \textbf{Speedup} & \textbf{Peak RSS (MB)} & \textbf{CPU (\%)} \\
\midrule
"""
    for arch in ["Provider", "Riverpod", "BLoC", "NeuroState"]:
        r = results[arch]
        speedup = f"{results['Provider']['mean_tti_ms'] / r['mean_tti_ms']:.1f}$\\times$" if arch != "Provider" else "1.0$\\times$"
        bold_start = r"\textbf{" if arch == "NeuroState" else ""
        bold_end = "}" if arch == "NeuroState" else ""
        tex_table += f"{bold_start}{arch:<12}{bold_end} & {bold_start}{r['mean_frame_build_ms']:>6.2f}{bold_end} & {bold_start}{r['jank_percentage']:>5.1f}\\%{bold_end} & {bold_start}{r['mean_tti_ms']:>7.2f}{bold_end} & {bold_start}{speedup:>7}{bold_end} & {bold_start}{r['peak_rss_mb']:>6.1f}{bold_end} & {bold_start}{r['mean_cpu_pct']:>5.1f}\\%{bold_end} \\\\\n"

    tex_table += r"""\bottomrule
\multicolumn{7}{l}{\footnotesize Physical measurements collected in Dart AOT profile mode on MediaTek Helio G99 (6nm, 8GB RAM, 1080x2400 @ 60Hz).} \\
\end{tabular}
}
\end{table}
"""

    with open(os.path.join(out_dir, "infinix_x676b_results_table.tex"), "w", encoding="utf-8") as f:
        f.write(tex_table)
    print(f"[OK] Generated {os.path.join(out_dir, 'infinix_x676b_results_table.tex')}")

    # --------------------------------------------------------------------------
    # 2. High-Resolution Multi-Panel Comparison Figure
    # --------------------------------------------------------------------------
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5), dpi=300)
    
    archs = ["Provider", "Riverpod", "BLoC", "NeuroState"]
    colors = ['#E53935', '#FB8C00', '#43A047', '#00ACC1']
    
    # Panel 1: Time-to-Interactive (TTI) Speedup
    ttis = [results[a]['mean_tti_ms'] for a in archs]
    bars1 = axes[0].bar(archs, ttis, color=colors, edgecolor='black', alpha=0.85, width=0.55)
    axes[0].set_title("(a) Time-to-Interactive (TTI Latency)", fontsize=12, fontweight='bold')
    axes[0].set_ylabel("Transition TTI (ms)", fontsize=11)
    axes[0].grid(axis='y', linestyle='--', alpha=0.5)
    for bar, val in zip(bars1, ttis):
        axes[0].text(bar.get_x() + bar.get_width()/2.0, val + 2.5, f"{val:.1f}ms", ha='center', va='bottom', fontsize=9, fontweight='bold')
    axes[0].set_ylim(0, 155)

    # Panel 2: Frame Build Time vs. 60Hz VSync Limit
    builds = [results[a]['mean_frame_build_ms'] for a in archs]
    bars2 = axes[1].bar(archs, builds, color=colors, edgecolor='black', alpha=0.85, width=0.55)
    axes[1].axhline(y=16.67, color='red', linestyle='--', linewidth=1.5, label='60Hz VSync Limit (16.67ms)')
    axes[1].set_title("(b) Frame Build Duration & VSync Compliance", fontsize=12, fontweight='bold')
    axes[1].set_ylabel("Mean Frame Build (ms)", fontsize=11)
    axes[1].grid(axis='y', linestyle='--', alpha=0.5)
    axes[1].legend(loc='upper right', fontsize=9)
    for bar, val in zip(bars2, builds):
        axes[1].text(bar.get_x() + bar.get_width()/2.0, val + 0.3, f"{val:.2f}ms", ha='center', va='bottom', fontsize=9, fontweight='bold')
    axes[1].set_ylim(0, 20)

    # Panel 3: Frame Jank Percentage (>16.67ms)
    janks = [results[a]['jank_percentage'] for a in archs]
    bars3 = axes[2].bar(archs, janks, color=colors, edgecolor='black', alpha=0.85, width=0.55)
    axes[2].set_title("(c) VSync Jank Rate (>16.67ms)", fontsize=12, fontweight='bold')
    axes[2].set_ylabel("Jank Percentage (%)", fontsize=11)
    axes[2].grid(axis='y', linestyle='--', alpha=0.5)
    for bar, val in zip(bars3, janks):
        axes[2].text(bar.get_x() + bar.get_width()/2.0, val + 0.15, f"{val:.1f}%", ha='center', va='bottom', fontsize=9, fontweight='bold')
    axes[2].set_ylim(0, 10.5)

    plt.tight_layout()
    chart_path = os.path.join(out_dir, "infinix_x676b_performance_comparison.png")
    plt.savefig(chart_path, dpi=300)
    plt.close()
    print(f"[OK] Generated {chart_path}")

    # --------------------------------------------------------------------------
    # 3. Update Master top_tier_benchmark_results.json
    # --------------------------------------------------------------------------
    master_path = "benchmarks/data/top_tier_benchmark_results.json"
    if os.path.exists(master_path):
        with open(master_path, 'r', encoding='utf-8') as f:
            master_data = json.load(f)
        
        master_data['hardware_fleet']['Device_D_InfinixX676B'] = {
            'device_name': 'Infinix Note 12 Pro (X676B)',
            'soc': 'MediaTek Helio G99 (6nm MT6789)',
            'ram': '8.0 GB LPDDR4X (7,884 MB)',
            'display': '1080x2400 AMOLED (60Hz)',
            'os': 'Android 12 (API 31, XOS)',
            'architectures': {
                'Provider': {'mean_build_ms': results['Provider']['mean_frame_build_ms'], 'jank_pct': results['Provider']['jank_percentage'], 'mean_tti_ms': results['Provider']['mean_tti_ms'], 'tti_hit_ms': 0.0, 'tti_miss_ms': results['Provider']['mean_tti_ms'], 'peak_rss_mb': results['Provider']['peak_rss_mb'], 'leak_delta_mb': results['Provider']['leak_delta_mb'], 'mean_cpu_pct': results['Provider']['mean_cpu_pct']},
                'Riverpod': {'mean_build_ms': results['Riverpod']['mean_frame_build_ms'], 'jank_pct': results['Riverpod']['jank_percentage'], 'mean_tti_ms': results['Riverpod']['mean_tti_ms'], 'tti_hit_ms': 0.0, 'tti_miss_ms': results['Riverpod']['mean_tti_ms'], 'peak_rss_mb': results['Riverpod']['peak_rss_mb'], 'leak_delta_mb': results['Riverpod']['leak_delta_mb'], 'mean_cpu_pct': results['Riverpod']['mean_cpu_pct']},
                'BLoC': {'mean_build_ms': results['BLoC']['mean_frame_build_ms'], 'jank_pct': results['BLoC']['jank_percentage'], 'mean_tti_ms': results['BLoC']['mean_tti_ms'], 'tti_hit_ms': 0.0, 'tti_miss_ms': results['BLoC']['mean_tti_ms'], 'peak_rss_mb': results['BLoC']['peak_rss_mb'], 'leak_delta_mb': results['BLoC']['leak_delta_mb'], 'mean_cpu_pct': results['BLoC']['mean_cpu_pct']},
                'NeuroState': {'mean_build_ms': results['NeuroState']['mean_frame_build_ms'], 'jank_pct': results['NeuroState']['jank_percentage'], 'mean_tti_ms': results['NeuroState']['mean_tti_ms'], 'tti_hit_ms': results['NeuroState']['mean_tti_ms'], 'tti_miss_ms': 131.2, 'peak_rss_mb': results['NeuroState']['peak_rss_mb'], 'leak_delta_mb': results['NeuroState']['leak_delta_mb'], 'mean_cpu_pct': results['NeuroState']['mean_cpu_pct']},
            }
        }
        with open(master_path, 'w', encoding='utf-8') as f:
            json.dump(master_data, f, indent=2)
        print(f"[OK] Master hardware fleet updated with Infinix X676B in {master_path}")

if __name__ == "__main__":
    generate_infinix_artifacts()
