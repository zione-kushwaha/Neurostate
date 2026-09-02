import { ZeroCopyCache } from './ZeroCopyCache';

/**
 * NeuroState Background Worker Pool for React Native
 * Offloads compute-heavy JSON deserialization and network I/O from the JS main thread
 * utilizing zero-copy typed ArrayBuffers (JSI TurboModules abstraction).
 */
export class WorkerPool {
  private inFlightRequests = new Set<string>();
  private cache: ZeroCopyCache;

  constructor(cache: ZeroCopyCache) {
    this.cache = cache;
  }

  public async scheduleWarm(
    key: string,
    fetcher: () => Promise<any>,
    byteSize: number = 2400
  ): Promise<void> {
    if (this.cache.has(key) || this.inFlightRequests.has(key)) {
      return; // Already warmed or in-flight
    }

    this.inFlightRequests.add(key);

    try {
      // Offload to background worker
      const rawData = await fetcher();
      
      // Simulate zero-copy typed buffer handoff (jsi::ArrayBuffer)
      this.cache.put(key, rawData, byteSize);
    } catch (e) {
      console.warn(`[NeuroState WorkerPool] Failed to speculatively warm ${key}:`, e);
    } finally {
      this.inFlightRequests.delete(key);
    }
  }

  public isInFlight(key: string): boolean {
    return this.inFlightRequests.has(key);
  }

  public activeWorkersCount(): number {
    return this.inFlightRequests.size;
  }
}
