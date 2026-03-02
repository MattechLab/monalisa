#!/usr/bin/env python3
"""Download and sample Kaggle dataset files for CI (ephemeral only)."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import sys


DATASET_ID = "mateuszbuda/lgg-mri-segmentation"
DEFAULT_EXTS = {".png", ".jpg", ".jpeg", ".tif", ".tiff", ".bmp", ".npy", ".csv", ".mat"}


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--out", required=True, help="Output directory for sampled files")
    p.add_argument("--max-files", type=int, default=24, help="Maximum sampled files")
    return p.parse_args()


def is_enabled() -> bool:
    return os.getenv("MONALISA_USE_KAGGLE_DATA", "false").strip().lower() == "true"


def main() -> int:
    args = parse_args()
    out_dir = Path(args.out).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    if not is_enabled():
        print("Kaggle data disabled (MONALISA_USE_KAGGLE_DATA != true).")
        return 0

    kaggle_user = os.getenv("KAGGLE_USERNAME", "").strip()
    kaggle_key = os.getenv("KAGGLE_KEY", "").strip()
    if not kaggle_user or not kaggle_key:
        print("Kaggle is enabled but KAGGLE_USERNAME/KAGGLE_KEY are missing.", file=sys.stderr)
        return 2

    try:
        import kagglehub
    except Exception as exc:  # pragma: no cover - defensive
        print(f"Failed to import kagglehub: {exc}", file=sys.stderr)
        return 3

    dataset_path = Path(kagglehub.dataset_download(DATASET_ID)).resolve()
    print(f"Downloaded dataset path: {dataset_path}")

    files = sorted(
        p for p in dataset_path.rglob("*")
        if p.is_file() and p.suffix.lower() in DEFAULT_EXTS
    )
    if not files:
        print("No suitable files found in downloaded Kaggle dataset.", file=sys.stderr)
        return 4

    max_files = max(1, int(args.max_files))
    selected = files[:max_files]

    copied = []
    for idx, src in enumerate(selected, start=1):
        dst = out_dir / f"{idx:04d}{src.suffix.lower()}"
        shutil.copy2(src, dst)
        copied.append({"src": str(src), "dst": str(dst)})

    manifest = {
        "dataset": DATASET_ID,
        "download_path": str(dataset_path),
        "sample_count": len(copied),
        "max_files": max_files,
        "files": copied,
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(f"Sampled {len(copied)} files into {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

