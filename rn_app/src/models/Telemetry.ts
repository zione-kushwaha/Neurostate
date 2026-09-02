export interface TelemetryLog {
  timestamp: number;
  route: string;
  ttiMs: number;
  isSpeculativeHit: boolean;
  frameBuildMs: number;
  isJanky: boolean;
  predictedProbability: number;
  thresholdTau: number;
  wastedBytes: number;
}

export interface SystemTelemetryState {
  batteryLevel: number; // 0.0 - 1.0
  networkRttMs: number; // e.g. 15ms (5G), 80ms (4G), 350ms (3G)
  availableRamRatio: number; // 0.0 - 1.0
  scrollVelocityPxPerSec: number;
  thermalHeadroom: number; // 1.0 = cool, 0.0 = throttling
}
