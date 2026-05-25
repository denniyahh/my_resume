#!/usr/bin/env bash
# Build script for Dennis Kim's resume via Pandoc.
#
# Goals:
#   - Produce a visually polished PDF (via LaTeX) AND a PDF that extracts cleanly for ATS / copy-paste.
#   - Avoid PDF text-extraction artifacts caused by font encoding / unusual glyph mapping.
#
# Usage:
#   ./build_resume.sh               # uses resume.md by default
#   ./build_resume.sh path/to/file  # uses custom input markdown
#
# Optional env vars:
#   OUT_DIR=dist
#   BASENAME=resume
#   PANDOC_TEMPLATE=eisvogel
#   PDF_ENGINE=lualatex|xelatex|tectonic
#   ATS_SAFE=1            # normalize punctuation to ATS-friendly ASCII before PDF build
#   KEEP_TMP=1            # keep normalized temp markdown for inspection

set -euo pipefail

#########################
# Configuration
#########################

INPUT_MD="${1:-resume.md}"
OUT_DIR="${OUT_DIR:-dist}"
BASENAME="${BASENAME:-$(basename "${INPUT_MD%.*}")}"

# Default Pandoc template (if present). Override via env.
PANDOC_TEMPLATE="${PANDOC_TEMPLATE:-eisvogel}"

# Prefer LuaLaTeX for better Unicode handling in many toolchains; fall back to XeLaTeX.
PDF_ENGINE="${PDF_ENGINE:-}"

# ATS-safe normalization (recommended for distribution copies).
ATS_SAFE="${ATS_SAFE:-1}"
KEEP_TMP="${KEEP_TMP:-0}"

#########################
# Helper functions
#########################

err() { echo "ERROR: $*" >&2; exit 1; }

check_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

pick_pdf_engine() {
  # If user explicitly set PDF_ENGINE, honor it (and validate later).
  if [[ -n "${PDF_ENGINE}" ]]; then
    echo "${PDF_ENGINE}"
    return 0
  fi

  # Otherwise pick the best available engine.
  if check_command "lualatex"; then
    echo "lualatex"
  elif check_command "xelatex"; then
    echo "xelatex"
  elif check_command "tectonic"; then
    echo "tectonic"
  else
    err "No LaTeX PDF engine found (lualatex/xelatex/tectonic). Install one or set PDF_ENGINE."
  fi
}

normalize_md_for_ats() {
  # Creates an ATS-friendly copy:
  #   - Replace middle dots with " | " (common in headers)
  #   - Replace en/em dashes with hyphens (avoids odd glyph mapping in some PDFs)
  #   - Replace non-breaking spaces with normal spaces
  #   - Remove soft hyphens and zero-width characters if present
  #
  # NOTE: This does not change meaning; it only normalizes typography.
  local in="$1"
  local out="$2"

  python3 - <<'PY' "$in" "$out"
import sys
from pathlib import Path

inp = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")

# Common typography → ATS-safe ASCII equivalents
repl = {
    "\u00B7": " | ",   # middle dot
    "\u2022": "*",     # bullet (pandoc will render anyway; safe in raw text)
    "\u2013": "-",     # en dash
    "\u2014": "--",    # em dash
    "\u2212": "-",     # minus sign
    "\u00A0": " ",     # nbsp
}

for u, r in repl.items():
    inp = inp.replace(u.encode("utf-8").decode("unicode_escape"), r)

# Strip soft hyphen, BOM, and common zero-width chars (harmless if absent)
for u in ["\u00AD", "\uFEFF", "\u200B", "\u200C", "\u200D", "\u2060"]:
    inp = inp.replace(u.encode("utf-8").decode("unicode_escape"), "")

# Collapse repeated spaces introduced by replacements
while "  " in inp:
    inp = inp.replace("  ", " ")

Path(sys.argv[2]).write_text(inp, encoding="utf-8")
PY
}

#########################
# Pre-flight checks
#########################

[[ -f "$INPUT_MD" ]] || err "Input markdown file not found: $INPUT_MD"
check_command "pandoc" || err "Required command 'pandoc' not found in PATH."

PDF_ENGINE="$(pick_pdf_engine)"
check_command "$PDF_ENGINE" || err "Required PDF engine '$PDF_ENGINE' not found in PATH."

mkdir -p "$OUT_DIR"

#########################
# Template detection
#########################

TEMPLATE_ARGS=()
if [[ -n "$PANDOC_TEMPLATE" ]]; then
  POTENTIAL_TEMPLATES=(
    "$HOME/.local/share/pandoc/templates/${PANDOC_TEMPLATE}.latex"
    "$HOME/.pandoc/templates/${PANDOC_TEMPLATE}.latex"
    "./templates/${PANDOC_TEMPLATE}.latex"
  )

  for f in "${POTENTIAL_TEMPLATES[@]}"; do
    if [[ -f "$f" ]]; then
      echo "Using Pandoc template: $f"
      TEMPLATE_ARGS=(--template="$f")
      break
    fi
  done
fi

#########################
# Build PDF
#########################

echo "Building PDF (engine: $PDF_ENGINE)..."

PDF_INPUT="$INPUT_MD"
TMP_MD=""
if [[ "$ATS_SAFE" == "1" ]]; then
  TMP_MD="$(mktemp -t resume_ats_XXXXXX.md)"
  normalize_md_for_ats "$INPUT_MD" "$TMP_MD"
  PDF_INPUT="$TMP_MD"
  echo "  ATS_SAFE=1: using normalized markdown for PDF build: $TMP_MD"
fi

# Notes on encoding robustness:
#  - --standalone: ensure full document
#  - mainfont: use a well-supported font (Source Sans 3), but you can override via env or template
#  - Disable TeX ligature substitutions that can sometimes confuse text extraction
#  - Explicit UTF-8 input assumption
pandoc "$PDF_INPUT"   -o "${OUT_DIR}/${BASENAME}.pdf"   --pdf-engine="$PDF_ENGINE"   --standalone   "${TEMPLATE_ARGS[@]}"   --metadata=title:"Dennis Kim — Resume"   --variable mainfont="Source Sans 3"   --variable mainfontoptions="Ligatures=NoCommon"   --variable fontsize=10pt   --include-in-header resume-preamble.tex

# Cleanup temp file unless KEEP_TMP=1
if [[ -n "${TMP_MD}" && "$KEEP_TMP" != "1" ]]; then
  rm -f "$TMP_MD"
fi

#########################
# Build DOCX
#########################

echo "Building DOCX..."
pandoc "$INPUT_MD"   -o "${OUT_DIR}/${BASENAME}.docx"   --standalone   --metadata=title:"Dennis Kim — Resume"

#########################
# Build HTML
#########################

echo "Building HTML..."
pandoc "$INPUT_MD"   -o "${OUT_DIR}/${BASENAME}.html"   --standalone   --metadata=title:"Dennis Kim — Resume"   --toc=false

#########################
# Summary
#########################

echo "Build complete. Outputs:"
echo "  - ${OUT_DIR}/${BASENAME}.pdf"
echo "  - ${OUT_DIR}/${BASENAME}.docx"
echo "  - ${OUT_DIR}/${BASENAME}.html"
