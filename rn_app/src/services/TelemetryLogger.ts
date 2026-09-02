import { TelemetryLog } from '../models/Telemetry';

/**
 * High-Resolution Telemetry and Performance Metrics Logger for React Native
 */
export class TelemetryLogger {
  private logs: TelemetryLog[] = [];
  private totalWastedBytes = 0;
  private totalUsedBytes = 0;

  public recordLog(log: TelemetryLog): void {
    this.logs.push(log);
    if (log.isSpeculativeHit) {
      this.totalUsedBytes += 2400;
    } else {
      this.totalWastedBytes += log.wastedBytes;
    }
  }

  public getSummary() {
    if (this.logs.length === 0) {
      return {
        totalTransitions: 0,
        meanTtiMs: 0,
        hitRatePct: 0,
        jankRatePct: 0,
        wbrPct: 0,
      };
    }

    const total = this.logs.length;
    const hits = this.logs.filter((l) => l.isSpeculativeHit).length;
    const janks = this.logs.filter((l) => l.isJanky).length;
    const sumTti = this.logs.reduce((acc, l) => acc + l.ttiMs, 0);

    const totalNetwork = this.totalUsedBytes + this.totalWastedBytes;
    const wbr = totalNetwork > 0 ? (this.totalWastedBytes / totalNetwork) * 100.0 : 0.0;

    return {
      totalTransitions: total,
      meanTtiMs: parseFloat((sumTti / total).toFixed(2)),
      hitRatePct: parseFloat(((hits / total) * 100.0).toFixed(1)),
      jankRatePct: parseFloat(((janks / total) * 100.0).toFixed(1)),
      wbrPct: parseFloat(wbr.toFixed(1)),
    };
  }

  public getLogs(): TelemetryLog[] {
    return [...this.logs];
  }

  public clear(): void {
    this.logs = [];
    this.totalWastedBytes = 0;
    this.totalUsedBytes = 0;
  }
}
