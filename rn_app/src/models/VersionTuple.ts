export interface VersionTuple {
  clientVersion: number;
  serverVersion: number;
  timestamp: number;
}

export interface SpeculativeCacheEntry<T> {
  key: string;
  data: T;
  version: VersionTuple;
  byteSize: number;
  cachedAt: number;
  accessCount: number;
  isWarmed: boolean;
}
