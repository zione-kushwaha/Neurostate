"""
Telemetry validation harness for NeuroState mobile traces.
Validates frame render intervals against display VSync deadlines:
- 60 Hz: 16.67 ms
- 90 Hz: 11.11 ms
- 120 Hz: 8.33 ms
"""
import sys

def check_jank_deadline(frame_times_ms, refresh_rate=60):
    deadline = 1000.0 / refresh_rate
    jank_frames = [t for t in frame_times_ms if t > deadline]
    jank_rate = len(jank_frames) / max(1, len(frame_times_ms))
    return {
        "refresh_rate_hz": refresh_rate,
        "deadline_ms": deadline,
        "total_frames": len(frame_times_ms),
        "jank_frames": len(jank_frames),
        "jank_percentage": jank_rate * 100.0
    }

if __name__ == "__main__":
    sample_frames = [12.1, 14.3, 15.8, 16.2, 19.4, 13.5, 14.1, 15.0]
    res = check_jank_deadline(sample_frames, 60)
    print("Telemetry check:", res)
