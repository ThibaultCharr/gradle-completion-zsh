#!/usr/bin/env python3
import sys
import os

if len(sys.argv) < 3:
    print("Usage: gradle-scan-modules.py <project_root> <cache_file>", file=sys.stderr)
    sys.exit(1)

project_root = sys.argv[1]
cache_file = sys.argv[2]

if not os.path.isdir(project_root):
    print(f"Error: project root '{project_root}' is not a directory", file=sys.stderr)
    sys.exit(1)

lines = []

for dirpath, dirnames, filenames in os.walk(project_root):
    dirnames[:] = [d for d in sorted(dirnames) if d != "build"]
    if dirpath == project_root:
        continue  # skip root-level build.gradle.kts
    if "build.gradle.kts" in filenames or "build.gradle" in filenames:
        rel = os.path.relpath(dirpath, project_root)
        module = ":" + rel.replace("/", ":")
        lines.append(module)

lines.sort()
with open(cache_file, "w") as f:
    f.write("\n".join(lines) + "\n")
