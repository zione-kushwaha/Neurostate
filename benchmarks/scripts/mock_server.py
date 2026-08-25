"""
High-Performance Mock API Server for Flutter State Management Benchmark.
Serves configurable synthetic datasets (1,000 to 50,000 items) with simulated network latency.
"""

import argparse
import json
import random
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

# Global mock database
ITEMS_DB = []

def generate_mock_db(count: int):
    global ITEMS_DB
    categories = ["Tech", "Science", "Design", "Business", "AI & ML", "Mobile Dev", "Systems"]
    tags = ["flutter", "performance", "architecture", "state-management", "dart", "cache", "profiling"]
    
    print(f"[*] Pre-generating {count:,} mock items in memory...")
    ITEMS_DB = [
        {
            "id": f"item_{i:06d}",
            "title": f"Scientific Benchmark & Discovery #{i}: Advances in Reactive State Systems",
            "author": f"Researcher_{i % 150}",
            "category": categories[i % len(categories)],
            "tags": random.sample(tags, k=random.randint(1, 3)),
            "thumbnail": f"https://picsum.photos/seed/{i}/200/200",
            "readTimeMinutes": (i % 12) + 3,
            "views": (i * 37) % 10000,
            "likes": (i * 13) % 2500,
            "publishedAt": "2026-08-28T12:00:00Z",
            # Heavy detail payload for detail screen prefetching tests
            "summary": f"Executive abstract for entity #{i}. Evaluating memory allocation and frame jank during fast list traversals.",
            "contentMarkdown": f"# In-Depth Report on Entity #{i}\n\n" + (
                "Detailed empirical observations demonstrating the interaction between reactive state "
                "invalidation, speculative prefetching, and isolate JSON decoding threads.\n\n" * 8
            ),
            "commentsCount": (i * 7) % 80,
            "comments": [
                {
                    "commentId": f"c_{i}_{j}",
                    "user": f"User_{j * 7}",
                    "text": f"Interesting observation on speculative caching in item #{i} comment #{j}."
                }
                for j in range(min(5, (i * 7) % 80))
            ]
        }
        for i in range(count)
    ]
    print(f"[OK] Database generated. Total payload: ~{len(json.dumps(ITEMS_DB)) / (1024*1024):.2f} MB")

class MockAPIHandler(BaseHTTPRequestHandler):
    latency_ms = 80

    def _send_json(self, data, status=200):
        if self.latency_ms > 0:
            time.sleep(self.latency_ms / 1000.0)
        
        response_bytes = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(response_bytes)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(response_bytes)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        params = parse_qs(parsed.query)

        # GET /api/feed?page=0&limit=50
        if path == "/api/feed":
            page = int(params.get("page", ["0"])[0])
            limit = int(params.get("limit", ["50"])[0])
            start = page * limit
            end = min(start + limit, len(ITEMS_DB))
            
            items_slice = [
                {k: v for k, v in item.items() if k not in ("contentMarkdown", "comments")}
                for item in ITEMS_DB[start:end]
            ]
            self._send_json({
                "page": page,
                "limit": limit,
                "total": len(ITEMS_DB),
                "items": items_slice
            })
            return

        # GET /api/items/<id>
        if path.startswith("/api/items/"):
            item_id = path.replace("/api/items/", "")
            item = next((it for it in ITEMS_DB if it["id"] == item_id), None)
            if item:
                self._send_json(item)
            else:
                self._send_json({"error": "Item not found"}, status=404)
            return

        # Health / Stats
        if path == "/api/health":
            self._send_json({"status": "ok", "totalItems": len(ITEMS_DB), "latencyMs": self.latency_ms})
            return

        self._send_json({"error": "Endpoint not found"}, status=404)

    def log_message(self, format, *args):
        # Quiet standard HTTP log to keep terminal clean
        pass

def main():
    parser = argparse.ArgumentParser(description="Synthetic Mock API for Flutter State Benchmark")
    parser.add_argument("--port", type=int, default=8080, help="Port to listen on (default: 8080)")
    parser.add_argument("--items", type=int, default=10000, help="Number of items to generate (default: 10000)")
    parser.add_argument("--latency", type=int, default=100, help="Simulated network latency in ms (default: 100)")
    args = parser.parse_args()

    MockAPIHandler.latency_ms = args.latency
    generate_mock_db(args.items)

    server = HTTPServer(("0.0.0.0", args.port), MockAPIHandler)
    print(f"🚀 Mock API Server running at http://127.0.0.1:{args.port}")
    print(f"   Endpoints: /api/feed?page=0&limit=50 | /api/items/<id> | /api/health")
    print("   Press Ctrl+C to terminate.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[!] Shutting down server.")
        server.server_close()

if __name__ == "__main__":
    main()
