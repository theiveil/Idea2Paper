from __future__ import annotations

import json
from collections import deque
from pathlib import Path
from typing import Optional

STAGE_ORDER = [
    ("Recall", 0.15),
    ("Pattern Selection", 0.30),
    ("Story Generation", 0.45),
    ("Critic Review", 0.60),
    ("Refinement", 0.70),
    ("Novelty Check", 0.80),
    ("Verification", 0.88),
    ("Bundling", 0.95),
    ("Done", 1.0),
    ("Failed", 1.0),
]

EVENT_TO_STAGE = [
    ("run_error", "Failed"),
    ("run_end", "Done"),
    ("results_bundled", "Bundling"),
    ("verification_from_novelty", "Verification"),
    ("verification_skipped", "Verification"),
    ("novelty_check_done", "Novelty Check"),
    ("novelty_pivot_triggered", "Novelty Check"),
    ("critic_result", "Critic Review"),
    ("review_", "Critic Review"),
    ("pattern_selected", "Pattern Selection"),
    ("recall_end", "Recall"),
    ("recall_start", "Recall"),
]

DETAILS = {
    "Recall": "Retrieving relevant ideas/patterns",
    "Pattern Selection": "Scoring and selecting patterns",
    "Story Generation": "Generating structured story",
    "Critic Review": "Multi-agent review in progress",
    "Refinement": "Applying refinement loop",
    "Novelty Check": "Checking novelty / similarity",
    "Verification": "Final collision verification",
    "Bundling": "Bundling results",
    "Done": "Run completed",
    "Failed": "Run failed",
}


def _progress_for(stage: str) -> float:
    for name, prog in STAGE_ORDER:
        if name == stage:
            return prog
    return 0.05


def _read_last_events(path: Path, max_lines: int = 200):
    if not path.exists():
        return []
    dq = deque(maxlen=max_lines)
    try:
        with path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                dq.append(line)
    except Exception:
        return []
    events = []
    for line in dq:
        try:
            events.append(json.loads(line))
        except Exception:
            continue
    return events


def infer_stage(events_path: Path, process_status: str) -> dict:
    events = _read_last_events(events_path)
    stage = "Initializing"
    if process_status == "failed":
        stage = "Failed"
    elif process_status == "done":
        stage = "Done"

    # look for latest matching event
    if events:
        for ev in reversed(events):
            ev_type = ev.get("event_type") or ev.get("type") or ev.get("event")
            if not ev_type:
                continue
            for key, name in EVENT_TO_STAGE:
                if key.endswith("_"):
                    if ev_type.startswith(key):
                        stage = name
                        break
                elif ev_type == key:
                    stage = name
                    break
            else:
                continue
            break

    if stage == "Initializing" and process_status in ("starting", "running"):
        detail = "Starting pipeline..."
        return {"name": stage, "progress": 0.05, "detail": detail}

    detail = DETAILS.get(stage, "Running")
    return {"name": stage, "progress": _progress_for(stage), "detail": detail}
