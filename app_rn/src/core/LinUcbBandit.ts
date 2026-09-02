import { TelemetryContext } from './types';

export class LinUcbBandit {
  private dimension: number = 5;
  private alpha: number = 0.5; // Exploration parameter
  private tauMin: number = 0.15;
  private tauMax: number = 0.75;
  
  // Weights vector w for threshold estimation
  private weights: number[] = [0.20, 0.25, 0.15, 0.10, 0.30];

  public computeDynamicThreshold(context: TelemetryContext): number {
    const x = [
      context.batteryLevel,
      context.networkRtt,
      context.availableRam,
      context.scrollVelocity,
      context.thermalHeadroom
    ];

    // Compute resource deficiency (1 - x_i)
    let deficiencyScore = 0.0;
    for (let i = 0; i < this.dimension; i++) {
      deficiencyScore += this.weights[i] * (1.0 - x[i]);
    }

    // Dynamic threshold mapped to [tauMin, tauMax]
    const tau = this.tauMin + deficiencyScore * (this.tauMax - this.tauMin);
    return Math.max(this.tauMin, Math.min(this.tauMax, tau));
  }
}
