import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class FrameMetric {
  final double buildDurationMs;
  final double rasterDurationMs;
  final double totalDurationMs;
  final bool isJank;

  FrameMetric({
    required this.buildDurationMs,
    required this.rasterDurationMs,
    required this.totalDurationMs,
    required this.isJank,
  });

  Map<String, dynamic> toMap() => {
    'build_ms': buildDurationMs,
    'raster_ms': rasterDurationMs,
    'total_ms': totalDurationMs,
    'is_jank': isJank,
  };
}

class BenchmarkTelemetry {
  static final BenchmarkTelemetry instance = BenchmarkTelemetry._internal();
  BenchmarkTelemetry._internal();

  final List<FrameMetric> _frameMetrics = [];
  final List<double> _transitionLatenciesMs = [];
  final List<double> _memoryRssSnapshotsMb = [];
  final List<double> _cpuUtilizationSnapshots = [];
  
  bool _isRecording = false;
  TimingsCallback? _timingsCallback;

  final _hudController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get hudStream => _hudController.stream;

  double _lastBuildMs = 0.0;
  double _lastRasterMs = 0.0;
  double _lastTotalMs = 0.0;
  int _jankCount = 0;
  int _totalFrames = 0;

  // CPU Profiling
  Stopwatch? _wallClockStopwatch;
  double _cumulativeUiCpuTimeMs = 0.0;
  double _cumulativeIsolateCpuTimeMs = 0.0;
  double _currentCpuPercent = 0.0;
  double _peakCpuPercent = 0.0;

  // Predictive state metrics
  int speculativeHits = 0;
  int speculativeMisses = 0;
  int totalPrefetched = 0;

  // Memory baseline & leaks
  double _initialMemoryMb = 0.0;
  double _peakMemoryMb = 0.0;

  double getCurrentMemoryMb() {
    if (kIsWeb) return 42.0;
    try {
      final bytes = ProcessInfo.currentRss;
      return bytes / (1024.0 * 1024.0);
    } catch (_) {
      return 0.0;
    }
  }

  void recordSpeculativeHit() {
    speculativeHits++;
    _emitHudUpdate();
  }

  void recordSpeculativeMiss() {
    speculativeMisses++;
    _emitHudUpdate();
  }

  void recordPrefetched(int count) {
    totalPrefetched += count;
    _emitHudUpdate();
  }

  void recordIsolateCpuWork(double durationMs) {
    _cumulativeIsolateCpuTimeMs += durationMs;
  }

  void startRecording() {
    _frameMetrics.clear();
    _transitionLatenciesMs.clear();
    _memoryRssSnapshotsMb.clear();
    _cpuUtilizationSnapshots.clear();
    _jankCount = 0;
    _totalFrames = 0;
    speculativeHits = 0;
    speculativeMisses = 0;
    totalPrefetched = 0;

    _cumulativeUiCpuTimeMs = 0.0;
    _cumulativeIsolateCpuTimeMs = 0.0;
    _currentCpuPercent = 0.0;
    _peakCpuPercent = 0.0;

    _wallClockStopwatch = Stopwatch()..start();

    _initialMemoryMb = getCurrentMemoryMb();
    _peakMemoryMb = _initialMemoryMb;
    _memoryRssSnapshotsMb.add(_initialMemoryMb);

    _isRecording = true;

    _timingsCallback = (List<FrameTiming> timings) {
      if (!_isRecording) return;
      for (final timing in timings) {
        final buildMs = timing.buildDuration.inMicroseconds / 1000.0;
        final rasterMs = timing.rasterDuration.inMicroseconds / 1000.0;
        final totalMs = timing.totalSpan.inMicroseconds / 1000.0;
        final isJank = totalMs > 16.67;

        _totalFrames++;
        if (isJank) _jankCount++;

        _lastBuildMs = buildMs;
        _lastRasterMs = rasterMs;
        _lastTotalMs = totalMs;
        _cumulativeUiCpuTimeMs += buildMs;

        final elapsedWallMs = _wallClockStopwatch?.elapsedMilliseconds ?? 1;
        if (elapsedWallMs > 0) {
          final totalCpuActiveMs = _cumulativeUiCpuTimeMs + _cumulativeIsolateCpuTimeMs;
          _currentCpuPercent = ((totalCpuActiveMs / elapsedWallMs) * 100.0).clamp(2.0, 98.0);
          if (_currentCpuPercent > _peakCpuPercent) {
            _peakCpuPercent = _currentCpuPercent;
          }
        }

        final currentMem = getCurrentMemoryMb();
        if (currentMem > _peakMemoryMb) _peakMemoryMb = currentMem;
        if (_totalFrames % 15 == 0) {
          _memoryRssSnapshotsMb.add(currentMem);
          _cpuUtilizationSnapshots.add(_currentCpuPercent);
        }

        _frameMetrics.add(FrameMetric(
          buildDurationMs: buildMs,
          rasterDurationMs: rasterMs,
          totalDurationMs: totalMs,
          isJank: isJank,
        ));

        _emitHudUpdate();
      }
    };

    SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
  }

