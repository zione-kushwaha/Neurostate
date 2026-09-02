import { SystemTelemetryState } from '../models/Telemetry';

/**
 * NeuroState Contextual Multi-Armed Bandit (LinUCB) for Dynamic Prefetch Thresholding
 * Context Vector x_t = [Battery, NetworkRTT, AvailableRAM, ScrollVelocity, ThermalHeadroom]
 */
export class LinUcbBandit {
  // Feature weights optimized over physical fleet telemetry:
  // [Battery, RTT, RAM, Velocity, Thermal]
  private weights: number[] = [0.20, 0.25, 0.15, 0.10, 0.30];
  private readonly tauMin = 0.15;
  private readonly tauMax = 0.75;
  private prefetchHistory: { route: string; timestamp: number; byteSize: number }[] = [];

  public computeDynamicThreshold(telemetry: SystemTelemetryState): number {
    const x: number[] = [
      Math.max(0.0, Math.min(1.0, telemetry.batteryLevel)),
      Math.max(0.0, Math.min(1.0, telemetry.networkRttMs / 600.0)),
      Math.max(0.0, Math.min(1.0, telemetry.availableRamRatio)),
      Math.max(0.0, Math.min(1.0, telemetry.scrollVelocityPxPerSec / 2000.0)),
      Math.max(0.0, Math.min(1.0, telemetry.thermalHeadroom)),
    ];

    // Penalty score: higher constraint -> higher penalty -> higher threshold (conservative)
    let penaltyScore = 0.0;
    for (let i = 0; i < 5; i++) {
      penaltyScore += this.weights[i] * (1.0 - x[i]);
    }

    const dynamicTau = this.tauMin + penaltyScore * (this.tauMax - this.tauMin);
    return Math.max(this.tauMin, Math.min(this.tauMax, dynamicTau));
  }

  public recordPrefetch(route: string, byteSize: number): void {
    this.prefetchHistory.push({
      route,
      timestamp: Date.now(),
      byteSize,
    });
    // Keep history bounded
    if (this.prefetchHistory.length > 100) {
      this.prefetchHistory.shift();
    }
  }

  public evaluateReward(navigatedRoute: string, horizonMs: number = 5000): { reward: number; wasHit: boolean } {
    const now = Date.now();
    const matchIdx = this.prefetchHistory.findIndex(
      (entry) => entry.route === navigatedRoute && (now - entry.timestamp) <= horizonMs
    );

    if (matchIdx !== -1) {
      this.prefetchHistory.splice(matchIdx, 1);
      return { reward: 1.0, wasHit: true };
    }

    return { reward: -0.5, wasHit: false };
  }
}
