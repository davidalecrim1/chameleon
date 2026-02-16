#!/usr/bin/env python3
"""Render a RenderCV YAML file to output/, using the venv rendercv binary."""

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VENV_BIN = ROOT / ".venv" / ("Scripts" if sys.platform == "win32" else "bin")
RENDERCV = VENV_BIN / ("rendercv.exe" if sys.platform == "win32" else "rendercv")


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: python scripts/render.py <path-to-yaml>")
        sys.exit(1)

    source = Path(sys.argv[1].strip())
    if not source.exists():
        print(f"Error: {source} not found")
        sys.exit(1)

    if not RENDERCV.exists():
        print("Error: rendercv not found. Run: make install-tools")
        sys.exit(1)

    output_dir = ROOT / "output"
    output_dir.mkdir(exist_ok=True)

    stem = source.stem
    tmp = ROOT / source.name
    shutil.copy2(source, tmp)

    try:
        result = subprocess.run(
            [
                str(RENDERCV), "render", str(tmp),
                "--pdf-path",      str(output_dir / f"{stem}.pdf"),
                "--typst-path",    str(output_dir / f"{stem}.typ"),
                "--markdown-path", str(output_dir / f"{stem}.md"),
                "--html-path",     str(output_dir / f"{stem}.html"),
                "--png-path",      str(output_dir / f"{stem}.png"),
            ],
            check=False,
        )
    finally:
        tmp.unlink(missing_ok=True)

    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
