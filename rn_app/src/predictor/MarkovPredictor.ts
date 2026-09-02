/**
 * NeuroState Higher-Order Markov Trajectory Predictor for React Native
 * Supports 1st/2nd-Order Katz Backoff, Dirichlet Prior Smoothing, and Cold-Start Blending.
 */
export class MarkovPredictor {
  private firstOrderCounts = new Map<string, Map<string, number>>();
  private secondOrderCounts = new Map<string, Map<string, Map<string, number>>>();
  private globalVisits = new Map<string, number>();
  private totalVisits = 0;
  private previousRoute: string | null = null;
  private currentRoute: string = 'Feed';
  private stepCount = 0;
  private readonly alpha = 0.05; // Laplace smoothing
  private readonly decayFactor = 0.98; // Exponential concept drift decay

  public recordTransition(toRoute: string): void {
    this.stepCount += 1;
    this.globalVisits.set(toRoute, (this.globalVisits.get(toRoute) || 0) + 1);
    this.totalVisits += 1;

    // Apply exponential decay periodically
    if (this.stepCount % 50 === 0) {
      this.applyDecay();
    }

    // 1st-Order Transition: current -> toRoute
    if (!this.firstOrderCounts.has(this.currentRoute)) {
      this.firstOrderCounts.set(this.currentRoute, new Map());
    }
    const firstMap = this.firstOrderCounts.get(this.currentRoute)!;
    firstMap.set(toRoute, (firstMap.get(toRoute) || 0) + 1);

    // 2nd-Order Transition: previous -> current -> toRoute
    if (this.previousRoute) {
      if (!this.secondOrderCounts.has(this.previousRoute)) {
        this.secondOrderCounts.set(this.previousRoute, new Map());
      }
      const secondMap = this.secondOrderCounts.get(this.previousRoute)!;
      if (!secondMap.has(this.currentRoute)) {
        secondMap.set(this.currentRoute, new Map());
      }
      const targetMap = secondMap.get(this.currentRoute)!;
      targetMap.set(toRoute, (targetMap.get(toRoute) || 0) + 1);
    }

    this.previousRoute = this.currentRoute;
    this.currentRoute = toRoute;
  }

  public getTransitionProbability(targetRoute: string): number {
    const globalPrior = this.totalVisits > 0
      ? (this.globalVisits.get(targetRoute) || 0) / this.totalVisits
      : 0.20;

    // 1st-Order Probability
    let p1 = globalPrior;
    const firstMap = this.firstOrderCounts.get(this.currentRoute);
    if (firstMap) {
      let sum = 0;
      for (const count of firstMap.values()) sum += count;
      const count = firstMap.get(targetRoute) || 0;
      p1 = (count + this.alpha) / (sum + this.alpha * (firstMap.size || 1));
    }

    // 2nd-Order Katz Backoff Probability
    let p2 = p1;
    if (this.previousRoute && this.secondOrderCounts.has(this.previousRoute)) {
      const secondMap = this.secondOrderCounts.get(this.previousRoute)!;
      if (secondMap.has(this.currentRoute)) {
        const targetMap = secondMap.get(this.currentRoute)!;
        let sum2 = 0;
        for (const count of targetMap.values()) sum2 += count;
        if (sum2 >= 2) {
          const count2 = targetMap.get(targetRoute) || 0;
          p2 = (count2 + this.alpha) / (sum2 + this.alpha * (targetMap.size || 1));
        }
      }
    }

    // Cold-Start Dynamic Prior Blending (Eq. 6)
    if (this.stepCount <= 15) {
      const blend = this.stepCount / 15.0;
      return (1.0 - blend) * globalPrior + blend * p2;
    }

    return p2;
  }

  public getTopPredictions(allRoutes: string[], threshold: number): string[] {
    return allRoutes.filter((route) => {
      if (route === this.currentRoute) return false;
      return this.getTransitionProbability(route) >= threshold;
    });
  }

  private applyDecay(): void {
    for (const [, map] of this.firstOrderCounts) {
      for (const [key, val] of map) {
        map.set(key, val * this.decayFactor);
      }
    }
    for (const [key, val] of this.globalVisits) {
      this.globalVisits.set(key, val * this.decayFactor);
    }
  }

  public getStepCount(): number {
    return this.stepCount;
  }
}
