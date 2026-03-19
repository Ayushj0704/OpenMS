import argparse
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Print a 1-based line range from a text file.")
    parser.add_argument("path", type=Path)
    parser.add_argument("start", type=int, help="1-based start line")
    parser.add_argument("end", type=int, help="1-based end line (inclusive)")
    args = parser.parse_args()

    lines = args.path.read_text(encoding="utf-8", errors="replace").splitlines()
    start = max(args.start, 1)
    end = min(args.end, len(lines))
    for i in range(start, end + 1):
        print(f"{i:5d}: {lines[i-1]}")


if __name__ == "__main__":
    main()
