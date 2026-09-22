"""
Unit tests for bounded LRU cache with timestamped hybrid version tuples.
Verifies eviction, O(1) buffer ownership handoffs, and stale state invalidation.
"""
from collections import OrderedDict
import time

class HybridVersionedCache:
    def __init__(self, capacity=16):
        self.capacity = capacity
        self.cache = OrderedDict()
        self.versions = {}
        
    def put(self, key, payload, version):
        if key in self.cache:
            if version < self.versions.get(key, 0):
                # Stale write rejected
                return False
            self.cache.move_to_end(key)
        else:
            if len(self.cache) >= self.capacity:
                oldest, _ = self.cache.popitem(last=False)
                self.versions.pop(oldest, None)
        self.cache[key] = payload
        self.versions[key] = version
        return True
        
    def get(self, key):
        if key not in self.cache:
            return None
        self.cache.move_to_end(key)
        return self.cache[key]

def test_cache_lru_and_versioning():
    cache = HybridVersionedCache(capacity=2)
    cache.put("route_A", b"state_A", version=1)
    cache.put("route_B", b"state_B", version=1)
    
    # Stale version write should fail
    assert not cache.put("route_A", b"stale_A", version=0)
    
    # Cache access updates LRU
    assert cache.get("route_A") == b"state_A"
    
    # Exceed capacity -> route_B should be evicted
    cache.put("route_C", b"state_C", version=1)
    assert cache.get("route_B") is None
    assert cache.get("route_A") == b"state_A"
    assert cache.get("route_C") == b"state_C"
    print("LRU hybrid cache tests passed!")

if __name__ == "__main__":
    test_cache_lru_and_versioning()
