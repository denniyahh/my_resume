#!/usr/bin/env bash
# ATS Safe Resume — Build Script (v2 Python Package)
#
# Usage:
#   ./build_resume.sh                  # uses resume.md by default
#   ./build_resume.sh path/to/file.md  # custom input
#
# Env vars for power users:
#   OUT_DIR=dist                       # output directory
#

set -euo pipefail

INPUT_MD="${1:-resume.md}"
OUT_DIR="${OUT_DIR:-dist}"

echo "Building resume using ats_safe_resume v2..."
ats-safe-resume "$INPUT_MD" --out-dir "$OUT_DIR"

# Copy PDF to example/ for committed demo
BASENAME="$(basename "${INPUT_MD%.*}")"
if [[ -f "${OUT_DIR}/${BASENAME}.pdf" ]]; then
  mkdir -p example
  cp "${OUT_DIR}/${BASENAME}.pdf" "example/resume.pdf"
  echo "  Demo PDF copied to example/resume.pdf"
fi
