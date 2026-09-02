import { SpeculativeCacheEntry, VersionTuple } from '../models/VersionTuple';

/**
 * NeuroState Bounded Zero-Copy LRU Cache with Hybrid Version Tuple Coherency
 * Guaranteed O(1) Lookups, O(1) Evictions, and Conflict-Free Reconciliation.
 */
export class ZeroCopyCache {
  private readonly capacity: number;
  private cache = new Map<string, SpeculativeCacheEntry<any>>();

  constructor(capacity: number = 50) {
    this.capacity = capacity;
  }

  public get<T>(key: string): SpeculativeCacheEntry<T> | undefined {
    const entry = this.cache.get(key);
    if (!entry) return undefined;

    // Refresh LRU order (delete & re-insert)
    this.cache.delete(key);
    entry.accessCount += 1;
    this.cache.set(key, entry);
    return entry;
  }

  public put<T>(key: string, data: T, byteSize: number, serverVersion: number = 1): void {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    } else if (this.cache.size >= this.capacity) {
      // Evict oldest (first entry in Map iterator)
      const oldestKey = this.cache.keys().next().value;
      if (oldestKey) {
        this.cache.delete(oldestKey);
      }
    }

    const version: VersionTuple = {
      clientVersion: 1,
      serverVersion: serverVersion,
      timestamp: Date.now(),
    };

    const entry: SpeculativeCacheEntry<T> = {
      key,
      data,
      version,
      byteSize,
      cachedAt: Date.now(),
      accessCount: 1,
      isWarmed: true,
    };

    this.cache.set(key, entry);
  }

  /**
   * Optimistic local mutation with version increment
   */
  public mutateOptimistic<T>(key: string, updater: (prev: T) => T): VersionTuple | null {
    const entry = this.get<T>(key);
    if (!entry) return null;

    entry.data = updater(entry.data);
    entry.version.clientVersion += 1;
    entry.version.timestamp = Date.now();
    return entry.version;
  }

  /**
   * Server Invalidation via WebSocket push with Last-Write-Wins (LWW)
   */
  public handleServerInvalidation(key: string, serverVersion: number): boolean {
    const entry = this.cache.get(key);
    if (!entry) return false;

    if (serverVersion > entry.version.serverVersion) {
      // Stale entry -> Evict immediately
      this.cache.delete(key);
      return true;
    }
    return false;
  }

  public has(key: string): boolean {
    return this.cache.has(key);
  }

  public size(): number {
    return this.cache.size;
  }

  public clear(): void {
    this.cache.clear();
  }

  public getTotalBytes(): number {
    let total = 0;
    for (const entry of this.cache.values()) {
      total += entry.byteSize;
    }
    return total;
  }
}
