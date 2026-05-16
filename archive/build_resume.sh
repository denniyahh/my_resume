#!/usr/bin/env bash
# Build script for Dennis Kim's resume via Pandoc.
# Usage:
#   ./build_resume.sh               # uses resume.md by default
#   ./build_resume.sh path/to/file  # uses custom input markdown

set -euo pipefail

#########################
# Configuration
#########################

# Default input file
INPUT_MD="${1:-resume.md}"

# Directory for build artifacts
OUT_DIR="dist"

# Base name for outputs (resume.pdf, resume.docx, resume.html)
BASENAME="$(basename "${INPUT_MD%.*}")"

# Default Pandoc template (if present)
# You can override via env: PANDOC_TEMPLATE=mytemplate
PANDOC_TEMPLATE="${PANDOC_TEMPLATE:-eisvogel}"

# PDF engine
PDF_ENGINE="${PDF_ENGINE:-xelatex}"

#########################
# Helper functions
#########################

err() {
  echo "ERROR: $*" >&2
  exit 1
}

check_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Required command '$cmd' not found in PATH."
  fi
}

#########################
# Pre-flight checks
#########################

# Check that input exists
if [[ ! -f "$INPUT_MD" ]]; then
  err "Input markdown file not found: $INPUT_MD"
fi

# Check for pandoc
check_command "pandoc"

# Check for LaTeX engine only if building PDF
check_command "$PDF_ENGINE"

# Ensure output directory exists
mkdir -p "$OUT_DIR"

#########################
# Template detection
#########################

# We try to apply a template *if* Pandoc can see it.
# Common search locations for Eisvogel:
#   - ~/.local/share/pandoc/templates/eisvogel.latex
#   - ~/.pandoc/templates/eisvogel.latex
#   - ./templates/eisvogel.latex
TEMPLATE_ARGS=()

if [[ -n "$PANDOC_TEMPLATE" ]]; then
  # Try to locate a matching template file by name heuristic.
  # This is conservative; if we don't find it, we just don't pass --template.
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

echo "Building PDF..."
pandoc "$INPUT_MD" \
  -o "${OUT_DIR}/${BASENAME}.pdf" \
  --pdf-engine="$PDF_ENGINE" \
  --standalone \
  "${TEMPLATE_ARGS[@]}" \
  --metadata=title:"Dennis Kim — Resume" \
  --variable mainfont="Inter" \
  --variable fontsize=11pt

#########################
# Build DOCX
#########################

echo "Building DOCX..."
pandoc "$INPUT_MD" \
  -o "${OUT_DIR}/${BASENAME}.docx" \
  --standalone \
  --metadata=title:"Dennis Kim — Resume"

#########################
# Build HTML
#########################

echo "Building HTML..."
pandoc "$INPUT_MD" \
  -o "${OUT_DIR}/${BASENAME}.html" \
  --standalone \
  --metadata=title:"Dennis Kim — Resume" \
  --toc=false

#########################
# Summary
#########################

echo "Build complete. Outputs:"
echo "  - ${OUT_DIR}/${BASENAME}.pdf"
echo "  - ${OUT_DIR}/${BASENAME}.docx"
echo "  - ${OUT_DIR}/${BASENAME}.html"

