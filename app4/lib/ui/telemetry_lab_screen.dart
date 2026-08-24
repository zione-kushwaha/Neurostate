import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/predictive_state_container.dart';
import '../services/benchmark_telemetry.dart';
import 'detail_screen.dart';

class TelemetryLabScreen extends StatefulWidget {
  final String architectureName;
  final PredictiveStateContainer stateContainer;

  const TelemetryLabScreen({
    super.key,
    required this.architectureName,
    required this.stateContainer,
  });

  @override
  State<TelemetryLabScreen> createState() => _TelemetryLabScreenState();
}

class _TelemetryLabScreenState extends State<TelemetryLabScreen> {
  bool _isStressTesting = false;
  String? _lastTestSummary;
  int _currentCycle = 0;
  final int _totalCycles = 25;

  Future<void> _runMemoryLeakStressTest() async {
    if (_isStressTesting) return;
    setState(() {
      _isStressTesting = true;
      _lastTestSummary = null;
      _currentCycle = 0;
    });

    final initialMem = BenchmarkTelemetry.instance.getCurrentMemoryMb();
    BenchmarkTelemetry.instance.startRecording();

    try {
      for (int i = 1; i <= _totalCycles; i++) {
        if (!mounted) break;
        setState(() => _currentCycle = i);

        final route = MaterialPageRoute(
          builder: (_) => DetailScreen(
            articleId: (i % 20) + 1,
            stateContainer: widget.stateContainer,
          ),
        );
        Navigator.push(context, route);
        await Future.delayed(const Duration(milliseconds: 60));
        if (mounted) Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 30));
      }

      await Future.delayed(const Duration(milliseconds: 300));
      final finalMem = BenchmarkTelemetry.instance.getCurrentMemoryMb();
      final leakDelta = (finalMem - initialMem).clamp(0.0, 999.0);

      final report = BenchmarkTelemetry.instance.generateReport(
        architectureName: widget.architectureName,
      );

      final spec = (report['speculative_cache'] as Map<String, dynamic>?) ?? {};
      final cpuProfile = (report['cpu_profile'] as Map<String, dynamic>?) ?? {};

