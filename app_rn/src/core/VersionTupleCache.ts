import { CacheEntry, VersionTuple } from './types';

export class VersionTupleCache {
  private capacity: number;
  private cache: Map<string, CacheEntry> = new Map();

  constructor(capacity: number = 50) {
    this.capacity = capacity;
  }

  public get(key: string): CacheEntry | undefined {
    const entry = this.cache.get(key);
    if (entry) {
      entry.accessCount += 1;
      // Refresh LRU order
      this.cache.delete(key);
      this.cache.set(key, entry);
    }
    return entry;
  }

  public put(key: string, dataBuffer: ArrayBuffer, version: VersionTuple): void {
    if (this.cache.size >= this.capacity) {
      // Evict oldest entry (LRU)
      const oldestKey = this.cache.keys().next().value;
      if (oldestKey) {
        this.cache.delete(oldestKey);
      }
    }

    this.cache.set(key, {
      key,
      dataBuffer,
      version,
      createdAt: Date.now(),
      accessCount: 1
    });
  }

  public invalidateIfStale(key: string, incomingServerVersion: number): boolean {
    const entry = this.cache.get(key);
    if (entry && incomingServerVersion > entry.version.serverVersion) {
      this.cache.delete(key);
      return true; // Evicted due to stale version
    }
    return false;
  }

  public clear(): void {
    this.cache.clear();
  }

  public size(): number {
    return this.cache.size;
  }
}
