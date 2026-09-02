export class MarkovPredictor {
  private transitionCounts: Map<string, Map<string, number>> = new Map();
  private globalVisits: Map<string, number> = new Map();
  private totalVisits: number = 0;
  private alpha: number = 0.05; // Laplace smoothing
  private decayFactor: number = 0.98; // Concept drift decay
  private coldStartHorizon: number = 15;

  public recordTransition(fromRoute: string, toRoute: string): void {
    // 1. Update global popularity
    const currentVisits = this.globalVisits.get(toRoute) || 0;
    this.globalVisits.set(toRoute, currentVisits + 1);
    this.totalVisits += 1;

    // 2. Update transition matrix
    if (!this.transitionCounts.has(fromRoute)) {
      this.transitionCounts.set(fromRoute, new Map());
    }
    const fromMap = this.transitionCounts.get(fromRoute)!;
    const currentCount = fromMap.get(toRoute) || 0;
    fromMap.set(toRoute, currentCount + 1);

    // Apply exponential decay to prevent concept drift
    for (const [, map] of this.transitionCounts.entries()) {
      for (const [route, count] of map.entries()) {
        map.set(route, count * this.decayFactor);
      }
    }
  }

  public getEffectiveProbability(fromRoute: string, toRoute: string, sessionStep: number): number {
    const globalPrior = this.totalVisits > 0 ? (this.globalVisits.get(toRoute) || 0) / this.totalVisits : 0.2;

    const fromMap = this.transitionCounts.get(fromRoute);
    let markovProb = 0.0;
    if (fromMap) {
      let totalTransitions = 0;
      for (const count of fromMap.values()) {
        totalTransitions += count;
      }
      const transitionCount = fromMap.get(toRoute) || 0;
      markovProb = (transitionCount + this.alpha) / (totalTransitions + this.alpha * fromMap.size);
    } else {
      markovProb = globalPrior;
    }

    // Cold-start prior blending for step <= 15
    if (sessionStep <= this.coldStartHorizon) {
      const blendWeight = sessionStep / this.coldStartHorizon;
      return (1.0 - blendWeight) * globalPrior + blendWeight * markovProb;
    }

    return markovProb;
  }
}
