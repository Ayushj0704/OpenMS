import argparse
import csv
import re
from pathlib import Path


PERF_RE = re.compile(
    r"^.*PERF OpenSwathWorkflow::performExtraction: "
    r"windows=(?P<windows>\d+), batches=(?P<batches>\d+), total=(?P<total>[0-9.]+) s; "
    r"select=(?P<select>[0-9.]+) s, index=(?P<index>[0-9.]+) s, batch=(?P<batch>[0-9.]+) s, ms1=(?P<ms1>[0-9.]+) s, "
    r"coords=(?P<coords>[0-9.]+) s, extract=(?P<extract>[0-9.]+) s, convert=(?P<convert>[0-9.]+) s, "
    r"score=(?P<score>[0-9.]+) s, write=(?P<write>[0-9.]+) s\s*$"
)


def parse_file(path: Path):
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = PERF_RE.match(line)
        if match:
            row = dict(match.groupdict())
            row["log"] = str(path)
            yield row


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract OpenSwathWorkflow PERF lines into CSV.")
    parser.add_argument("log", nargs="+", type=Path)
    args = parser.parse_args()

    fieldnames = [
        "log",
        "windows",
        "batches",
        "total",
        "select",
        "index",
        "batch",
        "ms1",
        "coords",
        "extract",
        "convert",
        "score",
        "write",
    ]
    import sys

    writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
    writer.writeheader()
    for log_path in args.log:
        for row in parse_file(log_path):
            writer.writerow(row)


if __name__ == "__main__":
    main()