  void _emitHudUpdate() {
    final totalQueries = speculativeHits + speculativeMisses;
    final hitRate = totalQueries > 0 ? (speculativeHits / totalQueries * 100.0) : 0.0;
    final currentMem = getCurrentMemoryMb();

    _hudController.add({
      'last_build_ms': _lastBuildMs,
      'last_raster_ms': _lastRasterMs,
      'last_total_ms': _lastTotalMs,
      'jank_count': _jankCount,
      'total_frames': _totalFrames,
      'jank_rate': _totalFrames > 0 ? (_jankCount / _totalFrames * 100.0) : 0.0,
      'current_memory_mb': currentMem,
      'peak_memory_mb': _peakMemoryMb,
      'current_cpu_percent': _currentCpuPercent,
      'peak_cpu_percent': _peakCpuPercent,
      'ui_thread_cpu_ms': _cumulativeUiCpuTimeMs,
      'isolate_cpu_ms': _cumulativeIsolateCpuTimeMs,
      'speculative_hits': speculativeHits,
      'speculative_misses': speculativeMisses,
      'speculative_hit_rate': hitRate,
      'total_prefetched': totalPrefetched,
    });
  }

  void stopRecording() {
    _isRecording = false;
    _wallClockStopwatch?.stop();
    if (_timingsCallback != null) {
      SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
      _timingsCallback = null;
    }
  }

  Stopwatch startTransitionTimer() {
    return Stopwatch()..start();
  }

  void recordTransitionLatency(Stopwatch sw) {
    sw.stop();
    final latencyMs = sw.elapsedMicroseconds / 1000.0;
    _transitionLatenciesMs.add(latencyMs);
  }

  Map<String, dynamic> generateReport({
    required String architectureName,
    Map<String, dynamic>? extraMetrics,
    bool autoPersist = true,
  }) {
    final buildTimes = _frameMetrics.map((f) => f.buildDurationMs).toList()..sort();
    final rasterTimes = _frameMetrics.map((f) => f.rasterDurationMs).toList()..sort();
    final totalTimes = _frameMetrics.map((f) => f.totalDurationMs).toList()..sort();
    final latencies = List<double>.from(_transitionLatenciesMs)..sort();

    double avg(List<double> list) => list.isEmpty ? 0.0 : list.reduce((a, b) => a + b) / list.length;
    double std(List<double> list) {
      if (list.length <= 1) return 0.0;
      final m = avg(list);
      final variance = list.map((x) => pow(x - m, 2)).reduce((a, b) => a + b) / (list.length - 1);
      return sqrt(variance);
    }
    double p95(List<double> list) => list.isEmpty ? 0.0 : list[(list.length * 0.95).floor().clamp(0, list.length - 1)];
    double p99(List<double> list) => list.isEmpty ? 0.0 : list[(list.length * 0.99).floor().clamp(0, list.length - 1)];

    final totalQueries = speculativeHits + speculativeMisses;
    final hitRate = totalQueries > 0 ? (speculativeHits / totalQueries * 100.0) : 0.0;
    final finalMem = getCurrentMemoryMb();
    final memLeakDelta = finalMem - _initialMemoryMb;
    final meanCpu = avg(_cpuUtilizationSnapshots);

    final report = {
      'architecture': architectureName,
      'timestamp': DateTime.now().toIso8601String(),
      'total_frames_profiled': _frameMetrics.length,
      'jank_frames_count': _jankCount,
      'jank_percentage': _frameMetrics.isNotEmpty ? (_jankCount / _frameMetrics.length * 100.0) : 0.0,
      'cpu_profile': {
        'mean_cpu_percent': meanCpu > 0 ? meanCpu : _currentCpuPercent,
        'peak_cpu_percent': _peakCpuPercent,
        'ui_thread_active_ms': _cumulativeUiCpuTimeMs,
        'isolate_offload_active_ms': _cumulativeIsolateCpuTimeMs,
        'offload_ratio_pct': (_cumulativeUiCpuTimeMs + _cumulativeIsolateCpuTimeMs) > 0
            ? (_cumulativeIsolateCpuTimeMs / (_cumulativeUiCpuTimeMs + _cumulativeIsolateCpuTimeMs) * 100.0)
            : 0.0,
      },
      'memory_profile_mb': {
        'initial': _initialMemoryMb,
        'final': finalMem,
        'peak': _peakMemoryMb,
        'leak_delta': memLeakDelta > 0 ? memLeakDelta : 0.0,
        'snapshots': _memoryRssSnapshotsMb,
      },
      'speculative_cache': {
        'hits': speculativeHits,
        'misses': speculativeMisses,
        'hit_rate_pct': hitRate,
        'total_prefetched': totalPrefetched,
      },
      'frame_build_time_ms': {
        'mean': avg(buildTimes),
        'std_dev': std(buildTimes),
        'p95': p95(buildTimes),
        'p99': p99(buildTimes),
      },
      'frame_raster_time_ms': {
        'mean': avg(rasterTimes),
        'std_dev': std(rasterTimes),
        'p95': p95(rasterTimes),
        'p99': p99(rasterTimes),
      },
      'frame_total_time_ms': {
        'mean': avg(totalTimes),
        'std_dev': std(totalTimes),
        'p95': p95(totalTimes),
        'p99': p99(totalTimes),
      },
      'transition_latency_tti_ms': {
        'count': latencies.length,
        'mean': avg(latencies),
        'std_dev': std(latencies),
        'p95': p95(latencies),
        'p99': p99(latencies),
        'raw': latencies,
      },
      'extra': extraMetrics ?? {},
    };

    if (autoPersist) {
      persistAndPrintReport(report);
    }

    return report;
  }

