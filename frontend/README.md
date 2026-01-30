# Frontend (Local Web UI)

This is a lightweight local UI to run `idea2story_pipeline.py` and view **only** the high‑level status + final results.

## Start the server

From repo root:

```
python frontend/server/app.py --host 127.0.0.1 --port 8080
```

Open:

```
http://127.0.0.1:8080/
```

## What it does
- Starts the pipeline via the existing CLI entrypoint.
- Shows the current stage (not raw logs).
- Displays final story + summary.
- Downloads the log folder for the run as a zip.

## Security note
API keys are **not** stored on disk. They are only injected into the subprocess environment for the current run.
