import 'package:flutter/material.dart';
import '../../services/benchmark_telemetry.dart';

class TelemetryHUD extends StatelessWidget {
  final String architectureName;

  const TelemetryHUD({super.key, required this.architectureName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: BenchmarkTelemetry.instance.hudStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final buildMs = (data['last_build_ms'] as double?) ?? 0.0;
        final totalMs = (data['last_total_ms'] as double?) ?? 0.0;
        final jankCount = (data['jank_count'] as int?) ?? 0;
        final currentMem = (data['current_memory_mb'] as double?) ?? BenchmarkTelemetry.instance.getCurrentMemoryMb();
        final cpuPercent = (data['current_cpu_percent'] as double?) ?? 0.0;

        final isJank = totalMs > 16.67;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C).withAlpha(240),
            border: Border(
              bottom: BorderSide(
                color: isJank ? Colors.redAccent : const Color(0xFF3A3A55),
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withAlpha(50),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF00C896)),
                ),
                child: Text(
                  architectureName,
                  style: const TextStyle(
                    color: Color(0xFF00E6AC),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricCol("CPU", "${cpuPercent.toStringAsFixed(0)}%", cpuPercent > 50 ? Colors.orangeAccent : Colors.cyanAccent),
                    _metricCol("RAM", "${currentMem.toStringAsFixed(0)}MB", const Color(0xFF00C896)),
                    _metricCol("Build", "${buildMs.toStringAsFixed(1)}ms", isJank ? Colors.orangeAccent : Colors.white70),
                    _metricCol("Frame", "${totalMs.toStringAsFixed(1)}ms", isJank ? Colors.redAccent : Colors.greenAccent),
                    _metricCol("Jank", "$jankCount", jankCount > 0 ? Colors.amberAccent : Colors.white60),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricCol(String label, String value, Color valColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(color: valColor, fontSize: 10.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