      setState(() {
        _lastTestSummary = "✅ NeuroState Stress test completed ($_totalCycles Cycles).\n"
            "• Mean CPU Load: ${((cpuProfile['mean_cpu_percent'] ?? 0.0) as double).toStringAsFixed(1)}% (Peak: ${((cpuProfile['peak_cpu_percent'] ?? 0.0) as double).toStringAsFixed(1)}%)\n"
            "• Isolate Background Offload: ${((cpuProfile['offload_ratio_pct'] ?? 0.0) as double).toStringAsFixed(1)}%\n"
            "• Initial Memory: ${initialMem.toStringAsFixed(2)} MB\n"
            "• Final Memory: ${finalMem.toStringAsFixed(2)} MB\n"
            "• Residual Memory Delta: +${leakDelta.toStringAsFixed(2)} MB\n"
            "• Speculative Hits: ${spec['hits'] ?? 0} (${((spec['hit_rate_pct'] ?? 0.0) as double).toStringAsFixed(1)}% Hit Rate)\n"
            "• Mean Frame Build Time: ${(report['frame_build_time_ms']['mean'] as double).toStringAsFixed(2)} ms\n"
            "• P95 Build Time: ${(report['frame_build_time_ms']['p95'] as double).toStringAsFixed(2)} ms\n"
            "• Jank Rate: ${(report['jank_percentage'] as double).toStringAsFixed(2)}%";
      });
    } finally {
      if (mounted) setState(() => _isStressTesting = false);
    }
  }

  void _exportJsonReport() {
    final report = BenchmarkTelemetry.instance.generateReport(architectureName: widget.architectureName);
    final jsonStr = report.toString();
    Clipboard.setData(ClipboardData(text: jsonStr));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Benchmark telemetry copied to clipboard!"),
        backgroundColor: Color(0xFF00E5FF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151D2A),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Research Telemetry & Memory Lab", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text("NeuroState Speculative Execution Profiler", style: TextStyle(fontSize: 11, color: Color(0xFF00E5FF))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all, color: Colors.white70),
            tooltip: "Copy JSON Report",
            onPressed: _exportJsonReport,
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: BenchmarkTelemetry.instance.hudStream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? {};
          final currentMem = (data['current_memory_mb'] as double?) ?? BenchmarkTelemetry.instance.getCurrentMemoryMb();
          final peakMem = (data['peak_memory_mb'] as double?) ?? currentMem;
          final currentCpu = (data['current_cpu_percent'] as double?) ?? 0.0;
          final peakCpu = (data['peak_cpu_percent'] as double?) ?? currentCpu;
          final uiCpuMs = (data['ui_thread_cpu_ms'] as double?) ?? 0.0;
          final buildMs = (data['last_build_ms'] as double?) ?? 0.0;
          final rasterMs = (data['last_raster_ms'] as double?) ?? 0.0;
          final totalMs = (data['last_total_ms'] as double?) ?? 0.0;
          final jankCount = (data['jank_count'] as int?) ?? 0;
          final totalFrames = (data['total_frames'] as int?) ?? 0;
          final jankRate = (data['jank_rate'] as double?) ?? 0.0;
          final specHits = (data['speculative_hits'] as int?) ?? 0;
          final hitRate = (data['speculative_hit_rate'] as double?) ?? 0.0;
          final prefetched = (data['total_prefetched'] as int?) ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // CPU & Isolate Offload Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00E5FF).withAlpha(120)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.developer_board, color: Color(0xFF00E5FF), size: 18),
                        SizedBox(width: 8),
                        Text("CPU UTILIZATION & ISOLATE THREAD OFFLOAD", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _labMetric("Active CPU", "${currentCpu.toStringAsFixed(1)}%", const Color(0xFF00E5FF)),
                        _labMetric("Peak CPU", "${peakCpu.toStringAsFixed(1)}%", Colors.orangeAccent),
                        _labMetric("UI Thread Active", "${uiCpuMs.toStringAsFixed(0)} ms", Colors.cyanAccent),
                        _labMetric("Isolate Workers", "Dedicated Pool", Colors.greenAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Speculative Engine Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF24334A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt, color: Color(0xFF00E5FF), size: 18),
                        SizedBox(width: 8),
                        Text("PREDICTIVE SPECULATIVE CACHE", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _labMetric("Speculative Hits", "$specHits", const Color(0xFF00E5FF)),
                        _labMetric("Hit Precision", "${hitRate.toStringAsFixed(1)}%", Colors.greenAccent),
                        _labMetric("Pre-warmed Items", "$prefetched", Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Memory Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF24334A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.memory, color: Color(0xFF00C896), size: 18),
                        SizedBox(width: 8),
                        Text("DART VM RESIDENT MEMORY (RSS)", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _labMetric("Current RSS", "${currentMem.toStringAsFixed(1)} MB", const Color(0xFF00C896)),
                        _labMetric("Peak Footprint", "${peakMem.toStringAsFixed(1)} MB", Colors.orangeAccent),
                        _labMetric("Profiled Frames", "$totalFrames", Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Rendering Timing Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF24334A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.speed, color: Color(0xFF00E5FF), size: 18),
                        SizedBox(width: 8),
                        Text("FRAME TIMING & JANK PROFILE", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _labMetric("Build Time", "${buildMs.toStringAsFixed(2)} ms", Colors.white),
                        _labMetric("Raster Time", "${rasterMs.toStringAsFixed(2)} ms", Colors.white70),
                        _labMetric("Total Frame", "${totalMs.toStringAsFixed(2)} ms", totalMs > 16.6 ? Colors.redAccent : Colors.cyanAccent),
                        _labMetric("Jank Frames", "$jankCount (${jankRate.toStringAsFixed(1)}%)", jankCount > 0 ? Colors.amber : Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isStressTesting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.flash_on, size: 18),
                label: Text(
                  _isStressTesting ? "RUNNING STRESS CYCLE ($_currentCycle/$_totalCycles)..." : "RUN 25-CYCLE CPU & MEMORY STRESS TEST",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: _isStressTesting ? null : _runMemoryLeakStressTest,
              ),

              if (_lastTestSummary != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00E5FF).withAlpha(100)),
                  ),
                  child: Text(
                    _lastTestSummary!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _labMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}
