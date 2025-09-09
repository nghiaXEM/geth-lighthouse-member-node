#!/usr/bin/env python3
import subprocess
import sys

# Danh sách các file Python cần chạy
scripts = [
    "scripts/run_el.py",
    "scripts/run_cl.py",
    "scripts/run_vc.py",
]

for script in scripts:
    print(f"🔹 Running {script} ...")
    try:
        # Chạy script và chặn tới khi script kết thúc
        result = subprocess.run(
            ["python3", script],
            check=True  # raise CalledProcessError nếu exit code != 0
        )
    except subprocess.CalledProcessError as e:
        print(f"❌ Script {script} failed with exit code {e.returncode}. Stopping!")
        sys.exit(e.returncode)

print("✅ All scripts completed successfully!")