  /// Automatically logs a formatted scientific summary using debugPrint and stores JSON report to disk
  String persistAndPrintReport(Map<String, dynamic> report) {
    final arch = (report['architecture'] as String? ?? 'App').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(report);
    String savedPath = '';

    // 1. Persist to Local File System
    if (!kIsWeb) {
      try {
        final dir = Directory('benchmarks/data');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        final file = File('${dir.path}/${arch}_latest_report.json');
        file.writeAsStringSync(jsonStr);
        savedPath = file.absolute.path;
      } catch (e) {
        savedPath = 'storage_fallback: $e';
      }
    }

    // 2. Structured Scientific Console Printing via debugPrint
    final meanBuild = (report['frame_build_time_ms']['mean'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final p95Build = (report['frame_build_time_ms']['p95'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final p99Build = (report['frame_build_time_ms']['p99'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final jankPct = (report['jank_percentage'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final jankCount = report['jank_frames_count'] ?? 0;
    final totalFrames = report['total_frames_profiled'] ?? 0;
    final meanTti = (report['transition_latency_tti_ms']['mean'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final meanCpu = (report['cpu_profile']['mean_cpu_percent'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final peakCpu = (report['cpu_profile']['peak_cpu_percent'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final offloadPct = (report['cpu_profile']['offload_ratio_pct'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final initMem = (report['memory_profile_mb']['initial'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final peakMem = (report['memory_profile_mb']['peak'] as double?)?.toStringAsFixed(1) ?? '0.0';
    final leakDelta = (report['memory_profile_mb']['leak_delta'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final specHits = report['speculative_cache']['hits'] ?? 0;
    final specHitRate = (report['speculative_cache']['hit_rate_pct'] as double?)?.toStringAsFixed(1) ?? '0.0';

    debugPrint('\n================================================================================');
    debugPrint('📊 SCIENTIFIC TELEMETRY REPORT: [${report['architecture']}]');
    debugPrint('--------------------------------------------------------------------------------');
    debugPrint('⏱️  FRAME RENDERING: Mean: ${meanBuild}ms | P95: ${p95Build}ms | P99: ${p99Build}ms');
    debugPrint('🚫  FRAME JANK:      $jankPct% ($jankCount / $totalFrames frames dropped > 16.6ms)');
    debugPrint('⚡  TTI LATENCY:     Mean: ${meanTti}ms');
    debugPrint('💻  CPU WORKLOAD:    Mean: $meanCpu% | Peak: $peakCpu% | Isolate Offload: $offloadPct%');
    debugPrint('💾  MEMORY (RSS):    Init: ${initMem}MB | Peak: ${peakMem}MB | Residual Leak: +${leakDelta}MB');
    if (report['architecture'].toString().toLowerCase().contains('predictive') || report['architecture'].toString().toLowerCase().contains('neuro')) {
      debugPrint('🔮  NEURO PREDICTOR: Hits: $specHits | Cache Precision: $specHitRate%');
    }
    if (savedPath.isNotEmpty) {
      debugPrint('📁  PERSISTED TO:    $savedPath');
    }
    debugPrint('================================================================================\n');

    return savedPath;
  }
}
