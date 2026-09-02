export interface TelemetryContext {
  batteryLevel: number;      // 0.0 to 1.0
  networkRtt: number;        // Normalized (rtt / 1000)
  availableRam: number;      // Normalized (free / total)
  scrollVelocity: number;    // Normalized (v / v_max)
  thermalHeadroom: number;   // 0.0 (throttling) to 1.0 (cool)
}

export interface VersionTuple {
  clientVersion: number;
  serverVersion: number;
  timestamp: number;
}

export interface CacheEntry {
  key: string;
  dataBuffer: ArrayBuffer;
  version: VersionTuple;
  createdAt: number;
  accessCount: number;
}

export interface BenchmarkSample {
  iteration: number;
  frameBuildMs: number;
  jsEventLagMs: number;
  totalFrameMs: number;
  isJank: boolean;
  hitTtiMs: number;
  effectiveTtiMs: number;
  rssMb: number;
  cpuUtilPct: number;
}

export interface ArchitectureBenchmarkSummary {
  architecture: string;
  runtime: string;
  meanFrameBuildMs: number;
  jankPercentage: number;
  speculativeHitTtiMs: number;
  effectiveTtiMs: number;
  speedupVsStandard: number;
  cpuLoadPct: number;
  workerOffloadPct: number;
  peakRssMb: number;
  samples: BenchmarkSample[];
}
