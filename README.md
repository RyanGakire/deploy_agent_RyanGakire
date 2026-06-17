# deploy_agent_GithubUsername

A shell script "Project Factory" that bootstraps the Student Attendance Tracker workspace from scratch — no manual setup required.

## What it does

Running `setup_project.sh` creates this entire structure automatically:

```
attendance_tracker_{input}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

All source files are embedded inside the script and written to disk on execution.

## How to run

```bash
chmod +x setup_project.sh
./setup_project.sh
```

Then follow the prompts:
1. Enter a project identifier (e.g. `v1`) — creates the folder `attendance_tracker_v1/`
2. Choose whether to update the attendance thresholds (Warning default: 75%, Failure default: 50%)

Once setup completes, run the tracker:

```bash
cd attendance_tracker_{input}
python3 attendance_checker.py
```

## How to trigger the archive feature

Press **Ctrl+C at any point while `setup_project.sh` is running**.

The script will catch the interrupt and automatically:
1. Bundle whatever has been created into `attendance_tracker_{input}_archive.tar.gz`
2. Delete the incomplete project directory
3. Exit cleanly

## Requirements

- Bash (any Linux/macOS terminal)
- `python3` (the script will warn you if it's missing)
