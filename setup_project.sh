#!/bin/bash

# Setup script for Student Attendance Tracker
# This script creates the project folder structure and all necessary files

# =============================================================================
# SIGNAL TRAP - handles Ctrl+C
# =============================================================================
cleanup() {
    echo ""
    echo "Script interrupted! Archiving current progress..."

    if [ -d "$PROJECT_DIR" ]; then
        tar -czf "${PROJECT_DIR}_archive.tar.gz" $PROJECT_DIR
        echo "Archive created: ${PROJECT_DIR}_archive.tar.gz"
        rm -rf $PROJECT_DIR
        echo "Incomplete directory deleted."
    fi

    echo "Exiting."
    exit 1
}

trap cleanup SIGINT

# =============================================================================
# Ask user for project name
# =============================================================================
echo "Enter a project name:"
read PROJECT_NAME

PROJECT_DIR="attendance_tracker_${PROJECT_NAME}"

# Create the directory structure
echo "Creating project directories..."
mkdir $PROJECT_DIR
mkdir $PROJECT_DIR/Helpers
mkdir $PROJECT_DIR/reports

echo "Directories created."

# ── Write attendance_checker.py ───────────────────────────────────────────────
cat > $PROJECT_DIR/attendance_checker.py << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

echo "attendance_checker.py created."

# ── Write Helpers/assets.csv ──────────────────────────────────────────────────
cat > $PROJECT_DIR/Helpers/assets.csv << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

echo "assets.csv created."

# ── Write Helpers/config.json ─────────────────────────────────────────────────
cat > $PROJECT_DIR/Helpers/config.json << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

echo "config.json created."

# ── Write reports/reports.log ─────────────────────────────────────────────────

cat > $PROJECT_DIR/reports/reports.log << 'EOF'

--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---

[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.

[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

echo "reports.log created."

# =============================================================================
# DYNAMIC CONFIGURATION - update thresholds using sed
# =============================================================================
echo ""
echo "Do you want to update the attendance thresholds? (y/n)"
read UPDATE

if [ "$UPDATE" = "y" ]; then
    echo "Enter new Warning threshold (current: 75):"
    read NEW_WARNING

    echo "Enter new Failure threshold (current: 50):"
    read NEW_FAILURE

    sed -i "s/\"warning\": 75/\"warning\": $NEW_WARNING/" $PROJECT_DIR/Helpers/config.json
    sed -i "s/\"failure\": 50/\"failure\": $NEW_FAILURE/" $PROJECT_DIR/Helpers/config.json

    echo "Thresholds updated in config.json."
fi

# =============================================================================
# HEALTH CHECK - verify python3 and folder structure
# =============================================================================
echo ""
echo "Running health check..."


# Check python3

python3 --version
if [ $? -eq 0 ]; then
    echo "python3 is installed."

else
    echo "WARNING: python3 was not found. Please install it."

fi

# Check files exist
if [ -f "$PROJECT_DIR/attendance_checker.py" ] && \
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] && \
   [ -f "$PROJECT_DIR/Helpers/config.json" ] && \
   [ -f "$PROJECT_DIR/reports/reports.log" ]; then
    echo "All files are present. Structure looks good."
else
    echo "WARNING: Some files are missing."
fi

echo ""
echo "Setup complete! Your project is ready at: $PROJECT_DIR"
echo "To run the tracker: cd $PROJECT_DIR && python3 attendance_checker.py"
